import 'dart:convert';
import 'package:http/http.dart' as http;

// APIサーバーのIPを定数で管理（変更しやすい）
const String API_BASE_URL = "http://10.0.2.2:8000";


class ApiService {
  // 推奨ラベルを返すAPIを呼び出す
  static Future<List<String>> classifyText(String text) async {
    final url = Uri.parse("$API_BASE_URL/classify"); // APIのエンドポイント

    print("Sending request to: $url");
    print("Request body: ${jsonEncode({"text": text})}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["suggested_labels"]); // 推奨ラベルを返す
    } else {
      throw Exception("Failed to classify text");
    }
  }

  // テキストとラベルを保存するAPI
  static Future<void> storeText(String text, List<String> labels) async {
    final url = Uri.parse("$API_BASE_URL/store");

    print("Sending request to: $url");
    print("Request body: ${jsonEncode({"text": text, "labels": labels})}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "labels": labels}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to store text");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
