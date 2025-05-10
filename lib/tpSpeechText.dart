//読み上げ用テキスト変換関数
String toSpeechText(String inputText) {
  // 記号
  inputText = inputText.replaceAll(r'$', '');
  inputText = inputText.replaceAll(r'(', '');
  inputText = inputText.replaceAll(r')', '');
  inputText = inputText.replaceAll(r'（', '');
  inputText = inputText.replaceAll(r'）', '');
  inputText = inputText.replaceAll(RegExp(r'[.…]{2,}'), ''); // 3点
  inputText = inputText.replaceAll(RegExp(r'"'), ''); // ””
  inputText = inputText.replaceAll(RegExp(r':'), ''); // コロン
  inputText = inputText.replaceAll(RegExp(r'：'), ''); // コロン(全角)
  inputText = inputText.replaceAll(RegExp(r'\*'), ''); // アスタリスク

  // 理科の単位(もっと上手に指定できそう)
  inputText = inputText.replaceAll(RegExp(r'm^2'), '平方メートル');
  inputText = inputText.replaceAll(RegExp(r'm^3'), '立法メートル');
  inputText = inputText.replaceAll(RegExp(r'cm^2'), '平方センチメートル');
  inputText = inputText.replaceAll(RegExp(r'cm^3'), '立法センチメートル');
  inputText = inputText.replaceAll(RegExp(r'm/s'), 'メートル毎秒');
  inputText = inputText.replaceAll(RegExp(r'm/s^2'), 'メートル毎秒毎秒');
  inputText = inputText.replaceAll(RegExp(r'm/s'), 'センチメートル毎秒');
  inputText = inputText.replaceAll(RegExp(r'm/s^2'), 'センチメートル毎秒毎秒');
  inputText = inputText.replaceAll(RegExp(r'mol/L'), 'モル毎リットル');

  // 数学
  inputText = inputText.replaceAllMapped(RegExp(r'([a-zA-Z0-9])\^([a-zA-Z0-9])'), (m) => '${m[1]}${m[2]}乗');
  inputText = inputText.replaceAllMapped(RegExp(r'([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)'), (m) => '${m[2]}分の${m[1]}');
  inputText = inputText.replaceAll(r'=', 'イコール');
  inputText = inputText.replaceAll(r'-', 'マイナス');

  // ~形
  inputText = inputText.replaceAll('現在形', '現在けい');
  inputText = inputText.replaceAll('過去形', '過去けい');
  inputText = inputText.replaceAll('進行形', '進行けい');

  // www → 笑
  inputText = inputText.replaceAll(RegExp(r'\b(w{2,})\b', caseSensitive: false), '笑');

  // 絵文字の削除
  final symbolEmojiRegex = RegExp(
    r'''
  (?:[\u2300-\u23FF]|
     [\u2600-\u26FF]|
     [\u2700-\u27BF]|
     \u{1F300}-\u{1F5FF}|
     \u{1F600}-\u{1F64F}|
     \u{1F680}-\u{1F6FF}|
     \u{1F900}-\u{1F9FF}
    )
  ''',
    unicode: true,
  );
  inputText = inputText.replaceAll(symbolEmojiRegex, '');

  return inputText;
}