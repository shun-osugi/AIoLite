import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'api_service.dart';     // API呼び出し用
import 'colors.dart';


class ResultPage extends StatefulWidget {
  final String text;

  const ResultPage({Key? key, required this.text}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<String>> _suggestedDataFuture;

  @override
  void initState() {
    super.initState();
    // APIからフィードバック用テキスト＆類題ラベルのリスト を取得する想定
    _suggestedDataFuture = _fetchData(widget.text);
  }

  //APIからデータ取得
  Future<List<String>> _fetchData(String text) async {
    try {
      // ApiService.classifyText が List<String> を返す前提
      return await ApiService.classifyText(text);
    } catch (e) {
      // エラーの場合は投げ直す（FutureBuilder 側で捕捉し表示）
      throw Exception("データ取得時にエラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィードバック'),
        backgroundColor: AppColors.mainColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

              //アバターを表示させるスペース用の空白
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Container(
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
              ),

              //フィードバックを表示する吹き出し
              FutureBuilder<List<String>>(
                future: _suggestedDataFuture,
                builder: (context, snapshot) {
                  Widget feedbackWidget;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // ローディング中
                    feedbackWidget = const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // エラー発生時
                    feedbackWidget = Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    // 正常にデータ取得できた場合
                    final data = snapshot.data ?? [];
                    // 先頭をフィードバック用テキストとみなす
                    final feedbackText = data.isNotEmpty
                        ? data.first
                        : 'フィードバック内容がありません';

                    feedbackWidget = ChatBubble(text: feedbackText);
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: feedbackWidget,
                  );
                },
              ),

              //類題の提示
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FutureBuilder<List<String>>(
                  future: _suggestedDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      );
                    } else {
                      final data = snapshot.data ?? [];
                      // 2番目以降を類題リストとみなす
                      final labels = data.length > 1
                          ? data.sublist(1)
                          : <String>[];

                      if (labels.isEmpty) {
                        return const Text('類題のラベルがありません');
                      }
                      return Text(labels.join('\n'));
                    }
                  },
                ),
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
      ..moveTo((size.width - triangleWidth) / 2, 0) // 三角形左端
      ..lineTo(size.width / 2, -triangleHeight) // 三角形の頂点（中央上）
      ..lineTo((size.width + triangleWidth) / 2, 0) // 三角形右端
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
