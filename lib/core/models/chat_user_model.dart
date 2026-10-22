import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';

class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
    super.isOnline,
  });

  // Firestore Document to Model
  factory ChatUserModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return ChatUserModel(
      uid: docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  // from Model to Firestore just in case
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
    };
  }

  // change to entity to use in domain layer
  ChatUserEntity toEntity() {
    return ChatUserEntity(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      isOnline: isOnline,
    );
  }
}