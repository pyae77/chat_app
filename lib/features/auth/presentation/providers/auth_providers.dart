import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Domain
import '../../../../core/routes/auth_redirect_guard.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// Data
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';

// =====================================================
// 1. FIREBASE PROVIDERS
// =====================================================

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// =====================================================
// 2. DATA SOURCE PROVIDERS
// =====================================================

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final firestoreUserDataSourceProvider = Provider<FirestoreUserDataSource>((
  ref,
) {
  return FirestoreUserDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// =====================================================
// 3. REPOSITORY PROVIDER
// =====================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDataSource: ref.watch(firebaseAuthDataSourceProvider),
    userDataSource: ref.watch(firestoreUserDataSourceProvider),
  );
});

// =====================================================
// 4. USE CASE PROVIDERS
// =====================================================

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  return GoogleSignInUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// =====================================================
// 5. AUTH STATE STREAM
// =====================================================

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// =====================================================
// 6. EMAIL AUTH CONTROLLER
// =====================================================

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(signInUseCaseProvider)(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider)();
    });
  }
}

// =====================================================
// 7. GOOGLE AUTH CONTROLLER
// =====================================================

final googleAuthControllerProvider =
    AsyncNotifierProvider<GoogleAuthController, void>(GoogleAuthController.new);

class GoogleAuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(googleSignInUseCaseProvider)();
    });
  }
}

// =====================================================
// 8. SIGN UP CONTROLLER
// =====================================================

final signUpControllerProvider = AsyncNotifierProvider<SignUpController, void>(
  SignUpController.new,
);

class SignUpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    AuthRedirectGuard.isRegistrationInProgress = true;
    late final AsyncValue<void> result;
    try {
      result = await AsyncValue.guard(() async {
        await ref.read(signUpUseCaseProvider)(
          name: name.trim(),
          email: email.trim(),
          password: password,
        );
      });
    } finally {
      AuthRedirectGuard.isRegistrationInProgress = false;
    }

    state = result;
  }
}

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(
    authStateProvider,
  ); // authStateProvider = StreamProvider<User?>
  return authState.value?.uid;
});
