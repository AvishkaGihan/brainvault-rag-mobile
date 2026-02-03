import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/chat_api.dart';
import '../../data/chat_stream_event.dart';
import '../providers/chat_history_provider.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late List<ChatMessage> _messages;
  bool _canSend = false;
  bool _isAwaitingResponse = false;
  bool _isStreaming = false;
  int? _streamingMessageIndex;
  String _streamingText = '';
  DateTime? _lastStreamScroll;
  int? _fadeInMessageIndex;
  double _fadeInOpacity = 1.0;
  bool _hasLoadedHistory = false;
  String? _historyDocumentId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _messages = List<ChatMessage>.from(widget.messages);
    _historyDocumentId = widget.documentId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chatHistoryDocumentIdProvider.notifier).set(_historyDocumentId);
      _scrollToLatestMessage();
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.messages, widget.messages)) {
      _messages = List<ChatMessage>.from(widget.messages);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLatestMessage();
      });
    }
    if (oldWidget.documentId != widget.documentId) {
      _historyDocumentId = widget.documentId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(chatHistoryDocumentIdProvider.notifier)
            .set(_historyDocumentId);
      });
      _hasLoadedHistory = false;
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
    if (_messages.isEmpty || !_scrollController.hasClients) return;
    // Use animateTo for smoother scrolling with large message lists
    // Add extra offset if thinking indicator is shown to ensure it's fully visible
    final extraOffset = _isAwaitingResponse && !_isStreaming ? 60.0 : 0.0;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + extraOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _throttledScrollToLatest() {
    final now = DateTime.now();
    if (_lastStreamScroll == null ||
        now.difference(_lastStreamScroll!) >
            const Duration(milliseconds: 120)) {
      _lastStreamScroll = now;
      _scrollToLatestMessage();
    }
  }

  bool _isDocumentUnavailable() {
    final documentId = widget.documentId;
    if (documentId == null || documentId.trim().isEmpty) {
      return false;
    }

    final documentsState = ref.read(documentsProvider);
    return documentsState.maybeWhen(
      data: (documents) {
        // Optimized lookup using firstWhere instead of linear search
        try {
          final doc = documents.firstWhere((d) => d.id == documentId);
          return doc.status != DocumentStatus.ready;
        } catch (e) {
          // Document not found
          return true;
        }
      },
      orElse: () => false,
    );
  }

  void _handleMissingDocument() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_Strings.missingDocumentMessage)),
    );
    context.go('/home');
  }

  void _handleNewChat() {
    // Placeholder handler for Story 5.9: New Conversation feature
  }

  Future<void> _handleSend() async {
    if (_isAwaitingResponse) return;
    if (_isDocumentUnavailable()) {
      _handleMissingDocument();
      return;
    }

    final documentId = widget.documentId;
    if (documentId == null || documentId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_Strings.noDocumentSelectedMessage)),
      );
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatApi = ref.read(chatApiProvider);

    setState(() {
      _messageController.clear();
      _canSend = false;
      _streamingText = '';
      _messages = [
        ..._messages,
        ChatMessage(
          text: text,
          role: ChatMessageRole.user,
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          text: '',
          role: ChatMessageRole.assistant,
          createdAt: DateTime.now(),
        ),
      ];
      _isAwaitingResponse = true;
      _isStreaming = true;
      _streamingMessageIndex = _messages.length - 1;
      _fadeInMessageIndex = null;
      _fadeInOpacity = 1.0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatestMessage();
    });

    var receivedStreamEvent = false;

    try {
      await for (final event in chatApi.streamDocumentChat(
        documentId: documentId,
        question: text,
      )) {
        if (!mounted) return;
        receivedStreamEvent = true;

        if (event is ChatStreamDelta) {
          _streamingText += event.text;
          _updateStreamingMessage(_streamingText, const []);
          _throttledScrollToLatest();
        } else if (event is ChatStreamDone) {
          _finalizeStreamingMessage(event.answer, event.sources);
          _endStreaming();
          return;
        } else if (event is ChatStreamError) {
          _handleStreamingFailure(event.message);
          return;
        }
      }

      if (!receivedStreamEvent) {
        throw Exception('Streaming not available');
      }
    } catch (error) {
      if (!mounted) return;
      if (!receivedStreamEvent && _streamingText.isEmpty) {
        await _fallbackToNonStream(chatApi, documentId, text);
        return;
      }
      _handleStreamingFailure(_Strings.chatFailureMessage);
    }
  }

  void _updateStreamingMessage(String text, List<ChatSource> sources) {
    final index = _streamingMessageIndex;
    if (index == null || index < 0 || index >= _messages.length) return;

    final existing = _messages[index];
    final updated = ChatMessage(
      text: text,
      role: ChatMessageRole.assistant,
      createdAt: existing.createdAt,
      sources: sources,
    );

    setState(() {
      final updatedMessages = List<ChatMessage>.from(_messages);
      updatedMessages[index] = updated;
      _messages = updatedMessages;
    });
  }

  void _finalizeStreamingMessage(String answer, List<ChatSource> sources) {
    _streamingText = answer;
    _updateStreamingMessage(answer, sources);
  }

  void _endStreaming() {
    setState(() {
      _isAwaitingResponse = false;
      _isStreaming = false;
      _streamingMessageIndex = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatestMessage();
    });
  }

  Future<void> _fallbackToNonStream(
    ChatApi chatApi,
    String documentId,
    String question,
  ) async {
    if (!mounted) return;
    setState(() {
      _isStreaming = false;
      _streamingMessageIndex = null;
      _streamingText = '';
      _messages = List<ChatMessage>.from(_messages)..removeLast();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatestMessage();
    });

    try {
      final response = await chatApi.queryDocumentChat(
        documentId: documentId,
        question: question,
      );

      if (!mounted) return;

      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(
            text: response.answer,
            role: ChatMessageRole.assistant,
            createdAt: DateTime.now(),
            sources: response.sources,
          ),
        ];
        _isAwaitingResponse = false;
        _fadeInMessageIndex = _messages.length - 1;
        _fadeInOpacity = 0.0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _fadeInOpacity = 1.0;
        });
        _scrollToLatestMessage();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isAwaitingResponse = false;
      });
      _showChatError(error);
    }
  }

  void _handleStreamingFailure(String message) {
    setState(() {
      _isAwaitingResponse = false;
      _isStreaming = false;
      _streamingMessageIndex = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showChatError(Object error) {
    // Determine user-friendly error message based on error type
    String errorMessage = _Strings.chatFailureMessage;
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException') ||
        error.toString().contains('connection')) {
      errorMessage = _Strings.networkErrorMessage;
    } else if (error.toString().contains('401') ||
        error.toString().contains('unauthorized')) {
      errorMessage = _Strings.authErrorMessage;
    } else if (error.toString().contains('429') ||
        error.toString().contains('rate limit')) {
      errorMessage = _Strings.rateLimitErrorMessage;
    } else if (error.toString().contains('500') ||
        error.toString().contains('server')) {
      errorMessage = _Strings.serverErrorMessage;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Widget _buildThinkingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Maintain 8dp rhythm per UX spec (separators use 8dp)
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _Strings.thinkingText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        (widget.documentTitle != null &&
            widget.documentTitle!.trim().isNotEmpty)
        ? widget.documentTitle!
        : 'Chat';
    final historyState = ref.watch(chatHistoryProvider);

    final historyMessages = historyState.asData?.value;
    if (!_hasLoadedHistory && historyMessages != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasLoadedHistory) return;
        setState(() {
          _messages = List<ChatMessage>.from(historyMessages);
          _hasLoadedHistory = true;
        });
        _scrollToLatestMessage();
      });
    }

    final messages = _messages;
    final isSendEnabled = _canSend && !_isAwaitingResponse;
    final showThinkingIndicator = _isAwaitingResponse && !_isStreaming;
    final showHistoryLoading = historyState.isLoading && messages.isEmpty;

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
                ? (showHistoryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const ChatEmptyState())
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemBuilder: (context, index) {
                      if (showThinkingIndicator && index == messages.length) {
                        return _buildThinkingIndicator(context);
                      }
                      final message = messages[index];
                      final showCursor =
                          _isStreaming && index == _streamingMessageIndex;
                      final bubble = ChatMessageBubble(
                        message: message,
                        showStreamingCursor: showCursor,
                      );
                      if (_fadeInMessageIndex == index) {
                        return AnimatedOpacity(
                          opacity: _fadeInOpacity,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: bubble,
                        );
                      }
                      return bubble;
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount:
                        messages.length + (showThinkingIndicator ? 1 : 0),
                  ),
          ),
          SafeArea(
            top: false,
            child: ChatInput(
              controller: _messageController,
              onChanged: _handleTextChanged,
              onSend: _handleSend,
              isSendEnabled: isSendEnabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _Strings {
  static const String thinkingText = 'Thinking...';
  static const String missingDocumentMessage =
      'This document is no longer available. Returning to Documents.';
  static const String noDocumentSelectedMessage =
      'Select a document to start chatting.';
  static const String chatFailureMessage =
      'Unable to get an answer right now. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Check your network and try again.';
  static const String authErrorMessage =
      'Session expired. Please log in again.';
  static const String rateLimitErrorMessage =
      'Too many requests. Please wait a moment.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
}

enum _ChatMenuAction { newChat }
