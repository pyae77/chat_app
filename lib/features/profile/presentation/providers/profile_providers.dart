import 'package:flutter_chat_app/core/services/user_presence_service.dart';
import 'package:flutter_chat_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chat_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_chat_app/features/home/presentation/providers/home_providers.dart';
import 'package:flutter_chat_app/features/people/presentation/providers/people_providers.dart';
import 'package:flutter_chat_app/features/profile/data/repositories_impl/profile_repository_impl.dart';
import 'package:flutter_chat_app/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter_chat_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_chat_app/features/profile/domain/usecases/update_online_status_usecase.dart';
import 'package:flutter_chat_app/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    googleSignIn: ref.watch(googleSignInProvider),
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  return UpdateUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final toggleOnlineStatusUseCaseProvider = Provider<ToggleOnlineStatusUseCase>((
  ref,
) {
  return ToggleOnlineStatusUseCase(ref.watch(profileRepositoryProvider));
});

final userProfileStreamProvider =
    StreamProvider.autoDispose<UserProfileEntity?>((ref) {
      final currentUserId = ref.watch(currentUserIdProvider);
      if (currentUserId == null || currentUserId.isEmpty) {
        return Stream.value(null);
      }

      final repo = ref.watch(profileRepositoryProvider);
      return repo.getUserProfile().map((either) {
        return either.fold(
          ifLeft: (failure) => null,
          ifRight: (profile) => profile,
        );
      });
    });

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref);
    });

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  bool _isSigningOut = false;

  ProfileController(this.ref) : super(const AsyncData(null));

  bool get isSigningOut => _isSigningOut;

  Future<void> updateProfile({
    required String name,
    required String bio,
    String? photoBase64,
  }) async {
    if (_isSigningOut) return;
    state = const AsyncLoading();
    final result = await ref
        .read(updateUserProfileUseCaseProvider)
        .execute(name: name, bio: bio, photoBase64: photoBase64);

    state = result.fold(
      ifLeft: (failure) => AsyncError(failure.message, StackTrace.current),
      ifRight: (_) => const AsyncData(null),
    );
  }

  Future<void> toggleOnlineStatus(bool isOnline) async {
    await ref.read(toggleOnlineStatusUseCaseProvider).execute(isOnline);
    ref.invalidate(onlineUsersProvider);
  }

  Future<void> signOut() async {
    if (_isSigningOut) return;
    _isSigningOut = true;
    state = const AsyncLoading();

    try {
      await ref.read(userPresenceServiceProvider).goOfflineAndStop();
      final result = await ref.read(profileRepositoryProvider).signOut();

      result.fold(
        ifLeft: (failure) {
          state = AsyncError(failure.message, StackTrace.current);
        },
        ifRight: (_) {
          _resetSessionProviders();
          state = const AsyncData(null);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    } finally {
      _isSigningOut = false;
    }
  }

  void _resetSessionProviders() {
    ref.invalidate(userProfileStreamProvider);
    ref.invalidate(chatUsersProvider);
    ref.invalidate(peopleProvider);
    ref.invalidate(onlineUsersProvider);
    ref.invalidate(peopleSearchQueryProvider);
    ref.invalidate(searchQueryProvider);
    ref.invalidate(bottomNavIndexProvider);
    ref.invalidate(authControllerProvider);
    ref.invalidate(googleAuthControllerProvider);
  }
}
