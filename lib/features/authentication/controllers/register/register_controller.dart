import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';
import 'package:edox_library/utils/constants/colors.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  // Variables
  final libraryNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();
  final hidePassword = true.obs;
  final isLoading = false.obs;
  final privacyPolicy = true.obs;

  @override
  void onClose() {
    libraryNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    try {
      // Form Validation
      if (!registerFormKey.currentState!.validate()) return;

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        Get.snackbar(
          'Accept Privacy Policy',
          'In order to create an account, you must read and accept the Privacy Policy & Terms of Use.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: XColors.warning,
          colorText: XColors.white,
        );
        return;
      }

      // Start Loading
      isLoading.value = true;

      // Register User in Firebase Authentication
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Save user details in Firestore
      final newLibrary = LibraryModel(
        id: userCredential.user!.uid,
        libraryName: libraryNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        address: addressController.text.trim(),
        logo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await LibraryRepository.instance.saveLibraryRecord(newLibrary);

      // Show Success Message
      Get.snackbar(
        'Success',
        'Your account has been created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.success,
        colorText: XColors.white,
      );

      // AuthenticationRepository's onReady handles redirect

    } catch (e) {
      // Show Error
      Get.snackbar(
        'Registration Failed',
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
