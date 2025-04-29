// 全体統計画面（ホーム画面から統計ボタンクリックで遷移）
// ドーナツ型グラフ、各教科のよく使うラベルを一覧表示
// データは仮置き、データベースとの連携は未実装

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(), // ← 戻るボタン
        title: const Text('全体統計'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ドーナツグラフ＋凡例
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ドーナツグラフをできるだけ大きく表示
                Expanded(child: DonutPieChart(data: _pieData)),
                const SizedBox(width: 16),
                // グラフと凡例を縦並びで
                _buildLegend(),
              ],
            ),

            const SizedBox(height: 24),

            //ラベルタブ（よく使うラベル）
            Text(
              'よく使うラベル',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildSubjectChips(),

            const SizedBox(height: 16),

            // 選択中教科の詳細
            _buildDetailCard(),
          ],
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
              Text(subject, style: const TextStyle(fontSize: 14)),
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
            label: Text(subject),
            selected: selected,
            onSelected: (_) => setState(() => _selected = subject),
            selectedColor:
            _getColor(_pieData.keys.toList().indexOf(subject)).withOpacity(0.25),
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
      color: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.asMap().entries.map(
                (e) {
              // (index, (title, count))
              return ListTile(
                dense: true,
                leading: Text('${e.key + 1}.'),
                title: Text(e.value.$1),
                trailing: Text('${e.value.$2}回'),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // 教科タブのカラーパレット
  Color _getColor(int index) {
    const colors = [
      Colors.redAccent,  //国語
      Colors.indigo,     //数学
      Colors.green,      //理科
      Colors.amber,      //社会
      Colors.blueAccent, //英語
    ];
    return colors[index % colors.length];
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
      aspectRatio: 1.2, // 幅:高さ ≒ 1:1.2
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

  /// グラフ用カラーパレット（教科タブの色と一緒）
  Color _getColor(int index) {
    const colors = [
      Colors.redAccent,
      Colors.indigo,
      Colors.green,
      Colors.amber,
      Colors.blueAccent,
    ];
    return colors[index % colors.length];
  }
}
