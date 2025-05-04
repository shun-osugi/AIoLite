import 'dart:io';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'api_service.dart';
import 'colors.dart';
import 'tts_service.dart';
import 'widget_fbsheet.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String inputText = "";
  String feedbackText = "";
  List<String> labels = [];
  String wrong = "";
  String wrongpartans = "";
  String correctans = "";
  late List<dynamic> similarQuestions = [];

  //  フィードバックシートの可視状態
  bool _isFbsheetVisible = false;

  //音声読み上げサービス
  final TTSService _ttsService = TTSService();
  bool _hasReadFeedback = false; //何度も読み上げられることを防止

  //フィードバック保存
  ScreenshotController ssController = ScreenshotController();

  // AIモデル
  late final GenerativeModel _model;
  late final ChatSession AI;
  bool isread = false; //データが読み込まれたかどうか

  // はじめにAIの初期化
  @override
  void initState() {
    super.initState();
    var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    // _initdata();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();  
    // 引数を受け取る
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic> && !isread) {
      setState(() {
        // inputTextを取得
        inputText = args['inputText']?.toString() ?? "";

        // feedbackTextを取得
        feedbackText = args['feedbackText']?.toString() ?? "";

        // labelsを取得
        labels = (args['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        // inputTextとlabelsを基に類題を検索
        if (inputText.isNotEmpty && labels.isNotEmpty) {
          fetchSimilarQuestions(inputText, labels);
        }
        print(similarQuestions);

        // wrongを取得
        wrong = args['wrong']?.toString() ?? "";
        // wrongpartansを取得
        wrongpartans = args['wrongpartans']?.toString() ?? "";
        // correctansを取得
        correctans = args['correctans']?.toString() ?? "";
      });

      if (feedbackText.isNotEmpty && !_hasReadFeedback) {
        _hasReadFeedback = true;  //何回も読み上げることの防止
        _ttsService.stop();
        _ttsService.speak(feedbackText); //フィードバックを読み上げ
      }
    }
    isread = true;
  }

  //RAGによる問題生成
  Future<void> generateRAG() async {
    try{
      //出力制限
      await AI.sendMessage(Content.text('''
      これから伝える各情報ごとに，適切な学習問題の提示をお願いします．
      そちらの出力は，挨拶などはいらないので，問題文の出力だけお願いします．
      そちらが話す文章は読み上げを行うので，そのまま読むとおかしくなるような文字は出力しないでください．
      例えば，数式表現や文字効果（**A**などの），絵文字，コードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします.
      '''));
      List<String> list = [];
      for(int i=0;i<similarQuestions.length;i++){
        final response = await AI.sendMessage(Content.text('''
        ユーザーが解いた問題：$inputText
        ユーザーが間違えた部分：$wrong
        ユーザーへのフィードバック：$feedbackText
        元の問題に似た問題：${similarQuestions[i]['text']}
        '''));
        list.add(response.text ?? similarQuestions[i]['text']);
      }
      setState(() {
        for(int i=0;i<similarQuestions.length;i++){
          similarQuestions[i]['ragtext'] = list[i];
        }
      });
    }catch(e){
      print('AI生成エラー');
      print(e);
    }
  }

  // 類題を検索する関数
  Future<void> fetchSimilarQuestions(String text, List<String> labels) async {
    try {
      final response = await ApiService.searchText(text, labels);
      print(response);

      setState(() {
        var uniqueQuestions = <String, dynamic>{};

        // 重複を削除しながらリストを作成
        response["similar_texts"]?.forEach((item) {
          item['ragtext'] = '類題検索中';
          uniqueQuestions[item['text']] = item; // textをキーにして保存
        });

        similarQuestions = uniqueQuestions.values.toList();
      });

      //RAGにより問題をAI生成
      generateRAG();
    } catch (e) {
      debugPrint("類題検索エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('類題検索に失敗しました: $e')),
      );
    }
  }

  //フィードバック保存
  void _saveFbSheet() async {
    final uint8List = await ssController.capture();
    if (uint8List != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/AIoLite_${DateTime.now()}.png';
      final file = File(imagePath);
      await file.writeAsBytes(uint8List);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存しました!: $imagePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A_Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              //アバターを表示
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ModelViewer(
                  src: 'assets/avatar0.glb',
                  alt: 'A 3D model of AI avatar',
                  cameraOrbit: "0deg 90deg 0deg",
                  ar: false,
                  autoRotate: false,
                  disableZoom: true,
                  disableTap: true,
                  cameraControls: false,
                  interactionPrompt: null,
                  interactionPromptThreshold: 0,
                  autoPlay: true,
                  animationName: 'hello',
                ),
              ),

              //フィードバックを表示する吹き出し
              FeedbackBubble(
                feedbackText:
                feedbackText.isEmpty ? 'フィードバック内容がありません。' : feedbackText,
              ),

              // ▼ ---------- フィードバックシート ---------- ▼ //
              // フィードバックシートを表示するボタン
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.mainColor,
                    foregroundColor: A_Colors.white,
                  ),
                  onPressed: () {
                    // 画面を保存
                    // _saveFbSheet();
                    // visible の状態を 反転して UI を再描画
                    setState(() {
                      _isFbsheetVisible = !_isFbsheetVisible;
                    });
                  },
                  child: const Text('詳細表示'),
                ),
              ),

              // フィードバックシート(widget_fbsheet.dart)
              Visibility(
                visible: _isFbsheetVisible, //ボタンが押されるたびに可視/不可視を切り替え
                child: Screenshot(
                  controller: ssController,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Stack(clipBehavior: Clip.none,children: [
                      FbSheet(
                        labels: labels,
                        problem: inputText,
                        wrong: wrong,
                        wrongpartans: wrongpartans,
                        correctans: correctans,
                        )]),
                  ),
                ),
              ),
              // ▲ ---------- フィードバックシート ---------- ▲ //

              // 類題の提示
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: A_Colors.subColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Center(child: Text('類題も解いてみよう！', style: TextStyle(color: A_Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),),
                    SizedBox(height: 16,),
                    similarQuestions.isNotEmpty
                        ? Column(
                      children: similarQuestions.map((item) {
                        // labelsの部分をList<String>に変換
                        List<String> itemLabels = (item['labels'] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList();

                        return ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.95,
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [A_Colors.subColor, A_Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: A_Colors.white, width: 4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: Icon(Icons.close, color: A_Colors.white,),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                item['ragtext'],
                                                style: TextStyle(
                                                  color: A_Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // ボタンを押した時に渡すデータ
                                              final inputText = item['ragtext'];
                                              final remainingLabels = itemLabels;

                                              Navigator.pushNamed(
                                                context,
                                                '/chat',
                                                arguments: {
                                                  'inputText': inputText,
                                                  'labels': remainingLabels,
                                                },
                                              );
                                            },child: Text('この類題を解く→',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(color: A_Colors.mainColor, fontSize: 16,),
                                          ),
                                          ),
                                        ],
                                      ),
                                    ),),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: A_Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Padding(padding: EdgeInsets.all(16),
                            child: Text(
                              item['ragtext'],
                              style: TextStyle(
                                color: A_Colors.black,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                        : const Text('類題がありません。', style: TextStyle(color: A_Colors.black), textAlign: TextAlign.center,),
                  ],
                ),
              ),

              //ホーム画面に戻るボタン
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.mainColor,
                    foregroundColor: A_Colors.white,
                  ),
                  onPressed: () {
                    // ルート指定でホーム画面へ戻る
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('ホーム画面へ戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}

class FeedbackBubble extends StatelessWidget {
  final String feedbackText;

  FeedbackBubble({required this.feedbackText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 吹き出しの本体
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: A_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedbackText.isEmpty ? 'フィードバック内容がありません。' : feedbackText,
              style: TextStyle(
                color: A_Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 吹き出しの上に表示する三角形
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: CustomPaint(
                size: const Size(40, 20),
                painter: TrianglePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = A_Colors.subColor;

    final Path path = Path()
      ..moveTo(size.width / 2, 0) // 三角形の頂点（中央上）
      ..lineTo(0, size.height) // 左下
      ..lineTo(size.width, size.height) // 右下
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}