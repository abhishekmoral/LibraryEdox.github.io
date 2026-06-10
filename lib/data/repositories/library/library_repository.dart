import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class LibraryRepository {
  static LibraryRepository get instance => locator<LibraryRepository>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save new library record
  Future<void> saveLibraryRecord(LibraryModel library) async {
    try {
      await _db.collection(XFirebaseConstants.librariesCollection).doc(library.id).set(library.toJson());
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to save library data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // Fetch library details based on ID
  Future<LibraryModel> fetchLibraryDetails(String libraryId) async {
    try {
      final documentSnapshot = await _db.collection(XFirebaseConstants.librariesCollection).doc(libraryId).get();
      if (documentSnapshot.exists) {
        return LibraryModel.fromSnapshot(documentSnapshot);
      } else {
        return LibraryModel.empty();
      }
    } on FirebaseException catch (e) {
      throw e.message ?? 'Failed to fetch library data.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
