import 'package:agro/app/all_applications/all_applications_controller.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:get/get.dart';

import '../app/help/components/help_controller.dart';
import '../app/home/components/home_controller.dart';
import '../app/profile/components/profile_controller.dart';

void initializeGet() {
  Get.put(HelpController());
  Get.put(HomeController());
  Get.put(ProfileController());
  Get.put(TariffsController());
  Get.put(AllApplicationsController());
}
