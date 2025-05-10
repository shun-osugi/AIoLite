import 'package:flutter/material.dart';
import 'colors.dart';

class MathKeyboard extends StatefulWidget {
  final void Function(String latex) onInsert;

  const MathKeyboard({super.key, required this.onInsert});

  @override
  _MathKeyboardState createState() => _MathKeyboardState();
}

class _MathKeyboardState extends State<MathKeyboard> {
  int currentTab = 0; // 現在のタブ(0:数式,1:単位,2:使い方)

  // タブの変更
  void setTab(int tabNum) {
    setState(() {
      currentTab = tabNum;
    });
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 文字タブ
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setTab(0);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: SizedBox(
                    width: currentTab == 0
                        ? MediaQuery.of(context).size.width * 0.2
                        : MediaQuery.of(context).size.width * 0.12,
                    child: Text(
                      '123',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 0 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // 数式タブ
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setTab(1);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: SizedBox(
                    width: currentTab == 1
                        ? MediaQuery.of(context).size.width * 0.2
                        : MediaQuery.of(context).size.width * 0.12,
                    child: Text(
                      'f(x)',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 1 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // 単位タブ
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setTab(2);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: SizedBox(
                    width: currentTab == 2
                        ? MediaQuery.of(context).size.width * 0.2
                        : MediaQuery.of(context).size.width * 0.12,
                    child: Text(
                      'm/s',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 2 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // 使い方タブ
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setTab(3);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: A_Colors.black,
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: SizedBox(
                    width: currentTab == 3
                        ? MediaQuery.of(context).size.width * 0.2
                        : MediaQuery.of(context).size.width * 0.12,
                    child: Text(
                      '?',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 3 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if(currentTab == 0) ...[
              Text(
                '数字 0~9',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('0', r'\0', context),
                  _buildButton('1', r'\1', context),
                  _buildButton('2', r'\2', context),
                  _buildButton('3', r'\3', context),
                  _buildButton('4', r'\4', context),
                  _buildButton('5', r'\5', context),
                  _buildButton('6', r'\6', context),
                  _buildButton('7', r'\7', context),
                  _buildButton('8', r'\8', context),
                  _buildButton('9', r'\9', context),
                ],

              ),
              const SizedBox(height: 16),
              Text(
                '基本文字',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('a', r'\a', context),
                  _buildButton('b', r'\b', context),
                  _buildButton('x', r'x', context),
                  _buildButton('y', r'y', context),
                  _buildButton('π', r'\pi', context),
                  _buildButton('e', r'\e', context),
                  _buildButton('θ', r'\theta', context),
                  _buildButton('ω', r'\omega', context),
                  _buildButton('t', r'\t', context),
                  _buildButton('m', r'\m', context),
                  _buildButton('g', r'\g', context),
                  _buildButton('S', r'\S', context),
                  _buildButton('l', r'\l', context),
                ],
              ),

            ],

            if(currentTab == 1) ...[
              Text(
                '基本計算',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('＋', r'\+', context),
                  _buildButton('－', r'\-', context),
                  _buildButton('×', r'\times', context),
                  _buildButton('÷', r'\div', context),
                  _buildButton('＝', r'\=', context),
                  _buildButton('≡', r'\equiv', context),
                  _buildButton('>', r'\>', context),
                  _buildButton('<', r'\<', context),
                  _buildButton('≥', r'\ge', context),
                  _buildButton('≤', r'\le', context),
                  _buildButton('（', r'\(', context),
                  _buildButton('）', r'\)', context),
                  _buildButton('±', r'\pm', context),
                  _buildButton('∓', r'\mp', context),
                ],

              ),
              const SizedBox(height: 16),
              Text(
                '数式',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('x²', r'x^2', context),
                  _buildButton('a₁', r'a_1', context),
                  _buildButton('√x', r'\sqrt{x}', context),
                  _buildButton('分数', r'\frac{分子}{分母}', context),
                  _buildButton('sin', r'\sin', context),
                  _buildButton('cos', r'\cos', context),
                  _buildButton('tan', r'\tan', context),
                ],
              ),

            ],

            if(currentTab == 2) ...[
              Text(
                '単位',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('/', '/', context),
                  _buildButton('m', 'm', context),
                  _buildButton('kg', 'kg', context),
                  _buildButton('s', 's', context),
                  _buildButton('θ', r'\theta', context),
                  _buildButton('rad', 'rad', context),
                  _buildButton('A', 'A', context),
                  _buildButton('V', 'V', context),
                  _buildButton('Ω', 'Ω', context),
                  _buildButton('N', 'N', context),
                  _buildButton('J', 'J', context),
                  _buildButton('Pa', 'Pa', context),
                  _buildButton('mol', 'mol', context),
                ],

              ),
            ],

            if(currentTab == 3)
              Text(
                '',
                style: TextStyle(

                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, String value, BuildContext context) {
    final displayedText = "\$$value\$"; // ← r'' を含めるようにする
    return ElevatedButton(
      onPressed: () => widget.onInsert(displayedText),
      child: Text(
        label,
        style: TextStyle(
          color: A_Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
