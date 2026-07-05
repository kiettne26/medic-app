import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/dto/chatbot_dto.dart';
import '../data/source/chatbot_api.dart';

class ChatbotState {
  final List<ChatbotMessageDto> messages;
  final bool isTyping;

  ChatbotState({
    this.messages = const [],
    this.isTyping = false,
  });

  ChatbotState copyWith({
    List<ChatbotMessageDto>? messages,
    bool? isTyping,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotApi _api;
  final _uuid = const Uuid();

  ChatbotNotifier(this._api) : super(ChatbotState()) {
    // Thêm tin nhắn chào mừng ban đầu
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    state = state.copyWith(
      messages: [
        ChatbotMessageDto(
          id: _uuid.v4(),
          text: "Xin chào! Tôi là Trợ lý Sức khỏe ảo của MediBook. Tôi có thể tư vấn sơ bộ về triệu chứng bệnh và gợi ý chuyên khoa phù hợp nhất cho bạn. Bạn đang gặp vấn đề gì thế?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Thêm tin nhắn của User
    final userMsg = ChatbotMessageDto(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // 2. Gọi API để lấy phản hồi
    final result = await _api.askChatbot(text);
    
    state = state.copyWith(isTyping: false);

    if (result != null) {
      final reply = result['reply'] as String? ?? "Xin lỗi, tôi không thể xử lý câu hỏi này lúc này.";
      final specialty = result['suggestedSpecialty'] as String?;

      final botMsg = ChatbotMessageDto(
        id: _uuid.v4(),
        text: reply,
        isUser: false,
        suggestedSpecialty: specialty,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
      );
    } else {
      final errorMsg = ChatbotMessageDto(
        id: _uuid.v4(),
        text: "Kết nối đến trợ lý ảo bị gián đoạn. Vui lòng kiểm tra lại kết nối mạng.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
      );
    }
  }

  void clearConversation() {
    state = ChatbotState();
    _addWelcomeMessage();
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  final api = ref.watch(chatbotApiProvider);
  return ChatbotNotifier(api);
});
