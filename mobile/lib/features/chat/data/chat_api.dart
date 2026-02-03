import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/entities/chat_message.dart';

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
}

final chatApiProvider = Provider<ChatApi>((ref) {
  return ChatApi(dioClient: DioClient());
});
