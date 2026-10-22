import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

abstract class ChatRepository {
  
  Stream<Either<AppFailure, List<ChatUserEntity>>> getRecentChatUsers(String currentUserId);
}