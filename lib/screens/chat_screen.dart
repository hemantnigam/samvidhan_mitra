import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';
import '../models/chat_message.dart';
import '../services/chat_provider.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late ChatProvider _chatProvider;
  int _messageCount = 0;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _messageCount = _chatProvider.messages.length;
    
    // Auto-scroll if initiated from outside or initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _chatProvider.addListener(_onProviderChange);
    _scrollController.addListener(_onScroll);
  }

  void _onProviderChange() {
    if (!mounted) return;
    if (_chatProvider.messages.length > _messageCount) {
      _messageCount = _chatProvider.messages.length;
      _scrollToBottom();
    } else if (_chatProvider.messages.length < _messageCount) {
      _messageCount = _chatProvider.messages.length; // Handle history cleared
    }
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _showScrollToBottom = maxScroll - currentScroll > 200;
      });
    }
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onProviderChange);
    _scrollController.removeListener(_onScroll);
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
    final messagesLength = context.select<ChatProvider, int>((p) => p.messages.length);
    final isLoading = context.select<ChatProvider, bool>((p) => p.isLoading);
    final isOverlayVisible = context.select<ChatProvider, bool>((p) => p.isOverlayVisible);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 100;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close keyboard when tapping background
      child: Container(
        color: AppConstants.paperWhite,
        child: Stack(
          children: [
            Column(
              children: [
                const _StatusHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(20, 24, 20, isKeyboardOpen ? bottomInset + 80 : 180),
                    itemCount: messagesLength + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messagesLength) {
                        return const _ReasoningShimmer();
                      }
                      
                      // Using a Consumer here allows the bubble to be updated independently
                      // but since message content never changes, we just pass the data.
                      final message = context.read<ChatProvider>().messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ModernChatBubble(message: message),
                          if (index == messagesLength - 1 && !message.isUser && !isLoading)
                            _QuickReplySuggestions(
                              onTap: (text) {
                                context.read<ChatProvider>().sendMessage(text);
                                _scrollToBottom();
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Manual floating input that reacts to keyboard inset directly
            Positioned(
              bottom: isKeyboardOpen ? bottomInset + 10 : 100, // 100px to sit above nav bar
              left: 0,
              right: 0,
              child: _FloatingInputArea(
                controller: _controller,
                onSend: (text) {
                  context.read<ChatProvider>().sendMessage(text);
                  _controller.clear();
                  _scrollToBottom();
                },
              ),
            ),
            
            // Scroll to Bottom FAB
            if (_showScrollToBottom)
              Positioned(
                bottom: isKeyboardOpen ? bottomInset + 80 : 180, // Above input area
                right: 24,
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  backgroundColor: AppConstants.paperWhite,
                  child: const Icon(Icons.arrow_downward, color: AppConstants.primaryNavy),
                ),
              ),

            if (isOverlayVisible)
              _ListeningOverlay(
                onDone: (recognizedText) {
                  final provider = context.read<ChatProvider>();
                  provider.stopListening();
                  if (recognizedText.isNotEmpty) {
                    provider.sendMessage(recognizedText);
                  }
                  _scrollToBottom();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) {
    final speechLocale = context.select<ChatProvider, String>((p) => p.speechLocale);
    final isHindi = speechLocale == 'hi_IN';
    
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: const [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppConstants.accentGreen),
                  const SizedBox(width: 4),
                  const Text(
                    "System Ready",
                    style: TextStyle(color: AppConstants.accentGreen, fontSize: 10, fontWeight: FontWeight.bold),
                  ),

                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.read<ChatProvider>().toggleSpeechLocale(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  isHindi ? "हिंदी | EN" : "EN | हिंदी",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ModernChatBubble({required this.message});

  static final _markdownStyle = MarkdownStyleSheet(
    p: const TextStyle(
      fontSize: 15,
      height: 1.6,
      color: AppConstants.primaryNavy,
      fontFamily: 'Instrument Sans',
    ),
    h1: const TextStyle(fontFamily: 'Newsreader', fontWeight: FontWeight.bold),
    h2: const TextStyle(fontFamily: 'Newsreader', fontWeight: FontWeight.bold),
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryNavy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionIcon(
                          icon: Icons.copy_rounded,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied to clipboard")),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Consumer<ChatProvider>(
                          builder: (context, provider, child) {
                            final isSpeaking = provider.currentlySpeakingMessageId == message.timestamp.toIso8601String();
                            return _ActionIcon(
                              icon: isSpeaking ? Icons.stop_circle : Icons.volume_up_rounded,
                              onTap: () => provider.toggleSpeakMessage(message),
                              color: isSpeaking ? Colors.red : AppConstants.secondaryGray,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: message.text,
                      styleSheet: _markdownStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildCitations(message.text),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static final _citationRegExp = RegExp(r'Article\s+\d+|अनुच्छेद\s+\d+', caseSensitive: false);

  Widget _buildCitations(String text) {
    final articleMatch = _citationRegExp.firstMatch(text);
    if (articleMatch == null) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.secondaryGray.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_outline, size: 14, color: AppConstants.secondaryGray),
              const SizedBox(width: 6),
              Text(
                "[1] ${articleMatch.group(0)}",
                style: const TextStyle(fontSize: 11, color: AppConstants.secondaryGray, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.color = AppConstants.secondaryGray,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _ReasoningShimmer extends StatelessWidget {
  const _ReasoningShimmer();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AutoAwesomeShimmer(),
                SizedBox(width: 8),
                Text(
                  "Thinking...",
                  style: TextStyle(
                    color: AppConstants.secondaryGray,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _TextShimmer(),
          ],
        ),
      ),
    );
  }
}

class _AutoAwesomeShimmer extends StatelessWidget {
  const _AutoAwesomeShimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstants.accentWheat,
      highlightColor: Colors.white,
      child: const Icon(Icons.auto_awesome, size: 16),
    );
  }
}

class _TextShimmer extends StatelessWidget {
  const _TextShimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstants.secondaryGray.withValues(alpha: 0.1),
      highlightColor: AppConstants.secondaryGray.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(width: 200, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }
}

class _QuickReplySuggestions extends StatelessWidget {
  final Function(String) onTap;
  const _QuickReplySuggestions({required this.onTap});

  static const _suggestions = ["Tell me more", "Related Articles", "Practical example"];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(s),
                onPressed: () => onTap(s),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: AppConstants.primaryNavy, fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                  side: BorderSide(color: AppConstants.secondaryGray.withValues(alpha: 0.15)),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _FloatingInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _FloatingInputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final isListening = context.select<ChatProvider, bool>((p) => p.isListening);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10), // 10px gap at the bottom
      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstants.secondaryGray.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.read<ChatProvider>().toggleListening(),
              icon: Icon(
                isListening ? Icons.stop_circle : Icons.mic_none,
                color: isListening ? Colors.red : AppConstants.secondaryGray,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Ask Samvidhan Mitra...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppConstants.secondaryGray.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(fontFamily: 'Instrument Sans', fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningOverlay extends StatelessWidget {
  final Function(String) onDone;

  const _ListeningOverlay({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final speechLocale = context.select<ChatProvider, String>((p) => p.speechLocale);
    final lastRecognizedText = context.select<ChatProvider, String>((p) => p.lastRecognizedText);
    final isHindi = speechLocale == 'hi_IN';
    
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
                      color: AppConstants.primaryNavy,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final provider = context.read<ChatProvider>();
                      provider.stopListening();
                      provider.toggleSpeechLocale();
                      provider.startListening();
                    },
                    icon: const Icon(Icons.language, size: 16),
                    label: Text(isHindi ? "English" : "हिंदी"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.accentWheat,
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
                    lastRecognizedText.isEmpty 
                        ? (isHindi ? "बोलिए..." : "Speak now...")
                        : lastRecognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onDone(lastRecognizedText),
                    icon: const Icon(Icons.send),
                    label: Text(isHindi ? "भेजें" : "Send"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      final provider = context.read<ChatProvider>();
                      provider.stopListening();
                      provider.clearRecognizedText();
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
