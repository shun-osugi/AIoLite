import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:ps_hacku_osaka/widget_fbsheet.dart';
import 'subject_categories.dart';
import 'package:sqflite/sqflite.dart';

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
  feedback(this.id, this.subject, this.field, this.problem, this.summary, this.wrong, this.wrongpartans, this.correctans);
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
      ['教科', '教科', '教科'],
      ['分類11111111', '分類22222222', '分類33333333'],
      '問題文問題文問題文問題文問題文問題文問題文問題文問題文問題文問題文問題文問題文',
      '要約された問題文',
      'aaaaaaaaa',
      'aaaaaaaaa',
      'aaaaaaaaa',
    ),
    feedback(
      2,
      ['数学', '教科'],
      ['正の数・負の数', 'b'],
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
    ),
    feedback(
      3,
      ['理科', '数学'],
      ['物質のすがた', "文字式"],
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
    ),
    feedback(
      4,
      ['理科', '教科'],
      ['物質のすがた', 'd'],
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
    ),
    feedback(
      5,
      ['ee', '教科'],
      ['e', 'e'],
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
    ),
  ];
  List<List<String>> allLabels = [];  // 教科と分類を統合したリストのリスト(ラベル)
  String? selectedSubject; // 教科ドロップダウン選択
  String? selectedCategory; // 分類ドロップダウン選択
  List<String> selectedFilter = []; //選択した教科ラベル ["教科-ラベル",...
  List<feedback> _filteredFbList = []; // 絞り込み後のフィードバックリスト
  final ScrollController _scrollController = ScrollController(); // スクロールのコントローラ
  bool onFilter = false; // フィルターの表示・非表示
  bool _showScrollToTopButton = false; // トップに戻るボタンの表示・非表示
  late Database _database; //データベース
  bool listOrDetail = true; // フィードバックの表示方法選択[ 問題文リスト(true) or 詳細(false) ]
  final ScrollController _fbScrollController = ScrollController(); // 詳細表示のスクロールコントローラ

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      } else if (_scrollController.offset <= 0 && _showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    });
    // _initDatabase();
    _filteredFbList = List.from(fblist); // 初期表示は全件
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ▼ ---------- データベース読み取り ---------- ▼ //
  // データベースから読み解り
  Future<void> _initDatabase() async {
    // データベースをオープン（存在しない場合は作成）
    try {
      // String databasePath = await getDatabasesPath();
      // String path = '${databasePath}/database.db';
      // await deleteDatabase(path);
      _database = await openDatabase(
        'database.db',
        version: 1,
        onCreate: (Database db, int version) async {
          //テーブルがないなら作成
          //フィードバックテーブルを作成
          //fieldはリスト（flutter側に持ってくるときに変換予定）
          return db.execute(
            '''
            CREATE TABLE IF NOT EXISTS feedback(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              subject TEXT,
              field TEXT,
              problem TEXT,
              summary TEXT,
              wrong TEXT,
              wrongpartans TEXT,
              correctans TEXT
            )
            ''',
          );
        },
      );
      //全データを読み取り
      final records = await _database.query('feedback') as List<Map<String, dynamic>>;
      //fblistに追加
      for (int i = 0; i < records.length; i++) {
        fblist.add(feedback(
          records[i]['id'],
          records[i]['subject'].split('&&'),
          records[i]['field'].split('&&'),
          records[i]['problem'],
          records[i]['summary'],
          records[i]['wrong'],
          records[i]['wrongpartans'],
          records[i]['correctans'],
        ));
      }
      print('jsdlkfjlsd');
    } catch (e) {
      print("データベース読み取りエラー");
      print(e);
    }
  }
  // ▲ ---------- データベース読み取り ---------- ▲ //

  // ▼ ---------- 絞り込み処理 ---------- ▼ //
  // 絞り込み処理
  void _filterFeedbackList() {
    _filteredFbList.clear();
    //絞り込み検索
    for (int i = 0; i < fblist.length; i++) {
      //分類も指定されているならさらに検索
      for (int j = 0; j < fblist[i].subject.length; j++) {
        //教科ごとの選択なら無条件で追加
        if (selectedFilter.contains('${fblist[i].subject[j]}-すべて')) {
          _filteredFbList.add(fblist[i]);
          break;
        } //そうでないなら分類も含めて検索
        else if (selectedFilter.contains('${fblist[i].subject[j]}-${fblist[i].field[j]}')) {
          _filteredFbList.add(fblist[i]);
          break;
        }
      }
    }
    // for(int i=0;i<_filteredFbList.length;i++){
    //   print(_filteredFbList[i].id);
    // }
    // print('jdshfsd');
  }

  //フィルター追加時の処理
  void addFilter() {
    if (selectedSubject == null) return;
    final filter = '$selectedSubject-すべて';
    //分類選択がすべての場合
    //selectedCategory==全て　元のやつから削除
    if (selectedCategory == null) {
      //教科が同じものは削除
      selectedFilter.removeWhere((e) => e.contains(selectedSubject!));
      //直前の検索で消されるので'教科-すべて'を追加
      selectedFilter.add(filter);
    } else if (!selectedFilter.contains(filter) && !selectedFilter.contains('$selectedSubject-$selectedCategory')) {
      //全てがある場合は追加しない
      selectedFilter.add('$selectedSubject-$selectedCategory');
    }
    setState(() {});
  }

  //フィルター削除時の処理
  void removeFilter(String filter) {
    setState(() {
      selectedFilter.remove(filter);
    });
  }
  // ▲ ---------- 絞り込み処理 ---------- ▲ //

  // ▼ ---------- 絞り込みUI ---------- ▼ //
  //大元の絞り込みUI
  //mainからパクってきたよ
  Widget filterUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // テキスト編集フィールド
      child: Container(
        decoration: BoxDecoration(
          color: A_Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: A_Colors.black, width: 3),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  Text(
                    "フィルター設定",
                    style: TextStyle(color: A_Colors.black, fontSize: MediaQuery.of(context).size.width * 0.05, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        onFilter = !onFilter;
                      });
                    },
                    icon: onFilter ? Icon(Icons.expand_more) : Icon(Icons.expand_less),
                    iconSize: MediaQuery.of(context).size.width * 0.1,
                    color: A_Colors.mainColor,
                  )
                ],
              ),
              if (onFilter) ...[
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
                              ...subjectCategories.keys.toSet().toList().map((String subject) {
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
                                    selectedSubject == null
                                        ? "未選択"
                                        : //何も選んでない時は未選択
                                        "すべて",
                                    style: TextStyle(color: A_Colors.black),
                                  ), // デフォルトのnull選択肢
                                ),
                                ...(subjectCategories[selectedSubject] ?? []).map((String category) {
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
                          padding: EdgeInsets.zero, //デフォルト値があるらしい
                          color: A_Colors.mainColor,
                          icon: Icon(Icons.add_circle, size: 40),
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
                  height: MediaQuery.of(context).size.height * 0.11, //フィルター二列が見える状態
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: A_Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    //フィルター二列が見える状態
                    child: Wrap(
                      //横幅に収まりきらなかったら改行して配置
                      spacing: 5, //chipごとの横の幅
                      runSpacing: 5, //chipごとの横の幅
                      children: selectedFilter.map((filter) {
                        return Chip(
                          //消去できるwidget
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: A_Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          backgroundColor: A_Colors.background,
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

                Row(
                  //関係ないrowあ，左寄せのためか
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //リセットボタン
                    TextButton(
                      onPressed: () async {
                        selectedFilter.clear();
                        setState(() {});
                        // print(selectedFilter);
                      },
                      child: Text(
                        "リセット",
                        style: TextStyle(color: A_Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 5),

                    //絞り込みボタン
                    TextButton(
                      onPressed: _filterFeedbackList,
                      child: Text(
                        "絞り込み",
                        style: TextStyle(color: A_Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
  // ▲ ---------- 絞り込みUI ---------- ▲ //

  // ▼ ---------- メインのbuildメソッド ---------- ▼ //
  @override
  Widget build(BuildContext context) {
    int allLength = fblist.length;

    for (int i = 0; i < allLength; i++) {
      int labelLength = fblist[i].subject.length < fblist[i].field.length ? fblist[i].subject.length : fblist[i].field.length;
      List<String> tmpLabel = []; // 各 fblist アイテムのラベルリスト
      for (int j = 0; j < labelLength; j++) {
        tmpLabel.add('${fblist[i].subject[j]} - ${fblist[i].field[j]}');
      }
      allLabels.add(tmpLabel);
    }
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: A_Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,

        // 戻るボタン
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: A_Colors.mainColor,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // タイトル
        title: Text(
          "フィードバック一覧",
          style: TextStyle(color: A_Colors.black, fontSize: MediaQuery.of(context).size.width * 0.06, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: A_Colors.background,
      body: SafeArea(
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // フィードバック表示
              if(listOrDetail) ...[
                summeryList(),
                filterUI(),
              ]
              else ...[
                feedbackDetails(0),
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),

          // 右下のトップに戻るボタン
          if (_showScrollToTopButton)
            Positioned(
              bottom: onFilter ? MediaQuery.of(context).size.height * 0.37 : MediaQuery.of(context).size.height * 0.1,
              right: 24,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.14,
                height: MediaQuery.of(context).size.width * 0.14,
                decoration: BoxDecoration(
                  color: A_Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: A_Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: A_Colors.black.withOpacity(0.7),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_up, color: A_Colors.black),
                  iconSize: MediaQuery.of(context).size.width * 0.13,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),
        ]),
      ),
    );
  }
  // ▲ ---------- メインのbuildメソッド ---------- ▲ //

  // ▼ ---------- 問題文リスト ---------- ▼ //

  // 問題文一覧のウィジェット
  Widget summeryList() {
    return Expanded(
      // 要約された問題文リスト
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: A_Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: [
                SizedBox(height: 16),
                for (int i = 0; i < fblist.length; i++)
                  Column(
                    children: [
                      builderSummery(context, allLabels[i], fblist[i].summary), //1つの問題文
                      SizedBox(height: MediaQuery.of(context).size.width * 0.01), //余白
                    ],
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 問題文1つのbuilder
  Widget builderSummery(BuildContext context, List<String> labels, String summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: MediaQuery.of(context).size.width * 0.9,
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
          padding: EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // 問題文(summary)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  summary,
                  style: TextStyle(
                    color: A_Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.width * 0.02), //余白

            // 分類(field)
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: A_Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
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
                      backgroundColor: A_Colors.background,
                      side: BorderSide(
                        color: A_Colors.black,
                        width: 0.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(horizontal: 3),
                      visualDensity: VisualDensity(horizontal: 1.0, vertical: -3),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  // ▲ ---------- 問題文リスト ---------- ▲ //

  // ▼ ---------- フィードバック詳細 ---------- ▼ //
  Widget feedbackDetails(int targetNum) {
  final _scrollController = ScrollController(initialScrollOffset: MediaQuery.of(context).size.width * targetNum); // 初期位置を設定
  return SingleChildScrollView(
    controller: _scrollController,
    scrollDirection: Axis.horizontal,
    child: StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: GestureDetector(
          onHorizontalDragEnd: (fbdrag) {
            if (fbdrag.primaryVelocity != null) {
              final pageWidth = MediaQuery.of(context).size.width;
              if (fbdrag.primaryVelocity! < 0 && targetNum < fblist.length - 1) {
                // 右→左 (fblistを1進める)
                _scrollController.animateTo(
                  _scrollController.offset + pageWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                setState(() {
                  targetNum++;
                });
              } else if (fbdrag.primaryVelocity! > 0 && targetNum > 0) {
                // 左→右 (fblistを1戻る)
                _scrollController.animateTo(
                  _scrollController.offset - pageWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                setState(() {
                  targetNum--;
                });
              }
            }
          },
          child: Row( // Stack の代わりに Row を使用
            children: [
              for (int i = 0; i < fblist.length; i++)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92, // Padding 分を考慮
                  child: FbSheet(
                    labels: allLabels[i % allLabels.length], // index に応じたラベル
                    problem: fblist[i].problem,
                    wrong: fblist[i].wrong,
                    wrongpartans: fblist[i].wrongpartans,
                    correctans: fblist[i].correctans,
                  ),
                ),
            ],
          ),
        ),
      );
    }),
  );
}
  // ▲ ---------- フィードバック詳細 ---------- ▲ //
}
