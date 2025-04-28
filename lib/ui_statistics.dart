import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutPieChart extends StatefulWidget {
  final Map<String, double> data;

  const DonutPieChart({super.key, required this.data});

  @override
  _DonutPieChartState createState() => _DonutPieChartState();
}

class _DonutPieChartState extends State<DonutPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (a, b) => a + b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(widget.data.length, (i) {
                final entry = widget.data.entries.elementAt(i);
                final percentage = (entry.value / total * 100);
                final isTouched = i == touchedIndex;
                final double radius = isTouched ? 80 : 70;

                return PieChartSectionData(
                  color: _getColor(i),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
            swapAnimationDuration: Duration(milliseconds: 600),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          children: widget.data.keys.toList().asMap().entries.map((entry) {
            final i = entry.key;
            final subject = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 16, height: 16, color: _getColor(i)),
                const SizedBox(width: 4),
                Text(subject, style: TextStyle(fontSize: 16)),
              ],
            );
          }).toList(),
        )
      ],
    );
  }

  Color _getColor(int index) {
    const colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red];
    return colors[index % colors.length];
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('教科別学習割合')),
    body: Center(
      child: DonutPieChart(
        data: {
          '国語': 10,
          '算数': 20,
          '理科': 8,
          '社会': 12,
          '英語': 15,
        },
      ),
    ),
  );
}

