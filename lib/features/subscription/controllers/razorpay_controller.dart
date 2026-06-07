import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class RazorpayController extends GetxController {
  static RazorpayController get instance => Get.find();

  late Razorpay _razorpay;
  
  // Replace this with your real Test/Live Key later!
  final String razorpayKey = 'rzp_test_12345678901234'; 

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  /// Opens the Razorpay Checkout overlay
  void openCheckout(String planName, double amountInRupees) {
    // Razorpay expects amount in paise (Rupees * 100)
    var options = {
      'key': razorpayKey,
      'amount': (amountInRupees * 100).toInt(),
      'name': 'EdoxLibrary SaaS',
      'description': 'Upgrade to $planName Plan',
      'prefill': {
        'contact': '9876543210',
        'email': 'admin@edoxlibrary.com'
      },
      'theme': {
        'color': '#7B5AFF' // Match our app's primary color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      XHelperFunctions.showSnackBar('Error launching payment gateway: $e', isError: true);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // In a real app, you would verify the signature on your server
    // and then update the user's plan in Firestore.
    Get.snackbar(
      'Payment Successful!',
      'Payment ID: ${response.paymentId}. Your plan has been upgraded!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: XColors.success,
      colorText: XColors.white,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      '${response.message}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: XColors.error,
      colorText: XColors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    XHelperFunctions.showSnackBar('External Wallet Selected: ${response.walletName}');
  }
}
