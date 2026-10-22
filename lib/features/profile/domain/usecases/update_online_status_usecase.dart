
import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../repositories/profile_repository.dart';

class ToggleOnlineStatusUseCase {
  final ProfileRepository repository;
  ToggleOnlineStatusUseCase(this.repository);

  Future<Either<AppFailure, void>> execute(bool isOnline) {
    return repository.toggleOnlineStatus(isOnline);
  }
}