import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../entities/message_entity.dart';

abstract class ChatRoomRepository {
  Stream<Either<AppFailure, List<MessageEntity>>> getMessagesStream(String chatRoomId);
  Future<Either<AppFailure, void>> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String messageText,
  });

  Future<Either<AppFailure, void>> sendImageMessage({
    required String chatRoomId,
    required String receiverId,
    required String imagePath,
  });
}