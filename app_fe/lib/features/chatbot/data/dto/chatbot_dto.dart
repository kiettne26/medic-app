class ChatbotMessageDto {
  final String id;
  final String text;
  final bool isUser;
  final String? suggestedSpecialty;
  final DateTime timestamp;

  ChatbotMessageDto({
    required this.id,
    required this.text,
    required this.isUser,
    this.suggestedSpecialty,
    required this.timestamp,
  });
}
