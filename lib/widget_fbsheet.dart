import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';

class FbSheet extends StatefulWidget {  
  final List<String> labels; //ラベル
  final String problem;      //問題文
  final String wrong;        //間違えてた部分
  final String wrongpartans; //間違えてた部分の正しい解き方
  final String correctans;   //それの正しい解き方

  const FbSheet({
    super.key,
    this.labels = const [],
    this.problem = "none",
    this.wrong = "none",
    this.wrongpartans = "none",
    this.correctans = "none",
    });

  @override
  State<FbSheet> createState() => _FbSheetState();
}

class _FbSheetState extends State<FbSheet> {
  // フィードバック1
  String fbTitle1 = "aaa"; // 問題文(ラベル)
  String fbText1 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  // フィードバック2
  String fbTitle2 = "bbb"; // 間違えてた部分
  String fbText2 = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  // フィードバック3
  String fbTitle3 = "ccc"; // それの正しい解き方
  String fbText3 = "cccccccccccccccccccccccccccccccc";
  // 内容が空だった場合のテキスト
  String fbErrorText = "。。。";

  @override
  void initState() {
    super.initState();
    fbText1 = widget.wrong; //仮設定
    fbText2 = widget.wrongpartans;
    fbText3 = widget.correctans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A_Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          // ▼ ---------- フィードバック1 ---------- ▼ //
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: A_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // タイトル
                Center(
                  child: Text(
                    fbTitle1,
                    style: TextStyle(
                        color: A_Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // テキスト枠
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: A_Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // テキスト文章
                  child: Text(
                    fbText1,
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ▲ ---------- フィードバック1 ---------- ▲ //

          // ▼ ---------- フィードバック2 ---------- ▼ //
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: A_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // タイトル
                Center(
                  child: Text(
                    fbTitle2,
                    style: TextStyle(
                        color: A_Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // テキスト枠
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: A_Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // テキスト文章
                  child: Text(
                    fbText2,
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ▲ ---------- フィードバック2 ---------- ▲ //

          // ▼ ---------- フィードバック3 ---------- ▼ //
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: A_Colors.subColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // タイトル
                Center(
                  child: Text(
                    fbTitle3,
                    style: TextStyle(
                        color: A_Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // テキスト枠
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: A_Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // テキスト文章
                  child: Text(
                    fbText3,
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ▲ ---------- フィードバック3 ---------- ▲ //
        ],
      )
    );
  }
}
