import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/entities/paginated_result.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../repositories/people_repository.dart';

class GetPeopleUseCase {
  final PeopleRepository _repository;

  GetPeopleUseCase(this._repository);

  Future<Either<AppFailure, PaginatedResult<ChatUserEntity>>> execute({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
    bool onlineOnly = false,
  }) {
    return _repository.getPeople(
      currentUserId: currentUserId,
      lastDocument: lastDocument,
      limit: limit,
      onlineOnly: onlineOnly,
    );
  }

  Stream<ChatUserEntity?> getUserPresenceStream(String userId) {
    return _repository.getUserPresenceStream(userId);
  }
}
