import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';

class MemberRepository {
  static MemberRepository get instance => locator<MemberRepository>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _membersCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.membersCollection);

  // Fetch all members stream
  Stream<List<MemberModel>> getAllMembersStream(String slotId) {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _membersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MemberModel.fromSnapshot(doc))
          .where((m) => m.status != 'deleted')
          .where((m) => slotId == 'all' || m.slotId == slotId)
          .toList();
    });
  }

  // Save new member record
  Future<String> saveMemberRecord(MemberModel member) async {
    try {
      final docRef = await _membersCollection.add(member.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save member data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Update existing member
  Future<void> updateMember(MemberModel member) async {
    try {
      await _membersCollection.doc(member.id).update(member.toJson());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to update member data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Delete member (moves to Recycle Bin)
  Future<void> deleteMember(String id) async {
    try {
      await _membersCollection.doc(id).update({
        'status': 'deleted',
        'deletedAt': Timestamp.now(),
        'seatId': '',
        'seatNumber': 'Unassigned',
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete member.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Permanently delete member from backend
  Future<void> permanentlyDeleteMember(String id) async {
    try {
      await _membersCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to permanently delete member.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Restore member from Recycle Bin
  Future<void> restoreMember(MemberModel member) async {
    try {
      final isExpired = DateTime.now().isAfter(member.expiryDate);
      await _membersCollection.doc(member.id).update({
        'status': isExpired ? 'expired' : 'active',
        'deletedAt': FieldValue.delete(),
        'seatId': '',
        'seatNumber': 'Unassigned',
      });
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to restore member.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Get stream of Recycle Bin members
  Stream<List<MemberModel>> getBinMembersStream() {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _membersCollection
        .where('status', isEqualTo: 'deleted')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MemberModel.fromSnapshot(doc))
          .toList();
      // Sort by deletedAt descending (most recently deleted first)
      list.sort((a, b) {
        if (a.deletedAt == null) return 1;
        if (b.deletedAt == null) return -1;
        return b.deletedAt!.compareTo(a.deletedAt!);
      });
      return list;
    });
  }

  // Get total members count using overlap logic
  Future<int> getTotalMembersCount(String slotId) async {
    if (_libraryId.isEmpty) return 0;
    
    final snapshot = await _membersCollection.get();
    final activeDocs = snapshot.docs.where((doc) => (doc.data()['status'] as String? ?? 'active') != 'deleted').toList();
    
    if (slotId == 'all') {
      return activeDocs.length;
    }
    
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
      return activeDocs.where((doc) => doc.data()['slotId'] == slotId).length;
    }
    
    int count = 0;
    for (final doc in activeDocs) {
      final data = doc.data();
      final memberSlotId = data['slotId'] as String? ?? 'default';
      final memberSlot = slotMap[memberSlotId];
      if (memberSlot == null) continue;
      
      if (slotsCubit.doSlotsOverlap(
        viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
        memberSlot.name, memberSlot.startTime, memberSlot.endTime,
      )) {
        count++;
      }
    }
    return count;
  }

  // Get active members count using overlap logic
  Future<int> getActiveMembersCount(String slotId) async {
    if (_libraryId.isEmpty) return 0;
    
    final snapshot = await _membersCollection.where('status', isEqualTo: 'active').get();
    final activeDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      final seatId = data['seatId'] as String? ?? '';
      final seatNumber = data['seatNumber'] as String? ?? '';
      return seatId.isNotEmpty && seatNumber != 'Unassigned';
    }).toList();
    
    if (slotId == 'all') {
      return activeDocs.length;
    }
    
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
      return activeDocs.where((doc) => doc.data()['slotId'] == slotId).length;
    }
    
    int count = 0;
    for (final doc in activeDocs) {
      final data = doc.data();
      final memberSlotId = data['slotId'] as String? ?? 'default';
      final memberSlot = slotMap[memberSlotId];
      if (memberSlot == null) continue;
      
      if (slotsCubit.doSlotsOverlap(
        viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
        memberSlot.name, memberSlot.startTime, memberSlot.endTime,
      )) {
        count++;
      }
    }
    return count;
  }

  // Get pending payments amount using overlap logic
  Future<double> getPendingPaymentsAmount(String slotId) async {
    if (_libraryId.isEmpty) return 0.0;
    
    final snapshot = await _membersCollection.where('paymentStatus', isEqualTo: 'pending').get();
    
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
    
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      // Exclude soft-deleted members
      if ((data['status'] as String? ?? 'active') == 'deleted') continue;

      if (slotId != 'all') {
        final memberSlotId = data['slotId'] as String? ?? 'default';
        final memberSlot = slotMap[memberSlotId];
        if (memberSlot == null) continue;
        
        if (viewedSlot == null) {
          if (memberSlotId != slotId) continue;
        } else {
          if (!slotsCubit.doSlotsOverlap(
            viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
            memberSlot.name, memberSlot.startTime, memberSlot.endTime,
          )) continue;
        }
      }
      
      final planId = data['planId'] as String?;
      if (planId == 'monthly') total += 1500;
      else if (planId == 'quarterly') total += 4000;
      else if (planId == 'half_yearly') total += 7500;
      else if (planId == 'annual') total += 14000;
    }
    return total;
  }
}
