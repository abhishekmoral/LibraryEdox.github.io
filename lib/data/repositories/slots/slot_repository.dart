import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';

class SlotRepository {
  static SlotRepository get instance => locator<SlotRepository>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _slotsCollection =>
      _db.collection('libraries').doc(_libraryId).collection('slots');

  // Fetch slots stream
  Stream<List<SlotModel>> getSlotsStream() {
    if (_libraryId.isEmpty) return const Stream.empty();
    return _slotsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SlotModel.fromSnapshot(doc)).toList();
    });
  }

  // Save new slot record
  Future<String> saveSlotRecord(SlotModel slot) async {
    try {
      final docRef = await _slotsCollection.add(slot.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save slot data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Save slot with a specific ID
  Future<void> saveSlotRecordWithId(String id, SlotModel slot) async {
    try {
      await _slotsCollection.doc(id).set(slot.toJson());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save slot data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Delete slot
  Future<void> deleteSlot(String id) async {
    try {
      await _slotsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete slot.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Update slot
  Future<void> updateSlot(SlotModel slot) async {
    try {
      await _slotsCollection.doc(slot.id).update(slot.toJson());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update slot.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
