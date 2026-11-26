import 'package:agro/data/session_storage.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/app_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSessionActions {
  static void openSite() => launchUrl(Uri.parse(AppConstants.siteUrl));

  static void openSupport() =>
      launchUrl(Uri.parse(AppConstants.supportTelegramUrl));

  static void openPrivacy() =>
      launchUrl(Uri.parse(AppConstants.privacyPolicyUrl));

  static void openTariffs() => Get.toNamed(Routes.tariffs);

  static void openQrScan() => Get.toNamed(Routes.scanQrCode);

  static void confirmDeleteAccount(BuildContext context) {
    showConfirmPoUp(
      context,
      '${context.l.deleteProfile}?',
      context.l.dataWillBeDeleted,
      confirmLabel: context.l.delete,
      icon: Icons.delete_outline_rounded,
      destructive: true,
      () async {
        await SessionStorage.instance.clear();
        await LocalStorageRepository().clear();

        if (!context.mounted) return;

        inAppNotification(
          text: context.l.profileCancelActionLog,
          c: context,
        );
        _resetSessionAndRestart();
      },
    );
  }

  static void confirmLogout(BuildContext context) {
    showConfirmPoUp(
      context,
      '${context.l.logOutOfProfile}?',
      context.l.dataDeviceDeleted,
      confirmLabel: context.l.logOut,
      icon: Icons.logout_rounded,
      destructive: true,
      () async {
        await SessionStorage.instance.clear();
        await LocalStorageRepository().clear();

        if (!context.mounted) return;

        _resetSessionAndRestart();
      },
    );
  }

  static void _resetSessionAndRestart() {
    if (Get.isRegistered<NewHomeController>()) {
      Get.delete<NewHomeController>(force: true);
    }
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().resetSession();
    }
    if (!Get.isRegistered<AppController>()) {
      Get.put<AppController>(AppController(), permanent: true);
    }
    if (!Get.isRegistered<MainController>()) {
      Get.put<MainController>(MainController(), permanent: true);
    }
    Get.offAllNamed(Routes.splash);
  }
}
