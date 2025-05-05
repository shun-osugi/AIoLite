// 全体統計画面（ホーム画面から統計ボタンクリックで遷移）
// 教科別ドーナツグラフと "よく使う分野" リストを DB から動的生成

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ps_hacku_osaka/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

//フィードバックデータの定義
class FeedbackData {
  int id;
  List<String> subject;
  List<String> field;
  String problem;
  String summary;
  String wrong;
  String wrongpartans;
  String correctans;

  FeedbackData(
      this.id,
      this.subject,
      this.field,
      this.problem,
      this.summary,
      this.wrong,
      this.wrongpartans,
      this.correctans,
      );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //PC上でもデータベース使えるようにする
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; //←これが無いとBad stateエラー
  }

  runApp(const MyApp());
}

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

//統計ページ
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<FeedbackData> _fbList = [];                   //取得したレコード
  final Map<String, double> _pieData = {};                 // 教科別割合 (%)
  final Map<String, List<(String, int)>> _details = {};    // 教科 → 上位(3分野, 回数)

  String _selected = '国語';                                //ラベル使用回数ランキング表示で最初に選択してある教科
  late Database _database;
  bool _isLoading = true;                                  //読み込みが終わらない問題の対策


  @override
  void initState() {
    super.initState();
    _initDatabaseAndStats();
  }

  //統計データを画面に表示
  Future<void> _initDatabaseAndStats() async {
    try {
      await _openDatabase();         //DBつくる
      await _readAllFeedback();      //全データ読み出す
    } catch (e) {
      // エラー内容をデバッグ出力して無視（空データで継続）
      debugPrint('DB Error: $e');
    } finally {
      _calcStats();             //データが無くても必ず円グラフ用データを作る
      if (mounted) {
        setState(() => _isLoading = false);  //UIの再ビルド
      }
    }
  }

  //googleCromeで動作確認するための処理 後で消す？
  Future<void> _openDatabase() async {
    // Android/iOS: /data/data/<pkg>/databases
    // macOS/Windows/linux: getDatabasesPath() がホーム配下を返す
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, 'database.db');
    // Windows デバッグ時にフォルダが無いと openDatabase が失敗するので ensure
    if (!Directory(dbDir).existsSync()) Directory(dbDir).createSync(recursive: true);

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            field   TEXT,
            problem TEXT,
            summary TEXT,
            wrong TEXT,
            wrongpartans TEXT,
            correctans TEXT
          )''');
      },
    );
  }//↑後で消すかもここまで

  //フィードバックデータを読んで要素ごとに格納
  Future<void> _readAllFeedback() async {
    final rows = await _database.query('feedback');
    for (final r in rows) {
      _fbList.add(
        FeedbackData(
          r['id'] as int,
          (r['subject'] as String).split('&&'),
          (r['field'] as String).split('&&'),
          r['problem'] as String,
          r['summary'] as String,
          r['wrong'] as String,
          r['wrongpartans'] as String,
          r['correctans'] as String,
        ),
      );
    }
  }

  //データ集計
  void _calcStats() {
    //データがなかったらデータなしと書いたグラフを表示
    if (_fbList.isEmpty) {
      _pieData.clear();
      _pieData['データなし'] = 1;
      _details.clear();
      _selected = _pieData.keys.first;
      return;
    }

    //教科・分野をカウント
    final subjectCount = <String, int>{};
    final fieldCountBySubject = <String, Map<String, int>>{};
    //複数ラベルが含まれていいる時用
    for (final fb in _fbList) {
      for (final sub in fb.subject) {
        subjectCount[sub] = (subjectCount[sub] ?? 0) + 1;
        fieldCountBySubject.putIfAbsent(sub, () => {});
        for (final fld in fb.field) {
          fieldCountBySubject[sub]![fld] =
              (fieldCountBySubject[sub]![fld] ?? 0) + 1;
        }
      }
    }

    //円グラフ用のデータを作成
    final total = _fbList.length;
    _pieData
      ..clear()
      ..addEntries(subjectCount.entries.map(
            (e) => MapEntry(e.key, e.value / total * 100),
      ));

    //各教科のラベル使用ランキング生成
    _details.clear();
    for (final sub in subjectCount.keys) {
      final fieldMap = fieldCountBySubject[sub] ?? {};
      if (fieldMap.length < 3) {
        _details[sub] = [];    //データ不足の時用
        continue;
      }
      final top3 = fieldMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _details[sub] = top3.take(3).map((e) => (e.key, e.value)).toList();
    }
    //最初「国語」のタブを開く
    _selected = _pieData.keys.first;
  }

  //UI
  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isBasicMode = args?['isBasicMode'] ?? false;

    //ローディングインジケータ
    if (_isLoading) {
      return Scaffold(
        backgroundColor:
        isBasicMode ? B_Colors.background : A_Colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    //画面本体
    return Scaffold(
      appBar: _buildAppBar(isBasicMode, context),
      backgroundColor:
      isBasicMode ? B_Colors.background : A_Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildPieArea(isBasicMode),//円グラフと凡例用
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildLabelArea(isBasicMode),//ラベルランキング用
            ],
          ),
        ),
      ),
    );
  }

  /* ---------- 分割ウィジェット ---------- */
  AppBar _buildAppBar(bool isBasicMode, BuildContext context) => AppBar(
    backgroundColor: isBasicMode ? B_Colors.mainColor : A_Colors.black,
    toolbarHeight: MediaQuery.of(context).size.height * 0.07,
    leading: IconButton(  //戻るボタン
      icon: Icon(
        Icons.arrow_back,
        color: A_Colors.white,
        size: MediaQuery.of(context).size.width * 0.1,
      ),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
      isBasicMode ? 'おべんきょうのきろく' : '全体統計',  //ヘッダータイトル
      style: TextStyle(
        color: A_Colors.white,
        fontSize: MediaQuery.of(context).size.width * 0.06,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
  );

  //円グラフ＋凡例部分
  Widget _buildPieArea(bool isBasicMode) => Container(
    width: MediaQuery.of(context).size.width * 0.9,
    decoration: BoxDecoration(
      color: A_Colors.white,
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
            color: A_Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: DonutPieChart(data: _pieData)),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            _buildLegend(),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          ],
        ),
      ],
    ),
  );

  //ラベル使用ランキング部分
  Widget _buildLabelArea(bool isBasicMode) => Container(
    width: MediaQuery.of(context).size.width * 0.9,
    decoration: BoxDecoration(
      color: A_Colors.white,
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
            color: A_Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        _buildSubjectChips(),  //タブ切り替えボタン
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        _buildDetailCard(),    //ランキングデータ表示部分
      ],
    ),
  );

  /* ---------- 凡例 ---------- */
  Widget _buildLegend() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _pieData.keys.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: _getColor(index)),
            const SizedBox(width: 6),
            Text(
              subject,
              style: _tileTextStyle(context),
            ),
          ],
        ),
      );
    }).toList(),
  );

  // 教科タブ（クリックできるところ）
  Widget _buildSubjectChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Wrap(
      spacing: 8,
      children: _pieData.keys.map((subject) {
        final selected = _selected == subject;
        return ChoiceChip(
          label: Text(subject, style: _tileTextStyle(context)),
          selected: selected,
          onSelected: (_) => setState(() => _selected = subject),
          selectedColor: _getColor(_pieData.keys.toList().indexOf(subject))
              .withOpacity(0.5),
          backgroundColor: A_Colors.background.withOpacity(0.5),
        );
      }).toList(),
    ),
  );

  //各教科のラベル使用ランキングをカード表示
  Widget _buildDetailCard() {
    final items = _details[_selected] ?? [];

    //データ不足の時
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'データが不足しています',
          style: _tileTextStyle(context),
          textAlign: TextAlign.center,
        ),
      );
    }

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
          children: items.asMap().entries.map((e) {
            return ListTile(
              dense: true,
              leading: Text('${e.key + 1}.', style: _tileTextStyle(context)),
              title: Text(e.value.$1, style: _tileTextStyle(context)),
              trailing:
              Text('${e.value.$2}回', style: _tileTextStyle(context)),
            );
          }).toList(),
        ),
      ),
    );
  }

  TextStyle _tileTextStyle(BuildContext context) => TextStyle(
    color: A_Colors.black,
    fontSize: MediaQuery.of(context).size.width * 0.04,
    fontWeight: FontWeight.bold,
  );
}

//ドーナツグラフ
class DonutPieChart extends StatefulWidget {
  final Map<String, double> data;
  const DonutPieChart({super.key, required this.data});

  @override
  State<DonutPieChart> createState() => _DonutPieChartState();
}

class _DonutPieChartState extends State<DonutPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold<double>(0, (s, v) => s + v);

    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          startDegreeOffset: -90,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                touchedIndex = response?.touchedSection?.touchedSectionIndex ??
                    -1;
              });
            },
          ),
          sections: List.generate(widget.data.length, (i) {
            final entry = widget.data.entries.elementAt(i);
            final isTouched = i == touchedIndex;
            final radius = isTouched ? 78.0 : 65.0;
            final percentage = (entry.value / total * 100).toStringAsFixed(0);

            return PieChartSectionData(
              color: _getColor(i),
              value: entry.value,
              title: '$percentage%',
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

/* ------------------------------------------------------------------
 *  固定カラーパレット
 * ----------------------------------------------------------------*/
Color _getColor(int index) {
  const colors = [
    Subject_Colors.japanese,
    Subject_Colors.math,
    Subject_Colors.science,
    Subject_Colors.socialstudies,
    Subject_Colors.english,
  ];
  return colors[index % colors.length];
}
