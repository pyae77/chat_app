import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../repositories/chat_room_repository.dart';

class UpdateTypingStatusUseCase {
  final ChatRoomRepository _repository;

  UpdateTypingStatusUseCase(this._repository);

  Future<Either<AppFailure, void>> call({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) {
    return _repository.updateTypingStatus(
      chatRoomId,
      userId,
      isTyping,
    );
  }
}