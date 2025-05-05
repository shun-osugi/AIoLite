import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';

class FbSheet extends StatefulWidget {
  final List<String> labels; //ラベル
  final String problem; //問題文
  final String wrong; //間違えてた部分
  final String wrongpartans; //間違えてた部分の正しい解き方
  final String correctans; //全体の正しい解き方

  const FbSheet({
    super.key,
    this.labels = const [],
    this.problem = "------------------------------",
    this.wrong = "------------------------------",
    this.wrongpartans = "------------------------------",
    this.correctans = "------------------------------",
  });

  @override
  State<FbSheet> createState() => _FbSheetState();
}

class _FbSheetState extends State<FbSheet> {
  final ScrollController _scrollController = ScrollController(); // スクロールのコントローラ

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: A_Colors.white,
        ),
        child: Column(
          children: [
            // ▼ ---------- 問題文(problem) ---------- ▼ //
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [A_Colors.mainColor, A_Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                widget.problem,
                style: TextStyle(
                  color: A_Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ▲ ---------- 問題文(problem) ---------- ▲ //
            Expanded(
                child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(children: [
                // ▼ ---------- 間違えた部分(wrong) ---------- ▼ //
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [A_Colors.subColor, A_Colors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // タイトル
                      Center(
                        child: Text(
                          'つまづきポイント',
                          style: TextStyle(
                            color: A_Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: A_Colors.black,
                                offset: Offset(0, 0),
                                
                              ),
                            ],
                          ),
                        ),
                      ),

                      // テキスト枠
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: A_Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // テキスト文章
                        child: Text(
                          widget.wrong,
                          style: TextStyle(
                            color: A_Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ▲ ---------- 間違えた部分(wrong) ---------- ▲ //

                // ▼ ---------- 間違えた部分の正しい解き方(wrongpartans) ---------- ▼ //
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [A_Colors.subColor, A_Colors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // タイトル
                      Center(
                        child: Text(
                          'ピンポイント解説',
                          style: TextStyle(
                            color: A_Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: A_Colors.black,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // テキスト枠
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: A_Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // テキスト文章
                        child: Text(
                          widget.wrongpartans,
                          style: TextStyle(
                            color: A_Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ▲ ---------- 間違えた部分の正しい解き方(wrongpartans) ---------- ▲ //

                // ▼ ---------- 全体の正しい解き方(correctans) ---------- ▼ //
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [A_Colors.subColor, A_Colors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // タイトル
                      Center(
                        child: Text(
                          '全体の解説',
                          style: TextStyle(
                            color: A_Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: A_Colors.black,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // テキスト枠
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: A_Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // テキスト文章
                        child: Text(
                          widget.wrong,
                          style: TextStyle(
                            color: A_Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ▲ ---------- 全体の正しい解き方(correctans) ---------- ▲ //
              ]),
            ))
          ],
        ));
  }
}
