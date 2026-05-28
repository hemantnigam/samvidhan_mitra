import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class AIService {
  late GenerativeModel _model;
  ChatSession? _chat;

  AIService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(AppConstants.systemPrompt),
      // In a real implementation, you would link the file search tool here
      // tools: [Tool(fileSearch: FileSearch())], 
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      _chat ??= _model.startChat();
      
      final response = await _chat!.sendMessage(
        Content.text(message),
      );
      
      return response.text ?? 'I am sorry, I could not process that.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void resetChat() {
    _chat = null;
  }
}
