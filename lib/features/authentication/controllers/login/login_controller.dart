import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/utils/constants/colors.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // Variables
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final hidePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> login() async {
    try {
      // Form Validation
      if (!loginFormKey.currentState!.validate()) return;

      // Start Loading
      isLoading.value = true;

      // Authenticate User
      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // AuthenticationRepository's onReady will handle the redirect, but we can also manually ensure it.
      // Usually, the stream listener handles it.

    } catch (e) {
      // Show Error
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.error,
        colorText: XColors.white,
      );
    } finally {
      // Stop Loading
      isLoading.value = false;
    }
  }
}
