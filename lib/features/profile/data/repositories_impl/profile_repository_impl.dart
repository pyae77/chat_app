import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/core/failures/app_failure.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<Either<AppFailure, UserProfileEntity?>> getUserProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const Left(ServerFailure('User not authenticated')));
    }

    return _firestore.collection('users').doc(uid).snapshots().map<Either<AppFailure, UserProfileEntity?>>((doc) {
      try {
        if (!doc.exists || doc.data() == null) {
          return const Right(null);
        }
        final data = doc.data()!;
        final profile = UserProfileEntity(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? _auth.currentUser?.email ?? '',
          bio: data['bio'] ?? '',
          photoBase64: (data['photoBase64'] is String &&
                  (data['photoBase64'] as String).trim().isNotEmpty)
              ? (data['photoBase64'] as String).trim()
              : null,
          isOnline: data['isOnline'] ?? false,
          lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
        );
        return Right(profile);
      } catch (e) {
        return Left(ServerFailure('Failed to parse user profile: $e'));
      }
    }).handleError((error) {
      return Left(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<AppFailure, void>> updateProfile({required String name, required String bio, String? photoBase64}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return const Left(ServerFailure('User not authenticated'));

      final updateData = <String, dynamic>{
        'name': name,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (photoBase64 != null) {
        updateData['photoBase64'] = photoBase64;
      }
      
      await _firestore.collection('users').doc(uid).update(updateData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> toggleOnlineStatus(bool isOnline) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return const Left(ServerFailure('User not authenticated'));

      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update online status: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }
}