import 'package:flutter/material.dart';
import 'api_service.dart';  // ApiService をインポート
import 'colors.dart';

void main() {
  runApp(ResultPage());
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isLoading = false; // ローディング状態
  List<String> _suggestedLabels = []; // APIから取得したラベル

  // APIからデータを取得するメソッド
  Future<void> _getSuggestedLabels(String text) async {
    setState(() {
      _isLoading = true; // ローディング開始
    });

    try {
      List<String> labels = await ApiService.classifyText(text);
      setState(() {
        _suggestedLabels = labels;
        _isLoading = false; // ローディング終了
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // エラー発生時もローディング終了
      });
      // エラーハンドリング（UIでエラーメッセージを表示する場合など）
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("類題の表示"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ローディング中の表示
            if (_isLoading)
              Center(child: CircularProgressIndicator()),

            // 類題の表示
            if (!_isLoading && _suggestedLabels.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestedLabels.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestedLabels[index]),
                    );
                  },
                ),
              ),
            // ラベルがない場合のメッセージ
            if (!_isLoading && _suggestedLabels.isEmpty)
              Center(child: Text("類題がありません")),
          ],
        ),
      ),
    );
  }
}
