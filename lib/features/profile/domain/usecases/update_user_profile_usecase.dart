
import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository repository;
  UpdateUserProfileUseCase(this.repository);

  Future<Either<AppFailure, void>> execute({required String name, required String bio, String? photoBase64}) {
    return repository.updateProfile(name: name, bio: bio, photoBase64: photoBase64);
  }
}