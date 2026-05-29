import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AIService {
  final String apiKey;
  final String model = 'llama-3.3-70b-versatile'; // Verified active model on Groq

  AIService({required this.apiKey});

  // For Groq, we'll maintain history manually
  List<Map<String, String>> _history = [];

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    // Add user message to history
    _history.add({"role": "user", "content": message});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {"role": "system", "content": AppConstants.systemPrompt},
          ..._history,
        ],
        "temperature": 0.7,
        "max_tokens": 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiContent = data['choices'][0]['message']['content'];
      
      // Add AI response to history
      _history.add({"role": "assistant", "content": aiContent});
      
      return aiContent;
    } else {
      throw Exception('Groq API Error: ${response.body}');
    }
  }

  void resetChat() {
    _history = [];
  }
}
