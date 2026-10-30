
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<void> createUserProfile({
    required User user,
    String? fallbackName,
    String? fallbackEmail,
    bool isOnline = false,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? fallbackName ?? 'No Name',
      'email': user.email ?? fallbackEmail ?? '',
      'profilePic': user.photoURL ?? '',
      'photoUrl': user.photoURL ?? '',
      'photoBase64': null,
      'createdAt': FieldValue.serverTimestamp(),
      'isOnline': isOnline,
    });
  }

  Future<void> createProfileIfNotExists({
    required User user,
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await createUserProfile(
        user: user,
        fallbackName: fallbackName,
        fallbackEmail: fallbackEmail,
        isOnline: true,
      );
    } else {
      await userRef.update({
        'isOnline': true,
      });
    }
  }
}
