import 'dart:io';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'colors.dart';
import 'tts_service.dart';
import 'package:screenshot/screenshot.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String inputText = "";
  String feedbackText = "";
  List<String> labels = [];
  late List<dynamic> similarQuestions = [];
//
  //音声読み上げサービス
  final TTSService _ttsService = TTSService();
  bool _hasReadFeedback = false; //何度も読み上げられることを防止

  //フィードバック保存
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 引数を受け取る
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
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
        /*similarQuestions = [
          {
            'text': 'あるクラスでは、校外学習のためにバスを借りることになりました。バスの料金は、1台あたり25,000円です。クラスには42人の生徒がいて、さらに先生が3人同行します。1台のバスには最大で15人が乗ることができます。(1) クラス全員と先生が乗るためには、バスを最低何台借りる必要がありますか？(2) バスの料金は、全員の人数で均等に分けて支払うことになりました。1人あたりの支払額はいくらになりますか？（小数点以下を切り上げて計算してください。）(3) もし、学校がバス料金の半額を負担してくれる場合、1人あたりの支払額はいくらになりますか？',
            'labels' : ['数学 - 式と計算'],
          },];*/
        if (inputText.isNotEmpty && labels.isNotEmpty) {
          fetchSimilarQuestions(inputText, labels);
        }
        print(similarQuestions);
      });

      if (feedbackText.isNotEmpty && !_hasReadFeedback) {
        _hasReadFeedback = true;  //何回も読み上げることの防止
        _ttsService.stop();
        _ttsService.speak(feedbackText); //フィードバックを読み上げ
      }
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
          uniqueQuestions[item['text']] = item; // textをキーにして保存
        });

        similarQuestions = uniqueQuestions.values.toList();
      });
    } catch (e) {
      debugPrint("類題検索エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('類題検索に失敗しました: $e')),
      );
    }
  }

  //フィードバック保存
  void _captureScreenshot() async {
    final uint8List = await screenshotController.capture();
    if (uint8List != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/screenshot_${DateTime.now()}.png';
      final file = File(imagePath);
      await file.writeAsBytes(uint8List);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('スクリーンショットを保存しました: $imagePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: Screenshot(controller: screenshotController,
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
                  feedbackText: feedbackText.isEmpty
                      ? 'フィードバック内容がありません。'
                      : feedbackText,
              ),

              // 類題の提示
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.subColor, AppColors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Center(child: Text('類題も解いてみよう！', style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.bold),),),
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
                                      colors: [AppColors.subColor, AppColors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.white, width: 4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(Icons.close, color: AppColors.white,),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              item['text'],
                                              style: TextStyle(
                                                color: AppColors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // ボタンを押した時に渡すデータ
                                            final inputText = item['text'];
                                            final remainingLabels = itemLabels;

                                            _captureScreenshot();

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
                                          style: TextStyle(color: AppColors.mainColor, fontSize: 16,),
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
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Padding(padding: EdgeInsets.all(16),
                          child: Text(
                          item['text'],
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          ),
                        ),
                    );
                  }).toList(),
                )
                    : const Text('類題がありません。', style: TextStyle(color: AppColors.black), textAlign: TextAlign.center,),
                  ],
                ),
              ),

              //ホーム画面に戻るボタン
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () {
                    // 画面を保存
                    _captureScreenshot();
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
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.subColor, AppColors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedbackText.isEmpty ? 'フィードバック内容がありません。' : feedbackText,
              style: TextStyle(
                color: AppColors.black,
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
    final Paint paint = Paint()
      ..color = AppColors.subColor;

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