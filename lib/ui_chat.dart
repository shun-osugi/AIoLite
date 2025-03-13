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
    // チャットセッション開始
    _chatSession = _model.startChat();
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
      // 背景を白などに指定（任意）
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1) 画面上部のタイトル部分
            GestureDetector(
              onTap: _showTitlePopup,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // タイトルの背景は灰色
                  borderRadius: BorderRadius.circular(16), // 角を丸く
                ),
                child: Center(
                  child: Text(
                    "短いタイトル（タップで詳細）",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // 2) タイトルの下にあるボタンや画像
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 戻るボタン（黒い三角形）
                IconButton(
                  icon: Icon(Icons.arrow_left, color: Colors.black),
                  onPressed: () {
                    // 戻るボタンを押したときの処理をここに書く（画面遷移など）
                    Navigator.pop(context);
                  },
                ),
                // 「終」の丸ボタン
                ElevatedButton(
                  onPressed: () {
                    // 終了や他のアクションをしたい処理
                    print('終 ボタンが押されました');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), // 丸いボタンにする
                    padding: EdgeInsets.all(12),
                    primary: Colors.grey, // ボタンの色
                  ),
                  child: Text(
                    "終",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                // ピンクの楕円をイメージしたWidget
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(40), // 楕円風
                  ),
                )
              ],
            ),

            // 3) チャット履歴部分（吹き出しを並べる）
            // Expandedを使って、残りの領域を全て使うようにする
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // 灰色の背景
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    // 吹き出しの背景色を分ける
                    final bubbleColor = message.isUser
                        ? Colors.pinkAccent[100]
                        : Colors.lightBlueAccent[100];
                    // 吹き出しの整列を分ける
                    final alignment = message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start;

                    return Column(
                      crossAxisAlignment: alignment,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message.text),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 4) 画面下部の入力欄 + マイクボタン + カメラボタン + ？ボタン
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // マイクアイコンボタン
                  IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {
                      // 音声入力などの機能をここに実装
                      print('マイクボタンタップ');
                    },
                  ),
                  // カメラアイコンボタン
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      // カメラ起動などの機能をここに実装
                      print('カメラボタンタップ');
                    },
                  ),
                  // テキスト入力欄
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'メッセージを入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  // 「？」ボタン（丸ボタン）
                  InkWell(
                    onTap: () {
                      print('？ボタンタップ');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // 送信ボタン（本コードでは「START」の代わりにSendと表記）
                  ElevatedButton(
                    onPressed: _onSendMessage,
                    child: Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
