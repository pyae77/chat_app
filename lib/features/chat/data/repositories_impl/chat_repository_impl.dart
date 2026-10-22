import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/firestore_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirestoreChatDataSource _datasource;

  ChatRepositoryImpl({required FirestoreChatDataSource datasource})
      : _datasource = datasource;

  @override
  Stream<Either<AppFailure, List<ChatUserEntity>>> getRecentChatUsers(
    String currentUserId,
  ) {
    try {
      return _datasource.getRecentChatUsers(currentUserId).map((models) {
        final entities = models.map((model) => model.toEntity()).toList();
        return Right<AppFailure, List<ChatUserEntity>>(entities);
      }).handleError((error) {
        return Left<AppFailure, List<ChatUserEntity>>(
          UserFetchFailure(error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(UserFetchFailure(e.toString())),
      );
    }
  }
}