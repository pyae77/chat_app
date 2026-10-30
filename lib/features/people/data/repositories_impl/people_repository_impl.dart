import 'package:dart_either/dart_either.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/entities/paginated_result.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import 'package:flutter_chat_app/core/models/chat_user_model.dart';
import '../../domain/repositories/people_repository.dart';
import '../datasources/firestore_people_datasource.dart';

class PeopleRepositoryImpl implements PeopleRepository {
  final FirestorePeopleDataSource _dataSource;

  PeopleRepositoryImpl({required FirestorePeopleDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<AppFailure, PaginatedResult<ChatUserEntity>>> getPeople({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
    bool onlineOnly = false,
  }) async {
    try {
      final snapshot = await _dataSource.getPeople(
        currentUserId: currentUserId,
        lastDocument: lastDocument,
        limit: limit,
        onlineOnly: onlineOnly,
      );

      final users = snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map(
            (doc) => ChatUserModel.fromFirestore(doc.data(), doc.id).toEntity(),
          )
          .toList();

      return Right(
        PaginatedResult(
          items: users,
          cursor: snapshot.docs.isEmpty ? lastDocument : snapshot.docs.last,
          hasMore: snapshot.docs.length == limit,
        ),
      );
    } catch (e) {
      return Left(UserFetchFailure(e.toString()));
    }
  }

  @override
  Stream<ChatUserEntity?> getUserPresenceStream(String userId) {
    return _dataSource
        .getUserPresenceStream(userId)
        .map((model) => model?.toEntity());
  }
}
