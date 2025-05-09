import 'package:flutter/material.dart';

class MathPopup extends StatelessWidget {
  final void Function(String latex) onInsert;

  const MathPopup({super.key, required this.onInsert});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('数式・単位入力'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔢 数式入力', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('x²', r'x^2'),
                _buildButton('√', r'\sqrt{}'),
                _buildButton('分数', r'\frac{}{ }'),
                _buildButton('π', r'\pi'),
                _buildButton('∑', r'\sum'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('📐 単位', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('m/s', 'm/s'),
                _buildButton('N', 'N'),
                _buildButton('J', 'J'),
                _buildButton('mol', 'mol'),
                _buildButton('Ω', 'Ω'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildButton(String label, String value) {
    final displayedText = "r'$value'"; // ← r'' を含めるようにする
    return ElevatedButton(
      onPressed: () => onInsert(displayedText),
      child: Text(label),
    );
  }
}
