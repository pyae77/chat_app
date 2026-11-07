import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  final String? replyToMessageId;
  final String? replyToSenderId;
  final String? replyToMessage;
  final String? replyToImageUrl;
  
  final Map<String, String> reactions;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.replyToMessageId,
    this.replyToSenderId,
    this.replyToMessage,
    this.replyToImageUrl, 
    this.reactions = const {},
  });

  factory MessageModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return MessageModel(
      id: docId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'],
      imageUrl: json['imageUrl'],
      timestamp:
          (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      replyToMessageId: json['replyToMessageId'],
      replyToSenderId: json['replyToSenderId'],
      replyToMessage: json['replyToMessage'],
      replyToImageUrl: json['replyToImageUrl'],

      reactions: Map<String, String>.from(
      json['reactions'] ?? {},
),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
      'replyToSenderId': replyToSenderId,
      'replyToMessage': replyToMessage,
      'replyToImageUrl': replyToImageUrl,
      'reactions': reactions,
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message ?? '',
      imageUrl: imageUrl,
      timestamp: timestamp,
      isRead: isRead,
      replyToMessageId: replyToMessageId,
      replyToSenderId: replyToSenderId,
      replyToMessage: replyToMessage,
      replyToImageUrl: replyToImageUrl,
      reactions: reactions,
    );
  }
}