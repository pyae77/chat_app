import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/entities/paginated_result.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/firestore_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirestoreChatDataSource _datasource;

  ChatRepositoryImpl({required FirestoreChatDataSource datasource})
    : _datasource = datasource;

  @override
  Future<Either<AppFailure, PaginatedResult<ChatUserEntity>>>
  getRecentChatUsers({
    required String currentUserId,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
  }) async {
    try {
      final page = await _datasource.getRecentChatUsers(
        currentUserId: currentUserId,
        lastDocument: lastDocument,
        limit: limit,
      );
      return Right(
        PaginatedResult(
          items: page.items.map((model) => model.toEntity()).toList(),
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      return Left(UserFetchFailure(e.toString()));
    }
  }
}
