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
        actions: [
          _LanguageToggle(),
        ],
      ),
      body: Column(
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
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isHindi = chatProvider.currentLanguage == 'hi_IN';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        onPressed: () {
          chatProvider.setLanguage(isHindi ? 'en_IN' : 'hi_IN');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
        ),
        child: Text(isHindi ? 'A | अ' : 'अ | A'),
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

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: chatProvider.currentLanguage == 'hi_IN' 
                      ? 'सवाल पूछें...' 
                      : 'Ask a question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onLongPressStart: (_) => chatProvider.startListening(),
              onLongPressEnd: (_) => chatProvider.stopListeningAndSend(),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: chatProvider.isListening 
                    ? Colors.red 
                    : AppConstants.accentSaffron,
                child: Icon(
                  chatProvider.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppConstants.primaryBlue),
              onPressed: () => onSend(controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
