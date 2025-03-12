import 'package:flutter/material.dart';
import 'main.dart';
import 'ui_result.dart';
import 'colors.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
const apiKey = 'AIzaSyBKSKfHy_6DjTpx-3Zep78Vf-FXZWP1Tsw';

class chat{
  int p; //0:自分 1:相手
  String str; //会話内容
  chat(this.p,this.str);
}

void main() {
  runApp(ChatPage());
}

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String inputText = "";
  final TextEditingController _textController = TextEditingController();
  List<chat> chats = []; //会話リスト
  late final GenerativeModel _model;
  late final ChatSession AI;

  @override
  void initState() {
    super.initState();
    // dotenv.load(fileName: ".env");
    // var apiKey = dotenv.get('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    AI = _model.startChat();
    AI.sendMessage(Content.text('これから送る問題を教えて欲しいのですが、解き方を一気に教えられても難しいので順序立てて出力し、こちらの解答を待ってから次にやることを出力するようにしてください'));
    AI.sendMessage(Content.text('口調は友達のような感じで大丈夫だよ！'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 引数を受け取る
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _textController.text = args;
      inputText = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(//角を丸くする
                  color: Color.fromARGB(255, 255, 255, 255),
                  border: Border(
                    top:    BorderSide(color: Colors.black, width: 2),
                    right:  BorderSide(color: Colors.black, width: 2),
                    bottom: BorderSide(color: Colors.black, width: 2),
                    left:   BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                alignment: Alignment.center,
                child: ListView.builder(
                  itemCount: chats.length,
                  //itemCount分表示
                  itemBuilder: (context, index) {
                    int p=chats[index].p;
                    String str=chats[index].str;
                    return Row(
                      children:[
                        Container(
                          child: Flexible(
                            child: p == 0 ?
                            Text('自分 ') :
                            Text('相手 '),
                          ),
                        ),
                        Container(
                          child: Flexible(
                            child:Text(str),
                          ),
                        ),
                      ]
                    );
                  },
                ),
              ),

              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: "テキストを入力",
                  border: OutlineInputBorder(),  // 境界線を追加
                ),
                maxLines: 4,  // 複数行対応
              ),

              ElevatedButton(
                onPressed: onchat,
                child: Text('START'),
              ),
            ]
          ),
        ),
        // child: Text(
        //   inputText, // 受け取ったテキストを表示
        //   style: Theme.of(context).textTheme.headlineMedium,
        //   textAlign: TextAlign.center,
        // ),
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

  void onchat(){
    chats.add(chat(
      0,
      _textController.text,
    ));
    setState((){});
    AIchat();
  }

  void AIchat() async {
    // GenerativeModel AI = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    // String apiKey = dotenv.get('GEMINI_API_KEY');
    // if (apiKey == null) {
    //   print('API Key取得失敗');
    //   return;
    // }
    // final genModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    final content = Content.text(_textController.text);
    final response = await AI.sendMessage(content);
    String resText = response.text ?? 'Gemini返答失敗';
    chats.add(chat(
      1,
      resText,
    ));

    setState((){
      _textController.text = "";
    });
  }
}

/*

*/