import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:ps_hacku_osaka/widget_fbsheet.dart';
import 'subject_categories.dart';

class feedback {
  //フィードバック一つのデータ
  int id; //id
  String subject; //教科
  List<String> field; //分野
  String problem; //問題文
  String firstans; //どういう解き方を最初したのか
  String wrong; //間違えてた部分
  String wrongpartans; //間違えてた部分の正しい解き方
  String correctans; //それの正しい解き方
  feedback(this.id, this.subject, this.field, this.problem, this.firstans,
      this.wrong, this.wrongpartans, this.correctans);
}

class FblistPage extends StatefulWidget {
  @override
  _FblistPageState createState() => _FblistPageState();
}

class _FblistPageState extends State<FblistPage> {
  // List<feedback> fblist = [];
  List<feedback> fblist = [
    //仮データ
    feedback(
      1,
      '教科',
      ['分類11111111', '分類22222222', '分類33333333'],
      '問題文',
      'aaaaaaaaa',
      'aaaaaaaaa',
      'aaaaaaaaa',
      'aaaaaaaaa',
    ),
    feedback(
      2,
      'bb',
      ['b', 'b'],
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
    ),
    feedback(
      3,
      'cc',
      ['c', 'c'],
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
    ),
    feedback(
      4,
      'dd',
      ['d', 'd'],
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
    ),
    feedback(
      5,
      'ee',
      ['e', 'e'],
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
    ),
  ];
  // List<String> _filteredLabels = []; // 絞り込み後のラベル
  // list<String> _filteredSubjects = []; // 絞り込み後の科目リスト
  // List<String> _filteredFields = []; // 絞り込み後の分野リスト
  // List<feedback> _filteredFbList = []; // 絞り込み後のフィードバックリスト

/*
  @override
  void initState() {
    super.initState();
    _filteredFbList = List.from(fblist); // 初期表示は全件
  }
*/
  /*
  // ダイアログからラベルを受け取るコールバック関数
  void _updateFilteredLabels(List<String> labels) {
    setState(() {
      _filteredLabels = labels;
      _filteredSubjects.clear();
      _filteredFields.clear();

      for (final label in _filteredLabels) {
        final parts = label.split(' - ');
        if (parts.length == 2) {
          _filteredSubjects.add(parts[0]);
          _filteredFields.add(parts[1]);
        }
      }
      // print("選択されたラベル: $_filteredLabels");
      // print("絞り込み科目: $_filteredSubjects");
      // print("絞り込み分野: $_filteredFields");

      // 絞り込み処理を実行
      _filterFeedbackList();
    });
  }
  */

  String? selectedSubjects;   // 教科ドロップダウン選択
  String? selectedCategories; // 分類ドロップダウン選択
  List<String> editedLabels = []; //選択した教科ラベル ["教科-ラベル",...

  // 絞り込み処理
  void _filterFeedbackList() {}

  //大元の絞り込みUI
  //mainからパクってきたよ
  Widget filterUI()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      // テキスト編集フィールド
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "ラベル絞り込み",
            style: TextStyle(
              color: A_Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 16),

