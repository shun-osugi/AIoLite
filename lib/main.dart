import 'package:flutter/material.dart';

// import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'ui_chat.dart';
import 'ui_result.dart';
import 'colors.dart';
import 'subject_categories.dart';
import 'api_service.dart';
import 'terms_content.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      routes: {
        '/home': (context) => MyHomePage(),
        '/chat': (context) => ChatPage(),
        '/result': (context) => ResultPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String str = ""; //入力する文字列
  FilePickerResult? file;
  String filename = ""; //写真の名前

  @override
  Widget build(BuildContext context) {
    file = null;
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // アバター表示
            Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
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
                        animationName: 'wait',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // メインUI
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Image.asset(
                      'assets/logo.png',
                      height: MediaQuery.of(context).size.height * 0.4,
                    ), // ロゴ画像
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                    // STARTボタン
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.subColor, AppColors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.white, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.subColor.withOpacity(0.7),
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
                          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                        ),
                        child: Text(
                          'START',
                          style: TextStyle(
                            color: AppColors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: AppColors.black,
                                offset: Offset(0, 0),
                              ),
                            ],
                            fontSize: MediaQuery.of(context).size.width * 0.15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    //DifficultyDropdown(), // 難易度選択
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 40,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  TermsButton(),   // 利用規約を表示するボタン
                  SizedBox(width: 16),
                  HelpButton(),    // ヘルプを表示するボタン（既存）
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//利用規約ボタン
class TermsButton extends StatelessWidget {
  const TermsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.info_outline, size: 50, color: AppColors.white),
      onPressed: () {
        _showTermsDialog(context);
      },
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

class TermsDialog extends StatelessWidget {
  const TermsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // `terms_content.dart` からリストを取得
    final articles = TermsContent.articles;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "利用規約",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // 条項リストを順に表示
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: articles.map((article) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // タイトル（太字）
                        Text(
                          article['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        // 本文
                        Text(
                          article['body'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // 閉じるボタン
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "閉じる",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.subColor,
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
//ヘルプボタン
class HelpButton extends StatelessWidget {
  const HelpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.help_outline, size: 50, color: AppColors.white),
      onPressed: () {
        _showHelpDialog(context);
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return HelpDialog();
      },
    );
  }
}

class HelpDialog extends StatefulWidget {
  @override
  _HelpDialogState createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // ヘルプ内容
  final List<Map<String, String>> helpPages = [
    {
      "image": "assets/help1.png",
      "head": "まずは、画面下のSTARTボタンを押して、問題の送信方法を選ぼう！",
      "text":
      "送信方法は、音声入力、画像入力(画像ファイルからor写真を撮影)、テキスト入力から選べます。\n音声や画像を送信した場合は、自動でテキストに変換されます。"
    },
    {
      "image": "assets/help2.png",
      "head": "問題の送信方法を選んだら、問題文の編集をしよう！",
      "text": "テキスト入力の場合はここで入力、音声や画像で入力した場合は、問題文を修正できます。"
    },
    {
      "image": "assets/help3.png",
      "head": "問題文を決定したら、ラベルの編集をしよう！",
      "text":
      "\n送信された問題文を元に、自動でいくつかのラベルが選択されます。問題にあったラベルを編集・追加してください。\n最大4つのラベルを選択することができます。"
    },
    {
      "image": "assets/help4.png",
      "head": "ラベルを決定したら、AIとのチャットを開始！\nAIの質問に答えながら、問題を解いていこう！",
      "text":
      "下のテキストボックスからAIへメッセージを送信すると、AIから返事が返ってきます。\n問題が解けたら、右上のボタンでチャットが終了できます。"
    },
    {
      "image": "assets/help5.png",
      "head":
      "チャットを終えると、AIからのフィードバックと類題が表示されるよ！\nフィードバックを参考にして、類題から次の問題を始めてみよう！",
      "text":
      "類題を選択することで、新たにAIとのチャットを開始できます。"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("使い方",
                style: TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: helpPages.length,
                physics: AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    // スクロールを可能にする
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              helpPages[index]['image']!,
                              height:
                              MediaQuery.of(context).size.height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.03),
                          Text(
                            helpPages[index]['head'].toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.02),
                          Text(
                            helpPages[index]['text'].toString(),
                            textAlign: TextAlign.left,
                            style:
                            TextStyle(color: AppColors.black, fontSize: 14),
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // インジケーター（現在のページを示すドット）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(helpPages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.subColor
                        : AppColors.black,
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage > 0
                      ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  child: Text("← 戻る", style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: _currentPage < helpPages.length - 1
                      ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : () {
                    Navigator.pop(context); // 最後のページならダイアログを閉じる
                  },
                  child: Text(
                      _currentPage < helpPages.length - 1 ? "次へ →" : "閉じる",
                      style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// 以下、カメラボタン・音声ボタン・テキストボタン・難易度ドロップダウン、
// 送信方法選択ダイアログ、問題編集ダイアログ、ラベル編集ダイアログなどは変更なし。
// ...
