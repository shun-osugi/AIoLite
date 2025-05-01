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
      'aa',
      ['a', 'a'],
      'aaaaaaaaa',
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

  // 絞り込み処理
  void _filterFeedbackList() {}

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

              // ▼ ---------- 要約された問題文 ---------- ▼ //
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: A_Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      // 一時的に要約される前の問題文を使用
                      // 分野は一番最初のやつ
                      for (int i = 0; i < fblist.length; i++)
                        builderSummery(context, fblist[i].subject,
                            fblist[i].field[0], fblist[i].problem),
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
  Widget builderSummery(
    BuildContext context, String subject, String field, String sProblem) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    height: MediaQuery.of(context).size.height * 0.05,
    decoration: BoxDecoration(
      color: A_Colors.mainColor,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: A_Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: A_Colors.mainColor.withOpacity(0.7),
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
        child: Row(
          children: [
            // 教科(subject)
            Expanded(
              flex: 1, // 比率 1
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subject,
                  style: TextStyle(
                    color: A_Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 分類(field)
            Expanded(
              flex: 1, // 比率 1
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  field,
                  style: TextStyle(
                    color: A_Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 問題文(sProblem)
            Expanded(
              flex: 3, // 比率 4 (より広いスペース)
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
          ],
        )),
  );
}
  // ▲ ---------- 要約された問題文のボタンのbuider ---------- ▲ //
}

// ▼ ---------- ラベル表示(使わないなら削除して) ---------- ▼ //

// ラベルを編集するダイアログ
void showLabelDialog(
    BuildContext context, Function(List<String>) updateFilteredLabels) {
  showDialog(
    context: context,
    builder: (context) => LabelDialog(onLabelsSelected: updateFilteredLabels),
  );
}

class LabelDialog extends StatefulWidget {
  const LabelDialog({Key? key, required this.onLabelsSelected})
      : super(key: key);
  final Function(List<String>) onLabelsSelected;

  @override
  _LabelDialogState createState() => _LabelDialogState();
}

class _LabelDialogState extends State<LabelDialog> {
  List<String?> selectedSubjects = List.filled(4, null); // 教科ドロップダウン選択
  List<String?> selectedCategories = List.filled(4, null); // 分類ドロップダウン選択
  bool _isLoading = false;

  // 教科と分類のドロップダウンペア
  Widget buildDropdownPair(int index) {
    return Row(
      children: [
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
              value: selectedSubjects[index],
              iconEnabledColor: A_Colors.black,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubjects[index] = newValue;
                  selectedCategories[index] = null; // 教科変更時に分類もリセット
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
                  print("DropdownMenuItem value: $subject"); // デバッグ出力
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(
                      subject,
                      style: TextStyle(color: A_Colors.black),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
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
                value: selectedCategories[index],
                iconEnabledColor: A_Colors.black,
                onChanged: selectedSubjects[index] == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedCategories[index] = newValue;
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
                  ...(subjectCategories[selectedSubjects[index]] ?? [])
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(color: A_Colors.black),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ダイアログ部分
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: A_Colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              // テキスト編集フィールド
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ラベルを選択",
                    style: TextStyle(
                        color: A_Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // 4つのドロップダウンペアを縦に並べる
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: A_Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        buildDropdownPair(0),
                        for (int i = 1; i < 4; i++) ...[
                          Divider(
                            color: A_Colors.black,
                          ),
                          buildDropdownPair(i),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          List<String> editedLabels = [];
                          for (int i = 0; i < 4; i++) {
                            if (selectedSubjects[i] != null &&
                                selectedCategories[i] != null) {
                              editedLabels.add(
                                  "${selectedSubjects[i]} - ${selectedCategories[i]}");
                            }
                          }

                          /* ここでラベルを保存
                          if (widget.editedText.isNotEmpty && editedLabels.isNotEmpty) {
                            try {
                              await ApiService.storeText(widget.editedText, editedLabels);
                              print("テキストとラベルを保存しました");
                            } catch (e) {
                              print("エラー: $e");
                            }
                          } else {
                            print("テキストまたはラベルが空です");
                          }
                          */

                          // ---------------------------------- ラベル選択実行　-------------------------------------------//

                          Navigator.pop(
                            context,
                          );
                        },
                        child: Text(
                          "開始 →",
                          style: TextStyle(
                              color: A_Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 左上の戻るボタン
            Positioned(
              top: 24,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: A_Colors.black, size: 40),
                onPressed: () {
                  Navigator.of(context).pop();
                  // showEditDialog(context, widget.editedText);
                },
              ),
            ),
            // ローディングインジケーター
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // 背景を半透明に
                  child: Center(
                    child: CircularProgressIndicator(), // ローディングインジケーター
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// ▲ ---------- ラベル表示 ---------- ▲ //
