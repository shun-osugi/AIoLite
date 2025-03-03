import 'package:flutter/material.dart';
import 'main.dart';
import 'ui_result.dart';

void main() {
  runApp(ChatPage());
}

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "chat",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/result');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
