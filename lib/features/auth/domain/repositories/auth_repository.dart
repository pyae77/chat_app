
abstract class AuthRepository {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
