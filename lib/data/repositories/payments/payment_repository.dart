import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class PaymentRepository extends GetxController {
  static PaymentRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.authUser.value?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _paymentsCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.paymentsCollection);

  // Save new payment record
  Future<String> savePaymentRecord(PaymentModel payment) async {
    try {
      final docRef = await _paymentsCollection.add(payment.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save payment data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Get total monthly revenue (current month)
  Future<double> getMonthlyRevenue() async {
    if (_libraryId.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final snapshot = await _paymentsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .get();
        
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] ?? 0.0).toDouble();
    }
    return total;
  }

  // Get today's collection
  Future<double> getTodaysCollection() async {
    if (_libraryId.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final snapshot = await _paymentsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
        
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] ?? 0.0).toDouble();
    }
    return total;
  }

  // Get revenue for the last 6 months
  Future<List<double>> getRevenueChartData() async {
    if (_libraryId.isEmpty) return List.filled(6, 0.0);
    
    final now = DateTime.now();
    final List<double> monthlyData = List.filled(6, 0.0);
    
    // Create a boundary for 6 months ago
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    final snapshot = await _paymentsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
        .get();
        
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final amount = (data['amount'] ?? 0.0).toDouble();
      
      // Determine which month bucket it falls into (0 to 5)
      // 5 is current month, 0 is 5 months ago
      final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
      if (monthDiff >= 0 && monthDiff < 6) {
        monthlyData[5 - monthDiff] += amount;
      }
    }
    
    return monthlyData;
  }
}
