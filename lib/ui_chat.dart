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
  String inputText = "";
  final TextEditingController _textController = TextEditingController();
  List<chat> chats = []; //会話リスト
  late final GenerativeModel _model;
  late final ChatSession AI;

  @override
  void initState() {
    super.initState();
    // dotenv.load(fileName: ".env");
    // var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    AI.sendMessage(Content.text('これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください'));
    AI.sendMessage(Content.text('口調は友達のような感じで大丈夫だよ！'));
  }

  void _sendMessage() {
    String text = _textController.text.trim(); // 入力値を取得し、前後の空白を削除
    if (text.isEmpty) return; // 入力が空の場合は送信しない

    setState(() {
      chats.add(chat(0, text)); // ユーザーのメッセージを会話リストに追加
      _textController.clear(); // 入力欄をクリア
    });
    _getAIResponse(text); // AIからの応答を取得
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
    if (args is String) {
      _textController.text = args;
      inputText = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI チャット"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb_outline, color: Colors.white),
            tooltip: "類題の提示",
            onPressed: () {
              Navigator.pushNamed(context, '/result');
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
                return Align(
                  alignment: chat.p == 0 ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: chat.p == 0 ? Colors.deepPurple[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat.str,
                      style: TextStyle(fontSize: 16),
                    ),
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
                  child: Icon(Icons.send, color: Colors.white),
                  backgroundColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}