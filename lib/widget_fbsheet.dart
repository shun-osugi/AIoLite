import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';

class FbSheet extends StatefulWidget {
  final List<String> labels; //ラベル
  final String problem; //問題文
  final String summary; //問題文の要約
  final String wrong; //間違えてた部分
  final String wrongpartans; //間違えてた部分の正しい解き方
  final String correctans; //全体の正しい解き方

  const FbSheet({
    super.key,
    this.labels = const [],
    this.problem = "------------------------------",
    this.summary = "------------------------------",
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
        gradient: LinearGradient(
          colors: [A_Colors.white, A_Colors.accentColor, A_Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: A_Colors.black, width: 4),
      ),
      padding: EdgeInsets.all(8),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ▼ ---------- タイトル(summary) ---------- ▼ //
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [A_Colors.subColor, A_Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: A_Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: A_Colors.mainColor.withOpacity(0.7),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                // タイトル
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  A_Colors.white,
                                  A_Colors.subColor,
                                  A_Colors.white
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: A_Colors.black, width: 4),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: A_Colors.black,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          widget.problem,
                                          style: TextStyle(
                                            color: A_Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    widget.summary,
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),

              // ▲ ---------- タイトル(summary) ---------- ▲ //
              Expanded(
                  child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: [
                  // ラベル(labels)
                  LabelCard(labels: widget.labels),
                  // 間違えた部分(wrong)
                  FeedBackCard(
                    title: 'つまづきポイント',
                    content: widget.wrong,
                  ),

                  // 間違えた部分の正しい解き方(wrongpartans)
                  FeedBackCard(
                    title: 'ピンポイント解説',
                    content: widget.wrongpartans,
                  ),

                  // 全体の正しい解き方(correctans)
                  FeedBackCard(
                    title: '問題解説',
                    content: widget.correctans,
                  ),
                ]),
              ))
            ],
          )),
    );
  }
}

// 各フィードバック内容
class LabelCard extends StatelessWidget {
  final List<String> labels;

  const LabelCard({
    Key? key,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return

        // テキスト枠(ラベル)
        Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(3),
      child: Expanded(
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: labels.map((label) {
            return Chip(
              label: Text(
                label,
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: 15,
                ),
              ),
              backgroundColor: A_Colors.subColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: EdgeInsets.symmetric(horizontal: 3),
              visualDensity: VisualDensity(horizontal: 1.0, vertical: -3),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 各フィードバック内容
class FeedBackCard extends StatelessWidget {
  final String title;
  final String content;

  const FeedBackCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [A_Colors.subColor, A_Colors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: A_Colors.white, width: 3),
      ),
      child: Column(
        children: [
          // タイトル
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: A_Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 16,
                    color: A_Colors.black,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 8,
          ),

          // テキスト枠
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: A_Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: A_Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
