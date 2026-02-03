import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/entities/chat_message.dart';
import 'chat_stream_event.dart';

class ChatQueryResponseData {
  final String answer;
  final List<ChatSource> sources;
  final double confidence;

  const ChatQueryResponseData({
    required this.answer,
    required this.sources,
    required this.confidence,
  });
}

class ChatApi {
  final DioClient _dioClient;

  ChatApi({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/v1/documents/$documentId/chat',
      data: {'question': question},
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Chat query failed');
    }

    final data = body['data'];
    if (data is! Map) {
      throw Exception('Invalid chat response');
    }

    final answer = data['answer'];
    final confidenceValue = data['confidence'];
    final sourcesRaw = data['sources'];

    if (answer is! String || answer.trim().isEmpty) {
      throw Exception('Invalid chat answer');
    }

    final sources = <ChatSource>[];
    if (sourcesRaw is List) {
      for (final item in sourcesRaw) {
        if (item is Map) {
          final pageNumber = item['pageNumber'];
          final snippet = item['snippet'];
          if (pageNumber is num) {
            sources.add(
              ChatSource(
                pageNumber: pageNumber.toInt(),
                snippet: snippet is String ? snippet : null,
              ),
            );
          }
        }
      }
    }

    return ChatQueryResponseData(
      answer: answer.trim(),
      sources: sources,
      confidence: confidenceValue is num ? confidenceValue.toDouble() : 0,
    );
  }

  Future<List<ChatMessage>> fetchChatHistory({
    required String documentId,
    int limit = 100,
  }) async {
    return _fetchChatHistoryInternal(documentId: documentId, limit: limit);
  }

  Future<List<ChatMessage>> fetchOlderChatHistory({
    required String documentId,
    required DateTime before,
    int limit = 100,
  }) async {
    return _fetchChatHistoryInternal(
      documentId: documentId,
      limit: limit,
      before: before.toIso8601String(),
    );
  }

  Future<List<ChatMessage>> _fetchChatHistoryInternal({
    required String documentId,
    required int limit,
    String? before,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/v1/documents/$documentId/chat/history',
      queryParameters: {'limit': limit, if (before != null) 'before': before},
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Chat history fetch failed');
    }

    final data = body['data'];
    if (data is! Map) {
      throw Exception('Invalid chat history response');
    }

    final messagesRaw = data['messages'];
    if (messagesRaw is! List) {
      return [];
    }

    final messages = <ChatMessage>[];
    for (final item in messagesRaw) {
      if (item is Map) {
        final roleValue = item['role'];
        final content = item['content'];
        final timestamp = item['timestamp'];
        final sourcesRaw = item['sources'];

        if (content is! String || content.trim().isEmpty) {
          continue;
        }

        final sources = <ChatSource>[];
        if (sourcesRaw is List) {
          for (final sourceItem in sourcesRaw) {
            if (sourceItem is Map) {
              final pageNumber = sourceItem['pageNumber'];
              final snippet = sourceItem['snippet'];
              if (pageNumber is num) {
                sources.add(
                  ChatSource(
                    pageNumber: pageNumber.toInt(),
                    snippet: snippet is String ? snippet : null,
                  ),
                );
              }
            }
          }
        }

        messages.add(
          ChatMessage(
            text: content.trim(),
            role: roleValue == 'assistant'
                ? ChatMessageRole.assistant
                : ChatMessageRole.user,
            createdAt: timestamp is String
                ? DateTime.tryParse(timestamp)
                : null,
            sources: sources,
          ),
        );
      }
    }

    return messages;
  }

  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    final response = await _dioClient.post<ResponseBody>(
      '/v1/documents/$documentId/chat/stream',
      data: {'question': question},
      options: Options(responseType: ResponseType.stream),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      throw Exception('Streaming response missing');
    }

    final stream = responseBody.stream.cast<List<int>>().transform(
      const Utf8Decoder(),
    );
    var buffer = '';

    await for (final chunk in stream) {
      buffer += chunk.replaceAll('\r\n', '\n');
      var separatorIndex = buffer.indexOf('\n\n');
      while (separatorIndex != -1) {
        final frame = buffer.substring(0, separatorIndex).trim();
        buffer = buffer.substring(separatorIndex + 2);
        separatorIndex = buffer.indexOf('\n\n');

        final event = _parseSseFrame(frame);
        if (event != null) {
          yield event;
        }
      }
    }
  }

  ChatStreamEvent? _parseSseFrame(String frame) {
    if (frame.isEmpty) return null;

    String? eventName;
    final dataLines = <String>[];

    for (final line in frame.split('\n')) {
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trim());
      }
    }

    if (eventName == null || dataLines.isEmpty) {
      return null;
    }

    final payload = dataLines.join('\n');
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    switch (eventName) {
      case 'delta':
        final text = decoded['text'];
        if (text is String) {
          return ChatStreamDelta(text: text);
        }
      case 'done':
        final answer = decoded['answer'];
        final confidenceValue = decoded['confidence'];
        final sourcesRaw = decoded['sources'];

        if (answer is! String) {
          return null;
        }

        final sources = <ChatSource>[];
        if (sourcesRaw is List) {
          for (final item in sourcesRaw) {
            if (item is Map) {
              final pageNumber = item['pageNumber'];
              final snippet = item['snippet'];
              if (pageNumber is num) {
                sources.add(
                  ChatSource(
                    pageNumber: pageNumber.toInt(),
                    snippet: snippet is String ? snippet : null,
                  ),
                );
              }
            }
          }
        }

        return ChatStreamDone(
          answer: answer.trim(),
          sources: sources,
          confidence: confidenceValue is num ? confidenceValue.toDouble() : 0,
        );
      case 'error':
        final code = decoded['code'];
        final message = decoded['message'];
        if (code is String && message is String) {
          return ChatStreamError(code: code, message: message);
        }
    }

    return null;
  }
}

final chatApiProvider = Provider<ChatApi>((ref) {
  return ChatApi(dioClient: DioClient());
});
