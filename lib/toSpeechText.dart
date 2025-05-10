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
  inputText = inputText.replaceAll(RegExp('[\u{2300}-\u{23FF}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{2600}-\u{26FF}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{2700}-\u{27BF}]'), '');
  /* 5桁の絵文字はエラーっぽい
  inputText = inputText.replaceAll(RegExp('[\u{1F300}-\u{1F3FF}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{1F550}-\u{1F5FF}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{1F600}-\u{1F64F}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{1F680}-\u{1F6FF}]'), '');
  inputText = inputText.replaceAll(RegExp('[\u{1F900}-\u{1F9FF}]'), '');
  */

  return inputText;
}