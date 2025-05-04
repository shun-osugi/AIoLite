// 全体統計画面（ホーム画面から統計ボタンクリックで遷移）
// ドーナツ型グラフ、各教科のよく使うラベルを一覧表示
// データは仮置き、データベースとの連携は未実装

import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sqflite/sqflite.dart';

class feedback {
  //フィードバック一つのデータ
  int id; //id
  List<String> subject; //教科
  List<String> field; //分野
  String problem; //問題文
  String summary;      //問題文の要約
  String wrong; //間違えてた部分
  String wrongpartans; //間違えてた部分の正しい解き方
  String correctans; //それの正しい解き方
  feedback(this.id, this.subject, this.field, this.problem, this.summary,
      this.wrong, this.wrongpartans, this.correctans);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const StatsPage(),
    );
  }
}

//グラフ表示
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // 円グラフ用ダミーデータ
  final Map<String, double> _pieData = {
    '国語': 25,
    '数学': 12,
    '理科': 18,
    '社会': 15,
    '英語': 30,
  };

  // 各ラベル（教科）ごとの統計データ（仮置き）
  final Map<String, List<(String, int)>> _details = {
    '国語': [('文語', 11), ('現代文', 12), ('漢文', 3)],
    '数学': [('計算', 4), ('図形', 6), ('確率', 2)],
    '理科': [('物理', 5), ('化学', 7), ('生物', 6)],
    '社会': [('歴史', 8), ('地理', 4), ('公民', 3)],
    '英語': [('英文法', 14), ('長文読解', 9), ('リスニング', 7)],
  };

  String _selected = '国語'; // 現在タブで選択中の教科

  // List<feedback> fblist = [];
  List<feedback> fblist = [//データベース使う時は消してね
    //仮データ
    feedback(
      1,
      ['教科','教科','教科'],
      ['分類11111111', '分類22222222', '分類33333333'],
      '問題文',
      'aaaaaaaaa',
      'aaaaaaaaa',
      'aaaaaaaaa',
      'aaaaaaaaa',
    ),
    feedback(
      2,
      ['数学','教科'],
      ['正の数・負の数', 'b'],
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
      'bbbbbbbb',
    ),
    feedback(
      3,
      ['理科','数学'],
      ['物質のすがた', "文字式"],
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
      'ccccccccc',
    ),
    feedback(
      4,
      ['理科','教科'],
      ['物質のすがた', 'd'],
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
      'ddddddddd',
    ),
    feedback(
      5,
      ['ee','教科'],
      ['e', 'e'],
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
      'eeeeeeeee',
    ),
  ];
  late Database _database;//データベース

  @override
  void initState() {
    super.initState();
    // _initDatabase();
  }

  //データベースから読み取り
  Future<void> _initDatabase() async {
    // データベースをオープン（存在しない場合は作成）
    try{
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
      for(int i=0;i<records.length;i++){
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
      print(fblist[0].correctans);
      print(fblist[3].subject);
    }catch(e){
      print("データベース読み取りエラー");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isBasicMode = args?['isBasicMode'] ?? false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isBasicMode ? B_Colors.mainColor : A_Colors.black,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,

        // 戻るボタン
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isBasicMode ? B_Colors.white : A_Colors.white,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // タイトル
        title: Text(
          "全体統計",
          style: TextStyle(
              color: isBasicMode ? B_Colors.white : A_Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: isBasicMode ? B_Colors.background : A_Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // ドーナツグラフ＋凡例
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: isBasicMode ? B_Colors.white : A_Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBasicMode ? 'きょうか' : '教科の割合',
                    style: TextStyle(
                      color: isBasicMode ? B_Colors.black : A_Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ドーナツグラフをできるだけ大きく表示
                      Expanded(child: DonutPieChart(data: _pieData)),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      // グラフと凡例を縦並びで
                      _buildLegend(),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: isBasicMode ? B_Colors.white : A_Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'よく使うラベル',
                    style: TextStyle(
                      color: isBasicMode ? B_Colors.black : A_Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // 教科選択
                  _buildSubjectChips(),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // 選択中教科の詳細
                  _buildDetailCard(),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }


  // 凡例 教科名＋カラー四角
  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _pieData.keys.toList().asMap().entries.map((entry) {
        final int index = entry.key;
        final String subject = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14, height: 14, color: _getColor(index)),
              const SizedBox(width: 6),
              Text(
                subject,
                style: TextStyle(
                color: A_Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  //  ChoiceChip で教科タブが移動（選択しているタブが広く表示される）
  Widget _buildSubjectChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: _pieData.keys.map((subject) {
          final bool selected = _selected == subject;
          return ChoiceChip(
            label: Text(
              subject,
              style: TextStyle(
                color: A_Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: selected,
            onSelected: (_) => setState(() => _selected = subject),
            selectedColor:
            _getColor(_pieData.keys.toList().indexOf(subject)).withOpacity(0.5),
            backgroundColor: A_Colors.background.withOpacity(0.5),
          );
        }).toList(),
      ),
    );
  }

  //  選択中の教科の頻出ラベルをカード表示
  Widget _buildDetailCard() {
    final items = _details[_selected] ?? [];

    return Card(
      elevation: 2,
      color: A_Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
        color: _getColor(_pieData.keys.toList().indexOf(_selected)),
        width: 2,
      ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.asMap().entries.map(
                (e) {
              // (index, (title, count))
              return ListTile(
                dense: true,
                leading: Text(
                  '${e.key + 1}.',
                  style: TextStyle(
                    color: A_Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  e.value.$1,
                  style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  '${e.value.$2}回',
                  style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

//ドーナツグラフ（fl_chart）
class DonutPieChart extends StatefulWidget {
  final Map<String, double> data;
  const DonutPieChart({super.key, required this.data});

  @override
  State<DonutPieChart> createState() => _DonutPieChartState();
}

class _DonutPieChartState extends State<DonutPieChart> {
  int? touchedIndex; // タップでハイライトするセクション番号

  @override
  Widget build(BuildContext context) {
    // 合計値を先に計算（% 表示用）
    final double total =
    widget.data.values.fold(0.0, (sum, value) => sum + value);

    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,      // セクション間の隙間
          centerSpaceRadius: 60, // 真ん中の “穴” の半径
          startDegreeOffset: -90, // 12時方向から描画開始
          // ------- タップ時の拡大処理 -----------
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                touchedIndex =
                    response?.touchedSection?.touchedSectionIndex ?? -1;
              });
            },
          ),
          // ------- セクション（扇形）生成 -------
          sections: List.generate(widget.data.length, (i) {
            final entry = widget.data.entries.elementAt(i);
            final bool isTouched = i == touchedIndex;
            final double radius = isTouched ? 78 : 65; // タップで少し膨らむ
            final String percentage =
            (entry.value / total * 100).toStringAsFixed(0);

            return PieChartSectionData(
              color: _getColor(i),   // 色
              value: entry.value,    // 数値
              title: '$percentage%', // 円弧上に表示する文字
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

/// カラーパレット
Color _getColor(int index) {
  const colors = [
    Subject_Colors.japanese,  //国語
    Subject_Colors.math,     //数学
    Subject_Colors.science,      //理科
    Subject_Colors.socialstudies,      //社会
    Subject_Colors.english, //英語
  ];
  return colors[index % colors.length];
}
