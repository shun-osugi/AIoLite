import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:ps_hacku_osaka/widget_fbsheet.dart';
import 'package:sqflite/sqflite.dart';

import 'subject_categories.dart';
import 'utility.dart';

class feedback {
  //フィードバック一つのデータ
  int id; //id
  List<String> subject; //教科
  List<String> field; //分野
  List<String> labels; //ラベル
  String problem; //問題文
  String summary; //問題文の要約
  String wrong; //間違えてた部分
  String wrongpartans; //間違えてた部分の正しい解き方
  String correctans; //それの正しい解き方
  feedback(this.id, this.subject, this.field, this.labels, this.problem, this.summary, this.wrong, this.wrongpartans, this.correctans);
}

class FblistPage extends StatefulWidget {
  @override
  _FblistPageState createState() => _FblistPageState();
}

class _FblistPageState extends State<FblistPage> {
  List<feedback> fblist = [];
  String? selectedSubject; // 教科ドロップダウン選択
  String? selectedCategory; // 分類ドロップダウン選択
  List<String> selectedFilter = []; //選択した教科ラベル ["教科-ラベル",...
  List<feedback> _filteredFbList = []; // 絞り込み後のフィードバックリスト
  final ScrollController _scrollController = ScrollController(); // スクロールのコントローラ
  bool onFilter = false; // フィルターの表示・非表示
  bool _showScrollToTopButton = false; // トップに戻るボタンの表示・非表示
  late Database _database; //データベース
  bool listOrDetail = true; // フィードバックの表示方法選択[ 問題文リスト(true) or 詳細(false) ]
  int targetNum = 0; // 対象としているフィードバック(fblistのid-1)

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
    selectedFilter.clear();
    _filteredFbList = List.from(fblist);
    setState(() {});
    // setState(() {
    //   _initDatabase();
    // });
    _initDatabase();
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
       // subjectとfieldを取り出してlabelsを生成
      for (int i = 0; i < records.length; i++) { 
        List<String> subjects = records[i]['subject'].split('&&'); // subject取り
        List<String> fields = records[i]['field'].split('&&');  // field取り出し
        List<List<String>> allLabels = [];  // labelのリスト
        // ラベルの生成
        List<String> tmpLabel = [];
        int labelLength = subjects.length < fields.length ? subjects.length : fields.length;
        for (int j = 0; j < labelLength; j++) {
          tmpLabel.add('${subjects[j]} - ${fields[j]}');
        }
        fblist.add(feedback(
          records[i]['id'],
          subjects,
          fields,
          tmpLabel,
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

    setState(() {
      _filteredFbList = List.from(fblist); // 初期表示は全件
    });
  }

  // ▲ ---------- データベース読み取り ---------- ▲ //

  // ▼ ---------- 絞り込み処理 ---------- ▼ //
  // 絞り込み処理
  void _filterFeedbackList() {
    if(selectedFilter.isEmpty){//何も絞り込んでないなら
      _filteredFbList = List.from(fblist);
      setState((){});
      return;
    }
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
    setState((){});
  }

  //フィルター追加時の処理
  void addFilter() {
    if (selectedSubject == null) return; //教科が選択されていないなら何もしない
    String filter = '$selectedSubject-';
    filter += selectedCategory ?? 'すべて';

    if (selectedFilter.contains(filter)) {
      //すでに選択されているなら何もしない
      //選択できないことを通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('そのラベルはすでに選択されています'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    //分類選択がすべての場合
    if (selectedCategory == null) {
      //教科が同じものは削除
      selectedFilter.removeWhere((e) => e.contains(selectedSubject!));
      //直前の検索で消されるので'教科-すべて'を追加
      selectedFilter.add(filter);
    } else {
      //分類も選択されている場合
      if (selectedFilter.contains('$selectedSubject-すべて')) {
        //全てがある場合は追加しない
        //全てがすでに追加されていることを通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('その分類は，"すべて"がすでに選択されています'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      } else {
        //全てがないなら追加
        selectedFilter.add(filter);
      }
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
                          alignment: Alignment.center,
                          //中央に配置↓
                          padding: EdgeInsets.zero,
                          //デフォルト値があるらしい
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
                  height: MediaQuery.of(context).size.height * 0.11,
                  //フィルター二列が見える状態
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
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          // 追加：上下の余計なmarginを削除
                          labelPadding: EdgeInsets.symmetric(horizontal: 3),
                          // 追加：文字左右の多すぎるpaddingを調整
                          visualDensity: VisualDensity(horizontal: 1.0, vertical: -3),
                          // 追加：文字上下の多すぎるpaddingを調整
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
                        _filteredFbList = List.from(fblist);
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
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: A_Colors.black,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,

        // 戻るボタン
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: A_Colors.white,
              size: MediaQuery.of(context).size.width * 0.1,
            ),
            onPressed: () {
              if (listOrDetail) {
                // 一覧表示：ホームにもどる
                Navigator.of(context).pop();
              } else {
                // 詳細表示：一覧に戻る
                setState(() {
                  listOrDetail = true;
                });
              }
            }),

        // タイトル
        title: Text(
          "フィードバック一覧",
          style: TextStyle(color: A_Colors.white, fontSize: MediaQuery.of(context).size.width * 0.06, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: A_Colors.background,
      // body
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: [
              listOrDetail
                  ? summeryList() // 一覧表示
                  : feedbackDetails(targetNum - 1), // 詳細表示
              filterUI(), // フィルターボタン
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
          // 右下のトップに戻るボタン
          if (_showScrollToTopButton)
            Positioned(
              bottom: onFilter ? MediaQuery.of(context).size.height * 0.38 : MediaQuery.of(context).size.height * 0.1,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  for (int i = 0; i < _filteredFbList.length; i++)
                    Column(
                      children: [
                        builderSummery(context, _filteredFbList[i].id, _filteredFbList[i].labels, _filteredFbList[i].summary), //1つの問題文
                        SizedBox(height: MediaQuery.of(context).size.width * 0.01), //余白
                      ],
                    ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 問題文1つのbuilder
  Widget builderSummery(BuildContext context, int id, List<String> labels, String summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: MediaQuery.of(context).size.width * 0.85,
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
        onPressed: () {
          // ボタンが押された
          setState(() {
            targetNum = id;
            listOrDetail = false;
            _showScrollToTopButton = false;
          });
        },
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextTeX(
                      text: summary,
                      textStyle: TextStyle(
                        color: A_Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.zoom_in,
                  color: A_Colors.white,
                  size: MediaQuery.of(context).size.width * 0.08,
                ),
              ),
            ]),

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
    final fbScrollController = ScrollController();
    final List<GlobalKey> fbSheetKeys = List.generate(_filteredFbList.length, (_) => GlobalKey()); //fbSheetを判別するためのkey

    // 描画完了後、ウィジェットを中央に配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fbSheetKeys.length > targetNum && fbSheetKeys[targetNum].currentContext != null) {
        Scrollable.ensureVisible(
          fbSheetKeys[targetNum].currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 0),
          curve: Curves.easeOut,
        );
      }
    });

    return Expanded(
        child: SingleChildScrollView(
      controller: fbScrollController,
      scrollDirection: Axis.horizontal,
      child: StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: GestureDetector(
            onHorizontalDragEnd: (fbdrag) {
              if (fbdrag.primaryVelocity != null) {
                if (fbdrag.primaryVelocity! < 0 && targetNum < _filteredFbList.length - 1) {
                  // 右→左 (fblistを1進める)
                  setState(() {
                    targetNum++;
                  });
                  // 中央配置
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (fbSheetKeys.length > targetNum && fbSheetKeys[targetNum].currentContext != null) {
                      Scrollable.ensureVisible(
                        fbSheetKeys[targetNum].currentContext!,
                        alignment: 0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                } else if (fbdrag.primaryVelocity! > 0 && targetNum > 0) {
                  // 左→右 (fblistを1戻る)
                  // target変更
                  setState(() {
                    targetNum--;
                  });

                  // 中央配置
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (fbSheetKeys.length > targetNum && fbSheetKeys[targetNum].currentContext != null) {
                      Scrollable.ensureVisible(
                        fbSheetKeys[targetNum].currentContext!,
                        alignment: 0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              }
            },
            // fbSheetの一覧
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                for (int i = 0; i < _filteredFbList.length; i++) ...[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: FbSheet(
                      key: fbSheetKeys[i],
                      labels: _filteredFbList[i].labels,
                      problem: _filteredFbList[i].problem,
                      summary: _filteredFbList[i].summary,
                      wrong: _filteredFbList[i].wrong,
                      wrongpartans: _filteredFbList[i].wrongpartans,
                      correctans: _filteredFbList[i].correctans,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                ]
              ],
            ),
          ),
        );
      }),
    ));
  }
// ▲ ---------- フィードバック詳細 ---------- ▲ //
}
