import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'api_service.dart';     // API呼び出し用
import 'colors.dart';


class ResultPage extends StatefulWidget {

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String feedbackText = "";
  List<String> labels = [];

  late Future<List<String>> _suggestedDataFuture;
  late Future<String> _getFeedbackData;

  @override
  void initState() {
    super.initState();
    // 類題ラベルのリスト を取得する
    _suggestedDataFuture = _fetchData(labels);
  }

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
      });
    }
  }

  //APIからデータ取得
  Future<List<String>> _fetchData(List<String> labels) async {
    try {
      // labelsを基にした類題取得処理,0番目に問題文,1~4番目にラベルが入ることを想定
      List<String> SAMPLE = ["1+1=", "数学 - 式と計算"];
      return SAMPLE;
    } catch (e) {
      // エラーの場合は投げ直す（FutureBuilder 側で捕捉し表示）
      throw Exception("データ取得時にエラー: $e");
    }
  }

  Future<String> _fetchFeedback() async {
    try {
      // ModalRoute を使って渡された引数を取得
      return ModalRoute.of(context)?.settings.arguments as String? ?? 'フィードバックの受け取りエラー';
    } catch (e) {
      throw Exception("データ取得時にエラー: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィードバック', style: TextStyle(color: AppColors.white),),
        backgroundColor: AppColors.mainColor,
        // automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

              //アバターを表示
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
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ChatBubble(
                        text: feedbackText.isEmpty
                            ? feedbackText = 'フィードバック内容がありません。'
                            : feedbackText),
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
                      return Center(
                        child: Column(
                          children: [
                            Text(data.first + ''),
                            SizedBox(height: 16),  // ボタンのスペース
                            ElevatedButton(
                              onPressed: () {
                                // ボタンを押した時に渡すデータ
                                if (labels.isNotEmpty) {
                                  final inputText = data[0];  // 1番目のラベルをinputTextに
                                  final remainingLabels = labels.length > 1 ? labels.sublist(1) : []; // labelsが1つ以上あれば、1番目から残りを渡す
                                  List<String> typedLabels = List<String>.from(remainingLabels);

                                  // '/chat' 画面に遷移し、必要なデータを渡す
                                  Navigator.pushNamed(
                                    context,
                                    '/chat',
                                    arguments: {
                                      'inputText': inputText,
                                      'labels': typedLabels,
                                    },
                                  );
                                }
                              },
                              child: const Text('類題をチャットで解く'),
                            ),
                          ],
                        ),
                      );
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
