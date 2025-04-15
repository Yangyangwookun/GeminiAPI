import 'package:flutter/material.dart';
import 'chatScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 있어도 되고 없어도 됨
  await dotenv.load(); // .env 불러오기
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Gemini 챗봇',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,





    );
  }
}
