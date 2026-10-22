
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/features/auth/domain/failures/auth_failure.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreUserDataSource _userDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreUserDataSource userDataSource,
  })  : _authDataSource = authDataSource,
        _userDataSource = userDataSource;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _userDataSource.createProfileIfNotExists(
          user: user,
          fallbackName: email.trim().split('@').first,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
    on FirebaseException catch (e) {
    throw _mapFirebaseException(e);
}
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authDataSource.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthFailure(
          'Account creation failed. Please try again.',
        );
      }

      await _authDataSource.updateDisplayName(
        user: user,
        name: name,
      );

      await _userDataSource.createUserProfile(
        user: user,
        fallbackName: name.trim(),
        fallbackEmail: email.trim(),
        isOnline: false,
      );

      // Preserve existing behavior:
      // user must sign in manually after registration.
      await _authDataSource.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
    on FirebaseException catch (e) {
  throw _mapFirebaseException(e);
}
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final credential = await _authDataSource.signInWithGoogle();

      // Google account selection was cancelled.
      if (credential == null) return;

      final user = credential.user;

      if (user != null) {
        await _userDataSource.createProfileIfNotExists(
          user: user,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
    on FirebaseException catch (e) {
  throw _mapFirebaseException(e);
}
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
    on FirebaseException catch (e) {
  throw _mapFirebaseException(e);
}
  }

  AuthFailure _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthFailure(
          'Please enter a valid email.',
        );

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          'Incorrect email or password.',
        );

      case 'email-already-in-use':
        return const AuthFailure(
          'This email is already registered.',
        );

      case 'weak-password':
        return const AuthFailure(
          'Please choose a stronger password.',
        );

      case 'network-request-failed':
        return const AuthFailure(
          'Network error. Please check your internet connection.',
        );

      case 'too-many-requests':
        return const AuthFailure(
          'Too many attempts. Please try again later.',
        );

      default:
        return const AuthFailure(
          'Authentication failed. Please try again.',
        );
    }
  }

  AuthFailure _mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const AuthFailure(
        'You do not have permission to perform this action.',
      );

    case 'unavailable':
      return const AuthFailure(
        'Service temporarily unavailable. Please try again.',
      );

    case 'deadline-exceeded':
      return const AuthFailure(
        'The request took too long. Please try again.',
      );

    default:
      return const AuthFailure(
        'Something went wrong. Please try again.',
      );
  }
}
}
