/// Chat message model for the AI chatbot feature.

enum MessageSender { user, bot }

class ChatMessage {
  final String content;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == MessageSender.user;
  bool get isBot => sender == MessageSender.bot;
}
