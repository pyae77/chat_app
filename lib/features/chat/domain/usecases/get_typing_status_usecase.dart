import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../repositories/chat_room_repository.dart';

class GetTypingStatusUseCase {
  final ChatRoomRepository _repository;

  GetTypingStatusUseCase(this._repository);

  Stream<Either<AppFailure, bool>> call({
    required String chatRoomId,
    required String userId,
  }) {
    return _repository.getTypingStatus(
      chatRoomId,
      userId,
    );
  }
}