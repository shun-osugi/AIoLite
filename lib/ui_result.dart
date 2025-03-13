import 'package:flutter/material.dart';
import 'api_service.dart';     // API呼び出し用
import 'colors.dart';

class ResultPage extends StatefulWidget {
  final String text;

  const ResultPage({Key? key, required this.text}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<String>> _suggestedDataFuture;

  @override
  void initState() {
    super.initState();
    // APIからフィードバック用テキスト＆類題ラベルのリスト を取得する想定
    _suggestedDataFuture = _fetchData(widget.text);
  }

  //APIからデータ取得
  Future<List<String>> _fetchData(String text) async {
    try {
      // ApiService.classifyText が List<String> を返す前提
      return await ApiService.classifyText(text);
    } catch (e) {
      // エラーの場合は投げ直す（FutureBuilder 側で捕捉し表示）
      throw Exception("データ取得時にエラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィードバック'),
        backgroundColor: AppColors.mainColor,
      ),
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              //アバターを表示させるスペース用の空白
              const SizedBox(height: 80),

              //フィードバックを表示する吹き出し
              FutureBuilder<List<String>>(
                future: _suggestedDataFuture,
                builder: (context, snapshot) {
                  Widget feedbackWidget;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // ローディング中
                    feedbackWidget = const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // エラー発生時
                    feedbackWidget = Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    );
                  } else {
                    // 正常にデータ取得できた場合
                    final data = snapshot.data ?? [];
                    // 先頭をフィードバック用テキストとみなす
                    final feedbackText = data.isNotEmpty
                        ? data.first
                        : 'フィードバック内容がありません';

                    feedbackWidget = Text(
                      feedbackText,
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: feedbackWidget,
                  );
                },
              ),

              //類題の提示
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<List<String>>(
                  future: _suggestedDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      );
                    } else {
                      final data = snapshot.data ?? [];
                      // 2番目以降を類題リストとみなす
                      final labels = data.length > 1
                          ? data.sublist(1)
                          : <String>[];

                      if (labels.isEmpty) {
                        return const Text('類題のラベルがありません');
                      }
                      return Text(labels.join('\n'));
                    }
                  },
                ),
              ),

              //ホーム画面に戻るボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor, // ボタン色
                    foregroundColor: AppColors.white,     // 文字色
                  ),
                  onPressed: () {
                    // ルート指定でホーム画面へ戻る
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('ホーム画面へ戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
