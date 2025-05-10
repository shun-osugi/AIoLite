import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:characters/characters.dart';

const String kVoiceVoxApiKey = 'G9705-F_55279-q';

class TTSService {
  final String apiKey;           // VoiceVoxAPIキー
  final String baseUrl;          // 合成エンドポイント
  final int speaker;             // 話者 ID
  final AudioPlayer _audio = AudioPlayer();


  bool _isMuted = false;         // ミュートON/OFF
  int  _jobId   = 0;             // レスポンスの世代管理ID

  bool get isMuted => _isMuted;

  //コンストラクタ
  TTSService({
    String? apiKey,
    this.baseUrl = 'https://api.tts.quest/v3/voicevox/synthesis',
    this.speaker = 3,
  }) : apiKey = apiKey ?? kVoiceVoxApiKey;


  /// ミュート状態切り替え
  Future<void> setMuted(bool value) async {
    _isMuted = value;
    await _audio.setVolume(_isMuted ? 0 : 1);        // 0:無音,1:通常
  }

  /// ミュートをトグル
  Future<void> toggleMute() => setMuted(!_isMuted);


  /// テキストを読み上げ（長文は自動分割）
  Future<void> speak(String text) async {
    if (_isMuted) return; //ミュートなら何もしない

    final myJob = ++_jobId; //レスポンスごとにIDを振る
    final chunks = _splitText(text); //句点3個ずつで分割

    if (chunks.isEmpty) return;

    //分割した文字列を一括で送信して届いたやつから再生 ちょっとはやくなった？
    final futures = <Future<String?>>[
      for (final chunk in chunks) _fetchAudioUrl(chunk, myJob)
    ];
    for (final future in futures) {
      // stop() されたらとめる
      if (myJob != _jobId) break;
      //stop()されてたらnullを返す
      final url = await future;
      if (url == null || myJob != _jobId) break;
      // URL再生　stop() 済みか毎回確認する
      await _playAudio(url, myJob);
    }
  }

  /// 再生停止　再生待ちのデータも強制終了させる
  Future<void> stop() async {
    _jobId++;                          //現在読み上げ中のURLのIDを更新
    await _audio.stop();               //停止
    await _audio.setReleaseMode(
      ReleaseMode.release,
    );
  }


  /// 句読点（ 。！! ？? ）が 3 つ出現するたびに分割
  List<String> _splitText(String text, {int maxLen = 1000}) {
    const punctuation = {'。', '！', '!', '？', '?'};
    final chunks = <String>[];
    var buffer   = StringBuffer();
    var count    = 0;                       // 句読点カウンタ

    for (final ch in text.characters) {
      buffer.write(ch);
      if (punctuation.contains(ch)) {
        if (++count >= 3) {                 // 句読点3つ溜まったら確定
          chunks.add(buffer.toString());
          buffer = StringBuffer();
          count  = 0;
        }
      }
      //1チャンクが長すぎるときは強制分割
      if (buffer.length >= maxLen) {
        chunks.add(buffer.toString());
        buffer = StringBuffer();
        count  = 0;
      }
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString());
    return chunks;
  }

  /// APIにリクエストする
  Future<String?> _fetchAudioUrl(String chunk, int myJob) async {
    if (myJob != _jobId) return null;             //stop()されていたら終了

    final uri = Uri.parse(
      '$baseUrl'
          '?text=${Uri.encodeComponent(chunk)}'
          '&speed=2'                                   //再生速度（v3だと変わらない？かも）
          '&speaker=$speaker'
          '&key=$apiKey',
    );

    //合成リクエスト
    final res = await http.get(uri);
    if (myJob != _jobId) return null;             //stop()されてたら終了

    if (res.statusCode != 200) {
      throw Exception('音声合成リクエスト失敗 (${res.statusCode})');
    }
    final jsonBody  = json.decode(res.body);
    final statusUrl = jsonBody['audioStatusUrl'] as String?;
    final mp3Url    = jsonBody['mp3DownloadUrl'] as String?;
    if (statusUrl == null || mp3Url == null) {
      throw Exception('API から URL を取得できませんでした');
    }

    //ポーリング
    const poll = Duration(milliseconds: 300);     //0.3 秒間隔
    const maxRetry = 100;
    for (var i = 0; i < maxRetry; i++) {
      if (myJob != _jobId) return null;           //stop()されてたら終了
      final statusRes = await http.get(Uri.parse(statusUrl));
      if (statusRes.statusCode == 200) {
        final status = json.decode(statusRes.body);
        if (status['isAudioReady'] == true) return mp3Url;
        if (status['isAudioError'] == true) {
          throw Exception('サーバ側でエンコード失敗');
        }
      }
      await Future.delayed(poll);
    }
    throw Exception('音声が生成されませんでした(タイムアウト)');
  }

  /// mp3のURLを再生。途中で stop()されたらとめる
  Future<void> _playAudio(String url, int myJob) async {
    if (myJob != _jobId) return;                  //stop()されてたら終了

    await _audio.setReleaseMode(ReleaseMode.release);
    await _audio.play(UrlSource(url));

    //stop()されてたら終了
    if (myJob != _jobId) return;
    await _audio.onPlayerComplete.first;
  }
}
