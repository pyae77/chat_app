import 'package:flutter_chat_app/features/profile/data/repositories_impl/profile_repository_impl.dart';
import 'package:flutter_chat_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter_chat_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_chat_app/features/profile/domain/usecases/update_online_status_usecase.dart';
import 'package:flutter_chat_app/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return UpdateUserProfileUseCase(ref.read(profileRepositoryProvider));
});

final toggleOnlineStatusUseCaseProvider = Provider<ToggleOnlineStatusUseCase>((ref) {
  return ToggleOnlineStatusUseCase(ref.read(profileRepositoryProvider));
});

// Stream Provider returning UserProfileEntity directly
final userProfileStreamProvider = StreamProvider.autoDispose<UserProfileEntity?>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getUserProfile().map((either) {
    return either.fold(
      ifLeft: (failure) => null,
      ifRight: (profile) => profile,
    );
  });
});

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref);
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ProfileController(this.ref) : super(const AsyncData(null));

  Future<void> updateProfile({required String name, required String bio, String? photoBase64}) async {
    state = const AsyncLoading();
    final result = await ref.read(updateUserProfileUseCaseProvider).execute(
          name: name,
          bio: bio,
          photoBase64: photoBase64,
        );

    state = result.fold(
      ifLeft: (failure) => AsyncError(failure.message, StackTrace.current),
      ifRight: (_) => const AsyncData(null),
    );
  }

  Future<void> toggleOnlineStatus(bool isOnline) async {
    await ref.read(toggleOnlineStatusUseCaseProvider).execute(isOnline);
  }

  Future<void> signOut() async {
    await ref.read(profileRepositoryProvider).signOut();
  }
}