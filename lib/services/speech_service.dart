import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isSpeechInitialized = false;

  Future<bool> initSpeech({
    Function(String)? onStatus,
    Function(String)? onError,
  }) async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize(
        onStatus: (status) => onStatus?.call(status),
        onError: (errorNotification) => onError?.call(errorNotification.errorMsg),
      );
    }
    return _isSpeechInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required String localeId,
    bool partialResults = true,
  }) async {
    try {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId, // We'll use multi-language engine
        onDevice: false,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: partialResults,
      );
    } catch (e) {
      // Error is handled via the initialize callback
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;

  bool get isSpeaking => _isSpeaking;
  bool _isSpeaking = false;

  Future<void> speak(String text, Function() onComplete) async {
    _isSpeaking = true;
    
    // Auto-detect language for TTS
    String languageCode = _detectLanguage(text);
    
    // Clean text: Remove markdown characters (*, #, _, etc.) for better TTS
    String cleanedText = text
        .replaceAll(RegExp(r'[*#_~`>]'), '') 
        .replaceAll(RegExp(r'\n+'), ' ');    
        
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setPitch(1.0);
    
    // Attempt to set a more Indian voice if available
    if (languageCode == 'hi-IN') {
      await _flutterTts.setVoice({"name": "hi-in-x-hie-local", "locale": "hi-IN"});
    } else {
      await _flutterTts.setVoice({"name": "en-in-x-ene-local", "locale": "en-IN"});
    }
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onComplete();
    });

    await _flutterTts.speak(cleanedText);
  }

  String _detectLanguage(String text) {
    // Basic detection: If it contains many Hindi characters, it's Hindi
    final hindiRegExp = RegExp(r'[\u0900-\u097F]');
    int hindiChars = hindiRegExp.allMatches(text).length;
    
    if (hindiChars > 5) {
      return 'hi-IN';
    }
    return 'en-IN';
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }
}
