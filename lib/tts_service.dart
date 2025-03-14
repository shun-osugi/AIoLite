import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  // テキストを読み上げるメソッド
  Future<void> speak(String text) async {
    // 言語を日本語に設定
    await _flutterTts.setLanguage("ja-JP");

    // 音量/スピード/ピッチの設定
    await _flutterTts.setVolume(1.0);   // 音量(0.0-1.0)
    await _flutterTts.setSpeechRate(0.5); // スピード(0.0-1.0) デフォルト1.0
    await _flutterTts.setPitch(1.0);    // ピッチ(0.5-2.0) デフォルト1.0

    // 読み上げ
    await _flutterTts.speak(text);
  }

  // 読み上げを停止するメソッド
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
