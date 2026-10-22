import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';

abstract class FirestoreChatRoomDataSource {
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId);
  Future<void> sendMessage(String chatRoomId, MessageModel message);
  Future<void> sendImageMessage(String chatRoomId, MessageModel messageModel, String imagePath);
}

class FirestoreChatRoomDataSourceImpl implements FirestoreChatRoomDataSource {
  final FirebaseFirestore _firestore;

  FirestoreChatRoomDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    final batch = _firestore.batch();

    // 1. New Message Add Kara
    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    batch.set(messageRef, message.toFirestore());

    // 2. Chat Room's Last Message Info Update Kara
    final roomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
    batch.set(
      roomRef,
      {
        'lastMessage': message.message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'participants': [message.senderId, message.receiverId],
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

@override
Future<void> sendImageMessage(String chatRoomId, MessageModel messageModel, String imagePath) async {

  final file = File(imagePath);
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final ref = FirebaseStorage.instance
      .ref()
      .child('chat_images')
      .child(chatRoomId)
      .child('$fileName.jpg');

 
  final uploadTask = await ref.putFile(file);
  final downloadUrl = await uploadTask.ref.getDownloadURL();


  final imageMessage = MessageModel(
    id: messageModel.id,
    senderId: messageModel.senderId,
    receiverId: messageModel.receiverId,
    message: "Photo", 
    imageUrl: downloadUrl, 
    timestamp: messageModel.timestamp,
    isRead: messageModel.isRead,
  );

  await sendMessage(chatRoomId, imageMessage);
}
}