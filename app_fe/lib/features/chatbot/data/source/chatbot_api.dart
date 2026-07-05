import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';

class ChatbotApi {
  final Dio _dio;

  ChatbotApi(this._dio);

  /// Gửi câu hỏi lên chatbot y tế ở backend
  Future<Map<String, dynamic>?> askChatbot(String message) async {
    try {
      final response = await _dio.post(
        '/api/chat/bot',
        data: {
          'message': message,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error calling chatbot API: $e');
      return null;
    }
  }
}

final chatbotApiProvider = Provider<ChatbotApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatbotApi(dio);
});
