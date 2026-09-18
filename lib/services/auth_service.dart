import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] so that no widget talks to Firebase
/// directly. All auth-related business logic lives here.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Emits the current [User] whenever the auth state changes
  /// (sign in, sign out, token refresh on app restart, etc).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Converts Firebase's error codes into short, human-readable messages.
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
