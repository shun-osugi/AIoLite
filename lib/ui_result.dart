import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'api_service.dart';
import 'colors.dart';
import 'tts_service.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String feedbackText = "";
  List<String> labels = [];
  late List<dynamic> similarQuestions = [];
  bool _isLoading = false; // ローディング状態を管理するフラグ

  //音声読み上げサービス
  final TTSService _ttsService = TTSService();
  bool _hasReadFeedback = false; //何度も読み上げられることを防止

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 引数を受け取る
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      setState(() {
        // feedbackTextを取得
        feedbackText = args['feedbackText']?.toString() ?? "";

        // labelsを取得
        labels = (args['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];
        similarQuestions = args['similarQuestions'] ?? [];
        print("[ResultPage] Received similarQuestions: $similarQuestions");
      });

      if (feedbackText.isNotEmpty && !_hasReadFeedback) {
        _hasReadFeedback = true;  //何回も読み上げることの防止
        _ttsService.stop();
        _ttsService.speak(feedbackText); //フィードバックを読み上げ
      }
    }
  }

  // ボタン押下時に非同期処理を行う関数
  Future<void> _onSolveSimilarQuestion(String inputText, List<String> remainingLabels) async {
    if (inputText.isEmpty || remainingLabels.isEmpty) return;
    setState(() {
      _isLoading = true; // ローディング開始
    });

    // APIリクエストを送信し、レスポンスを受け取る
    Map<String, dynamic> response = await ApiService.storeText(inputText, remainingLabels);

    // 類題を取得
    List<dynamic> similarTexts = response["similar_texts"] ?? [];



    // ログ出力
    debugPrint("テキストを保存: $inputText");
    debugPrint("保存したラベル: $remainingLabels");
    // 非同期処理をシミュレート（例えばAPIリクエスト）
    await Future.delayed(Duration(seconds: 2)); // ここでAPIリクエストのシミュレーション

    setState(() {
      _isLoading = false; // ローディング終了
    });

    // 画面遷移
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'inputText': inputText,
        'labels': remainingLabels,
        'similarQuestions': similarTexts, // 類題を渡す
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィードバック', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.mainColor,
      ),
      backgroundColor: AppColors.white,
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ChatBubble(
                  text: feedbackText.isEmpty
                      ? 'フィードバック内容がありません。'
                      : feedbackText,
                ),
              ),

              // 類題の提示
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: similarQuestions.isNotEmpty
                    ? Column(
                  children: similarQuestions.map((item) {
                    // labelsの部分をList<String>に変換
                    List<String> itemLabels = (item['labels'] as List<dynamic>)
                        .map((e) => e.toString())
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['text']),
                        SizedBox(height: 8),
                        Text(
                          "ラベル: ${itemLabels.join(', ')}",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 16),  // ボタンのスペース
                        _isLoading
                            ? Center(child: CircularProgressIndicator()) // ローディング中はインジケーターを表示
                            : ElevatedButton(
                          onPressed: () {
                            // ボタンを押した時に渡すデータ
                            final inputText = item['text'];
                            final remainingLabels = itemLabels;

                            // 類題を解く処理
                            _onSolveSimilarQuestion(inputText, remainingLabels);
                          },
                          child: const Text('類題をチャットで解く'),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                )
                    : const Text('類題のラベルがありません'),
              ),

              //ホーム画面に戻るボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor, // ボタン色
                    foregroundColor: AppColors.white,     // 文字色
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
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;

  const ChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 60), // 高さを設定（適切なサイズを指定）
      painter: BubblePainter(color: AppColors.background),
      child: Container(
        margin: const EdgeInsets.only(top: 10), // 三角形の分の余白
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color color;

  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double triangleWidth = 20;
    final double triangleHeight = 10;

    final Path path = Path()
      ..moveTo((size.width - triangleWidth) / 2, size.height) // 三角形左端
      ..lineTo(size.width / 2, size.height - triangleHeight) // 三角形の頂点（中央下）
      ..lineTo((size.width + triangleWidth) / 2, size.height) // 三角形右端
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
