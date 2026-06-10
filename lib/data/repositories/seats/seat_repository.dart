import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';

class SeatRepository {
  static SeatRepository get instance => locator<SeatRepository>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _seatsCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.seatsCollection);

  // Fetch all seats stream
  Stream<List<SeatModel>> getAllSeatsStream(String slotId) {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _seatsCollection
        .where('slotId', isEqualTo: 'default')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SeatModel.fromSnapshot(doc))
          .toList();
      // Sort in-memory by seat number to bypass composite index requirement
      list.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
      return list;
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
  Future<int> getTotalSeatsCount(String slotId) async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _seatsCollection
        .where('slotId', isEqualTo: 'default')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Get available seats count
  Future<int> getAvailableSeatsCount(String slotId) async {
    if (_libraryId.isEmpty) return 0;
    
    final total = await getTotalSeatsCount(slotId);
    
    // Count how many seats are in maintenance
    final maintenanceSnapshot = await _seatsCollection.where('status', isEqualTo: 'maintenance').count().get();
    final maintenanceCount = maintenanceSnapshot.count ?? 0;
    
    final occupied = await getOccupiedSeatsCount(slotId);
    
    final available = total - occupied - maintenanceCount;
    return available < 0 ? 0 : available;
  }

  // Get occupied seats count
  Future<int> getOccupiedSeatsCount(String slotId) async {
    if (_libraryId.isEmpty) return 0;
    
    final membersCollection = _db.collection(XFirebaseConstants.librariesCollection)
        .doc(_libraryId)
        .collection(XFirebaseConstants.membersCollection);

    // Fetch ALL active members (we need to check time-based overlaps in-memory)
    final snapshot = await membersCollection
        .where('status', isEqualTo: 'active')
        .get();

    if (slotId == 'all') {
      // "All" view: count any active member with a valid seat
      final occupiedSeatNumbers = snapshot.docs
          .map((doc) => doc.data()['seatNumber'] as String?)
          .where((seatNum) => seatNum != null && seatNum.isNotEmpty && seatNum != 'Unassigned')
          .toSet();
      return occupiedSeatNumbers.length;
    }

    // Build slot lookup map for time-range comparison
    final slotsCubit = locator<SlotsCubit>();
    
    final slotMap = <String, SlotModel>{
      'default': SlotModel(
        id: 'default', name: 'Complete',
        startTime: '12:00 AM', endTime: '11:59 PM',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    };
    for (final s in slotsCubit.state.slots) {
      slotMap[s.id] = s;
    }

    final viewedSlot = slotMap[slotId];
    if (viewedSlot == null) {
      // Fallback: exact slot match only
      final seatNumbers = snapshot.docs
          .where((doc) => doc.data()['slotId'] == slotId)
          .map((doc) => doc.data()['seatNumber'] as String?)
          .where((seatNum) => seatNum != null && seatNum.isNotEmpty && seatNum != 'Unassigned')
          .toSet();
      return seatNumbers.length;
    }

    // Count seats where the member's slot overlaps in time with the viewed slot
    final occupiedSeatNumbers = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final seatNum = data['seatNumber'] as String?;
      if (seatNum == null || seatNum.isEmpty || seatNum == 'Unassigned') continue;

      final memberSlotId = data['slotId'] as String? ?? 'default';
      final memberSlot = slotMap[memberSlotId];
      if (memberSlot == null) continue;

      if (slotsCubit.doSlotsOverlap(
        viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
        memberSlot.name, memberSlot.startTime, memberSlot.endTime,
      )) {
        occupiedSeatNumbers.add(seatNum);
      }
    }

    return occupiedSeatNumbers.length;
  }
}
