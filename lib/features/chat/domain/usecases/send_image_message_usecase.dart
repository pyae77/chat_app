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
  }) {
    return _repository.sendImageMessage(
      chatRoomId: chatRoomId,
      receiverId: receiverId,
      imagePath: imagePath,
    );
  }
}