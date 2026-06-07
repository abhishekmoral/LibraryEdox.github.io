import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class ActivityRepository extends GetxController {
  static ActivityRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _libraryId => AuthenticationRepository.instance.authUser.value?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _activityCollection =>
      _db.collection(XFirebaseConstants.librariesCollection).doc(_libraryId).collection(XFirebaseConstants.activityCollection);

  // Fetch recent activity
  Stream<List<ActivityModel>> getRecentActivityStream() {
    if (_libraryId.isEmpty) return const Stream.empty();
    
    return _activityCollection
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ActivityModel.fromSnapshot(doc)).toList());
  }

  // Save new activity
  Future<void> saveActivity(ActivityModel activity) async {
    try {
      await _activityCollection.add(activity.toJson());
    } catch (e) {
      // Silently fail activity logging
    }
  }
}
