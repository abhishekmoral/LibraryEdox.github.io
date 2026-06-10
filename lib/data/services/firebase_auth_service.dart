import 'package:firebase_auth/firebase_auth.dart';
import 'package:edox_library/bindings/dependency_injection.dart';

import 'package:edox_library/utils/logging/logger.dart';

/// A wrapper around [FirebaseAuth] that provides
/// authentication methods for the EdoxLibrary application.
class FirebaseAuthService {
  FirebaseAuthService() {
    _init();
  }

  static FirebaseAuthService get instance => locator<FirebaseAuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _init() {
    // Keep the logger in sync with the auth state.
    _auth.authStateChanges().listen((User? user) {
      XLoggerHelper.info(
        user != null
            ? 'Auth state changed → signed in as ${user.email}'
            : 'Auth state changed → signed out',
      );
    });
  }

  // ──────────────────────────── Email Auth ───────────────────────

  /// Signs in with [email] and [password] and returns the credential.
  Future<UserCredential> loginWithEmail(String email, String password) async {
    try {
      XLoggerHelper.info('Logging in with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e, st) {
      XLoggerHelper.error('Login failed: ${e.message}', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      XLoggerHelper.error('Login failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Registers a new user with [email] and [password].
  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      XLoggerHelper.info('Registering with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e, st) {
      XLoggerHelper.error('Registration failed: ${e.message}', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      XLoggerHelper.error('Registration failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Email Verification ───────────────

  /// Sends a verification email to the currently signed-in user.
  Future<void> sendEmailVerification() async {
    try {
      XLoggerHelper.info('Sending email verification');
      await _auth.currentUser?.sendEmailVerification();
    } catch (e, st) {
      XLoggerHelper.error('Email verification failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Password Reset ──────────────────

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      XLoggerHelper.info('Sending password reset email to $email');
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, st) {
      XLoggerHelper.error('Password reset email failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Session ─────────────────────────

  /// Signs the current user out.
  Future<void> logout() async {
    try {
      XLoggerHelper.info('Logging out');
      await _auth.signOut();
    } catch (e, st) {
      XLoggerHelper.error('Logout failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Whether a user is currently signed in.
  bool isLoggedIn() => _auth.currentUser != null;

  /// Returns the currently signed-in [User], or `null`.
  User? getCurrentUser() => _auth.currentUser;

  // ──────────────────────────── Account Management ──────────────

  /// Deletes the current user's account permanently.
  Future<void> deleteAccount() async {
    try {
      XLoggerHelper.info('Deleting user account');
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e, st) {
      XLoggerHelper.error('Account deletion failed: ${e.message}', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      XLoggerHelper.error('Account deletion failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Updates the current user's password to [newPassword].
  Future<void> updatePassword(String newPassword) async {
    try {
      XLoggerHelper.info('Updating password');
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e, st) {
      XLoggerHelper.error('Password update failed: ${e.message}', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      XLoggerHelper.error('Password update failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
