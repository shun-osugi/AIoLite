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
      '数学',
      ['正の数・負の数', 'b'],
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
    ),
    feedback(
      3,
      '数学',
      ['c', "文字式"],
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
  String? selectedSubject;   // 教科ドロップダウン選択
  String? selectedCategory;  // 分類ドロップダウン選択
  List<String> selectedFilter = []; //選択した教科ラベル ["教科-ラベル",...
  List<feedback> _filteredFbList = []; // 絞り込み後のフィードバックリスト

/*
  @override
  void initState() {
    super.initState();
    _filteredFbList = List.from(fblist); // 初期表示は全件
  }
*/

  // 絞り込み処理
  void _filterFeedbackList()
  {
    _filteredFbList.clear();
    //絞り込み検索
    for(int i=0;i<fblist.length;i++){
      if(selectedFilter.contains('${fblist[i].subject}-すべて')){ //教科ごとの選択なら無条件で追加
        _filteredFbList.add(fblist[i]);
      }
      else{
        //分類も指定されているならさらに検索
        for(int j=0;j<fblist[i].field.length;j++){
          if(selectedFilter.contains('${fblist[i].subject}-${fblist[i].field[j]}')){
            _filteredFbList.add(fblist[i]);
            break;
          }
        }
      }
    }
    for(int i=0;i<_filteredFbList.length;i++){
      print(_filteredFbList[i].id);
    }
  }

  //フィルター追加時の処理
  void addFilter() {
    if(selectedSubject == null) return;
    final filter = '$selectedSubject-すべて';
    //分類選択がすべての場合
    //selectedCategory==全て　元のやつから削除
    if(selectedCategory == null){
      //教科が同じものは削除
      selectedFilter.removeWhere((e) => e.contains(selectedSubject!));
      //直前の検索で消されるので'教科-すべて'を追加
      selectedFilter.add(filter);
    }
    else if (!selectedFilter.contains(filter) && 
              !selectedFilter.contains('$selectedSubject-$selectedCategory')){ //全てがある場合は追加しない
      selectedFilter.add('$selectedSubject-$selectedCategory');
    }
    setState((){});
  }

  //フィルター削除時の処理
  void removeFilter(String filter) {
    setState(() {
      selectedFilter.remove(filter);
    });
  }

  //大元の絞り込みUI
  //mainからパクってきたよ
  Widget filterUI()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
          SizedBox(height: 5),

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
                      value: selectedSubject,
                      iconEnabledColor: A_Colors.black,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue;
                          selectedCategory = null; // 教科変更時に分類もリセット
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
                        ...subjectCategories.keys.toSet().toList()
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
                        value: selectedCategory,
                        iconEnabledColor: A_Colors.black,
                        onChanged: selectedSubject == null
                        ? null
                        : (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              selectedSubject == null ?
                              "未選択" ://何も選んでない時は未選択
                              "すべて",
                              style: TextStyle(color: A_Colors.black),
                            ), // デフォルトのnull選択肢
                          ),
                          ...(subjectCategories[selectedSubject] ?? [])
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
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: IconButton(
                    alignment: Alignment.center, //中央に配置↓
                    padding: EdgeInsets.zero,//デフォルト値があるらしい
                    color: A_Colors.mainColor,
                    icon: Icon(
                      Icons.add_circle,
                      size: 40
                    ),
                    onPressed: addFilter,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          //絞り込みフィルター表示
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.15, //フィルター二列が見える状態
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(
                color: A_Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView( //フィルター二列が見える状態
              child: Wrap( //横幅に収まりきらなかったら改行して配置
                spacing: 5,    //chipごとの横の幅
                runSpacing: 5, //chipごとの横の幅
                children: selectedFilter.map((filter) {
                  return Chip( //消去できるwidget
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: A_Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    backgroundColor: A_Colors.white,
                    deleteIconColor: A_Colors.mainColor,
                    side: BorderSide(
                      color: A_Colors.black,
                      width: 0.5,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                    labelPadding: EdgeInsets.symmetric(horizontal: 3), // 追加：文字左右の多すぎるpaddingを調整
                    visualDensity: VisualDensity(horizontal: 1.0, vertical: -3), // 追加：文字上下の多すぎるpaddingを調整
                    onDeleted: () => removeFilter(filter),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10),

          Row(//関係ないrowあ，左寄せのためか
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //リセットボタン
              TextButton(
                onPressed: () async {
                  selectedFilter.clear();
                  setState((){});
                  // print(selectedFilter);
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
                onPressed: _filterFeedbackList,
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

  //main
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A_Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              filterUI(), //大場担当　絞り込み部分
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

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
