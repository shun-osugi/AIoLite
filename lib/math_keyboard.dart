import 'package:flutter/material.dart';
import 'colors.dart';

class MathKeyboard extends StatefulWidget {
  final void Function(String latex) onInsert;
  final bool mode;

  const MathKeyboard({super.key, required this.onInsert, required this.mode});

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
                    backgroundColor: widget.mode ? B_Colors.background : A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: widget.mode ? B_Colors.white : A_Colors.black,
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
                      TextStyle(color: widget.mode ? B_Colors.white : A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 0 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
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
                    backgroundColor: widget.mode ? B_Colors.background : A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: widget.mode ? B_Colors.white : A_Colors.black,
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
                      TextStyle(color: widget.mode ? B_Colors.white : A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 1 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
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
                    backgroundColor: widget.mode ? B_Colors.background : A_Colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: widget.mode ? B_Colors.white : A_Colors.black,
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
                      TextStyle(color: widget.mode ? B_Colors.white : A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 2 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
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
                    backgroundColor: A_Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      side: BorderSide(
                        color: widget.mode ? B_Colors.white : A_Colors.black,
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
                      TextStyle(color: widget.mode ? B_Colors.white : A_Colors.black, fontWeight: FontWeight.bold, fontSize: currentTab == 3 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04),
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
                widget.mode ? 'すうじ 0~9' : '数字 0~9',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('0', '0', context),
                  _buildButton('1', '1', context),
                  _buildButton('2', '2', context),
                  _buildButton('3', '3', context),
                  _buildButton('4', '4', context),
                  _buildButton('5', '5', context),
                  _buildButton('6', '6', context),
                  _buildButton('7', '7', context),
                  _buildButton('8', '8', context),
                  _buildButton('9', '9', context),
                ],

              ),
              const SizedBox(height: 16),
              Text(
                widget.mode ? 'もじ' : '基本文字',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('a', 'a', context),
                  _buildButton('b', 'b', context),
                  _buildButton('x', 'x', context),
                  _buildButton('y', 'y', context),
                  _buildButton('π', r'\pi', context),
                  _buildButton('e', 'e', context),
                  _buildButton('θ', r'\theta', context),
                  _buildButton('ω', r'\omega', context),
                  _buildButton('t', 't', context),
                  _buildButton('m', 'm', context),
                  _buildButton('g', 'g', context),
                  _buildButton('S', 'S', context),
                  _buildButton('l', 'l', context),
                ],
              ),

            ],

            if(currentTab == 1) ...[
              Text(
                '基本計算',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('＋', '+', context),
                  _buildButton('－', '-', context),
                  _buildButton('×', r'\times', context),
                  _buildButton('÷', r'\div', context),
                  _buildButton('＝', '=', context),
                  _buildButton('≡', r'\equiv', context),
                  _buildButton('>', '>', context),
                  _buildButton('<', '<', context),
                  _buildButton('≥', r'\ge', context),
                  _buildButton('≤', r'\le', context),
                  _buildButton('(', '(', context),
                  _buildButton(')', ')', context),
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
                widget.mode ? 'たんい' : '単位',
                style: TextStyle(
                  color: A_Colors.black,
                  fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
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

            if (currentTab == 3)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode ? 'つかいかた' : '使い方',
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.mode
                        ? '① 好きなタブをえらんで、ボタンをおすと数式がかんたんに入るよ！\n'
                        '② 入れた式は、キレイに見えるから安心！\n'
                        '③ 「分数」のボタンをおすと、「分子」と「分母」のところにすきなすうじやもじを入れるだけ！\n\n'
                        '📘 タブのせつめい：\n'
                        '・123：すうじやアルファベット、よく使うきごう\n'
                        '・f(x)：たしざんやぶんすうなど\n'
                        '・m/s：さんすうやりかで使うたんい（メートルなど）\n'
                        '・？：このせつめいを見るタブ\n\n'
                        '📝 コツ：\n'
                        '・ボタンをおしたあとに「ちょっとだけ へんこう」もできるよ。\n'
                        '　たとえば、x²の「2」を「3」にすれば、x³になるよ！'
                        : '① 好きなタブを選んでボタンを押すと、数式が入力されます。\n'
                        '② 入力された数式は、見た目もきれいに表示されるので安心！\n'
                        '③ 例えば「分数」を押すと「分子」と「分母」の場所に好きな文字を入れるだけでOK！\n\n'
                        '📘 タブの説明:\n'
                        '・123：数字やアルファベット、よく使う記号\n'
                        '・f(x)：計算記号（＋や√など）や関数（sinやcosなど）\n'
                        '・m/s：物理や化学で使う単位\n'
                        '・？：この説明タブ\n\n'
                        '📝 コツ：\n'
                        '・ボタンを押すと「\$…\$」で囲まれた数式が入力されます。\n'
                        '・そのまま編集してもOK！例えば、x^2の「2」を「3」に変えればx³になります。',
                    style: TextStyle(
                      color: A_Colors.black,
                      fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      onPressed: () => widget.onInsert(displayedText),
      child: Text(
        label,
        style: TextStyle(
          color: A_Colors.black,
          fontSize: widget.mode ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
