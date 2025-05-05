import 'package:flutter/material.dart';
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
  runApp(ChatBasicPage());
}

class ChatBasicPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatBasicPage> {

  String inputText = ""; // 入力文章用文字列

  bool isFirstSend = false; // はじめの問題文の送信をしたか
  bool _isSending = false; // 二度目以降、問題文の送信中を判断

  bool openMenu = false; // メニュー管理

  bool _isMuted = false; //音声読み上げを行うか否か

  List<String> labels = []; // ラベルの格納用リスト

  // テキストのコントローラー
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<chat> chats = []; //会話リスト
  int chatIndex = 0; // チャット表示のインデックス

  // AIモデル
  late final GenerativeModel _model;
  late final ChatSession AI;

  final TTSService _ttsService = TTSService(); //音声読み上げサービス

  // はじめにAIに送る指示
  @override
  void initState(){
    super.initState();
    var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await AI.sendMessage(Content.text('''
    これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください.
    そちらが話す文章は読み上げを行うので，そのまま読むとおかしくなるような文字は出力しないでください．
    例えば，数式表現や文字効果（**A**などの），絵文字，コードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします.
    こちら側は小学生を想定しているので漢字などを使う場合は難しい表現はあまりしないでください.
    もし，問題を解き終えたら，問題で使った知識が普段どういう風に使われているか教えてください.
    また全ての出力において，理解しやすいように多くても出力文字数は80文字以内になるようにしてください.
    口調は友達（小学生）のような感じで大丈夫だよ！
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
      chatIndex = chats.length - 2; // Indexを更新
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
    String aiMessage = '';
    try {
      final response = await AI.sendMessage(
          Content.text(userMessage)); // AIにメッセージを送信
      aiMessage = (response.text ?? 'イオからのメッセージが取得できませんでした').trim(); // AIの返答を取得
      setState(() {
        chats.add(chat(1, aiMessage)); // AIの返答を会話リストに追加
        chatIndex = chats.length - 2; // Indexを更新
        _isSending = false;
      });
    } catch (e) {
      // エラー時の処理
      setState(() {
        chats.add(chat(1, 'イオからのメッセージが取得できませんでした'));
        _isSending = false;
      });
    }
    try{
      //AI側のメッセージを読み上げ（新しいメッセージがきたら新しい方を読み上げはじめる）
      await _ttsService.stop();
      await _ttsService.speak(aiMessage);
    }
    catch(e){
      print('読み上げエラー');
      print(e);
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
          _isSending = true;
          chats.add(chat(0, receivedText));
          chatIndex = chats.length - 2; // Indexを更新
        });
        _getAIResponse(receivedText);
        isFirstSend = true;
        inputText = receivedText;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: B_Colors.background,
      body: Stack(
        children: [
          // アバター表示
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: MediaQuery.of(context).size.width * -0.05,
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
                disablePan: true,
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
                      colors: [B_Colors.subColor, B_Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: B_Colors.background, width: 4),
                  ),
                  child: Text('イオ', style: TextStyle(
                    color: B_Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,),)
              )
          ),

          // メニュー⇆チャット切替ボタン
          Positioned(
              top: MediaQuery.of(context).size.height * 0.17,
              right: MediaQuery.of(context).size.width * 0.15,
              child:
              MenuButton(
                icon: openMenu ? Icons.chat : Icons.menu,
                onPressed: () {
                  setState(() {
                    openMenu = !openMenu;
                  });
                },
              )
          ),

          // 会話部分
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width,
              ),

              // 問題文を表示するボタン
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [B_Colors.subColor, B_Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: B_Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: B_Colors.mainColor.withOpacity(0.7),
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
                              color: B_Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: B_Colors.black, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(Icons.close, color: B_Colors.black, size: MediaQuery.of(context).size.width * 0.1,),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          inputText,
                                          style: TextStyle(
                                            color: B_Colors.black,
                                            fontSize: MediaQuery.of(context).size.width * 0.05,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    inputText,
                    style: TextStyle(
                      color: B_Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.25),

              // チャット部分
              if (!openMenu)
                Expanded(
                  child: Stack(
                    children: [
                      for (int i = (chatIndex > -1 ? 0 : 1); i < 2; i++)
                        Positioned(
                          top: chats[chatIndex + i].p != 0 ? 0 : null,
                          bottom: chats[chatIndex + i].p == 0 ? 0 : null,
                          left: 0,
                          right: 0,
                          child: Opacity(
                            opacity: i == 0 ? 0.6 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                                mainAxisAlignment: chats[chatIndex + i].p == 0
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                                          minWidth: MediaQuery.of(context).size.width * 0.2,
                                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                                        ),
                                        child: IntrinsicWidth(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                            margin: EdgeInsets.only(bottom: 8, left: chats[chatIndex + i].p == 0 ? 40 : 8, right: chats[chatIndex + i].p == 0 ? 8 : 40),
                                            constraints: BoxConstraints(minWidth: 80),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  chats[chatIndex + i].p == 0 ? B_Colors.mainColor : B_Colors.subColor,
                                                  chats[chatIndex + i].p == 0 ? B_Colors.mainColor : B_Colors.white
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: SingleChildScrollView(
                                              child:Text(
                                                chats[chatIndex + i].str,
                                                style: TextStyle(
                                                  color: chats[chatIndex + i].p == 0 ? B_Colors.white : B_Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: chats[chatIndex + i].p == 0 ? 0 : null,
                                        top: chats[chatIndex + i].p != 0 ? 0 : null,
                                        right: chats[chatIndex + i].p == 0 ? 8 : null,
                                        left: chats[chatIndex + i].p == 0 ? null : 8,
                                        child: CustomPaint(
                                          painter: ChatBubbleTriangle(p: chats[chatIndex + i].p),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),


              // メニュー部分
              if (openMenu)
                Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1,),

                        // ヘルプボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            color: B_Colors.mainColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: B_Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: B_Colors.mainColor.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'おしゃべりのしかた',
                              style: TextStyle(
                                color: B_Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

                        // ミュート切替ボタン －－－－－－－－－－－－－－－－－－－－－－
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [B_Colors.subColor, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: B_Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: B_Colors.mainColor.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              // トグルして UI を更新
                              await _ttsService.toggleMute();
                              setState(() => _isMuted = _ttsService.isMuted);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              _isMuted ? 'おとをだす' : 'おとをださない',
                              style: TextStyle(
                                color: B_Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

                        // ホームに戻るボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [B_Colors.subColor, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: B_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: B_Colors.black.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, '/home');
                              await _ttsService.stop(); },  //画面遷移するときに読み上げ停止
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'ホームにもどる',
                              style: TextStyle(
                                color: B_Colors.black,
                                fontSize: MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

                        // 今の問題をやり直すボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [B_Colors.subColor, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: B_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: B_Colors.black.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                chats.clear();
                                chats.add(chat(0, inputText));
                                chatIndex = chats.length - 2; // Indexを更新
                                openMenu = false;
                              });
                              AI.sendMessage(Content.text('もう一度始めから教えて！'));
                              _getAIResponse(inputText);

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'もんだいをやりなおす',
                              style: TextStyle(
                                color: B_Colors.black,
                                fontSize: MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),

              // 入力部分
              if (!openMenu)
                Column(
                  children: [
                    // 矢印ボタンと？ボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 一つ前のチャットへ
                        Container(
                          width: MediaQuery.of(context).size.width * 0.20,
                          height: MediaQuery.of(context).size.width * 0.16,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [chatIndex > -1 ? B_Colors.accentColor : B_Colors.white, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: B_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: chatIndex > -1 ? B_Colors.accentColor.withOpacity(0.7) : Colors.transparent,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            iconSize: MediaQuery.of(context).size.width * 0.1,
                            color: B_Colors.black,
                            onPressed: () {
                              setState(() {
                                if (chatIndex > -1) {
                                  chatIndex -= 1;
                                }
                              });
                            },
                          ),
                        ),

                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                        // ？ボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.44,
                          height: MediaQuery.of(context).size.width * 0.16,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [B_Colors.accentColor, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: B_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: B_Colors.accentColor.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.question_mark),
                            iconSize: MediaQuery.of(context).size.width * 0.1,
                            color: B_Colors.black,
                            onPressed: () async {
                              setState(() {
                                _isSending = true;
                                chats.add(chat(0, '？')); // ユーザーのメッセージを会話リストに追加
                                chatIndex = chats.length - 2; // Indexを更新
                              });
                              await AI.sendMessage(Content.text('今のところがわからなかったから、もう一度分かりやすく教えて！'));
                              _getAIResponse(inputText);
                            },
                          ),
                        ),

                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                        // 一つ後のチャットへ
                        Container(
                          width: MediaQuery.of(context).size.width * 0.20,
                          height: MediaQuery.of(context).size.width * 0.16,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [chatIndex < chats.length - 2 ? B_Colors.accentColor : B_Colors.white, B_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: B_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: chatIndex < chats.length - 2 ? B_Colors.accentColor.withOpacity(0.7) : Colors.transparent,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward),
                            iconSize: MediaQuery.of(context).size.width * 0.1,
                            color: B_Colors.black,
                            onPressed: () {
                              setState(() {
                                if (chatIndex < chats.length - 2) {
                                  chatIndex += 1;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: _isSending ? B_Colors.subColor : B_Colors.mainColor,
                              controller: _textController,
                              enabled: !_isSending,
                              decoration: InputDecoration(
                                hintText: _isSending ? "イオの応答を待っています..." : "メッセージを入力...",
                                hintStyle: TextStyle(color: B_Colors.mainColor),
                                enabledBorder: OutlineInputBorder( // 未フォーカス時
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _isSending ? B_Colors.white : B_Colors.mainColor,
                                    width: 3,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder( // フォーカス時
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _isSending ? B_Colors.white : B_Colors.mainColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: _isSending ? null : _sendMessage,
                            child: Icon(Icons.send, color: _isSending ? B_Colors.black : B_Colors.white),
                            backgroundColor: _isSending ? B_Colors.white : B_Colors.mainColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),

          // チャット終了ボタン
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30,
            left: MediaQuery.of(context).size.width * 0.5,
            child:
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [B_Colors.accentColor, B_Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: B_Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: B_Colors.accentColor.withOpacity(0.7),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async { //フィードバックへ遷移
                  await _ttsService.stop();
                  try {
                    final feedback = await AI.sendMessage(Content.text(//簡単なフィードバック
                        'これまでの会話でよかったところをほめて！ また別の問題にも一緒に取り組みたくなるようなメッセージを一言で教えてほしいな'));
                    final feedbackMessage = feedback.text ??
                        'やったね！ また、べつのもんだいにもチャレンジしてみよう！ いっしょにがんばろうね！';
                    showDialog(
                      context: context,
                      builder: (context) => MessageDialog(
                        feedbackMessage: feedbackMessage,
                      ),
                      barrierDismissible: false,
                    );

                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => MessageDialog(
                        feedbackMessage: 'やったね！ また、べつのもんだいにもチャレンジしてみよう！ いっしょにがんばろうね！',
                      ),
                      barrierDismissible: false,
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
                  'できた！',
                  style: TextStyle(
                    color: B_Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final Color shadowColor;

  const MenuButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 80.0,
    this.color = B_Colors.mainColor,
    this.shadowColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.7),
            blurRadius: 4,
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
      ..color = p == 0 ? B_Colors.mainColor : B_Colors.subColor
      ..style = PaintingStyle.fill;

    final Path path = Path();
    if (p == 0) {
      // 右下に三角形
      path.moveTo(-36, -8);
      path.quadraticBezierTo(-48, 8, -72, 16);
      path.quadraticBezierTo(-62, 8, -56, -8);
    } else {
      // 左上に三角形
      path.moveTo(36, 0);
      path.quadraticBezierTo(48, -16, 72, -24);
      path.quadraticBezierTo(62, -16, 56, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MessageDialog extends StatelessWidget {
  final String feedbackMessage;
  final String modelPath;

  const MessageDialog({
    super.key,
    required this.feedbackMessage,
    this.modelPath = 'assets/avatar0.glb',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Container(
        width: size.width * 0.95,
        height: size.height * 0.6,
        decoration: BoxDecoration(
          color: B_Colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: B_Colors.accentColor, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // アバター表示
              SizedBox(
                height: size.height * 0.2,
                child: ModelViewer(
                  src: modelPath,
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

              // 一言メッセージ
              SizedBox(
                height: size.height * 0.28,
                child: SingleChildScrollView(
                  child: FeedbackBubble(feedbackText: feedbackMessage),
                ),
              ),

              SizedBox(height: size.height * 0.01,),

              //ホーム画面に戻るボタン
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: B_Colors.mainColor,
                    foregroundColor: B_Colors.white,
                  ),
                  onPressed: () {
                    // ルート指定でホーム画面へ戻る
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Text(
                    'ホームにもどる',
                    style: TextStyle(
                      color: B_Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
              color: B_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              feedbackText,
              style: TextStyle(
                color: B_Colors.black,
                fontSize: 20,
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