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
    if (widget.content == 'home') {
      // ホーム画面
      if (widget.mode == 'basic') {
        helpPages = [
          // ベーシック用
          {"image": "assets/help_home_basic/help0.png", "head": "はじめに", "text": "「START」ボタンをおして、もんだいをはじめよう！\nこのアプリのつかいかたがわからなくなったら、いつでもこのヘルプをみてね！"},
          {"image": "assets/help_home_basic/help1.png", "head": "もんだいの おくりかた", "text": "もんだいを おくるほうほうは、こえ・しゃしん・もじ の３つ！\nこえやしゃしんは じどうで もじになるよ！"},
          {"image": "assets/help_home_basic/help2.png", "head": "もんだいを かこう！", "text": "もんだいをもじでかこう！\nこえ・しゃしんでいれたもんだいが まちがっていたら、ここでなおすことができるよ。"},
          {"image": "assets/help_home_basic/help3.png", "head": "イオと おしゃべりしながら といてみよう！", "text": "もんだいが できたら、イオが おてつだいしてくれるよ。\nこたえがわかったら「できた！」ボタンを おしてね。"},
          {"image": "assets/help_home_basic/help4.png", "head": "もんだいがとけたら", "text": "もんだいがとけたら、「できた！」ボタンをおそう！イオからのメッセージがもらえるよ！\nさっそくもんだいをおくってはじめてみよう！"},
          {"image": "assets/help_home_basic/help5.png", "head": "おべんきょうのきろく", "text": "といたもんだいのかずは きょうかごとにきろくされているよ！\n「モードをえらぶ」ボタンのとなりのボタンからみてみよう！"},
        ];
      } else {
        helpPages = [
          // アドバンス用
          {"image": "assets/help_home_advanced/help0.png", "head": "まずは、「START」ボタンを押して問題を送信しよう！", "text": "ここでは、このアプリの使用方法を確認することができます。\n右上のハンバーガーメニューからは、本アプリの使い方のほか、利用規約やライセンス情報を確認できます。また、音声読み上げ機能のON/OFFの切り替えもこちらから行えます。"},
          {"image": "assets/help_home_advanced/help1.png", "head": "問題の送信方法を選んで、問題を送信しよう！", "text": "送信方法は、音声入力、画像入力(画像ファイルからor写真を撮影)、テキスト入力から選べます。\n音声や画像を送信した場合は、自動でテキストに変換されます。"},
          {"image": "assets/help_home_advanced/help2.png", "head": "問題文の編集をしよう！", "text": "テキスト入力の場合はここで入力、音声や画像で入力した場合は、問題文を修正できます。\n数式や単位は、専用入力ボタンを使うと簡単に入力できます。"},
          {"image": "assets/help_home_advanced/help3.png", "head": "問題のラベル(教科・単元)の編集をしよう！", "text": "\n送信された問題文を元に、自動でいくつかのラベルが選択されます。問題にあったラベルを編集・追加してください。\n最大4つのラベルを選択することができます。"},
          {
            "image": "assets/help_home_advanced/help4.png",
            "head": "イオとのチャットを開始！\nイオの質問に答えながら、問題を解いていこう！",
            "text": "AI教師「イオ」へメッセージを送信すると、イオから返答が返ってきます。イオと会話しながら問題を解いていきましょう。\n問題が解けたら、「解けた！」ボタンで振り返りへ移動できます。"
          },
          {"image": "assets/help_home_advanced/help5.png", "head": "フィードバックや類題を確認してみよう！", "text": "フィードバックでは、つまづいたポイントや正しい解き方を確認することができます。\n解きたい類題を選択することで、すぐにチャットを開始できます。"},
          {
            "image": "assets/help_home_advanced/help6.png",
            "head": "学習を振り返る便利機能！",
            "text": "「モードを選択」ボタンの隣にある二つのボタンからは、「フィードバック一覧」と「全体統計」を見ることができます。\nフィードバック一覧では、これまでに解いた問題のフィードバックを一覧でみることができ、特定の教科やラベルの問題だけを表示することもできます。\n全体統計では、各教科ごとの解いた問題数や、使用回数の多いラベルを見ることができます。"
          },
        ];
      }
    }
    if (widget.content == 'chat') {
      // チャット画面
      if (widget.mode == 'basic') {
        helpPages = [
          // ベーシック用
          {"image": "assets/help_chat_basic/help0.png", "head": "イオとはなそう！", "text": "ここでは、「イオ」とはなしながらもんだいをとくことができるよ！\nイオからのしつもんにこたえたり、イオにしつもんしてみよう！"},
          {"image": "assets/help_chat_basic/help1.png", "head": "ボタンのつかいかた", "text": "はなしたことをふりかえりたいときには、やじるしボタン（← →）をおそう！かいわをふりかえることができるよ！\nイオのしつもんがわからないときは、はてなボタン(？)をおそう！イオがもういちどわかりやすくおしえてくれるよ！"},
          {"image": "assets/help_chat_basic/help2.png", "head": "もんだいをかくにんする", "text": "うえにもんだいのまとめがかいてあるよ！\nもんだいをかくにんしたいときは、ここをおしてかくにんしよう！"},
          {"image": "assets/help_chat_basic/help3.png", "head": "もんだいがとけたら", "text": "もんだいがとけたら、「できた！」ボタンをおそう！イオからのメッセージがもらえるよ！"},
          {"image": "assets/help_chat_basic/help4.png", "head": "メニューをひらく", "text": "みぎうえのボタンでメニューにきりかえられるよ！\nメニューでは、イオのこえをオフにしたり、もんだいをやりなおすことができるよ！"},
          {
            "image": "assets/help_chat_basic/help5.png",
            "head": "メニューないよう",
            "text": "「いま：よみあげON(OFF)」ボタンをおすと、イオがこえをだすかどうかをかえることができるよ！「いま：よみあげON」だと、イオがへんじをしゃべるよ！\n「やりなおす」ボタンをすと、おなじもんだいをはじめからやりなおすことができるよ！\n「ホームにもどる」ボタンをおすと、イオとはなすのをやめて、ホームにもどることができるよ。"
          },
        ];
      } else {
        helpPages = [
          // アドバンス用
          {"image": "assets/help_chat_advanced/help0.png", "head": "イオと会話しよう！", "text": "ここは、AI教師「イオ」とのチャット画面です。\nイオからの質問に答えたり、イオに質問することで、解き方を理解しながら、問題の答えにたどり着くことができます。"},
          {"image": "assets/help_chat_advanced/help1.png", "head": "問題を確認する", "text": "上部には問題を要約した文章が表示されています。タップすることで、いつでも問題の全文を確認することができます。"},
          {
            "image": "assets/help_chat_advanced/help2.png",
            "head": "問題が解けたら",
            "text": "問題が解けたら、「解けた」ボタンを押して、イオからのフィードバックをもらいましょう！\nフィードバックでは、つまづいたポイントや問題の解説を見ることができます。フィードバックは保存され、ホーム画面から一覧を見ることができます。"
          },
          {"image": "assets/help_chat_advanced/help3.png", "head": "メニューを開く", "text": "右上のボタンから、チャットとメニューを切り替えることができます。\nメニューでは、音声読み上げのミュート設定や問題のやり直しができます。"},
          {
            "image": "assets/help_chat_advanced/help4.png",
            "head": "メニュー内容",
            "text": "「現在：読み上げON(OFF)」ボタンを押すと、音声読み上げのミュート切り替えができます。メニューには現在の設定が表示されています。\n「今の問題をやりなおす」ボタンを押すと、同じ問題をはじめからやりなおすことができます。\n「ホームに戻る」ボタンを押すと、チャットを終了して、ホーム画面に戻ることができます。このとき、フィードバックは保存されません。"
          },
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
            Text(widget.mode == 'basic' ? "つかいかた" : "使い方",
                style: TextStyle(
                    color: widget.mode == 'basic' ? B_Colors.black : A_Colors.black,
                    fontSize: widget.mode == 'basic' ? MediaQuery.of(context).size.width * 0.07 : MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold)),

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
                  return SingleChildScrollView(
                    // スクロールを可能にする
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
                                color: widget.mode == 'basic' ? B_Colors.black : A_Colors.black,
                                fontSize: widget.mode == 'basic' ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                          // ヘルプ本文
                          Text(
                            helpPages[index]['text'].toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: widget.mode == 'basic' ? B_Colors.black : A_Colors.black,
                              fontSize: widget.mode == 'basic' ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.04,
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
                        : widget.mode == 'basic'
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
                    widget.mode == 'basic' ? "←もどる" : "←戻る",
                    style: TextStyle(color: widget.mode == 'basic' ? B_Colors.black : A_Colors.black, fontSize: 18),
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
                    style: TextStyle(color: widget.mode == 'basic' ? B_Colors.black : A_Colors.black, fontSize: 18),
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
