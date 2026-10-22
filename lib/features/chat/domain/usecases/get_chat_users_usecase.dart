import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../repositories/chat_repository.dart';


class GetChatUsersUseCase {
  final ChatRepository _repository;

  GetChatUsersUseCase(this._repository);

  Stream<Either<AppFailure, List<ChatUserEntity>>> execute(String currentUserId) {
    return _repository.getRecentChatUsers(currentUserId);
  }
}