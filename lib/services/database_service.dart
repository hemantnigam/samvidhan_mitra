import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class DatabaseService {
  static const String chatBoxName = 'chat_history';

  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatMessageAdapter());
    await Hive.openBox<ChatMessage>(chatBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Future<void> saveLanguage(String languageCode) async {
    final box = Hive.box(settingsBoxName);
    await box.put('language', languageCode);
  }

  static String? getLanguage() {
    final box = Hive.box(settingsBoxName);
    return box.get('language');
  }

  static Box<ChatMessage> getChatBox() {
    return Hive.box<ChatMessage>(chatBoxName);
  }

  static Future<void> addMessage(ChatMessage message) async {
    final box = getChatBox();
    await box.add(message);
  }

  static List<ChatMessage> getHistory() {
    final box = getChatBox();
    return box.values.toList();
  }

  static Future<void> clearHistory() async {
    final box = getChatBox();
    await box.clear();
  }
}
