import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:edox_library/routes/app_routes.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> authUser;

  @override
  void onReady() {
    super.onReady();
    authUser = Rx<User?>(_auth.currentUser);
    authUser.bindStream(_auth.authStateChanges());
    ever(authUser, _setInitialScreen);
    _setInitialScreen(_auth.currentUser);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      if (Get.currentRoute != XRoutes.login) {
        Get.offAllNamed(XRoutes.login);
      }
    } else {
      if (Get.currentRoute != XRoutes.navigation) {
        Get.offAllNamed(XRoutes.navigation);
      }
    }
  }

  // --- Methods ---

  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Authentication failed.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration failed.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Logout failed.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send password reset email.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
