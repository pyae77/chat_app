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

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return MessageModel(
      id: docId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'],
      imageUrl: json['imageUrl'],
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
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
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message??'',
      imageUrl: imageUrl,
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}