import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/bindings/dependency_injection.dart';

class RazorpayService {
  static RazorpayService get instance => locator<RazorpayService>();

  late Razorpay _razorpay;
  
  // Replace this with your real Test/Live Key later!
  final String razorpayKey = 'rzp_test_12345678901234'; 
  BuildContext? _context;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Opens the Razorpay Checkout overlay
  void openCheckout(BuildContext context, String planName, double amountInRupees) {
    _context = context;
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
      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(content: Text('Error launching payment gateway: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! Payment ID: ${response.paymentId}. Your plan has been upgraded!'),
          backgroundColor: XColors.success,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: XColors.error,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}'),
        ),
      );
    }
  }
}
