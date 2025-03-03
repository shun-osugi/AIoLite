import 'package:flutter/material.dart';
import 'main.dart';
import 'ui_chat.dart';

void main() {
  runApp(ResultPage());
}

class ResultPage extends StatelessWidget {
    const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "feedback",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}