          // ドロップダウンペア
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: A_Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: A_Colors.black,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                //教科のドロップダウン
                Container(
                  width: 100,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: A_Colors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        "未選択",
                        style: TextStyle(color: A_Colors.black),
                      ),
                      value: selectedSubjects,
                      iconEnabledColor: A_Colors.black,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubjects = newValue;
                          selectedCategories = null; // 教科変更時に分類もリセット
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            "未選択",
                            style: TextStyle(color: A_Colors.black),
                          ), // デフォルトのnull選択肢
                        ),
                        ...subjectCategories.keys
                          .toSet()
                          .toList()
                          .map((String subject) {
                          // 重複を削除
                          // print("DropdownMenuItem value: $subject"); // デバッグ出力
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(
                              subject,
                              style: TextStyle(color: A_Colors.black),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),

                //分類のドロップダウン
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: A_Colors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          "未選択",
                          style: TextStyle(color: A_Colors.black),
                        ),
                        value: selectedCategories,
                        iconEnabledColor: A_Colors.black,
                        onChanged: selectedSubjects == null
                        ? null
                        : (String? newValue) {
                          setState(() {
                            selectedCategories = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              "未選択",
                              style: TextStyle(color: A_Colors.black),
                            ), // デフォルトのnull選択肢
                          ),
                          ...(subjectCategories[selectedSubjects] ?? [])
                            .map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: TextStyle(color: A_Colors.black),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),

                //追加ボタン
                //多分，あとでiconbuttonかなんかに変える
                SizedBox(
                  width: 30,
                  child: Text(
                    "+",
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Row(//関係ないrowあ，左寄せのためか
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //リセットボタン
              TextButton(
                onPressed: () async {
                  // ------------------------- ラベルリセット実行　--------------------------//
                  print(editedLabels);
                },
                child: Text(
                  "リセット",
                  style: TextStyle(
                    color: A_Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(width: 5),

              //絞り込みボタン
              TextButton(
                onPressed: () async {
                  if (selectedSubjects != null &&
                      selectedCategories != null) {
                    editedLabels.add("$selectedSubjects-$selectedCategories");
                  }

                  // ------------------------- ラベル選択実行　--------------------------//

                  // Navigator.pop(
                  //   context,
                  // );
                  print(editedLabels);
                },
                child: Text(
                  "絞り込み",
                  style: TextStyle(
                    color: A_Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // ▼ ---------- ラベルボタン ---------- ▼ //
                /*
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: A_Colors.mainColor,
                      foregroundColor: A_Colors.white,
                    ),
                    onPressed: () {
                      showLabelDialog(context, _updateFilteredLabels);
                    },
                    child: const Text('絞り込み'),
                  ),
                ),
              */
              ]),

              filterUI(), //大場担当　絞り込み部分

              // ▼ ---------- 要約された問題文リスト ---------- ▼ //
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: A_Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Column(
                    children: [
                      // 一時的に要約される前の問題文を使用
                      for (int i = 0; i < fblist.length; i++)
                        Column(
                          children: [
                            builderSummery(context, fblist[i].subject,
                            fblist[i].field, fblist[i].problem),  //1つの問題文
                            SizedBox(height: MediaQuery.of(context).size.width * 0.01), //余白
                          ],
                        )
                        
                    ],
                  ),
                ),
              ),

              // ▼ ---------- ホームボタン ---------- ▼ //
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [A_Colors.subColor, A_Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: A_Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: A_Colors.black.withOpacity(0.7),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'ホームに戻る',
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ▼ ---------- 要約された問題文のボタンのbuider ---------- ▼ //
  Widget builderSummery(BuildContext context, String subject, List<String> fields, String sProblem) {
    final combinedField = fields.join('  |  '); // 分野リストを結合
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.12,
      decoration: BoxDecoration(
        color: A_Colors.mainColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: A_Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 13, 13, 14).withOpacity(0.7),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ▼ ---------- 問題文(sProblem) ---------- ▼ //
              Expanded(
                flex: 6, // 上下の範囲の比率
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sProblem,
                    style: TextStyle(
                      color: A_Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 4, // 上下の範囲の比率
                  child: Row(
                    children: [
                      // ▼ ---------- 教科(subject) ---------- ▼ //
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: A_Colors.mainColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: A_Colors.background, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: A_Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // ▼ ---------- 分類(field) ---------- ▼ //
                      Container(
                          width: MediaQuery.of(context).size.width * 0.57,
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: BoxDecoration(
                            color: A_Colors.mainColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: A_Colors.background, width: 3),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              //スクロールできるようにする
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                combinedField, //結合したテキスト
                                style: TextStyle(
                                  color: A_Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                    ],
                  )),
              SizedBox(height: MediaQuery.of(context).size.width * 0.01), //余白
            ],
          )),
    );
  }
  // ▲ ---------- 要約された問題文のボタンのbuider ---------- ▲ //
}
