import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colors.dart';
import 'tts_service.dart';
import 'widget_help_dialog.dart';
import 'utility.dart';
import 'math_keyboard.dart';
import 'toSpeechText.dart';

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

  late FocusNode _focusNode;
  bool _hasFocus = false;

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
    _loadMuteSetting();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initAsync() async {
    await AI.sendMessage(Content.text('''
    コーチング型AI家庭教師プロンプト
    目的
    中高生が自力で問題を解く力を身につけられるように、「教える」のではなく「導く」スタイルで学習をサポートしてください。
    基本方針
    ・問題が与えられたら、必ず最初に「どこまで自力で解けるか解いてみて」と声をかけてください。
    ・いきなり答えや解説を出すのではなく、段階的にヒントや問いかけを通して導いてください。
    ・生徒が答えたら、それを受けて次のステップを提示してください。
    ・ときどき文章で説明する記述式の問いを混ぜてください。
    ・数式を使うときは、必ずTeX形式（例：\$x^2 + y^2 = z^2\$）で表記してください。
    出力ルール
    ・出力はプレーンテキストのみとし、以下は禁止です。
    ・Markdown記法（例：強調など）
    ・コードブロック（バッククォートなど）
    ・絵文字
    ・各メッセージは100文字以内に簡潔にまとめてください。
    ・すべて日本語で話してください。
    ・フレンドリーな口調で話してください。
    音声読み上げ対応（重要）
    ・出力された文章は音声で読み上げられるため、読み上げ時に不自然になる表現（記号や特殊フォーマットなど）は絶対に使わないでください。
    ・普通に人と話すような自然な文章にしてください。
    守るべきこと（まとめ）
    ・最初に考えさせること。
    ・段階的に導くこと。
    ・音声で自然に聞こえること。
    ・出力は100文字以内、日本語、プレーンテキストとすること。
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

  //問題文の要約を生成
  Future<void> _getsummary() async {
    final AIsummary = await _model.generateContent([
      Content.text('''
    $inputText
    この問題文を10~15文字で要約してください．
    余計な出力はいらないので，必ず要約した文章のみ出力してください．
    ''')
    ]);

    setState(() {
      summary = AIsummary.text ?? '問題文の要約に失敗しました';
    });
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

        _getsummary();
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

  void _loadMuteSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = prefs.getBool('isMuted') ?? false;
    });
    if (_isMuted) _ttsService.toggleMute();
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
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    // アバター表示
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.14,
                      left: MediaQuery.of(context).size.width * -0.05,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Offstage(
                          offstage: _hasFocus,
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
                    ),

                    // アバター名表示
                    if (!_hasFocus)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.16,
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
                    if (!_hasFocus)
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
                        if (!_hasFocus)
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
                                                    child: TextTeX(
                                                      text: inputText,
                                                      textStyle: TextStyle(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: TextTeX(
                                      text: summary,
                                      textStyle: TextStyle(
                                        color: A_Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      // overflow: TextOverflow.ellipsis,
                                      // maxLines: 2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.zoom_out_map,
                                      color: A_Colors.black,
                                      size: MediaQuery.of(context).size.width * 0.08,
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        if (!_hasFocus)
                          SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width,
                        ),

                        // チャット部分
                        if (!openMenu)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
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
                                                  child: TextTeX(
                                                    text: chat.str,
                                                    textStyle: TextStyle(
                                                      color: chat.p == 0 ? A_Colors.white : A_Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
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
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
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
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool('isMuted', _isMuted);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: Text(
                                        _isMuted ? '現在：読み上げOFF' : '現在：読み上げON',
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
                              ),
                          ),

                        // キーボードを閉じるボタン
                        if (_hasFocus)
                          Padding(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.36,
                                height: MediaQuery.of(context).size.width * 0.14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [A_Colors.white, A_Colors.accentColor, A_Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: A_Colors.black, width: 2),
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(Icons.keyboard_hide),
                                    iconSize: MediaQuery.of(context).size.width * 0.1,
                                    color: A_Colors.black,
                                    onPressed: () async {
                                      setState(() {
                                        FocusScope.of(context).unfocus(); // キーボードを閉じる
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ),

                        // 数式入力セット
                        Container(
                            height: MediaQuery.of(context).size.width * 0.12,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [A_Colors.white, A_Colors.accentColor, A_Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: A_Colors.black, width: 2),
                            ),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (_) {
                                      return Align(
                                        alignment: Alignment.topCenter,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height * 0.4,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: A_Colors.black, width: 2),
                                              ),
                                              child: MathKeyboard(
                                                mode: false,
                                                onInsert: (latex) {
                                                  final selection = _textController.selection;
                                                  final newText = _textController.text.replaceRange(
                                                    selection.start,
                                                    selection.end,
                                                    latex,
                                                  );
                                                  setState(() {
                                                    _textController.text = newText;
                                                    _textController.selection = TextSelection.collapsed(
                                                      offset: selection.start + latex.length,
                                                    );
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  '数式・単位を入力',
                                  style: TextStyle(
                                    color: A_Colors.black,
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // 入力部分
                        if (!openMenu)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.05,
                                MediaQuery.of(context).size.height * 0.01,
                                MediaQuery.of(context).size.width * 0.05,
                                MediaQuery.of(context).size.height * 0.01
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    cursorColor: _isSending ? A_Colors.subColor : A_Colors.mainColor,
                                    controller: _textController,
                                    focusNode: _focusNode,
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
                    if (!_hasFocus)
                      Positioned(
                      top: MediaQuery.of(context).size.height * 0.28,
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
                              _ttsService.speak(feedbackMessage);

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

                              await showDialog(
                                context: context,
                                builder: (context) => MessageDialog(
                                  inputText: inputText,
                                  feedbackMessage: feedbackMessage,
                                  labels: labels,
                                  summary: summary,
                                  wrong: wrong,
                                  wrongpartans: wrongpartans,
                                  correctans: correctans,
                                ),
                                barrierDismissible: false,
                              ).then((_) => _ttsService.stop());
                              await _ttsService.speak(feedbackMessage);
                            } catch (e) {
                              await showDialog(
                                context: context,
                                builder: (context) => MessageDialog(
                                  inputText: inputText,
                                  feedbackMessage: 'フィードバックで苦手なところを確認しよう！',
                                  labels: labels,
                                  summary: summary,
                                  wrong: wrong,
                                  wrongpartans: wrongpartans,
                                  correctans: correctans,
                                ),
                                barrierDismissible: false,
                              ).then((_) => _ttsService.stop());
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

class MessageDialog extends StatelessWidget {
  final String inputText;
  final String feedbackMessage;
  final List<String> labels;
  final String summary;
  final String wrong;
  final String wrongpartans;
  final String correctans;
  final String modelPath;

  const MessageDialog({
    super.key,
    required this.inputText,
    required this.feedbackMessage,
    required this.labels,
    required this.summary,
    required this.wrong,
    required this.wrongpartans,
    required this.correctans,
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
          color: A_Colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: A_Colors.accentColor, width: 4),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                height: size.height * 0.26,
                child: SingleChildScrollView(
                  child: FeedbackBubble(feedbackText: feedbackMessage),
                ),
              ),

              //ホーム画面に戻るボタン
              SizedBox(
                width: size.width * 0.9,
                height: size.height * 0.05,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.mainColor,
                    foregroundColor: A_Colors.white,
                  ),
                  onPressed: () {
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
                  },
                  child: Text(
                    'フィードバックへ',
                    style: TextStyle(
                      color: A_Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
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
              color: A_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextTeX(
              text: feedbackText,
              textStyle: TextStyle(
                color: A_Colors.black,
                fontSize: 18,
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
