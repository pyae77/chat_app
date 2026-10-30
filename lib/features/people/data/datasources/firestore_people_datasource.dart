import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/models/chat_user_model.dart';

abstract class FirestorePeopleDataSource {
  Future<QuerySnapshot<Map<String, dynamic>>> getPeople({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
    bool onlineOnly = false,
  });

  Stream<ChatUserModel?> getUserPresenceStream(String userId);
}

class FirestorePeopleDataSourceImpl implements FirestorePeopleDataSource {
  final FirebaseFirestore _firestore;

  FirestorePeopleDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getPeople({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
    bool onlineOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (onlineOnly) {
      query = query.where('isOnline', isEqualTo: true);
    } else {
      query = query.orderBy('name');
    }

    query = query.limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
  }

  @override
  Stream<ChatUserModel?> getUserPresenceStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? ChatUserModel.fromFirestore(snapshot.data()!, snapshot.id)
              : null,
        );
  }
}
