import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../utils/constants.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length) {
                      return const _LoadingBubble();
                    }
                    final message = chatProvider.messages[index];
                    return ChatBubble(message: message);
                  },
                ),
              ),
              _InputArea(
                controller: _controller,
                onSend: (text) {
                  chatProvider.sendMessage(text);
                  _controller.clear();
                  _scrollToBottom();
                },
              ),
            ],
          ),
          if (chatProvider.isOverlayVisible)
            _ListeningOverlay(
              onDone: (recognizedText) {
                chatProvider.stopListening();
                if (recognizedText.isNotEmpty) {
                  chatProvider.sendMessage(recognizedText);
                }
                _scrollToBottom();
              },
            ),
        ],
      ),
    );
  }
}

class _ListeningOverlay extends StatelessWidget {
  final Function(String) onDone;

  const _ListeningOverlay({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isHindi = chatProvider.speechLocale == 'hi_IN';
    
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? "सुन रहे हैं..." : "Listening...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                  // Small Toggle INSIDE overlay for quick correction
                  TextButton.icon(
                    onPressed: () {
                      chatProvider.stopListening();
                      chatProvider.toggleSpeechLocale();
                      chatProvider.startListening();
                    },
                    icon: const Icon(Icons.language, size: 16),
                    label: Text(isHindi ? "English" : "हिंदी"),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppConstants.accentSaffron,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    chatProvider.lastRecognizedText.isEmpty 
                        ? (isHindi ? "बोलिए..." : "Speak now...")
                        : chatProvider.lastRecognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onDone(chatProvider.lastRecognizedText),
                    icon: const Icon(Icons.send),
                    label: Text(isHindi ? "भेजें" : "Send"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      chatProvider.stopListening();
                      chatProvider.clearRecognizedText();
                    },
                    child: Text(isHindi ? "रद्द करें" : "Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _InputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isHindi = chatProvider.speechLocale == 'hi_IN';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            // Subsitute for top bar toggle: A small locale indicator
            GestureDetector(
              onTap: () => chatProvider.toggleSpeechLocale(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHindi ? 'अ' : 'A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask a question / सवाल...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => chatProvider.toggleListening(),
              icon: CircleAvatar(
                radius: 24,
                backgroundColor: chatProvider.isListening 
                    ? Colors.red 
                    : AppConstants.accentSaffron,
                child: Icon(
                  chatProvider.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onSend(controller.text),
              icon: const CircleAvatar(
                radius: 24,
                backgroundColor: AppConstants.primaryBlue,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
