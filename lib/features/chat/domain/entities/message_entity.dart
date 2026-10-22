class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false, 
    this.imageUrl,
  });

  
  bool isMe(String currentUserId) => senderId == currentUserId;
}