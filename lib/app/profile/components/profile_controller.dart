import 'package:agro/data/session_storage.dart';
import 'dart:developer';

import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import '../../../ui/local_notification/local_notification.dart';
import 'account_session_actions.dart';

class ProfileController extends BaseController {
  late Function(VoidCallback fn) setState;
  final modelUser = Rx<ModelUser>(ModelUser());
  final user = ModelUser();
  Tariff? tariff;
  Map<String, dynamic> userfield = {};
  @override
  void onInit() {
    loadRequest(Get.context!);
    modelUser.value = SessionStorage.instance.user ?? ModelUser();
    super.onInit();
  }

  bool get isFree => tariff?.isFree == true;

  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil =>
      int.tryParse('${userfield['ads_disabled_until'] ?? 0}') ?? 0;
      
  String get adsPrice => AppConstants.adsPrice;

  void onSite() => AccountSessionActions.openSite();

  void onHelp() => AccountSessionActions.openSupport();

  void onPrivacy() => AccountSessionActions.openPrivacy();

  void onTariffs() => AccountSessionActions.openTariffs();

  void onQrScan() => AccountSessionActions.openQrScan();

  Future<void> loadRequest(BuildContext context) async {
    final loaded = await AccountRepository().userfield();

    if (!context.mounted) return;

    userfield = loaded;
  }

  Future<void> disableAds(BuildContext context) async {
    final result = await AccountRepository().disableAds();

    if (result.ok) {
      await loadRequest(context);
    }

    if (context.mounted) {
      inAppNotification(text: result.message ?? '', c: context);
    }
  }

  void onTariffInfo() async {
    try {
      final loaded = await AccountRepository().currentTariff();
      setState(() => tariff = loaded);
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> initPage(BuildContext context) async {
    await Future.wait([
      loadRequest(context),
      _loadTariff(),
    ]);

    setState(() {});
  }

  DateTime? get adsDisabledUntilDate {
    final raw = userfield['ads_disabled_until'];

    if (raw == null) return null;

    final ts = raw is int ? raw : int.tryParse(raw.toString());

    if (ts == null || ts == 0) return null;

    return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  }

  String get adsDisabledUntilText {
    final date = adsDisabledUntilDate;

    if (date == null) return Get.context!.l.forever;

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadTariff() async {
    try {
      tariff = await AccountRepository().currentTariff();
    } catch (e) {
      log(e.toString());
    }
  }

  void onDeleteAccount(BuildContext context) =>
      AccountSessionActions.confirmDeleteAccount(context);

  void onExit(BuildContext context) =>
      AccountSessionActions.confirmLogout(context);
}
