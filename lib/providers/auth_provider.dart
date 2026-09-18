import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, error }

/// Exposes auth actions (sign in / sign up / sign out) and their loading
/// / error state to the UI. The actual "is a user logged in" state is
/// driven by a StreamProvider<User?> in main.dart, listening directly to
/// AuthService.authStateChanges, so screens rebuild reactively and
/// persistently across app restarts.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  User? get currentUser => _authService.currentUser;

  Future<bool> signIn(String email, String password) async {
    _setLoading();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setIdle();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading();
    try {
      await _authService.signUpWithEmail(email: email, password: password);
      _setIdle();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setIdle() {
    status = AuthStatus.idle;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    status = AuthStatus.error;
    errorMessage = message;
    notifyListeners();
  }
}
