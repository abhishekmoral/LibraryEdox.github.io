import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/features/subscription/controllers/subscription_cubit.dart';

class RazorpayService {
  static RazorpayService get instance => locator<RazorpayService>();

  late Razorpay _razorpay;
  
  // Replace this with your real Test/Live Key later!
  final String razorpayKey = 'rzp_test_12345678901234'; 
  BuildContext? _context;
  String _selectedPlanName = 'Basic';

  void init() {
    if (kIsWeb) return; // Native SDK is not supported on Web; skip initialization
    
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    if (kIsWeb) return;
    _razorpay.clear();
  }

  /// Opens the Razorpay Checkout overlay
  void openCheckout(BuildContext context, String planName, double amountInRupees) {
    _context = context;
    _selectedPlanName = planName;
    
    if (kIsWeb) {
      _simulateWebPayment(context, planName, amountInRupees);
      return;
    }
    
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

  void _simulateWebPayment(BuildContext context, String planName, double amountInRupees) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: dark ? const Color(0xFF111C44) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.payment, color: XColors.primary),
              const SizedBox(width: 10),
              Text(
                'Razorpay Web Simulator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : XColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are upgrading to the $planName Plan.',
                style: TextStyle(color: dark ? XColors.softGrey : XColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹$amountInRupees',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'This dialog simulates the Razorpay Checkout overlay because you are running on the web environment (Flutter Web does not support native mobile Razorpay SDK).',
                style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Simulate payment failure
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment Cancelled by User'),
                    backgroundColor: XColors.error,
                  ),
                );
              },
              child: const Text('Cancel / Fail', style: TextStyle(color: XColors.error)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                // Show loading state
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Processing payment simulation...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Wait briefly
                await Future.delayed(const Duration(milliseconds: 500));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Successful! Plan activated!'),
                      backgroundColor: XColors.success,
                    ),
                  );
                  
                  // Trigger database update
                  try {
                    context.read<SubscriptionCubit>().updateSubscriptionAfterPurchase(planName, 'monthly');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating subscription: $e'),
                        backgroundColor: XColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: XColors.success),
              child: const Text('Simulate Success'),
            ),
          ],
        );
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! Payment ID: ${response.paymentId}. Your plan has been upgraded!'),
          backgroundColor: XColors.success,
        ),
      );
      
      // Update subscription in database and trigger UI refresh
      try {
        _context!.read<SubscriptionCubit>().updateSubscriptionAfterPurchase(_selectedPlanName, 'monthly');
      } catch (e) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('Error updating subscription in database: $e'),
            backgroundColor: XColors.error,
          ),
        );
      }
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

