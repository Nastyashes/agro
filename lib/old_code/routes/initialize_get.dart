import 'package:agro/old_code/app/all_applications/all_applications_controller.dart';
import 'package:agro/old_code/app/help/components/help_controller.dart';
import 'package:agro/old_code/app/home/components/home_controller.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/app/profile/components/profile_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:get/get.dart';

void initializeGet() {
  Get.put(HelpController());
  Get.put(HomeController());
  Get.put(ProfileController());
  Get.put(TariffsController());
  Get.put(AllApplicationsController());
  Get.put<MainController>(MainController(), permanent: true);
}
