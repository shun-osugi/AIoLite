import 'package:flutter/material.dart';
import 'main.dart';
import 'ui_result.dart';
import 'colors.dart';
import 'tts_service.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class chat{
  int p; //0:自分 1:相手
  String str; //会話内容
  chat(this.p,this.str);
}

void main() {
  runApp(ChatPage());
}

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String inputText = ""; // 入力文章用文字列

  bool isFirstSend = false; // はじめの問題文の送信をしたか
  bool _isSending = false; // 二度目以降、問題文の送信中を判断

  List<String> labels = []; // ラベルの格納用リスト

  // テキストのコントローラー
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<chat> chats = []; //会話リスト

  // AIモデル
  late final GenerativeModel _model;
  late final ChatSession AI;

  final TTSService _ttsService = TTSService(); //音声読み上げサービス

  // はじめにAIに送る指示
  @override
  void initState() {
    super.initState();
    var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await AI.sendMessage(Content.text('''
    これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください.
    こちらが答えるとき，文章で説明し回答しなければならないような質問を，ときどきお願いします.
    出力は数式表現や文字効果（**A**などの），絵文字，コードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします.
    出力文字数は,多くても100文字程度になるようにしてください.
    中高生（受験生）を対象とするので，必ず最初に「どこまで自力で解けるか解いてみて」などと聞いて，それに伴って会話を進めてください.
    口調は友達のような感じで大丈夫だよ！
    '''));
  }

  // AIへメッセージを送信
  void _sendMessage() {
    if (_isSending) return;

    String text = _textController.text.trim(); // 入力値を取得し、前後の空白を削除
    if (text.isEmpty) return; // 入力が空の場合は送信しない

    setState(() {
      _isSending = true;
      chats.add(chat(0, text)); // ユーザーのメッセージを会話リストに追加
    });
    _getAIResponse(text); // AIからの応答を取得
    _textController.clear(); // 入力欄をクリア

    // メッセージ送信後にスクロールを最下部に移動
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0, // 一番下に移動
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // AIからのメッセージを取得
  void _getAIResponse(String userMessage) async {
    try {
      final response = await AI.sendMessage(
          Content.text(userMessage)); // AIにメッセージを送信
      String aiMessage = response.text ?? 'イオからのメッセージが取得できませんでした'; // AIの返答を取得

      setState(() {
        chats.add(chat(1, aiMessage)); // AIの返答を会話リストに追加
        _isSending = false;
      });

      //AI側のメッセージを読み上げ（新しいメッセージがきたら新しい方を読み上げはじめる）
      await _ttsService.stop();
      await _ttsService.speak(aiMessage);
    } catch (e) {
      // エラー時の処理
      setState(() {
        chats.add(chat(1, 'イオからのメッセージが取得できませんでした'));
        _isSending = false;
      });
    }
  }

  // 前画面から引数を受け取る
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 引数を受け取る
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      // inputTextを取得
      final receivedText = args['inputText'] as String?;
      if (receivedText != null && !isFirstSend) {
        setState(() {
          chats.add(chat(0, receivedText));
        });
        _getAIResponse(receivedText);
        isFirstSend = true;
        inputText = receivedText;
        _isSending = true;
      }

      // labelsを取得
      final receivedLabels = args['labels'] as List<String>?;
      if (receivedLabels != null) {
        labels = receivedLabels;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background_a,
      body: Stack(
        children: [
          // アバター表示
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: MediaQuery.of(context).size.width * -0.1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.26,
              width: MediaQuery.of(context).size.width * 0.7,
              child: ModelViewer(
                src: 'assets/avatar0.glb',
                alt: 'A 3D model of AI avatar',
                cameraOrbit: "-25deg 90deg 0deg",
                ar: false,
                autoRotate: false,
                disableZoom: true,
                disableTap: true,
                cameraControls: false,
                interactionPrompt: null,
                interactionPromptThreshold: 0,
                autoPlay: true,
                animationName: 'wait',
              ),
            ),
          ),

          // アバター名表示
          Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.subColor, AppColors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Text('イオ', style: TextStyle(
                    color: AppColors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: AppColors.black,
                        offset: Offset(0, 0),
                      ),
                    ],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,),)
              )
          ),

          // 会話部分
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

              // 問題文を表示するボタン
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.subColor, AppColors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainColor.withOpacity(0.7),
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
                                colors: [AppColors.subColor, AppColors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.white, width: 4),
                            ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                      inputText,
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  ),
                  child: Text(
                    inputText,
                    style: TextStyle(
                      color: AppColors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: AppColors.black,
                          offset: Offset(0, 0),
                        ),
                      ],
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.22),

              // チャット部分
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[chats.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: chat.p == 0
                            ? MainAxisAlignment.end // ユーザー: 右寄せ
                            : MainAxisAlignment.start, // AI: 左寄せ
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                                  minWidth: MediaQuery.of(context).size.width * 0.2,
                                ),
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    margin: EdgeInsets.only(bottom: 8, left: chat.p == 0 ? 40 : 8, right: chat.p == 0 ? 8 : 40),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [chat.p == 0 ? AppColors.mainColor : AppColors.subColor, chat.p == 0 ? AppColors.mainColor : AppColors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      chat.str,
                                      style: TextStyle(color: chat.p == 0 ? AppColors.white : AppColors.black, fontSize: 16, fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: chat.p == 0 ? 0 : null, // ユーザー（右側）の場合はbottomに配置
                                top: chat.p != 0 ? 0 : null,     // AI（左側）の場合はtopに配置
                                right: chat.p == 0 ? 8 : null,
                                left: chat.p == 0 ? null : 8,
                                child: CustomPaint(
                                  painter: ChatBubbleTriangle(p: chat.p),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 入力部分
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: _isSending ? AppColors.subColor : AppColors.mainColor,
                        controller: _textController,
                        enabled: !_isSending,
                        decoration: InputDecoration(
                          hintText: _isSending ? "イオの応答を待っています..." : "メッセージを入力...",
                          hintStyle: TextStyle(color: AppColors.mainColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.mainColor,
                              width: 2, // 枠線の太さ
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _isSending ? null : _sendMessage,
                      child: Icon(Icons.send, color: AppColors.white),
                      backgroundColor: _isSending ? AppColors.background : AppColors.mainColor,
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),

          // ボタングループ
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.5,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ホームボタン
                      CircleIconButton(
                        icon: Icons.home,
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                      ),

                      SizedBox(height: MediaQuery.of(context).size.width * 0.1),

                      // やり直しボタン
                      CircleIconButton(
                        icon: Icons.change_circle_outlined,
                        onPressed: () {
                          setState(() {
                            chats.clear();
                            chats.add(chat(0, inputText));
                          });
                          AI.sendMessage(Content.text('もう一度始めから教えて！'));
                          _getAIResponse(inputText);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // チャット終了ボタン
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentColor, AppColors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentColor.withOpacity(0.7),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async { //フィードバックへ遷移
                        try {
                          final feedback = await AI.sendMessage(Content.text(//簡単なフィードバック
                              '今回の会話はどうだった？私が苦手なところとか分かったら短く(50文字程度)一文で教えてほしいな．'));
                          final feedbackMessage = feedback.text ??
                              'フィードバックの作成に失敗しました';
                          
                          //詳細のフィードバックを作成
                          final info = await AI.sendMessage(Content.text('''
                          今回の会話について，
                          1,どういう解き方を最初したのか
                          2,ユーザーが間違えてた部分
                          3,間違えた部分の正しい解き方
                          4,問題自体の正しい解き方
                          を，必ず以下のフォーマットで送ってください
                          &&内容1&&内容2&&内容3&&内容4
                          '''));
                          String infotext = info.text ?? '作成失敗';
                          final B = infotext.substring(infotext.indexOf('&&')).split('&&');
                          String firstans = B[1];     //どういう解き方を最初したのか
                          String wrong = B[2];        //間違えてた部分
                          String wrongpartans = B[3]; //間違えてた部分の正しい解き方
                          String correctans = B[4];   //それの正しい解き方
                          // print("sdoifsdjffd");
                          // print(firstans);
                          // print(wrong);
                          // print(wrongpartans);
                          // print(correctans);

                          Navigator.pushNamed(
                            context, '/result',
                            arguments: {
                              'inputText': inputText,
                              'feedbackText': feedbackMessage,
                              'labels': labels,
                              'firstans': firstans,
                              'wrong': wrong,
                              'wrongpartans': wrongpartans,
                              'correctans': correctans,
                            },
                          );
                        } catch (e) {
                          Navigator.pushNamed(
                            context, '/result',
                            arguments: {
                              'inputText': inputText,
                              'feedbackText': 'フィードバックの作成に失敗しました',
                              'labels': labels,
                            },
                          );
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        '解けた！',
                        style: TextStyle(
                          color: AppColors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: AppColors.black,
                              offset: Offset(0, 0),
                            ),
                          ],
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),

        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final Color shadowColor;

  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 60.0,
    this.color = AppColors.mainColor,
    this.shadowColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.7),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size * 0.6,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class ChatBubbleTriangle extends CustomPainter {
  final int p;

  ChatBubbleTriangle({required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = p == 0 ? AppColors.mainColor : AppColors.subColor
      ..style = PaintingStyle.fill;

    final Path path = Path();
    if (p == 0) {
      // 右下に三角形
      path.moveTo(-44, -8);
      path.quadraticBezierTo(-32, 8, -8, 16);
      path.quadraticBezierTo(-18, 8, -24, -8);
    } else {
      // 左上に三角形
      path.moveTo(44, 0);
      path.quadraticBezierTo(32, -16, 8, -24);
      path.quadraticBezierTo(18, -16, 24, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}