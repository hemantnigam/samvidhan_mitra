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
  bool _isOverlayVisible = false;
  
  // Internal state for speech locale
  String _speechLocale = 'en_IN'; 

  ChatProvider({required String apiKey}) : _aiService = AIService(apiKey: apiKey) {
    _loadHistory();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _speechService.isListening;
  bool get isOverlayVisible => _isOverlayVisible;
  String get speechLocale => _speechLocale;

  void toggleSpeechLocale() {
    _speechLocale = (_speechLocale == 'hi_IN') ? 'en_IN' : 'hi_IN';
    notifyListeners();
  }

  void _loadHistory() {
    _messages = DatabaseService.getHistory();
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
      final aiResponseText = await _aiService.sendMessage(text, preferredLocale: _speechLocale);
      
      final aiMessage = ChatMessage(
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      await DatabaseService.addMessage(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "Error: ${e.toString()}",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _lastRecognizedText = '';
  String? _currentlySpeakingMessageId;

  String get lastRecognizedText => _lastRecognizedText;
  String? get currentlySpeakingMessageId => _currentlySpeakingMessageId;

  Future<void> toggleListening() async {
    if (_speechService.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    final initialized = await _speechService.initSpeech(
      onError: (error) {
        print("Speech Error: $error");
        notifyListeners();
      },
      onStatus: (status) {
        print("Speech Status: $status");
        notifyListeners();
      },
    );
    
    if (initialized) {
      _lastRecognizedText = '';
      _isOverlayVisible = true;
      await _speechService.startListening(
        localeId: _speechLocale,
        onResult: (text) {
          _lastRecognizedText = text;
          notifyListeners();
        },
      );
      notifyListeners();
    } else {
      print("Speech not initialized. Check permissions.");
    }
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _isOverlayVisible = false;
    notifyListeners();
  }

  void clearRecognizedText() {
    _lastRecognizedText = '';
    notifyListeners();
  }

  Future<void> toggleSpeakMessage(ChatMessage message) async {
    final messageId = message.timestamp.toIso8601String();
    if (_currentlySpeakingMessageId == messageId) {
      await stopSpeaking();
    } else {
      await stopSpeaking(); 
      _currentlySpeakingMessageId = messageId;
      notifyListeners();

      await _speechService.speak(message.text, () {
        _currentlySpeakingMessageId = null;
        notifyListeners();
      });
    }
  }

  Future<void> stopSpeaking() async {
    await _speechService.stopSpeaking();
    _currentlySpeakingMessageId = null;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await DatabaseService.clearHistory();
    _messages = [];
    _aiService.resetChat();
    notifyListeners();
  }
}
