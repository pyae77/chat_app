import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Presence is bound at app root via [AppPresenceBinder] so it is not tied to HomeScreen.

class UserPresenceService with WidgetsBindingObserver {
  UserPresenceService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _isObserving = false;

  void start() {
    if (!_isObserving) {
      WidgetsBinding.instance.addObserver(this);
      _isObserving = true;
    }
    _updateUserStatus(true);
  }

  /// Writes `isOnline: false` while auth is still valid, then detaches.
  Future<void> goOfflineAndStop() async {
    await _updateUserStatus(false);
    _stopObserving();
  }

  void stopObserving() {
    _stopObserving();
  }

  void dispose() {
    _stopObserving();
  }

  void _stopObserving() {
    if (!_isObserving) return;
    WidgetsBinding.instance.removeObserver(this);
    _isObserving = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_auth.currentUser == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserStatus(true);
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _updateUserStatus(false);
      case AppLifecycleState.inactive:
        // Ignore: iOS fires this for Control Center / incoming calls.
        break;
    }
  }

  Future<void> _updateUserStatus(bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Presence is best-effort; avoid crashing the app if the write fails.
    }
  }
}

final userPresenceServiceProvider = Provider<UserPresenceService>((ref) {
  final service = UserPresenceService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Keeps presence in sync with auth: start when a user is signed in, stop on logout.
final presenceLifecycleProvider = Provider<void>((ref) {
  final service = ref.watch(userPresenceServiceProvider);

  ref.listen<String?>(
    currentUserIdProvider,
    (previous, next) {
      if (next != null && next.isNotEmpty) {
        service.start();
      } else {
        service.stopObserving();
      }
    },
    fireImmediately: true,
  );
});

class AppPresenceBinder extends ConsumerWidget {
  final Widget child;

  const AppPresenceBinder({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(presenceLifecycleProvider);
    return child;
  }
}
