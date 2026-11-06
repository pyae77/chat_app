import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import '../repositories/chat_room_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRoomRepository _repository;

  MarkMessagesAsReadUseCase(this._repository);

  Future<Either<AppFailure, void>> execute(String chatRoomId, String currentUserId) {
    return _repository.markMessagesAsRead(chatRoomId, currentUserId);
  }
}