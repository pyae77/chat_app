import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/models/chat_user_model.dart';

abstract class FirestoreChatDataSource {
  Stream<List<ChatUserModel>> getRecentChatUsers(String currentUserId);
}

class FirestoreChatDataSourceImpl implements FirestoreChatDataSource {
  final FirebaseFirestore _firestore;

  FirestoreChatDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChatUserModel>> getRecentChatUsers(String currentUserId) {
   
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      
      final List<Map<String, dynamic>> roomDataList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final List<dynamic> participants = data['participants'] ?? [];
    
        final otherId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );

        if (otherId.isNotEmpty) {
          roomDataList.add({
            'otherId': otherId,
            'timestamp': (data['lastMessageTimestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
          });
        }
      }

      if (roomDataList.isEmpty) return [];
      roomDataList.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

      final List<String> orderedOtherUserIds = roomDataList.map((e) => e['otherId'] as String).toList();

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: orderedOtherUserIds)
          .get();

      final usersMap = {
        for (var doc in usersSnapshot.docs)
          doc.id: ChatUserModel.fromFirestore(doc.data(), doc.id)
      };

      final List<ChatUserModel> sortedUsers = [];
      for (var id in orderedOtherUserIds) {
        if (usersMap.containsKey(id)) {
          sortedUsers.add(usersMap[id]!);
        }
      }

      return sortedUsers;
    });
  }
}