import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/models/chat_user_model.dart'; 

abstract class FirestorePeopleDataSource {
  Future<List<ChatUserModel>> getPeople({
    required String currentUserId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String searchQuery = '',
  });
}

class FirestorePeopleDataSourceImpl implements FirestorePeopleDataSource {
  final FirebaseFirestore _firestore;

  FirestorePeopleDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ChatUserModel>> getPeople({
    required String currentUserId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String searchQuery = '',
  }) async {
    Query query = _firestore.collection('users').orderBy('name').limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .where((doc) => doc.id != currentUserId) 
        .map((doc) => ChatUserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}