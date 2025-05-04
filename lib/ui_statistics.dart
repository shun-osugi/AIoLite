import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'repository.dart';   // ← さっきのシングルトン

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Repository.I.loadFromDb();      // ① DB → メモリ
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/':      (_) => const HomePage(),
        '/stats': (_) => const StatsPage(),
      },
    );
  }
}

/*────────────────── ホーム画面 */
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      body: Center(
        child: ElevatedButton(
          child: const Text('統計を見る'),
          onPressed: () => Navigator.pushNamed(context, '/stats'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        // フィードバックを追加 → 統計再計算 → setState 先で rebuild
        onPressed: () => Repository.I.add(
          FeedbackData('理科', ['化学']),
        ),
      ),
    );
  }
}

/*────────────────── 統計ページ */
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Stats _stats;
  late List<String> _subjects;
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _refresh();                 // 初回ロード
  }

  void _refresh() {
    _stats    = Repository.I.stats;
    _subjects = _stats.subjectRate.keys.toList();
    _selected = _selected.isEmpty && _subjects.isNotEmpty
        ? _subjects.first
        : _selected;
    setState(() {});            // ← 画面更新
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator.pop から戻った時などに再読込したければここでも _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final hasEnough = Repository.I.stats.subjectRate.length >= 10;

    return Scaffold(
      appBar: AppBar(title: const Text('全体統計')),
      body: _stats.subjectRate.isEmpty
          ? const Center(child: Text('データがありません'))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: DonutPieChart(data: _stats.subjectRate)),
                const SizedBox(width: 16),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 24),
            Text('よく使うラベル',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildChips(),
            const SizedBox(height: 16),
            hasEnough
                ? _buildDetailCard()
                : const Center(
              child: Text('データが足りません'),
            ),
          ],
        ),
      ),
      // FAB を押せば stats 更新 → setState で即反映
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: _refresh,
      ),
    );
  }

  /*―――――――――――――― 業務ロジックを呼び出した後 setState で UI 更新 */

  Widget _buildLegend() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _subjects.asMap().entries.map((e) {
      final i = e.key;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: _color(i)),
            const SizedBox(width: 6),
            Text(e.value),
          ],
        ),
      );
    }).toList(),
  );

  Widget _buildChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Wrap(
      spacing: 8,
      children: _subjects.map((subj) {
        final i = _subjects.indexOf(subj);
        final sel = _selected == subj;
        return ChoiceChip(
          label: Text(subj),
          selected: sel,
          onSelected: (_) => setState(() => _selected = subj),
          selectedColor: _color(i).withOpacity(0.25),
        );
      }).toList(),
    ),
  );

  Widget _buildDetailCard() {
    final items = _stats.tops[_selected] ?? [];
    return Card(
      elevation: 2,
      color: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.asMap().entries.map((e) {
            return ListTile(
              dense: true,
              leading: Text('${e.key + 1}.'),
              title: Text(e.value.$1),
              trailing: Text('${e.value.$2}回'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _color(int i) => [
    Colors.redAccent,
    Colors.indigo,
    Colors.green,
    Colors.amber,
    Colors.blueAccent,
  ][i % 5];
}

/*────────────────── ドーナツグラフ (短縮版) */
class DonutPieChart extends StatelessWidget {
  final Map<String, double> data;
  const DonutPieChart({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (s, v) => s + v);
    return PieChart(
      PieChartData(
        centerSpaceRadius: 60,
        sections: List.generate(data.length, (i) {
          final e = data.entries.elementAt(i);
          return PieChartSectionData(
            color: _color(i),
            value: e.value,
            title: '${(e.value / total * 100).toStringAsFixed(0)}%',
          );
        }),
      ),
    );
  }

  Color _color(int i) => [
    Colors.redAccent,
    Colors.indigo,
    Colors.green,
    Colors.amber,
    Colors.blueAccent,
  ][i % 5];
}
