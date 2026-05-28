import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/speech_service.dart';

class ChatProvider with ChangeNotifier {
  final AIService _aiService;
  final SpeechService _speechService = SpeechService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentLanguage = 'en_IN'; // Default to English (India)

  ChatProvider({required String apiKey}) : _aiService = AIService(apiKey: apiKey) {
    _loadHistory();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _speechService.isListening;
  String get currentLanguage => _currentLanguage;

  void _loadHistory() {
    _messages = DatabaseService.getHistory();
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await DatabaseService.addMessage(userMessage);
    
    _isLoading = true;
    notifyListeners();

    try {
      final aiResponseText = await _aiService.sendMessage(text);
      
      final aiMessage = ChatMessage(
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      await DatabaseService.addMessage(aiMessage);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    final initialized = await _speechService.initSpeech();
    if (initialized) {
      await _speechService.startListening((text) {
        // We can handle partial results here if needed
      }, _currentLanguage);
      notifyListeners();
    }
  }

  Future<void> stopListeningAndSend() async {
    // In a real app, you'd capture the final recognized text
    // For this prototype, we'll assume the speech service handles the callback
    await _speechService.stopListening();
    notifyListeners();
  }

  Future<void> speakMessage(String text) async {
    final langCode = _currentLanguage.startsWith('hi') ? 'hi-IN' : 'en-IN';
    await _speechService.speak(text, langCode);
  }

  Future<void> stopSpeaking() async {
    await _speechService.stopSpeaking();
  }

  Future<void> clearHistory() async {
    await DatabaseService.clearHistory();
    _messages = [];
    _aiService.resetChat();
    notifyListeners();
  }
}
