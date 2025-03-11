import 'package:flutter/material.dart';
import 'api_service.dart'; // ApiService をインポート

class ResultPage extends StatefulWidget {
  final String text; // 類題を検索する元のテキスト

  const ResultPage({super.key, required this.text});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<String>> _suggestedLabelsFuture;

  @override
  void initState() {
    super.initState();
    _suggestedLabelsFuture = _getSuggestedLabels(widget.text);
  }

  // APIから類題のラベルを取得する
  Future<List<String>> _getSuggestedLabels(String text) async {
    try {
      return await ApiService.classifyText(text);
    } catch (e) {
      print("Error: $e");
      return []; // エラー時は空リストを返す
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
        child: FutureBuilder<List<String>>(
          future: _suggestedLabelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // ローディング表示
            } else if (snapshot.hasError) {
              return Center(child: Text("エラーが発生しました"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("類題がありません"));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
