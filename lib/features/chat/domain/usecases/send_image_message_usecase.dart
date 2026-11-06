import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_room_repository.dart';

class SendImageMessageUseCase {
  final ChatRoomRepository _repository;

  SendImageMessageUseCase(this._repository);

  Future<Either<AppFailure, void>> execute({
    required String chatRoomId,
    required String receiverId,
    required String imagePath,
    String caption = '',
    String? replyToMessageId,
    String? replyToSenderId,
    String? replyToMessage,
    String? replyToImageUrl,
  }) {
    return _repository.sendImageMessage(
      chatRoomId: chatRoomId,
      receiverId: receiverId,
      imagePath: imagePath,
      caption: caption,
      replyToMessageId: replyToMessageId,
      replyToSenderId: replyToSenderId,
      replyToMessage: replyToMessage,
      replyToImageUrl: replyToImageUrl,
    );
  }
}