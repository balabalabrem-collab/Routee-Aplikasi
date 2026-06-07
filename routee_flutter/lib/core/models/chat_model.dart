class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isFromDriver;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.isFromDriver,
  });
}
