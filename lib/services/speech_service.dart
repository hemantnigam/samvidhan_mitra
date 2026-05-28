import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isSpeechInitialized = false;

  Future<bool> initSpeech() async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize();
    }
    return _isSpeechInitialized;
  }

  Future<void> startListening(Function(String) onResult, String localeId) async {
    await _speechToText.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;

  Future<void> speak(String text, String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}
