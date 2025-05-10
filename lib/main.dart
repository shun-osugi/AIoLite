import 'dart:io';

// import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:ps_hacku_osaka/ui_fblist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'api_service.dart';
import 'colors.dart';
import 'math_keyboard.dart';
import 'subject_categories.dart';
import 'terms_content.dart';
import 'ui_chat.dart';
import 'ui_chat_basic.dart';
import 'ui_result.dart';
import 'ui_statistics.dart';
import 'widget_help_dialog.dart';
import 'utility.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:url_launcher/url_launcher.dart';


bool _isBasicMode = false;

Future<void> main() async {
  await dotenv.load(); // 環境変数の読み込み
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: A_Colors.black),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoBounceScrollBehavior(),
          child: child!,
        );
      },
      home: MyHomePage(),
      routes: {
        '/home': (context) => MyHomePage(),
        '/chat': (context) => ChatPage(),
        '/chat_basic': (context) => ChatBasicPage(),
        '/result': (context) => ResultPage(),
        '/fblist': (context) => FblistPage(),
        '/stats': (context) => StatsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String str = "";
  FilePickerResult? file;

  @override
  void initState() {
    super.initState();
    _loadMode(); // モード読込
  }

  // モード読込
  Future<void> _loadMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isBasicMode')) {
      // 保存されていれば読み込み
      setState(() {
        _isBasicMode = prefs.getBool('isBasicMode') ?? true;
      });
    } else {
      // 保存されていなければダイアログ表示
      await Future.delayed(Duration.zero); // ダイアログ表示のために必要
      _showModeSelectDialog(prefs);
    }
  }

  // モード選択ダイアログの表示
  void _showModeSelectDialog(SharedPreferences prefs) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // 画面外タップでは閉じない
      barrierColor: A_Colors.white, // 背景を白に
      pageBuilder: (context, _, __) {
        return SafeArea(
          child: Stack(
            children: [
              // 上部の案内テキスト
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                left: 20,
                right: 20,
                child: Text(
                  "はじめにモードを選んでね！",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: A_Colors.black,
                  ),
                ),
              ),

              // ダイアログ本体
              Center(
                child: ModeSelectDialog(
                  isBasicMode: false,
                  onChanged: (selectedMode) async {
                    setState(() {
                      _isBasicMode = selectedMode;
                    });
                    await prefs.setBool('isBasicMode', selectedMode); // フラグ保存
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    file = null;
    Color backgroundColor = _isBasicMode ? B_Colors.mainColor : A_Colors.mainColor;
    final safeAreaPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - safeAreaPadding.top - safeAreaPadding.bottom,
                child: Stack(children: [
                  // アバター表示
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
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
                              disablePan: true,
                              cameraControls: false,
                              interactionPrompt: null,
                              interactionPromptThreshold: 0,
                              loading: Loading.eager,
                              autoPlay: true,
                              animationName: 'wait',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // アバター名表示
                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.5,
                      right: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [A_Colors.subColor, A_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: A_Colors.white, width: 4),
                          ),
                          child: Text(
                            'イオ',
                            style: TextStyle(
                              color: _isBasicMode ? B_Colors.black : A_Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ))),

                  // メインUI
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                        Image.asset('assets/logo.png', height: MediaQuery.of(context).size.height * 0.38), // ロゴ画像

                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                        // STARTボタン
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.15,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [A_Colors.subColor, A_Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: A_Colors.white, width: 5),
                            boxShadow: [
                              BoxShadow(
                                color: A_Colors.subColor.withOpacity(0.7),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              showSendDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              'START',
                              style: TextStyle(
                                color: A_Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 20,
                                    color: A_Colors.black,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                                fontSize: MediaQuery.of(context).size.width * 0.15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                        // モード切替＋全体統計＋フィードバック一覧ボタン（横並び）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // モード切替ボタン
                            Container(
                              width: _isBasicMode ? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.44,
                              height: MediaQuery.of(context).size.width * 0.16,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [A_Colors.accentColor, A_Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: A_Colors.accentColor.withOpacity(0.7),
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ModeSelectDialog(
                                      isBasicMode: _isBasicMode,
                                      onChanged: (newMode) {
                                        setState(() {
                                          _isBasicMode = newMode;
                                        });
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  _isBasicMode ? 'モードをえらぶ' : 'モード選択',
                                  style: TextStyle(
                                    color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                            //フィードバック一覧のボタン（アドバンス時のみ）
                            if (!_isBasicMode)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.16,
                                height: MediaQuery.of(context).size.width * 0.16,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [A_Colors.accentColor, A_Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: A_Colors.accentColor.withOpacity(0.7),
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.auto_stories),
                                  iconSize: MediaQuery.of(context).size.width * 0.08,
                                  color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/fblist',
                                    );
                                  },
                                ),
                              ),

                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                            // 全体統計のボタン
                            Container(
                              width: MediaQuery.of(context).size.width * 0.16,
                              height: MediaQuery.of(context).size.width * 0.16,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [A_Colors.accentColor, A_Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: A_Colors.accentColor.withOpacity(0.7),
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.bar_chart),
                                iconSize: MediaQuery.of(context).size.width * 0.1,
                                color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/stats',
                                    arguments: {
                                      'isBasicMode': _isBasicMode,
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // メニューボタン
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.02,
                    right: MediaQuery.of(context).size.width * 0.06,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [A_Colors.accentColor, A_Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: A_Colors.accentColor.withOpacity(0.7),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.menu),
                        iconSize: MediaQuery.of(context).size.height * 0.04,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                                backgroundColor: _isBasicMode ? B_Colors.background : A_Colors.background,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                        Text(
                                          'メニュー',
                                          style: TextStyle(
                                            color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                            fontSize: _isBasicMode ? MediaQuery.of(context).size.width * 0.07 : MediaQuery.of(context).size.width * 0.06,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                        // ヘルプボタン
                                        HelpButton(
                                          mode: _isBasicMode ? 'basic' : 'advanced',
                                          content: 'home',
                                        ),

                                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                        // ミュート切替ボタン
                                        MuteButton(),

                                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                        // 利用規約ボタン
                                        TermsButton(),

                                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                        // ライセンスボタン
                                        LicenseButton(),

                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// バウンススクロール禁止
class NoBounceScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(); // Androidと同じようなスクロールにする
  }
}

// モード選択ボタン（ダイアログを表示）
class ModeSelectDialog extends StatefulWidget {
  final bool isBasicMode;
  final ValueChanged<bool> onChanged;

  const ModeSelectDialog({
    Key? key,
    required this.isBasicMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ModeSelectDialog> createState() => _ModeSelectDialogState();
}

class _ModeSelectDialogState extends State<ModeSelectDialog> {
  late bool currentMode; // 選択中のモード
  final ScrollController _scrollController = ScrollController(); // スクロールコントローラ

  @override
  void initState() {
    super.initState();
    currentMode = widget.isBasicMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentMode) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      backgroundColor: A_Colors.white,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: GestureDetector(
              onHorizontalDragEnd: (modeSelect) {
                if (modeSelect.primaryVelocity != null) {
                  if (modeSelect.primaryVelocity! < 0 && currentMode) {
                    // 右→左（advancedに切り替える）
                    setState(() async {
                      await _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      currentMode = false;
                    });
                  } else if (modeSelect.primaryVelocity! > 0 && !currentMode) {
                    // 左→右（basicに切り替える）
                    setState(() async {
                      await _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      currentMode = true;
                    });
                  }
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                      // タイトル
                      Text(
                        _isBasicMode ? "モードをえらぶ" : "モード選択",
                        style: TextStyle(
                          color: _isBasicMode ? B_Colors.black : A_Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                      // モード説明部
                      SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: NeverScrollableScrollPhysics(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // モード説明部(Basic)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              decoration: BoxDecoration(
                                color: B_Colors.mainColor,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                              child: Column(
                                children: [
                                  // イメージ
                                  Image.asset(
                                    'assets/logo.png',
                                    width: MediaQuery.of(context).size.width * 0.5,
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.width * 0.07),

                                  // モード名
                                  Text(
                                    'ベーシックモード',
                                    style: TextStyle(
                                      color: A_Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.07,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),

                                  // モード説明文
                                  RubyText(
                                    [
                                      RubyTextData('学', ruby: 'まな'),
                                      RubyTextData('んだことが'),
                                      RubyTextData('身', ruby: 'み'),
                                      RubyTextData('の'),
                                      RubyTextData('回', ruby: 'まわ'),
                                      RubyTextData('りの'),
                                      RubyTextData('どんなことに'),
                                      RubyTextData('使', ruby: 'つか'),
                                      RubyTextData('われているか'),
                                      RubyTextData('知', ruby: 'し'),
                                      RubyTextData('りたい'),
                                      RubyTextData('人', ruby: 'ひと'),
                                      RubyTextData('むけのモード'),
                                      RubyTextData('たのしく'),
                                      RubyTextData('学', ruby: 'まな'),
                                      RubyTextData('んでいこう！'),
                                    ],
                                    rubyStyle: TextStyle(fontSize: 10, color: Colors.white),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: A_Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: MediaQuery.of(context).size.width * 0.03),

                            // モード説明部(Advanced)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              decoration: BoxDecoration(
                                color: A_Colors.mainColor,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                              child: Column(
                                children: [
                                  // イメージ
                                  Image.asset(
                                    'assets/logo.png',
                                    width: MediaQuery.of(context).size.width * 0.5,
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.width * 0.07),

                                  // モード名
                                  Text(
                                    'アドバンスドモード',
                                    style: TextStyle(
                                      color: A_Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.07,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),

                                  // モード説明文
                                  Text(
                                    '自分の苦手分野を知って勉強に活かしたい人向けのモード\n問題後のフィードバックで、苦手なところを確認できる！',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: A_Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      // モード選択ボタン
                      Container(
                        width: _isBasicMode ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [A_Colors.accentColor, A_Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
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
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isBasicMode', currentMode);

                            widget.onChanged(currentMode);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text(
                            _isBasicMode ? 'このモードをえらぶ' : 'このモードを選ぶ',
                            style: TextStyle(
                              color: _isBasicMode ? B_Colors.black : A_Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ↓↓↓↓↓↓ メニュー内ボタン ↓↓↓↓↓↓ //
// ヘルプを表示するボタン
class HelpButton extends StatelessWidget {
  final String mode; // モード: 'basic' or 'advanced'
  final String content; // 内容: 'home'

  const HelpButton({Key? key, required this.mode, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: _isBasicMode ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        color: _isBasicMode ? B_Colors.mainColor : A_Colors.mainColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: A_Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _isBasicMode ? B_Colors.mainColor : A_Colors.mainColor.withOpacity(0.7),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
            _showHelpDialog(context);
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          _isBasicMode ? 'つかいかた' : '使い方',
          style: TextStyle(
            color: A_Colors.white,
            fontSize: _isBasicMode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return HelpDialog(
          mode: mode,
          content: content,
        );
      },
    );
  }
}

// ミュートを設定するボタン
class MuteButton extends StatefulWidget {
  const MuteButton({Key? key}) : super(key: key);

  @override
  _MuteButtonState createState() => _MuteButtonState();
}

class _MuteButtonState extends State<MuteButton> {
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadMuteSetting();
  }

  void _loadMuteSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = prefs.getBool('isMuted') ?? false;
    });
  }

  void _toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = !_isMuted;
    });
    await prefs.setBool('isMuted', _isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final label = _isMuted
        ? (_isBasicMode ? 'いま：おんせいOFF' : '現在：音声OFF')
        : (_isBasicMode ? 'いま：おんせいON' : '現在：音声ON');

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: _isBasicMode ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [A_Colors.subColor, A_Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: _isBasicMode ? B_Colors.subColor.withOpacity(0.7) : A_Colors.black.withOpacity(0.7),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _toggleMute,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            fontSize: _isBasicMode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 利用規約を表示するボタン
class TermsButton extends StatelessWidget {
  const TermsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: _isBasicMode ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [A_Colors.subColor, A_Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: _isBasicMode ? B_Colors.subColor.withOpacity(0.7) : A_Colors.black.withOpacity(0.7),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _showTermsDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          _isBasicMode ? 'りようきやく' : '利用規約',
          style: TextStyle(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            fontSize: _isBasicMode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TermsDialog();
      },
    );
  }
}

// 利用規約ダイアログ
class TermsDialog extends StatelessWidget {
  const TermsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "利用規約",
              style: TextStyle(
                color: _isBasicMode ? B_Colors.black : A_Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // スクロール表示
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: TermsContent.articles.map((article) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 条タイトル（太字）
                          Text(
                            article['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isBasicMode ? B_Colors.black : A_Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),

                          //15条のリンクを飛べるように
                          article['title'] == '第15条（その他）'
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '本規約に関するお問い合わせは、以下の連絡先までお願いいたします。',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '【メールアドレス】miakks2025@gmail.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final Uri url = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSeFVMT8ZYzBv12eJqaMCiSQTFwKL4v2EHxW2dhgp4JaPdOj_g/viewform?pli=1');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    print('Could not launch $url');
                                  }
                                },
                                child: Text(
                                  '【お問い合わせフォーム】',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '以上',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            article['body'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isBasicMode ? B_Colors.black : A_Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "閉じる",
                  style: TextStyle(
                    fontSize: 18,
                    color: A_Colors.subColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ライセンスを表示するボタン
class LicenseButton extends StatelessWidget {
  const LicenseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: _isBasicMode ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [A_Colors.subColor, A_Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isBasicMode ? B_Colors.black : A_Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: _isBasicMode ? B_Colors.subColor.withOpacity(0.7) : A_Colors.black.withOpacity(0.7),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          showLicensePage(
            context: context,
            applicationName: 'AIoLite',
            applicationVersion: '1.0.0',
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
          'ライセンス',
          style: TextStyle(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            fontSize: _isBasicMode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
// ↑↑↑↑↑↑ メニュー内ボタン ↑↑↑↑↑↑ //

// ↓↓↓↓↓↓ 送信方法選択ボタン ↓↓↓↓↓↓ //
// カメラを起動するボタン
class CameraButton extends StatelessWidget {
  final Function(String) onImagePicked;

  const CameraButton({Key? key, required this.onImagePicked}) : super(key: key);

  Future<void> file_to_text(File putfile, BuildContext context) async {
    //contextはmain画面のcontext
    try {
      //画像編集
      final data = await putfile.readAsBytes();
      ImageEditor.setI18n({
        //言語翻訳
        'Crop': '切り取り',
        'Save': '保存',
        'Freeform': 'フリーフォーム',
      });
      //画像編集画面
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCropper(
            image: data, // <-- Uint8List of image
          ),
        ),
      );
      await putfile.writeAsBytes(editedImage);
      final inputImage = InputImage.fromFile(putfile);
      // TextRecognizerの初期化（scriptで日本語の読み取りを指定しています※androidは日本語指定は失敗するのでデフォルトで使用すること）
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
      // 画像から文字を読み取る（OCR処理）
      final recognizedText = await textRecognizer.processImage(inputImage);

      onImagePicked(recognizedText.text);
      textRecognizer.close();
    } catch (e) {
      print('ファイル編集エラー');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    BuildContext currentContext = context; //contextの保持
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        /*Step 1:Pick image*/
        //Install image_picker
        //Import the corresponding library
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text(
                  '選択：',
                  style: TextStyle(
                    color: _isBasicMode ? B_Colors.black : A_Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  SimpleDialogOption(
                    child: Text(
                      '写真ライブラリから選択',
                      style: TextStyle(
                        color: _isBasicMode ? B_Colors.black : A_Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      FilePickerResult? file = await FilePicker.platform.pickFiles(
                        type: FileType.image, //写真ファイルのみ抽出
                        // allowedExtensions: ['png', 'jpeg'], // ピックする拡張子を限定できる。
                      );

                      if (file != null) {
                        String filename = file.files.first.name;
                        print(filename);

                        // File型に変換し文字に変換
                        file_to_text(File(file.files.first.path!), currentContext);
                      }
                    },
                  ),
                  SimpleDialogOption(
                    child: Text(
                      '写真を撮影',
                      style: TextStyle(
                        color: _isBasicMode ? B_Colors.black : A_Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      ImagePicker picker = ImagePicker();
                      //写真を撮る
                      final pickedFile = await picker.pickImage(source: ImageSource.camera);

                      if (pickedFile != null) {
                        print(pickedFile.path);
                        // File型に変換し文字に変換
                        file_to_text(File(pickedFile.path), currentContext);
                      }
                    },
                  )
                ],
              );
            });
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: A_Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _isBasicMode ? B_Colors.black : A_Colors.black,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt,
          size: screenWidth * 0.15,
          color: _isBasicMode ? B_Colors.black : A_Colors.black,
        ),
      ),
    );
  }
}

// 音声入力を行うボタン
class AudioButton extends StatefulWidget {
  final Function(String) onTextPicked;

  const AudioButton({Key? key, required this.onTextPicked}) : super(key: key);

  @override
  _AudioButtonState createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  // 音声認識開始・停止の制御
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            var speechText = result.recognizedWords;
            print(speechText);
            widget.onTextPicked(speechText); // 音声認識結果をコールバックに渡す
          });
        },
      );
    } else {
      print("失敗");
      widget.onTextPicked("音声認識の初期化に失敗しました");
    }
  }

  //音声認識停止
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (_isListening) {
          _stopListening(); // すでに認識中なら停止
          print("停止");
        } else {
          _startListening(); // 音声認識を開始
          print("開始");
        }
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: A_Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _isBasicMode ? B_Colors.black : A_Colors.black,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.mic, // 音声認識中は停止ボタン、認識していないときはマイクボタン
          size: screenWidth * 0.15,
          color: _isBasicMode ? B_Colors.black : A_Colors.black,
        ),
      ),
    );
  }
}

// 空の文字列を返すボタン
class EmptyTextButton extends StatelessWidget {
  final Function(String) onTextPicked;

  const EmptyTextButton({Key? key, required this.onTextPicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        onTextPicked("");
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: A_Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: _isBasicMode ? B_Colors.black : A_Colors.black,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _isBasicMode ? B_Colors.black : A_Colors.black,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.text_snippet_outlined,
          size: screenWidth * 0.15,
          color: _isBasicMode ? B_Colors.black : A_Colors.black,
        ),
      ),
    );
  }
}
// ↑↑↑↑↑↑ 送信方法選択ボタン ↑↑↑↑↑↑ //

// 問題の送信方法を選択するダイアログ
void showSendDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => SendDialog(),
  );
}

class SendDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      backgroundColor: _isBasicMode ? B_Colors.background : A_Colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      _isBasicMode ? "もんだいをおくる" : "問題を送る",
                      style: TextStyle(color: _isBasicMode ? B_Colors.black : A_Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  // アイコンオプションを並べる
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // マイクボタン
                      _sendOption(context, AudioButton(onTextPicked: (String text) {
                        print("音声認識: $text");
                        if (text.isNotEmpty) {
                          Navigator.pop(context);
                          showEditDialog(context, text);
                        }
                      }), _isBasicMode ? "こえ" : "音声入力"),
                      _sendOption(context, CameraButton(
                        onImagePicked: (String text) {
                          if (text.isNotEmpty) {
                            Navigator.pop(context);
                            showEditDialog(context, text);
                          }
                        },
                      ), _isBasicMode ? "しゃしん" : "画像入力"),
                      _sendOption(context, EmptyTextButton(
                        onTextPicked: (String text) {
                          Navigator.pop(context);
                          showEditDialog(context, text);
                        },
                      ), _isBasicMode ? "もじ" : "テキスト"),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // 左上の戻るボタン
            Positioned(
              top: 24,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: _isBasicMode ? B_Colors.black : A_Colors.black, size: 40),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendOption(BuildContext context, Widget sendButton, String label) {
    return Column(
      children: [
        sendButton,
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: _isBasicMode ? B_Colors.black : A_Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// 問題を編集するダイアログ
void showEditDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    // barrierDismissible: false,//barrierDismissibleをfalseにすると、戻るボタン以外をクリックしても反応しません
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                left: 0,
                right: 0,
                child: EditDialog(editedText: text),
              ),
            ],
          );
        },
      );
    },
  );
}

class EditDialog extends StatefulWidget {
  final String editedText;

  const EditDialog({Key? key, required this.editedText}) : super(key: key);

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.editedText);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      backgroundColor: _isBasicMode ? B_Colors.background : A_Colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _hasFocus = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).requestFocus(_focusNode);
              _textController.selection = TextSelection.collapsed(
                offset: _textController.text.length,
              );
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isBasicMode ? "もんだいをかく" : "問題を編集",
                      style: TextStyle(color: _isBasicMode ? B_Colors.black : A_Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        color: A_Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isBasicMode ? B_Colors.black : A_Colors.black,
                          width: 2,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: _hasFocus
                            ? TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                style: TextStyle(
                                  color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                minLines: null,
                                maxLines: null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: A_Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.all(12),
                                child: TextTeX(
                                  text: _textController.text,
                                  textStyle: TextStyle(
                                    color: _isBasicMode ? B_Colors.black : A_Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            String editedText = _textController.text;
                            Navigator.pop(context);
                            if (_isBasicMode) {
                              Navigator.pushNamed(
                                context,
                                '/chat_basic',
                                arguments: {
                                  'inputText': editedText,
                                },
                              );
                            } else {
                              showLabelDialog(context, editedText);
                            }
                          },
                          child: Text(
                            _isBasicMode ? "はじめる →" : "次へ →",
                            style: TextStyle(color: _isBasicMode ? B_Colors.black : A_Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 数式入力セット
              if (_hasFocus)
                Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          A_Colors.white,
                          A_Colors.accentColor,
                          A_Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border:
                      Border.all(color: A_Colors.black, width: 2),
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            barrierColor: Colors.transparent,
                            builder: (_) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: MathKeyboard(
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
                                  },
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
                ),

              // 左上の戻るボタン
              Positioned(
                top: 24,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: _isBasicMode ? B_Colors.black : A_Colors.black, size: 40),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showSendDialog(context);
                  },
                ),
              ),

              // ×ボタン(キーボードを閉じる用)
              _focusNode.hasFocus
                  ? Positioned(
                      top: 24,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        iconSize: MediaQuery.of(context).size.width * 0.08,
                        onPressed: () {
                          _focusNode.unfocus();
                          setState(() {});
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

// ラベルを編集するダイアログ
void showLabelDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => LabelDialog(
      editedText: text,
    ),
  );
}

class LabelDialog extends StatefulWidget {
  final String editedText;

  const LabelDialog({Key? key, required this.editedText}) : super(key: key);

  @override
  _LabelDialogState createState() => _LabelDialogState();
}

class _LabelDialogState extends State<LabelDialog> {
  List<String> _suggestedLabels = []; // 推奨ラベル
  List<String?> selectedSubjects = List.filled(4, null); // 教科ドロップダウン選択
  List<String?> selectedCategories = List.filled(4, null); // 分類ドロップダウン選択
  bool _isLoading = false; // ローディング状態を管理する変数
  bool _isBasicMode = false;

  @override
  void initState() {
    super.initState();
    // 初期化時にテキストを元にラベルを取得
    _getSuggestedLabels(widget.editedText);
    // モード読込
    _loadMode();
  }

  void _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBasicMode = prefs.getBool('isBasicMode') ?? true;
    });
  }

  // 推奨ラベルを取得
  Future<void> _getSuggestedLabels(String inputText) async {
    if (inputText.isEmpty) return;

    try {
      List<String> labels = await ApiService.classifyText(inputText);
      setState(() {
        _suggestedLabels = labels;
      });

      // ラベルを順番に設定
      _setDropdownValues();

      // ログ出力
      debugPrint("推奨ラベル: $labels");
    } catch (e) {
      debugPrint("エラー: $e");
    }
  }

  // 推奨ラベルを元にドロップダウンに順番に値をセット
  void _setDropdownValues() {
    if (_suggestedLabels.isEmpty) return;

    setState(() {
      for (int i = 0; i < _suggestedLabels.length && i < 4; i++) {
        String label = _suggestedLabels[i];

        List<String> parts = label.split(" - ");
        if (parts.length == 2) {
          selectedSubjects[i] = parts[0]; // 教科
          selectedCategories[i] = parts[1]; // 分類
        }
      }
    });
  }

  List<Map<String?, String?>> _getSortedLabelPairs() {
    List<Map<String?, String?>> pairs = [];

    // ペアを収集
    for (int i = 0; i < 4; i++) {
      pairs.add({
        'subject': selectedSubjects[i],
        'category': selectedCategories[i],
      });
    }

    // nullのペアを後ろに詰める
    pairs.sort((a, b) {
      bool aIsNull = a['subject'] == null && a['category'] == null;
      bool bIsNull = b['subject'] == null && b['category'] == null;
      return aIsNull == bIsNull ? 0 : (aIsNull ? 1 : -1);
    });

    return pairs;
  }

  // 教科と分類のドロップダウンペア
  Widget buildDropdownPair(int index) {
    final selectedPairs = List.generate(4, (i) {
      if (selectedSubjects[i] != null && selectedCategories[i] != null) {
        return "${selectedSubjects[i]} - ${selectedCategories[i]}";
      }
      return null;
    }).whereType<String>().toList();
    return Row(
      children: [
        Container(
          width: 100,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: A_Colors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                "未選択",
                style: TextStyle(color: A_Colors.black),
              ),
              value: selectedSubjects[index],
              iconEnabledColor: A_Colors.black,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubjects[index] = newValue;
                  selectedCategories[index] = null; // 教科変更時に分類もリセット
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    "未選択",
                    style: TextStyle(color: A_Colors.black),
                  ), // デフォルトのnull選択肢
                ),
                ...subjectCategories.keys.toSet().toList().map((String subject) {
                  // 重複を削除
                  print("DropdownMenuItem value: $subject"); // デバッグ出力
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(
                      subject,
                      style: TextStyle(color: A_Colors.black),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: A_Colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  "未選択",
                  style: TextStyle(color: A_Colors.black),
                ),
                value: selectedCategories[index],
                iconEnabledColor: A_Colors.black,
                onChanged: selectedSubjects[index] == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedCategories[index] = newValue;
                        });
                      },
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      "未選択",
                      style: TextStyle(color: A_Colors.black),
                    ), // デフォルトのnull選択肢
                  ),
                  ...(subjectCategories[selectedSubjects[index]] ?? []).where((category) {
                    final selectedPairs = List.generate(4, (i) {
                      if (selectedSubjects[i] != null && selectedCategories[i] != null) {
                        return "${selectedSubjects[i]} - ${selectedCategories[i]}";
                      }
                      return null;
                    }).whereType<String>().toList();

                    final currentPair = "${selectedSubjects[index]} - $category";
                    return !selectedPairs.contains(currentPair) || selectedCategories[index] == category;
                  }).map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(color: A_Colors.black),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ダイアログ部分
  @override
  Widget build(BuildContext context) {
    List<Map<String?, String?>> sortedPairs = _getSortedLabelPairs();
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      backgroundColor: A_Colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              // テキスト編集フィールド
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ラベルを編集",
                    style: TextStyle(color: A_Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // 4つのドロップダウンペアを縦に並べる
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: A_Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: List.generate(4, (i) {
                        selectedSubjects[i] = sortedPairs[i]['subject'];
                        selectedCategories[i] = sortedPairs[i]['category'];
                        return i == 0
                            ? buildDropdownPair(i)
                            : Column(
                          children: [
                            Divider(color: A_Colors.black),
                            buildDropdownPair(i),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          List<String> editedLabels = [];
                          for (int i = 0; i < 4; i++) {
                            if (selectedSubjects[i] != null && selectedCategories[i] != null) {
                              editedLabels.add("${selectedSubjects[i]} - ${selectedCategories[i]}");
                            }
                          }

                          // ここでラベルを保存
                          if (widget.editedText.isNotEmpty && editedLabels.isNotEmpty) {
                            ApiService.storeText(widget.editedText, editedLabels).then((_) => print("テキストとラベルを保存しました")).catchError((e) => print("保存エラー: $e"));
                          } else {
                            print("テキストまたはラベルが空です");
                          }

                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              'inputText': widget.editedText,
                              'labels': editedLabels,
                            },
                          );
                        },
                        child: Text(
                          "開始 →",
                          style: TextStyle(color: A_Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 左上の戻るボタン
            Positioned(
              top: 24,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: A_Colors.black, size: 40),
                onPressed: () {
                  Navigator.of(context).pop();
                  showEditDialog(context, widget.editedText);
                },
              ),
            ),
            // ローディングインジケーター
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // 背景を半透明に
                  child: Center(
                    child: CircularProgressIndicator(), // ローディングインジケーター
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
