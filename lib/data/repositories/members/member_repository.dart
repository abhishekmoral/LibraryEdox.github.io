import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class MemberRepository extends GetxController {
  static MemberRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.authUser.value?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _membersCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.membersCollection);

  // Fetch all members stream
  Stream<List<MemberModel>> getAllMembersStream() {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _membersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MemberModel.fromSnapshot(doc)).toList();
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

  // Delete member
  Future<void> deleteMember(String id) async {
    try {
      await _membersCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to delete member.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Get total members count
  Future<int> getTotalMembersCount() async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _membersCollection.count().get();
    return snapshot.count ?? 0;
  }

  // Get active members count
  Future<int> getActiveMembersCount() async {
    if (_libraryId.isEmpty) return 0;
    final snapshot = await _membersCollection.where('status', isEqualTo: 'active').count().get();
    return snapshot.count ?? 0;
  }

  // Get pending payments amount
  Future<double> getPendingPaymentsAmount() async {
    if (_libraryId.isEmpty) return 0.0;
    
    final snapshot = await _membersCollection
        .where('paymentStatus', isEqualTo: 'pending')
        .get();
        
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final planId = data['planId'] as String?;
      if (planId == 'monthly') total += 1500;
      else if (planId == 'quarterly') total += 4000;
      else if (planId == 'half_yearly') total += 7500;
      else if (planId == 'annual') total += 14000;
    }
    return total;
  }
}
