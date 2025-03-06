import 'package:flutter/material.dart';

// import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ui_chat.dart';
import 'ui_result.dart';

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
        body: Stack(
            children: [
              // ヘルプボタン
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, right: 20), // 上と右に余白を設定
                  child: IconButton(
                    icon: Icon(Icons.help_outline, size: 50),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('ヘルプ'),
                            content: Text('ここにヘルプの内容を記載'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('閉じる'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // メインUI
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Image.asset('assets/logo.png', height: MediaQuery.of(context).size.height * 0.2), // ロゴ画像
                      DifficultyDropdown(),
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.pink[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text('アバター', style: TextStyle(fontSize: 20)),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.refresh, size: 50),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.mic, size: 30),
                                  onPressed: () {
                                    // マイクボタンの処理（音声入力など）
                                  },
                                ),
                                CameraButton(
                                  onImagePicked: (String text) {
                                    setState(() {
                                      str = text;
                                      // print('OCRで取得したテキスト：${text}');
                                    });
                                  },
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.black,
                                )
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '問題を送って始める',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (str.isNotEmpty)
                        Text(str, style: TextStyle(fontSize: 16)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat');
                          },
                        child: Text('START', style: TextStyle(fontSize: 18)),
                      ),
                      SizedBox (height: MediaQuery.of(context).size.height * 0.05,)
                    ],
                  ),
                ),
              ),
            ]
        )
    );
  }
}

class CameraButton extends StatelessWidget {
  final Function(String) onImagePicked;
  const CameraButton({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        /*Step 1:Pick image*/
        //Install image_picker
        //Import the corresponding library

        FilePickerResult? file = await FilePicker.platform.pickFiles(
          type:  FileType.image, //写真ファイルのみ抽出
          // allowedExtensions: ['png', 'jpeg'], // ピックする拡張子を限定できる。
        );
        // Web上での実行時の処理

        if (file != null) {
          String filename = file.files.first.name;
          print(filename);

          // File型に変換
          File putfile = File(file.files.first.path!);
          // ml-kitで画像を読み込む
          final inputImage = InputImage.fromFile(putfile);
          // TextRecognizerの初期化（scriptで日本語の読み取りを指定しています※androidは日本語指定は失敗するのでデフォルトで使用すること）
          final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
          // 画像から文字を読み取る（OCR処理）
          final recognizedText = await textRecognizer.processImage(inputImage);

          onImagePicked(recognizedText.text);
        }
      },
        icon: const Icon(Icons.camera_alt, size: 30,)
    );
  }
}

class DifficultyDropdown extends StatefulWidget {
  @override
  _DifficultyDropdownState createState() => _DifficultyDropdownState();
}

class _DifficultyDropdownState extends State<DifficultyDropdown> {
  String selectedDifficulty = '○○';
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedDifficulty,
      style: TextStyle(fontSize: 20, color: Colors.black),
      items: ['○○', '△△', '□□']
          .map((level) => DropdownMenuItem(
          value: level,
          child: Text(
              '難易度: $level',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedDifficulty = value!;
        });
      },
    );
  }
}
