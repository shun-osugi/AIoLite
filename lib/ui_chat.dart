import 'package:flutter/material.dart';
// Google Generative AI (Gemini) を使うためのライブラリ
import 'package:google_generative_ai/google_generative_ai.dart';

/// 本来は安全に管理すべきAPIキーを、サンプル上では直書きしています。
const String apiKey = 'AIzaSy***************';

/// 1つのチャットメッセージを表すクラス
/// [isUser] が true ならユーザーの発言、false ならAIの発言
class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage(this.isUser, this.text);
}

void main() {
  runApp(MyApp());
}

/// アプリ全体のルートウィジェット
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

/// メイン画面（チャット画面）を定義する StatefulWidget
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

/// 状態管理クラス
class _ChatPageState extends State<ChatPage> {
  // チャット履歴
  final List<ChatMessage> _messages = [];
  // テキスト入力欄を制御するコントローラ
  final TextEditingController _textController = TextEditingController();

  // Google Generative AI (Gemini) 関連
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    // Geminiモデルの初期化
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

  /// ユーザーが入力したテキストを送信したときに呼ばれるメソッド
  void _onSendMessage() async {
    final userText = _textController.text;
    if (userText.isEmpty) return; // 空文字は無視

    // 1. ユーザーの発言をチャット履歴に追加
    setState(() {
      _messages.add(ChatMessage(true, userText));
      _textController.clear(); // 入力欄をクリア
    });

    // 2. Gemini への問い合わせ
    final content = Content.text(userText);
    final response = await _chatSession.sendMessage(content);

    // 3. AIからの応答テキストを取得してチャット履歴に追加
    final aiText = response.text ?? 'AIからの返答取得失敗';
    setState(() {
      _messages.add(ChatMessage(false, aiText));
    });
  }

  /// タイトルをタップした時に、ポップアップを表示するメソッド
  void _showTitlePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("より詳しい説明"),
          content: SingleChildScrollView(
            child: Text(
              "ここに、タイトルに関する長めのテキストや説明文を表示できます。\n"
              "スクロールして読めるようにSingleChildScrollViewを使っています。"
            ),
          ),
          actions: [
            TextButton(
              child: Text("閉じる"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
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
