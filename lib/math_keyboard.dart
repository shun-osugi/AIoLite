import 'package:flutter/material.dart';
import 'colors.dart';

class MathKeyboard extends StatelessWidget {
  final void Function(String latex) onInsert;

  const MathKeyboard({super.key, required this.onInsert});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            A_Colors.white,
            A_Colors.accentColor,
            A_Colors.white
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(top: BorderSide(color: A_Colors.white)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔢 数式入力',
              style: TextStyle(
                color: A_Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('x²', r'x^2', context),
                _buildButton('√', r'\sqrt{}', context),
                _buildButton('分数', r'\frac{}{ }', context),
                _buildButton('π', r'\pi', context),
                _buildButton('∑', r'\sum', context),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '📐 単位',
              style: TextStyle(
                color: A_Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('m/s', 'm/s', context),
                _buildButton('N', 'N', context),
                _buildButton('J', 'J', context),
                _buildButton('mol', 'mol', context),
                _buildButton('Ω', 'Ω', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, String value, BuildContext context) {
    final displayedText = "\$$value\$"; // ← r'' を含めるようにする
    return ElevatedButton(
      onPressed: () => onInsert(displayedText),
      child: Text(
        label,
        style: TextStyle(
          color: A_Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
