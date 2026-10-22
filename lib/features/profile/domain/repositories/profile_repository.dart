
import 'package:dart_either/dart_either.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';

import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Stream<Either<AppFailure, UserProfileEntity?>> getUserProfile();
  Future<Either<AppFailure, void>> updateProfile({required String name, required String bio, String? photoBase64});
  Future<Either<AppFailure, void>> toggleOnlineStatus(bool isOnline);
  Future<Either<AppFailure, void>> signOut();
}