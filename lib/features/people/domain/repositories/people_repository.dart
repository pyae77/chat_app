import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/entities/paginated_result.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

abstract class PeopleRepository {
  Future<Either<AppFailure, PaginatedResult<ChatUserEntity>>> getPeople({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
    bool onlineOnly = false,
  });

  Stream<ChatUserEntity?> getUserPresenceStream(String userId);
}
