import 'package:get/get.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';
import 'package:edox_library/utils/constants/colors.dart';

class LibraryController extends GetxController {
  static LibraryController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<LibraryModel> library = LibraryModel.empty().obs;
  final _libraryRepository = Get.put(LibraryRepository());

  @override
  void onInit() {
    super.onInit();
    fetchLibraryRecord();
  }

  Future<void> fetchLibraryRecord() async {
    try {
      profileLoading.value = true;
      final user = AuthenticationRepository.instance.authUser.value;
      if (user != null) {
        final libraryData = await _libraryRepository.fetchLibraryDetails(user.uid);
        library.value = libraryData;
      }
    } catch (e) {
      Get.snackbar(
        'Data not found',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: XColors.error,
        colorText: XColors.white,
      );
    } finally {
      profileLoading.value = false;
    }
  }
}
