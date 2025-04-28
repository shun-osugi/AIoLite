import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:ps_hacku_osaka/widget_fbsheet.dart';
import 'subject_categories.dart';
import 'api_service.dart';

class FblistPage extends StatefulWidget {
  @override
  _FblistPageState createState() => _FblistPageState();
}

class _FblistPageState extends State<FblistPage> {

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
              // ▼ ---------- ラベルボタン ---------- ▼ //
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.mainColor,
                    foregroundColor: A_Colors.white,
                  ),
                  onPressed: () {
                    showLabelDialog(context);
                  },
                  child: const Text('絞り込み'),
                ),
              ),

              // ▼ ---------- フィードバックシート ---------- ▼ //
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(clipBehavior: Clip.none, children: [FbSheet()]),
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

// ▼ ---------- ラベル表示 ---------- ▼ //

// ラベルを編集するダイアログ
void showLabelDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => LabelDialog(),
  );
}
class LabelDialog extends StatefulWidget {
  const LabelDialog({Key? key}) : super(key: key);

  @override
  _LabelDialogState createState() => _LabelDialogState();
}
class _LabelDialogState extends State<LabelDialog> {
  List<String> _suggestedLabels = []; // 推奨ラベル
  List<String?> selectedSubjects = List.filled(4, null); // 教科ドロップダウン選択
  List<String?> selectedCategories = List.filled(4, null); // 分類ドロップダウン選択
  bool _isLoading = false;

  // 推奨ラベルを取得
  Future<void> _getSuggestedLabels(String inputText) async {
    if (inputText.isEmpty) return;

    try {
      List<String> labels = await ApiService.classifyText(inputText);
      setState(() {
        _suggestedLabels = labels;
      });

      // ラベルを順番に設定
      _setDropdownValues();

      // ログ出力
      debugPrint("推奨ラベル: $labels");
    } catch (e) {
      debugPrint("エラー: $e");
    }
  }

  // 推奨ラベルを元にドロップダウンに順番に値をセット
  void _setDropdownValues() {
    if (_suggestedLabels.isEmpty) return;

    setState(() {
      for (int i = 0; i < _suggestedLabels.length && i < 4; i++) {
        String label = _suggestedLabels[i];

        List<String> parts = label.split(" - ");
        if (parts.length == 2) {
          selectedSubjects[i] = parts[0];  // 教科
          selectedCategories[i] = parts[1]; // 分類
        }
      }
    });
  }

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
              hint: Text("未選択", style: TextStyle(color: A_Colors.black),),
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
                  child: Text("未選択", style: TextStyle(color: A_Colors.black),), // デフォルトのnull選択肢
                ),
                ...subjectCategories.keys.toSet().toList().map((String subject) { // 重複を削除
                  print("DropdownMenuItem value: $subject"); // デバッグ出力
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject, style: TextStyle(color: A_Colors.black),),
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
                hint: Text("未選択", style: TextStyle(color: A_Colors.black),),
                value: selectedCategories[index],
                iconEnabledColor: A_Colors.black,
                onChanged: selectedSubjects[index] == null ? null : (String? newValue) {
                  setState(() {
                    selectedCategories[index] = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text("未選択", style: TextStyle(color: A_Colors.black),), // デフォルトのnull選択肢
                  ),
                  ...(subjectCategories[selectedSubjects[index]] ?? []).map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: TextStyle(color: A_Colors.black),),
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
                  Text("ラベルを選択", style: TextStyle(color: A_Colors.black, fontSize: 24, fontWeight: FontWeight.bold),),
                  SizedBox(height: 16),

                  // 4つのドロップダウンペアを縦に並べる=>とりあえず1つ
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: A_Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: A_Colors.black, width: 2,),
                    ),
                    child: Column(
                      children: [
                        buildDropdownPair(0),
                        for (int i = 1; i < 1; i++) ...[
                          Divider(color: A_Colors.black,),
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
                            if (selectedSubjects[i] != null && selectedCategories[i] != null) {
                              editedLabels.add("${selectedSubjects[i]} - ${selectedCategories[i]}");
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

                          Navigator.pop(
                            // ---------------------------------- ラベル選択実行　-------------------------------------------//
                            context,

                          );
                        },
                        child: Text("開始 →", style: TextStyle(color: A_Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
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