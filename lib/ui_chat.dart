import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'colors.dart';
import 'tts_service.dart';
import 'widget_help_dialog.dart';

class chat {
  int p; //0:自分 1:相手
  String str; //会話内容
  chat(this.p, this.str);
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

  bool openMenu = false; // メニュー管理

  bool _isMuted = false;

  List<String> labels = []; // ラベルの格納用リスト

  // テキストのコントローラー
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<chat> chats = []; //会話リスト

  // AIモデル
  late final GenerativeModel _model;
  late final ChatSession AI;

  final TTSService _ttsService = TTSService(); //音声読み上げサービス

  late Database _database; //データベース
  String summary = ""; //どういう解き方を最初したのか
  String wrong = ""; //間違えてた部分
  String wrongpartans = ""; //間違えてた部分の正しい解き方
  String correctans = "";

  // はじめにAIに送る指示
  @override
  void initState() {
    super.initState();
    var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    _initAsync();
    _initDatabase();
  }

  Future<void> _initAsync() async {
    await AI.sendMessage(Content.text('''
    これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください.
    こちらが答えるとき，文章で説明し回答しなければならないような質問を，ときどきお願いします.
    そちらが話す文章は読み上げを行うので，そのまま読むとおかしくなるような文字は出力しないでください．
    例えば，文字効果（**A**などの），絵文字，コードフィールドなどの環境依存のものは無しでプレーンテキストでお願いします.
    ただし，texの数式表現はOKです．texの表現はr''にしてください．\$.\$のようなマーカー付きのLaTeX形式は使ってはいけません．
    出力文字数は,多くても100文字程度になるようにしてください.
    中高生（受験生）を対象とするので，必ず最初に「どこまで自力で解けるか解いてみて」などと聞いて，それに伴って会話を進めてください.
    口調は友達のような感じで大丈夫だよ！
    '''));

    final AIsummary = await AI.sendMessage(Content.text('''
    先ほどの問題文を10~15文字で要約してください
    '''));
    setState(() {
      this.summary = AIsummary.text ?? '問題文の要約に失敗しました';
    });
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
    String aiMessage = '';
    String speechMessage = '';
    try {
      final response = await AI.sendMessage(Content.text(userMessage)); // AIにメッセージを送信
      aiMessage = response.text ?? 'イオからのメッセージが取得できませんでした'; // AIの返答を取得
      speechMessage = toSpeechText(aiMessage); //読み上げ用テキスト変換
      print('メッセージ: $aiMessage');
      print('メッセージ2: $speechMessage');
      setState(() {
        chats.add(chat(1, aiMessage.trimRight())); // AIの返答を会話リストに追加
        _isSending = false;
      });
    } catch (e) {
      // エラー時の処理
      setState(() {
        chats.add(chat(1, 'イオからのメッセージが取得できませんでした'));
        _isSending = false;
      });
    }
    try {
      //AI側のメッセージを読み上げ（新しいメッセージがきたら新しい方を読み上げはじめる）
      await _ttsService.stop();
      await _ttsService.speak(speechMessage);
    } catch (e) {
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

  //データベース初期化
  Future<void> _initDatabase() async {
    // データベースをオープン（存在しない場合は作成）
    bool b = true;
    try {
      // String databasePath = await getDatabasesPath();
      // String path = '${databasePath}/database.db';
      // await deleteDatabase(path);
      _database = await openDatabase(
        'database.db',
        version: 1,
        onCreate: (Database db, int version) async {
          //テーブルがないなら作成
          //フィードバックテーブルを作成
          //fieldはリスト（flutter側に持ってくるときに変換予定）
          b = false;
          return db.execute(
            '''
            CREATE TABLE IF NOT EXISTS feedback(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              subject TEXT,
              field TEXT,
              problem TEXT,
              summary TEXT,
              wrong TEXT,
              wrongpartans TEXT,
              correctans TEXT
            )
            ''',
          );
        },
      );
      if (b) {
        _database.execute(
          '''
          CREATE TABLE IF NOT EXISTS feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            field TEXT,
            problem TEXT,
            summary TEXT,
            wrong TEXT,
            wrongpartans TEXT,
            correctans TEXT
          )
          ''',
        );
      }
    } catch (e) {
      print("データベース保存エラー");
      print(e);
    }
  }

  Future<void> inputDatabase() async {
    String subject = 'なし'; //教科（sqliteでは文字列の状態で保存）
    String field = 'なし'; //ラベル（sqliteでは文字列の状態で保存）
    if (labels.isNotEmpty) {
      List<String> s = labels[0].replaceAll(RegExp(r'\s'), '').split('-'); //全ての空白を削除
      subject = s[0];
      field = s[1];
      for (int i = 1; i < labels.length; i++) {
        //二つ目以降のラベルも保存
        s = labels[i].replaceAll(RegExp(r'\s'), '').split('-'); //全ての空白を削除
        subject += '&&'; //教科1&&教科2&&...のフォーマットで保存
        subject += s[0];
        field += '&&'; //ラベル1&&ラベル2&&...のフォーマットで保存
        field += s[1];
      }
    } else {
      for (int i = 0; i < labels.length; i++) {
        //二つ目以降のラベルも保存
        List<String> s = labels[i].replaceAll(RegExp(r'\s'), '').split('-'); //全ての空白を削除
        subject += '&&'; //教科1&&教科2&&...のフォーマットで保存
        subject += s[0];
        field += '&&'; //ラベル1&&ラベル2&&...のフォーマットで保存
        field += s[1];
      }
    }
    try {
      // var all = await _database.query('feedback');
      //recordId 主キー
      await _database.insert('feedback', {'subject': subject, 'field': field, 'problem': inputText, 'summary': summary, 'wrong': wrong, 'wrongpartans': wrongpartans, 'correctans': correctans});
    } catch (e) {
      print("データベース保存エラー");
      print(e);
    }
  }

  //通常テキストと，texテキストを分割
  List<InlineSpan> MixedTextSpans(String text, Color color) {
    //$..$表現はr''にし，flutterが使える形に変換
    text = text.replaceAllMapped(RegExp(r'\$(.+?)\$'), (match) {
      return "r'${match.group(1)}'";
    });
    final List<InlineSpan> spans = [];
    final RegExp pattern = RegExp(r"r'(.*?)'"); //texの構文
    int currentIndex = 0; //現在の場所

    for (final match in pattern.allMatches(text)) {
      // texが見つかるところまでは，通常のテキスト部分
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
      }

      // TeX部分 (r'...') の中身を取り出す
      final String tex = match.group(1)!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          tex,
          mathStyle: MathStyle.text,
          textStyle: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      currentIndex = match.end; //texの部分まで探索終了
    }

    // 残りの通常文字列
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ));
    }

    print('kfksdfsf');
    for (int i = 0; i < spans.length; i++) {
      print(spans[i].toPlainText());
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: A_Colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - safeAreaPadding.top - safeAreaPadding.bottom,
                width: MediaQuery.of(context).size.width,
                child: Stack(
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
                                colors: [A_Colors.subColor, A_Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: A_Colors.background, width: 4),
                            ),
                            child: Text(
                              'イオ',
                              style: TextStyle(
                                color: A_Colors.black,
                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),

                    // メニュー⇆チャット切替ボタン
                    Positioned(
                        top: MediaQuery.of(context).size.height * 0.1,
                        right: MediaQuery.of(context).size.width * 0.15,
                        child: MenuButton(
                          icon: openMenu ? Icons.chat : Icons.menu,
                          onPressed: () {
                            setState(() {
                              openMenu = !openMenu;
                            });
                          },
                        )),

                    // 会話部分
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 問題文を表示するボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [A_Colors.subColor, A_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: A_Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: A_Colors.mainColor.withOpacity(0.7),
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
                                          colors: [A_Colors.white, A_Colors.subColor, A_Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: A_Colors.black, width: 4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: A_Colors.black,
                                                  size: MediaQuery.of(context).size.width * 0.1,
                                                ),
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
                                                      color: A_Colors.black,
                                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                              summary,
                              style: TextStyle(
                                color: A_Colors.black,
                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width,
                        ),

                        // チャット部分
                        if (!openMenu)
                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
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
                                          : MainAxisAlignment.start,
                                      // AI: 左寄せ
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
                                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                                  margin: EdgeInsets.only(bottom: 8, left: chat.p == 0 ? 40 : 8, right: chat.p == 0 ? 8 : 40),
                                                  constraints: BoxConstraints(minWidth: 80),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [chat.p == 0 ? A_Colors.mainColor : A_Colors.subColor, chat.p == 0 ? A_Colors.mainColor : A_Colors.white],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(24),
                                                  ),
                                                  child: RichText(
                                                    //複数に分けて表示
                                                    text: TextSpan(
                                                      children: MixedTextSpans(chat.str, chat.p == 0 ? A_Colors.white : A_Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: chat.p == 0 ? 0 : null,
                                              // ユーザー（右側）の場合はbottomに配置
                                              top: chat.p != 0 ? 0 : null,
                                              // AI（左側）の場合はtopに配置
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
                          ),

                        // メニュー部分
                        if (openMenu)
                          Expanded(
                              child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.1,
                              ),

                              // ヘルプボタン
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  color: A_Colors.mainColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: A_Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: A_Colors.mainColor.withOpacity(0.7),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return HelpDialog(
                                          mode: 'advanced',
                                          content: 'chat',
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    'チャット画面の使い方',
                                    style: TextStyle(
                                      color: A_Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              // ミュート切替ボタン －－－－－－－－－－－－－－－－－－－－－－
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [A_Colors.subColor, A_Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: A_Colors.black, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: A_Colors.black.withOpacity(0.7),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // 音声の ON / OFF をトグル
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
                                    _isMuted ? '音声読み上げ:OFF' : '音声読み上げ:ON',
                                    style: TextStyle(
                                      color: A_Colors.black,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              // 今の問題をやり直すボタン
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [A_Colors.subColor, A_Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: A_Colors.black, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: A_Colors.black.withOpacity(0.7),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      chats.clear();
                                      chats.add(chat(0, inputText));
                                      openMenu = false;
                                    });
                                    await AI.sendMessage(Content.text('もう一度始めから教えて！'));
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
                                    '今の問題をやりなおす',
                                    style: TextStyle(
                                      color: A_Colors.black,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              // ホームに戻るボタン
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [A_Colors.subColor, A_Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: A_Colors.black, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: A_Colors.black.withOpacity(0.7),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pushNamed(context, '/home');
                                    await _ttsService.stop();
                                  }, //画面遷移するときに読み上げ停止
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    'ホームに戻る',
                                    style: TextStyle(
                                      color: A_Colors.black,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),

                        // 入力部分
                        if (!openMenu)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    cursorColor: _isSending ? A_Colors.subColor : A_Colors.mainColor,
                                    controller: _textController,
                                    enabled: !_isSending,
                                    decoration: InputDecoration(
                                      hintText: _isSending ? "イオの応答を待っています..." : "メッセージを入力...",
                                      hintStyle: TextStyle(color: A_Colors.mainColor),
                                      enabledBorder: OutlineInputBorder(
                                        // 未フォーカス時
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _isSending ? A_Colors.white : A_Colors.mainColor,
                                          width: 3,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        // フォーカス時
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _isSending ? A_Colors.white : A_Colors.mainColor,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                FloatingActionButton(
                                  onPressed: _isSending ? null : _sendMessage,
                                  child: Icon(Icons.send, color: _isSending ? A_Colors.black : A_Colors.white),
                                  backgroundColor: _isSending ? A_Colors.white : A_Colors.mainColor,
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),

                    // チャット終了ボタン
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.32,
                      left: MediaQuery.of(context).size.width * 0.5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [A_Colors.accentColor, A_Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: A_Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: A_Colors.accentColor.withOpacity(0.7),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            //フィードバックへ遷移
                            await _ttsService.stop(); //画面遷移するときに読み上げ停止
                            try {
                              final feedback = await AI.sendMessage(Content.text(
                                  //簡単なフィードバック
                                  '今回の会話はどうだった？私が苦手なところとか分かったら短く(50文字程度)一文で教えてほしいな．'));
                              final feedbackMessage = feedback.text ?? 'フィードバックの作成に失敗しました';

                              //詳細のフィードバックを作成
                              final info = await AI.sendMessage(Content.text('''
                                今回の会話について，
                                1,ユーザーが間違えてた部分
                                2,間違えた部分の正しい解き方
                                3,問題自体の正しい解き方
                                を，必ず以下のフォーマットで送ってください
                                &&内容1&&内容2&&内容3
                              '''));

                              String infotext = info.text ?? '&&なし&&なし&&なし';
                              final B = infotext.substring(infotext.indexOf('&&')).split('&&');
                              wrong = B[1]; //間違えてた部分
                              wrongpartans = B[2]; //間違えてた部分の正しい解き方
                              correctans = B[3]; //それの正しい解き方
                              // print("sdoifsdjffd");
                              // print(summary);
                              // print(wrong);
                              // print(wrongpartans);
                              // print(correctans);

                              inputDatabase(); //データベースに追加

                              Navigator.pushNamed(
                                context,
                                '/result',
                                arguments: {
                                  'inputText': inputText,
                                  'feedbackText': feedbackMessage,
                                  'labels': labels,
                                  'summary': summary,
                                  'wrong': wrong,
                                  'wrongpartans': wrongpartans,
                                  'correctans': correctans,
                                },
                              );
                            } catch (e) {
                              Navigator.pushNamed(
                                context,
                                '/result',
                                arguments: {
                                  'inputText': inputText,
                                  'feedbackText': 'フィードバックの作成に失敗しました',
                                  'labels': labels,
                                  'summary': summary,
                                  'wrong': wrong,
                                  'wrongpartans': wrongpartans,
                                  'correctans': correctans,
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
                            '振り返りへ',
                            style: TextStyle(
                              color: A_Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
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
              ),
            );
          },
        ),
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
    this.size = 60.0,
    this.color = A_Colors.mainColor,
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
      ..color = p == 0 ? A_Colors.mainColor : A_Colors.subColor
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

//読み上げ用テキスト変換関数
String toSpeechText(String inputText) {
  // 数学系
  inputText = inputText.replaceAllMapped(RegExp(r'([a-zA-Z0-9])\^([a-zA-Z0-9])'), (m) => '${m[1]}${m[2]}乗');
  inputText = inputText.replaceAllMapped(RegExp(r'([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)'), (m) => '${m[2]}分の${m[1]}');
  inputText = inputText.replaceAll(r'=', 'イコール');
  inputText = inputText.replaceAll(r'-', 'イコール');

  // ネットスラング(笑)
  inputText = inputText.replaceAll(RegExp(r'\b(w{2,})\b', caseSensitive: false), '笑');

  // 三点リーダ→読点
  inputText = inputText.replaceAll(RegExp(r'[.…]{2,}'), '、');

  // 絵文字・記号の削除
  final symbolEmojiRegex = RegExp(
    r'''[
    \u2300-\u23FF
    \u2600-\u26FF
    \u2700-\u27BF
    \u{1F300}-\u{1F5FF}
    \u{1F600}-\u{1F64F}
    \u{1F680}-\u{1F6FF}
    \u{1F900}-\u{1F9FF}
  ]''',
    unicode: true,
  );
  inputText = inputText.replaceAll(symbolEmojiRegex, '');
  
  return inputText;
}
