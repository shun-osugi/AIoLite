import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TextTeX extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const TextTeX({
    Key? key,
    required this.text,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //$..$表現はr''にし，flutterが使える形に変換
    // String texttex = text.replaceAllMapped(RegExp(r"(?<!\\)\$(.+?)(?<!\\)\$", dotAll: true), (match) {
    //   return 'r"${match.group(1)}"';
    // });
    String texttex = text;

    final List<InlineSpan> spans = [];
    final RegExp pattern = RegExp(r"(?<!\\)\$(.+?)(?<!\\)\$", dotAll: true);//texの構文
    int currentIndex = 0;//現在の場所

    for (final match in pattern.allMatches(texttex)) {
      // texが見つかるところまでは，通常のテキスト部分
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: texttex.substring(currentIndex, match.start),
          style: textStyle,
        ));
      }

      // TeX部分 (r'...') の中身を取り出す
      final String tex = match.group(1)!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          tex,
          mathStyle: MathStyle.text,
          textStyle: textStyle,
        ),
      ));

      currentIndex = match.end;//texの部分まで探索終了
    }

    // 残りの通常文字列
    if (currentIndex < texttex.length) {
      spans.add(TextSpan(
        text: texttex.substring(currentIndex),
        style: textStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}