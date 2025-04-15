import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 추가됨!

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // .env에서 API 키 불러오기
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<void> _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.trim().isEmpty) return;

    // ✅ 실제 키 확인용
    print('API 키 불러오기: $_apiKey');

    setState(() {
      _messages.add({'role': 'user', 'text': userInput});
      _controller.clear();
    });

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=...'
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": userInput}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];

      setState(() {
        _messages.add({'role': 'bot', 'text': reply});
      });
    } else {
      print('에러 응답: ${response.body}');
      setState(() {
        _messages.add({'role': 'bot', 'text': '❗에러: ${response.statusCode}'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini 챗봇')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.teal[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(msg['text'] ?? ''),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: '메시지를 입력하세요',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          )
        ],
      ),
    );
  }
}
