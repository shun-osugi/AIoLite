import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:characters/characters.dart';

const String kVoiceVoxApiKey = 'G9705-F_55279-q';

/// VoiceVox でテキストを読み上げるサービス
class TTSService {
  // ------------------------ 基本設定 ------------------------
  final String apiKey;                // VoiceVox APIキー
  final String baseUrl;               // 合成エンドポイント
  final int speaker;                  // 話者 ID
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  /// ミュート状態を直接指定（UI のスイッチ用）
  Future<void> setMuted(bool value) async {
    _isMuted = value;
    await _audioPlayer.setVolume(_isMuted ? 0 : 1); // 0:無音, 1:通常
  }

  /// ミュートするか否か
  Future<void> toggleMute() => setMuted(!_isMuted);

  TTSService({
    String? apiKey,
    this.baseUrl = 'https://api.tts.quest/v3/voicevox/synthesis',
    this.speaker = 3,
  }) : apiKey = apiKey ?? kVoiceVoxApiKey;

  /// 長文は自動で分割→順番に読み上げ
  Future<void> speak(String text) async {
    if (_isMuted) return;
    // 1. 句読点 3 つごとに分割
    final chunks = _splitText(text);
    for (final chunk in chunks) {
      if (chunk.trim().isEmpty) continue;
      final mp3Url = await _fetchAudioUrl(chunk);
      await _playAudio(mp3Url);
    }
  }

  /// 再生停止
  Future<void> stop() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.stop();
  }



  /// 句読点（ 。  ！ ？ ! ? ）が 3 つ出現するたびに分割する
  List<String> _splitText(String text, {int maxLen = 1000}) {
    const punctuation = {'。',  '！', '!', '？', '?'};

    final chunks = <String>[];
    var buffer   = StringBuffer();
    var count    = 0;               // 句読点カウンタ

    for (final char in text.characters) {
      buffer.write(char);

      if (punctuation.contains(char)) {
        count++;                    // 句読点を数える
        if (count >= 3) {           // 3 つたまったらチャンク確定
          chunks.add(buffer.toString());
          buffer = StringBuffer();
          count  = 0;
          continue;
        }
      }

      // 安全用：異常に長くなったら強制分割
      if (buffer.length >= maxLen) {
        chunks.add(buffer.toString());
        buffer = StringBuffer();
        count  = 0;
      }
    }

    if (buffer.isNotEmpty) chunks.add(buffer.toString());
    return chunks;
  }

  /// chunk を合成 → audioStatusUrl で isAudioReady==true までポーリング
  Future<String> _fetchAudioUrl(String chunk) async {
    final encoded = Uri.encodeComponent(chunk);
    final uri = Uri.parse(
      '$baseUrl?text=$encoded&speed=2&speaker=$speaker&key=$apiKey',

    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('音声合成リクエスト失敗 (${res.statusCode})');
    }

    final jsonBody = json.decode(res.body);
    final statusUrl = jsonBody['audioStatusUrl'] as String?;
    final mp3Url    = jsonBody['mp3DownloadUrl'] as String?;
    if (statusUrl == null || mp3Url == null) {
      throw Exception('API から URL を取得できませんでした');
    }

    // ----- ポーリング -----
    const pollInterval = Duration(milliseconds: 500);
    const maxRetry = 60; // 0.5s × 60 = 30 秒でタイムアウト
    for (var i = 0; i < maxRetry; i++) {
      final statusRes = await http.get(Uri.parse(statusUrl));
      if (statusRes.statusCode == 200) {
        final status = json.decode(statusRes.body);
        if (status['isAudioReady'] == true) return mp3Url;
        if (status['isAudioError'] == true) {
          throw Exception('サーバ側でエンコード失敗');
        }
      }
      await Future.delayed(pollInterval);
    }
    throw Exception('タイムアウト：音声が生成されませんでした');
  }

  /// mp3Url を再生し、再生完了を await
  Future<void> _playAudio(String mp3Url) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.play(UrlSource(mp3Url));

    // 再生完了まで待機
    await _audioPlayer.onPlayerComplete.first;
  }
}
