import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class DatabaseService {
  static const String chatBoxName = 'chat_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatMessageAdapter());
    await Hive.openBox<ChatMessage>(chatBoxName);
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
