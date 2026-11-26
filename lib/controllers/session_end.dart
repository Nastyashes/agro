import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:get/get.dart';

bool _ending = false;

/// The one way a session ends: logout, deleted profile or expired token.
/// Clears the stored session ([keepCountry] keeps the country and language
/// so the next sign-in goes to the right backend), local call results, the
/// home lists and the in-memory user data, then opens [route]. Calls that
/// arrive while one is running (several 401s at once) are ignored.
Future<void> endSession({
  required bool keepCountry,
  required String route,
}) async {
  if (_ending) return;
  _ending = true;
  try {
    if (keepCountry) {
      await SessionStorage.instance.signOut();
    } else {
      await SessionStorage.instance.clear();
    }
    await LocalStorageRepository().clear();
    if (Get.isRegistered<NewHomeController>()) {
      Get.delete<NewHomeController>(force: true);
    }
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().resetSession();
    }
    Get.offAllNamed(route);
  } finally {
    _ending = false;
  }
}
