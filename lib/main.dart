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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () async {
                /*Step 1:Pick image*/
                //Install image_picker
                //Import the corresponding library

                file = await FilePicker.platform.pickFiles(
                  type:  FileType.image, //写真ファイルのみ抽出
                  // allowedExtensions: ['png', 'jpeg'], // ピックする拡張子を限定できる。
                );
                // Web上での実行時の処理

                filename = file!.files.first.name;
                print(filename);

                // File型に変換
                File putfile = File(file!.files.first.path!);
                // ml-kitで画像を読み込む
                final inputImage = InputImage.fromFile(putfile);
                // TextRecognizerの初期化（scriptで日本語の読み取りを指定しています※androidは日本語指定は失敗するのでデフォルトで使用すること）
                final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
                // 画像から文字を読み取る（OCR処理）
                final recognizedText = await textRecognizer.processImage(inputImage);
                str = recognizedText.text;
                // print('OCRで取得したテキスト：${recognizedText.text}');

                setState((){});
              },
              icon: const Icon(Icons.camera_alt)
            ),
            str != ""
            ? Text(str) //ファイルを選択したならファイル名を表示
            : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.navigate_next),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
