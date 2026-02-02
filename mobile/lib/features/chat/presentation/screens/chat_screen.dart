import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../domain/entities/chat_message.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String? documentId;
  final String? documentTitle;
  final List<ChatMessage> messages;

  const ChatScreen({
    super.key,
    this.documentId,
    this.documentTitle,
    this.messages = const [],
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatestMessage();
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.messages, widget.messages)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLatestMessage();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  void _scrollToLatestMessage() {
    if (widget.messages.isEmpty || !_scrollController.hasClients) return;
    // Use animateTo for smoother scrolling with large message lists
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleNewChat() {
    // Placeholder handler for Story 5.1
  }

  void _handleSend() {
    // Placeholder handler for Story 5.1
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (widget.documentTitle != null &&
            widget.documentTitle!.trim().isNotEmpty)
        ? widget.documentTitle!
        : 'Chat';
    final messages = widget.messages;

    return Scaffold(
      appBar: CustomAppBar(
        title: resolvedTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        actions: [
          PopupMenuButton<_ChatMenuAction>(
            onSelected: (action) {
              if (action == _ChatMenuAction.newChat) {
                _handleNewChat();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ChatMenuAction.newChat,
                child: Text('New Chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const ChatEmptyState()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(message.text),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: messages.length,
                  ),
          ),
          SafeArea(
            top: false,
            child: ChatInput(
              controller: _messageController,
              onChanged: _handleTextChanged,
              onSend: _handleSend,
              isSendEnabled: _canSend,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChatMenuAction { newChat }
