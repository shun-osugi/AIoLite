import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'api_service.dart';
import 'colors.dart';
import 'tts_service.dart';
import 'widget_fbsheet.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String inputText = "";
  String feedbackText = "";
  List<String> labels = [];
  String summary = "";
  String wrong = "";
  String wrongpartans = "";
  String correctans = "";

  late List<dynamic> similarQuestions = [];

  //  フィードバックシートの可視状態
  bool _isFbsheetVisible = true;

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
                .toList() ??
            [];

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
        _hasReadFeedback = true; //何回も読み上げることの防止
        _ttsService.stop();
        _ttsService.speak(feedbackText); //フィードバックを読み上げ
      }
    }
    isread = true;
  }

  //RAGによる問題生成
  Future<void> generateRAG() async {
    try {
      //出力制限
      await AI.sendMessage(Content.text('''
      これから伝える各情報ごとに，適切な学習問題の提示をお願いします．
      そちらの出力は，挨拶などはいらないので，問題文の出力だけお願いします．
      そちらが話す文章は読み上げを行うので，そのまま読むとおかしくなるような文字は出力しないでください．
      例えば，数式表現や文字効果（**A**などの），絵文字，コードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします.
      '''));
      List<String> list = [];
      for (int i = 0; i < similarQuestions.length; i++) {
        final response = await AI.sendMessage(Content.text('''
        ユーザーが解いた問題：$inputText
        ユーザーが間違えた部分：$wrong
        ユーザーへのフィードバック：$feedbackText
        元の問題に似た問題：${similarQuestions[i]['text']}
        '''));
        list.add(response.text ?? similarQuestions[i]['text']);
      }
      setState(() {
        for (int i = 0; i < similarQuestions.length; i++) {
          similarQuestions[i]['ragtext'] = list[i];
        }
      });
    } catch (e) {
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

  // --- タブの変更 --- //
  void setActiveTrue() {
    setState(() {
      _isFbsheetVisible = true;
    });
  }

  void setActiveFalse() {
    setState(() {
      _isFbsheetVisible = false;
    });
  }

  // --- タブの変更 --- //

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: A_Colors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // フィードバックタブ
            ElevatedButton(
              onPressed: () {
                setActiveTrue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: A_Colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  side: BorderSide(
                    color: A_Colors.black,
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.all(12),
                elevation: 2,
              ),
              child: SizedBox(
                width: _isFbsheetVisible ? MediaQuery.of(context).size.width * 0.6 - 50 : MediaQuery.of(context).size.width * 0.25,
                child: Text(
                  'フィードバック',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: _isFbsheetVisible ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            // 類題の提示タブ
            ElevatedButton(
              onPressed: () {
                setActiveFalse();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: A_Colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  side: BorderSide(
                    color: A_Colors.black,
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.all(12),
                elevation: 2,
              ),
              child: SizedBox(
                width: _isFbsheetVisible ? MediaQuery.of(context).size.width * 0.25 : MediaQuery.of(context).size.width * 0.6 - 50,
                child: Text(
                  '類題の提示',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: _isFbsheetVisible ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.width * 0.05),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: A_Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: MediaQuery.of(context).size.height - safeAreaPadding.top - safeAreaPadding.bottom,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  // ▼ ---------- フィードバック・類題表示 ---------- ▼ //
                  // フィードバックシート(widget_fbsheet.dart)
                  Visibility(
                    visible: _isFbsheetVisible, // trueで表示(初期：表示)
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.75,
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Stack(clipBehavior: Clip.none, children: [
                        FbSheet(
                          labels: labels,
                          problem: inputText,
                          wrong: wrong,
                          wrongpartans: wrongpartans,
                          correctans: correctans,
                        )
                      ]),
                    ),
                  ),

                  // 類題の提示
                  Visibility(
                    visible: !_isFbsheetVisible, // falseで表示(初期：非表示)
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.75,
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [A_Colors.white, A_Colors.accentColor, A_Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: A_Colors.black, width: 4),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                '類題も解いてみよう！',
                                style: TextStyle(color: A_Colors.black, fontSize: MediaQuery.of(context).size.width * 0.05, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            similarQuestions.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: similarQuestions.map((item) {
                                      // labelsの部分をList<String>に変換
                                      List<String> itemLabels = (item['labels'] as List<dynamic>).map((e) => e.toString()).toList();

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.01),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [A_Colors.subColor, A_Colors.white],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(40),
                                            border: Border.all(color: A_Colors.black, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: A_Colors.black.withOpacity(0.7),
                                                offset: Offset(0, 4),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
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
                                                          colors: [A_Colors.white, A_Colors.subColor, A_Colors.white],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: A_Colors.black, width: 4),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.topRight,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  color: A_Colors.white,
                                                                ),
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
                                                              },
                                                              child: Text(
                                                                'この類題を解く→',
                                                                textAlign: TextAlign.right,
                                                                style: TextStyle(
                                                                  color: A_Colors.black,
                                                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                                              child: Text(
                                                item['ragtext'],
                                                style: TextStyle(
                                                  color: A_Colors.black,
                                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : const Text(
                                    '類題がありません。',
                                    style: TextStyle(color: A_Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ▲ ---------- フィードバック・類題表示 ---------- ▲ //

                  // ホームに戻るボタン
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [A_Colors.subColor, A_Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: A_Colors.black, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: A_Colors.black.withOpacity(0.7),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, '/home');
                        await _ttsService.stop();
                      }, //画面遷移するときに読み上げ停止
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'ホームに戻る',
                        style: TextStyle(
                          color: A_Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

              ),
            );
          },
        ),
      ),
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
            width: MediaQuery.of(context).size.width * 0.8,
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
