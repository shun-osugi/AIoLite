import 'package:flutter/material.dart';
import 'colors.dart';

class HelpDialog extends StatefulWidget {
  final String mode; // モード: 'basic' or 'advanced'
  final String content; // 内容: 'home','chat'

  const HelpDialog({Key? key, required this.mode, required this.content}) : super(key: key);

  @override
  _HelpDialogState createState() => _HelpDialogState();
}
class _HelpDialogState extends State<HelpDialog> {
  PageController _pageController = PageController(); // ページコントローラ
  int _currentPage = 0; // 現在のページ

  // ヘルプ内容
  late final List<Map<String, String>> helpPages;

  @override
  void initState() {
    super.initState();

    // ヘルプ文章
    if (widget.content == 'home') { // ホーム画面
      if (widget.mode == 'basic') {
        helpPages = [
          // ベーシック用
          {"image": "assets/help_home_basic/help0.png", "head": "はじめに", "text": "『START』ボタンをおして、もんだいをはじめよう！\nこのアプリのつかいかたがわからなくなったら、いつでもこのヘルプをみてね！"},
          {"image": "assets/help_home_basic/help1.png", "head": "もんだいの いれかた", "text": "もんだいを いれるほうほうは、こえ・しゃしん・もじ の３つ！\nさっそくいれてみようか！"},
          {"image": "assets/help_home_basic/help2.png", "head": "もんだいを なおそう！", "text": "こえ・しゃしんでいれたもんだいが まちがっていたら、なおすことができるよ。"},
          {"image": "assets/help_home_basic/help3.png", "head": "もんだいの ぶんるい", "text": "\nもんだいにあう『かもく』を えらんでね！\nまちがっていても だいじょうぶ。\nえらびなおすことができるよ。"},
          {"image": "assets/help_home_basic/help4.png", "head": "AIと おしゃべりしながら といてみよう！", "text": "もんだいが できたら、AIが おてつだいしてくれるよ。\nこたえがわかったら『とけた！』ボタンを おしてね。\nみぎうえにあるおうちのボタンからいちばんさいしょのページにもどることができるよ。\nそれと、やじるしのマークをおすともういちどさいしょからAIがおてつだいしてくれるよ。"},
          {"image": "assets/help_home_basic/help5.png", "head": "どんなことにつかうのか　つぎのもんだい", "text": "とけたら、これからこのちしきをどうやってつかうのかをAIがおしえてくれるよ！\nにている もんだいにも チャレンジしてみてね！"},
        ];
      } else {
        helpPages = [
          // アドバンス用
          {"image": "assets/help_home_advanced/help0.png", "head": "まずは、STARTボタンを押して問題を送信しよう！", "text": "ここでは、このアプリの使用方法を確認することができます。\n右下のボタンからは、利用規約、ライセンス表示を確認することができます。"},
          {"image": "assets/help_home_advanced/help1.png", "head": "問題の送信方法を選んで、問題を送信しよう！", "text": "送信方法は、音声入力、画像入力(画像ファイルからor写真を撮影)、テキスト入力から選べます。\n音声や画像を送信した場合は、自動でテキストに変換されます。"},
          {"image": "assets/help_home_advanced/help2.png", "head": "問題文の編集をしよう！", "text": "テキスト入力の場合はここで入力、音声や画像で入力した場合は、問題文を修正できます。"},
          {"image": "assets/help_home_advanced/help3.png", "head": "問題のラベル(教科・単元)の編集をしよう！", "text": "\n送信された問題文を元に、自動でいくつかのラベルが選択されます。問題にあったラベルを編集・追加してください。\n最大4つのラベルを選択することができます。"},
          {"image": "assets/help_home_advanced/help4.png", "head": "AIとのチャットを開始！\nAIの質問に答えながら、問題を解いていこう！", "text": "下のテキストボックスからAIへメッセージを送信すると、AIから返答が返ってきます。\n問題が解けたら、「解けた！」ボタンでチャットが終了できます。\nまた、右上のボタンからは、ホーム画面に戻ることや、今の問題をもう一度初めからやり直すことができます。"},
          {"image": "assets/help_home_advanced/help5.png", "head": "チャットを終えると、AIからのフィードバックと類題が表示されるよ！\nフィードバックを参考にして、類題から次の問題を始めてみよう！", "text": "類題を選択することで、新たにAIとのチャットを開始できます。"},
        ];
      }
    }
    if (widget.content == 'chat') { // チャット画面
      if (widget.mode == 'basic') {
        helpPages = [
          // ベーシック用
          {"image": "assets/help_chat_basic/help0.png", "head": "イオとはなそう！", "text": "ここでは、「イオ」とはなしながらもんだいをとくことができるよ！\nイオからのしつもんにこたえたり、イオにしつもんしてみよう！"},
          {"image": "assets/help_chat_basic/help1.png", "head": "ボタンのつかいかた", "text": "はなしたことをふりかえりたいときには、やじるしボタン（← →）をおそう！かいわをふりかえることができるよ！\nイオのしつもんがわからないときは、はてなボタン(？)をおそう！イオがもういちどわかりやすくおしえてくれるよ！"},
          {"image": "assets/help_chat_basic/help2.png", "head": "もんだいをかくにんする", "text": "うえにもんだいのまとめがかいてあるよ！\nもんだいをかくにんしたいときは、ここをおしてかくにんしよう！"},
          {"image": "assets/help_chat_basic/help3.png", "head": "もんだいがおわったら", "text": "もんだいがおわったら、「できた」ボタンをおそう！イオからメッセージがもらえるよ！"},
          {"image": "assets/help_chat_basic/help4.png", "head": "メニューをひらく", "text": "みぎうえのボタンでメニューにきりかえられるよ！\nメニューでは、イオのこえをオフにしたり、もんだいをやりなおすことができるよ！"},
          {"image": "assets/help_chat_basic/help5.png", "head": "メニューないよう", "text": "「おとをだす(おとをださない)」ボタンをおすと、イオがこえをだすかどうかをかえることができるよ！「おとをだす」だと、イオがへんじをしゃべるよ！\n「やりなおす」ボタンをすと、おなじもんだいをはじめからやりなおすことができるよ！\n「ホームにもどる」ボタンをおすと、イオとはなすのをやめて、ホームにもどることができるよ。"},
        ];
      } else {
        helpPages = [
          // アドバンス用
          {"image": "assets/help_chat_advanced/help0.png", "head": "イオと会話しよう！", "text": "ここは、AI教師「イオ」とのチャット画面です。\nイオからの質問に答えたり、イオに質問することで、解き方を理解しながら、問題の答えにたどり着くことができます。"},
          {"image": "assets/help_chat_advanced/help1.png", "head": "問題を確認する", "text": "上部には問題を要約した文章が表示されています。タップすることで、いつでも問題の全文を確認することができます。"},
          {"image": "assets/help_chat_advanced/help2.png", "head": "問題が解けたら", "text": "問題が解けたら、「解けた」ボタンを押して、イオからのフィードバックをもらいましょう！\nフィードバックでは、つまづいたポイントや問題の解説を見ることができます。フィードバックは保存され、ホーム画面から一覧を見ることができます。"},
          {"image": "assets/help_chat_advanced/help3.png", "head": "メニューを開く", "text": "右上のボタンから、チャットとメニューを切り替えることができます。\nメニューでは、音声読み上げのミュート設定や問題のやり直しができます。"},
          {"image": "assets/help_chat_advanced/help4.png", "head": "メニュー内容", "text": "「音声読み上げ：ON(OFF)」ボタンを押すと、音声読み上げのミュート切り替えができます。メニューには現在の設定が表示されています。\n「今の問題をやりなおす」ボタンを押すと、同じ問題をはじめからやりなおすことができます。\n「ホームに戻る」ボタンを押すと、チャットを終了して、ホーム画面に戻ることができます。このとき、フィードバックは保存されません。"},
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
                widget.mode == 'basic'
                    ? "つかいかた"
                    : "使い方",
                style: TextStyle(
                    color:  widget.mode == 'basic'
                        ? B_Colors.black
                        : A_Colors.black,
                    fontSize: widget.mode == 'basic'
                        ? MediaQuery.of(context).size.width * 0.07
                        : MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold)
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            // 画像＋文章
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: helpPages.length,
                physics: AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView( // スクロールを可能にする
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              helpPages[index]['image']!,
                              height: MediaQuery.of(context).size.height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                          // ページタイトル
                          Text(
                            helpPages[index]['head'].toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color:  widget.mode == 'basic'
                                    ? B_Colors.black
                                    : A_Colors.black,
                                fontSize: widget.mode == 'basic'
                                    ? MediaQuery.of(context).size.width * 0.06
                                    : MediaQuery.of(context).size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                          // ヘルプ本文
                          Text(
                            helpPages[index]['text'].toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color:  widget.mode == 'basic'
                                  ? B_Colors.black
                                  : A_Colors.black,
                              fontSize: widget.mode == 'basic'
                                  ? MediaQuery.of(context).size.width * 0.05
                                  : MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // インジケーター（現在のページを示すドット）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(helpPages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? A_Colors.subColor
                        :  widget.mode == 'basic'
                        ? B_Colors.black
                        : A_Colors.black,
                  ),
                );
              }),
            ),

            SizedBox(height: 16),

            // ページ移動UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage > 0
                      ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  child: Text(
                      widget.mode == 'basic'
                          ? "←もどる"
                          : "←戻る",
                      style: TextStyle(
                          color:  widget.mode == 'basic'
                              ? B_Colors.black
                              : A_Colors.black,
                          fontSize: 18
                      ),
                  ),
                ),
                TextButton(
                  onPressed: _currentPage < helpPages.length - 1
                      ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : () {
                    Navigator.pop(context); // 最後のページならダイアログを閉じる
                  },
                  child: Text(
                      _currentPage < helpPages.length - 1
                          ? widget.mode == 'basic'
                            ? "→つぎ"
                            : "→次へ"
                          : widget.mode == 'basic'
                            ? "とじる"
                            : "閉じる",
                      style: TextStyle(
                          color:  widget.mode == 'basic'
                              ? B_Colors.black
                              : A_Colors.black,
                          fontSize: 18
                      ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}