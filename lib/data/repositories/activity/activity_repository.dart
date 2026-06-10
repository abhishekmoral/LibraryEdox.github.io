import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';

class ActivityRepository {
  static ActivityRepository get instance => locator<ActivityRepository>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _activityCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.activityCollection);

  // Fetch recent activity
  Stream<List<ActivityModel>> getRecentActivityStream(String slotId) {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _activityCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromSnapshot(doc))
            .where((a) => slotId == 'all' || a.slotId == slotId)
            .take(10)
            .toList());
  }

  // Save new activity
  Future<void> saveActivity(ActivityModel activity) async {
    try {
      final activeSlotId = locator<SlotsCubit>().state.selectedSlotId;
      final savedSlotId = activeSlotId == 'all' ? 'default' : activeSlotId;
      final savedActivity = activity.slotId.isEmpty
          ? activity.copyWith(slotId: savedSlotId)
          : activity;
      await _activityCollection.add(savedActivity.toJson());
    } catch (e) {
      // Silently fail activity logging
    }
  }
}
