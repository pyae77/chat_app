import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../entities/message_entity.dart';
import '../repositories/chat_room_repository.dart';

class GetMessagesUseCase {
  final ChatRoomRepository _repository;

  GetMessagesUseCase(this._repository);

  Stream<Either<AppFailure, List<MessageEntity>>> execute(
    String chatRoomId,
  ) {
    return _repository.getMessagesStream(chatRoomId);
  }
}

class SendMessageUseCase {
  final ChatRoomRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<AppFailure, void>> execute({
    required String chatRoomId,
    required String receiverId,
    required String messageText,
    String? replyToMessageId,
    String? replyToSenderId,
    String? replyToMessage,
    String? replyToImageUrl,
  }) {
    return _repository.sendMessage(
      chatRoomId: chatRoomId,
      receiverId: receiverId,
      messageText: messageText,
      replyToMessageId: replyToMessageId,
      replyToSenderId: replyToSenderId,
      replyToMessage: replyToMessage,
      replyToImageUrl: replyToImageUrl,
    );
  }
}