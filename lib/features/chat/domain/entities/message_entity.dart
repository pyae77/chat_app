class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  final String? replyToMessageId;
  final String? replyToSenderId;
  final String? replyToMessage;
  final String? replyToImageUrl;
  

  // Message Reactions
  final Map<String, String> reactions;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.replyToMessageId,
    this.replyToSenderId,
    this.replyToMessage,
    this.replyToImageUrl,
    this.reactions = const {},
  });

  bool isMe(String currentUserId) => senderId == currentUserId;
}