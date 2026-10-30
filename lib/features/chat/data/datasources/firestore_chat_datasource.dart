import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/paginated_result.dart';
import 'package:flutter_chat_app/core/models/chat_user_model.dart';

abstract class FirestoreChatDataSource {
  Future<PaginatedResult<ChatUserModel>> getRecentChatUsers({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
  });
}

class FirestoreChatDataSourceImpl implements FirestoreChatDataSource {
  final FirebaseFirestore _firestore;

  FirestoreChatDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PaginatedResult<ChatUserModel>> getRecentChatUsers({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final otherUserIds = snapshot.docs
        .map((doc) {
          final participants =
              doc.data()['participants'] as List<dynamic>? ?? [];
          return participants.whereType<String>().firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );
        })
        .where((id) => id.isNotEmpty)
        .toList();

    final userDocs = await Future.wait(
      otherUserIds.map((id) => _firestore.collection('users').doc(id).get()),
    );
    final users = userDocs
        .where((doc) => doc.exists && doc.data() != null)
        .map((doc) => ChatUserModel.fromFirestore(doc.data()!, doc.id))
        .toList();

    return PaginatedResult(
      items: users,
      cursor: snapshot.docs.isEmpty ? lastDocument : snapshot.docs.last,
      hasMore: snapshot.docs.length == limit,
    );
  }
}
