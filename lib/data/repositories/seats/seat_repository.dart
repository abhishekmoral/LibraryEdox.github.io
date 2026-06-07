import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class SeatRepository extends GetxController {
  static SeatRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.authUser.value?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _seatsCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.seatsCollection);

  // Fetch all seats stream
  Stream<List<SeatModel>> getAllSeatsStream() {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _seatsCollection.orderBy('seatNumber').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SeatModel.fromSnapshot(doc)).toList();
    });
  }

  // Save new seat record
  Future<String> saveSeatRecord(SeatModel seat) async {
    try {
      final docRef = await _seatsCollection.add(seat.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save seat data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Update existing seat
  Future<void> updateSeat(SeatModel seat) async {
    try {
      await _seatsCollection.doc(seat.id).update(seat.toJson());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update seat.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Delete seat
  Future<void> deleteSeat(String id) async {
    try {
      await _seatsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete seat.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Get total seats count
  Future<int> getTotalSeatsCount() async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _seatsCollection.count().get();
    return snapshot.count ?? 0;
  }

  // Get available seats count
  Future<int> getAvailableSeatsCount() async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _seatsCollection.where('status', isEqualTo: 'available').count().get();
    return snapshot.count ?? 0;
  }

  // Get occupied seats count
  Future<int> getOccupiedSeatsCount() async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _seatsCollection.where('status', isEqualTo: 'occupied').count().get();
    return snapshot.count ?? 0;
  }
}
