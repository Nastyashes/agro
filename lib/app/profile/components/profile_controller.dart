import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/model_notifier/user_notifier/user_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../../ui/local_notification/local_notification.dart';
import '../../../ui/text/read_text.dart';
import '../../../vars/model_notifier/bottom_menu_notifier/bottom_menu_notifier.dart';
import '../../home/components/home_controller.dart';

class ProfileController extends BaseController {
  late Function(VoidCallback fn) setState;
  final modelUser = Rx<ModelUser>(ModelUser());
  final user = ModelUser();
  Tariff? tariff;
  Map<String, dynamic> userfield = {};
  @override
  void onInit() {
    modelUser.value = Hive.box('data').get('modelUser');
    super.onInit();
  }

  bool get isFree => tariff?.isFree == true;

  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil => userfield['ads_disabled_until'] ?? 0;

  String get adsPrice => adsDisabledUntil == 0 ? '150 грн' : '300 грн';
  void onSite() => launchUrl(Uri.parse('https://uagro.trade/'));

  void onHelp() => launchUrl(Uri.parse('https://t.me/uagro_admin'));

  void onPrivacy() => launchUrl(Uri.parse(
      'https://www.freeprivacypolicy.com/live/3afe785c-8de8-4a5b-985b-353bfca6bd17'));

  void onTariffs() => Get.toNamed(Routes.tariffs);

  void onQrScan() => Get.toNamed(Routes.scanQrCode);

  void loadRequest(BuildContext context) => loadIfValid(() async {
        final apiAnswer = await Api().traider.getFreeOrders();

        if (!context.mounted) return;

        setState(() {
          userfield = Map<String, dynamic>.from(
            apiAnswer.data['userfield'] ?? {},
          );

          log(userfield.toString());
        });
      });
  Future<void> disableAds(BuildContext context) async {
    final result = await Api().traider.disableAds();

    if (result.data['status'] == '+') {
      loadRequest(context);

      inAppNotification(
        text: result.data['message'],
        c: context,
      );
    } else {
      inAppNotification(
        text: result.data['message'],
        c: context,
      );
    }
  }

  void onTariffInfo() async {
    try {
      ApiAnswer apiAnswer = await Api().traider.getTariff();
      setState(() {
        log('tariff info: ${apiAnswer.data['payload'].toString()}');
        tariff = Tariff.fromJson(apiAnswer.data['payload']);
      });
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  void onDeleteAccount(BuildContext context) => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext c) => Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
              title: Center(
                  child: readText(
                      text: '${context.l.deleteProfile}?',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      size: 20)),
              content: Center(
                  child: readText(
                      text: context.l.dataWillBeDeleted,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      size: 18,
                      align: TextAlign.center)),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () async {
                      await Hive.box('data').clear();
                      startActive = false;

                      if (c.mounted) {
                        c.read<UserNotifier>().setModelUser(val: ModelUser());
                        c
                            .read<BottomMenuNotifier>()
                            .setActiveButtMenu(val: 0, upd: false);
                        inAppNotification(
                            text: context.l.profileCancelActionLog, c: c);
                        Get.delete<HomeController>();
                        Get.deleteAll();

                        Navigator.pushAndRemoveUntil<dynamic>(
                            c,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    const Material(child: MyStart())),
                            (route) => false);
                      }
                    },
                    child: readText(
                        text: context.l.yes,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        size: 20)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(c),
                    child: readText(
                        text: context.l.cancel,
                        color: const Color(0xffFF1616),
                        fontWeight: FontWeight.w500,
                        size: 20))
              ])));

  void onExit(BuildContext context) => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext c) => Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
              title: Center(
                  child: readText(
                      text: '${context.l.logOutOfProfile}?',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      size: 20)),
              content: Center(
                  child: readText(
                      text: context.l.dataDeviceDeleted,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      size: 18,
                      align: TextAlign.center)),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () async {
                      await Hive.box('data').clear();
                      await LocalStorageRepository().clear();
                      startActive = false;

                      if (c.mounted) {
                        c.read<UserNotifier>().setModelUser(val: ModelUser());
                        c
                            .read<BottomMenuNotifier>()
                            .setActiveButtMenu(val: 0, upd: false);
                        Navigator.pushAndRemoveUntil<dynamic>(
                            c,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    const Material(child: MyStart())),
                            (route) => false);
                      }
                    },
                    child: readText(
                        text: context.l.yes,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        size: 20)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(c),
                    child: readText(
                        text: context.l.cancel,
                        color: const Color(0xffFF1616),
                        fontWeight: FontWeight.w500,
                        size: 20))
              ])));
}
