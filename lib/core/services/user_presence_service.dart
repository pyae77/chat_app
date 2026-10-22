
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPresenceService with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _updateUserStatus(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (state == AppLifecycleState.resumed) {

      _updateUserStatus(true);
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.detached ||
               state == AppLifecycleState.inactive) {
    
      _updateUserStatus(false);
    }
  }

  Future<void> _updateUserStatus(bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(), 
      });
    }
  }
}