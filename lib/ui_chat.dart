import 'package:flutter/material.dart';
import 'main.dart';
import 'ui_result.dart';
import 'colors.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
const apiKey = 'AIzaSyBKSKfHy_6DjTpx-3Zep78Vf-FXZWP1Tsw';

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
  bool isFirstSend = false;
  List<String> labels = [];
  final TextEditingController _textController = TextEditingController();
  List<chat> chats = []; //会話リスト
  late final GenerativeModel _model;
  late final ChatSession AI;
  late List<dynamic> similarQuestions = [];

  @override
  void initState() {
    super.initState();
    // dotenv.load(fileName: ".env");
    // var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    AI.sendMessage(Content.text('これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください'));
    AI.sendMessage(Content.text('こちらが答えるとき，文章で説明し回答しなければならないような質問を，ときどきお願いします'));
    AI.sendMessage(Content.text('出力は数式表現やコードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします'));
    AI.sendMessage(Content.text('口調は友達のような感じで大丈夫だよ！'));
  }

  void _sendMessage() {
    String text = _textController.text.trim(); // 入力値を取得し、前後の空白を削除
    if (text.isEmpty) return; // 入力が空の場合は送信しない

    setState(() {
      chats.add(chat(0, text)); // ユーザーのメッセージを会話リストに追加
    });
    _getAIResponse(text); // AIからの応答を取得
    _textController.clear(); // 入力欄をクリア
  }

  void _getAIResponse(String userMessage) async {
    final response = await AI.sendMessage(Content.text(userMessage)); // AIにメッセージを送信
    String aiMessage = response.text ?? 'AIの返答に失敗しました'; // AIの返答を取得

    setState(() {
      chats.add(chat(1, aiMessage)); // AIの返答を会話リストに追加
    });
  }

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
      }

      // labelsを取得
      final receivedLabels = args['labels'] as List<String>?;
      if (receivedLabels != null) {
        labels = receivedLabels;
      }

      // similarQuestionsを取得
      final receivedSimilarQuestions = args['similarQuestions'] as List<dynamic>?;
      if (receivedSimilarQuestions != null) {
        similarQuestions = receivedSimilarQuestions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI チャット", style: TextStyle(color: AppColors.white),),
        backgroundColor: AppColors.mainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: "会話の終了",
            onPressed: () async { //フィードバックへ遷移
              final feedback = await AI.sendMessage(Content.text('今回の会話はどうだった？私が苦手なところとか分かったら短く一文で教えてほしいな。またね！'));
              final feedbackMessage = feedback.text ?? 'フィードバックの作成に失敗しました';
              Navigator.pushNamed(
                context, '/result',
                arguments: {
                  'feedbackText': feedbackMessage,
                  'labels': labels,
                  'similarQuestions':similarQuestions,
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(10),
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
                      if (chat.p == 1) // AIのときだけアイコンを表示
                        CircleAvatar(
                          backgroundColor: AppColors.subColor,
                          child: Icon(Icons.android, color: AppColors.white),
                        ),
                      SizedBox(width: 8), // アイコンと吹き出しの間隔

                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: chat.p == 0
                                ? AppColors.mainColor // ユーザーの吹き出し
                                : AppColors.subColor, // AIの吹き出し
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat.str,
                            style: TextStyle(color: AppColors.white,fontSize: 16),
                          ),
                        ),
                      ),

                      if (chat.p == 0) // ユーザーのメッセージにはアイコンなし
                        SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "メッセージを入力...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send, color: AppColors.white),
                  backgroundColor: AppColors.mainColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}