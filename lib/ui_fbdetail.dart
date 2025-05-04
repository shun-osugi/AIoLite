import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:ps_hacku_osaka/widget_fbsheet.dart';
import 'subject_categories.dart';

class feedback {
  //フィードバック一つのデータ
  int id; //id
  List<String> subject; //教科
  List<String> field; //分野
  String problem; //問題文
  String summary; //問題文の要約
  String wrong; //間違えてた部分
  String wrongpartans; //間違えてた部分の正しい解き方
  String correctans; //それの正しい解き方
  feedback(this.id, this.subject, this.field, this.problem, this.summary,
      this.wrong, this.wrongpartans, this.correctans);
}

class FbdetailPage extends StatefulWidget {
  @override
  _FbdetailPageState createState() => _FbdetailPageState();
}

class _FbdetailPageState extends State<FbdetailPage> {
  List<feedback> fblist = [];
  int listNum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A_Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              /*
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // ▼ ---------- 左ボタン ---------- ▼ //
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: A_Colors.black),
                  onPressed: listNum > 0
                      ? () {
                          setState(() {
                            if (listNum > 0) {
                              listNum--;
                            }
                          });
                        }
                      : null,
                  color: A_Colors.black.withOpacity(listNum > 0 ? 1.0 : 0.3),
                ),
                // ▼ ---------- 右ボタン ---------- ▼ //
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: A_Colors.black),
                  onPressed: listNum > 0
                      ? () {
                          setState(() {
                            if (listNum < fblist.length - 1) {
                              listNum++;
                            }
                          });
                        }
                      : null,
                  color: A_Colors.black
                      .withOpacity(listNum < fblist.length - 1 ? 1.0 : 0.3),
                ),
              ]),
              */

              // ▼ ---------- フィードバックシート ---------- ▼ //
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(clipBehavior: Clip.none, children: [
                  if (fblist.isNotEmpty)
                    FbSheet(
                      labels: fblist[listNum].field,
                      problem: fblist[listNum].problem,
                      wrong: fblist[listNum].wrong,
                      wrongpartans: fblist[listNum].wrongpartans,
                      correctans: fblist[listNum].correctans,
                    )
                  else
                    const Text("該当なし", style: TextStyle(fontSize: 18)),
                ]),
              ),

              // ▼ ---------- ホームボタン ---------- ▼ //
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.mainColor,
                    foregroundColor: A_Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('ホーム画面へ戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
