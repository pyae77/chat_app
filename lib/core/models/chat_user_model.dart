import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';

class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
    super.photoBase64,
    super.isOnline,
  });

  factory ChatUserModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return ChatUserModel(
      uid: docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: _readNonEmptyString(json['photoUrl']) ??
          _readNonEmptyString(json['profilePic']),
      photoBase64: _readNonEmptyString(json['photoBase64']),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'photoBase64': photoBase64,
      'isOnline': isOnline,
    };
  }

  ChatUserEntity toEntity() {
    return ChatUserEntity(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      photoBase64: photoBase64,
      isOnline: isOnline,
    );
  }

  static String? _readNonEmptyString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
