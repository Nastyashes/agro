import 'package:agro/data/session_storage.dart';
import 'dart:developer';

import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPriceController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  MyPriceOverview overview = const MyPriceOverview();
  int tabIndex = 0;
  bool loadPage = false;

  final MainController mainController = Get.find<MainController>();

  ModelUser get modelUser =>
      SessionStorage.instance.user ?? ModelUser();

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) {
    this.context = context;
    setState = set;
    loadOverview();
  }

  Future<void> loadOverview() async {
    log('MyPrice loadOverview start');
    final result = await Api().myPrice.overview();
    log(
      'MyPrice loadOverview result ok=${result.ok} '
      'error=${result.errorCode} message=${result.message}',
    );
    if (!result.ok || result.data == null) {
      if (context.mounted) {
        await showMyPriceError(
          context,
          result,
          mainController: mainController,
        );
      }
      setState(() => loadPage = true);
      return;
    }
    overview = result.data!;
    _logEntries('combinations', overview.combinations);
    _logEntries('reservations', overview.reservations);
    _logDuplicateIds(overview.combinations);
    setState(() => loadPage = true);
  }

  void _logEntries(String label, List<MyPriceEntry> entries) {
    log('MyPrice $label count=${entries.length}');
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      log(
        'MyPrice $label[$i] id=${e.id} slotId=${e.slotId} status="${e.status}" '
        'isActive=${e.isActive} productId=${e.productId} regionId=${e.regionId} '
        'payment=${e.paymentType} price=${e.pricePerTon} '
        'startsAt=${e.startsAt} endsAt=${e.endsAt} queue=${e.queuePosition}',
      );
    }
  }

  void _logDuplicateIds(List<MyPriceEntry> entries) {
    final ids = <int, int>{};
    for (final e in entries) {
      final id = e.id;
      if (id == null) continue;
      ids[id] = (ids[id] ?? 0) + 1;
    }
    final duplicates = ids.entries.where((e) => e.value > 1).toList();
    if (duplicates.isNotEmpty) {
      log('MyPrice combinations duplicate ids=$duplicates');
    }
  }

  void onCreate() async {
    await Get.toNamed(Routes.myPriceCreate, arguments: overview);
    await loadOverview();
  }

  void onEdit(MyPriceEntry entry, {required bool reservation}) async {
    await Get.toNamed(
      Routes.myPriceEdit,
      arguments: {
        'overview': overview,
        'entry': entry,
        'targetType': reservation ? 'reservation' : 'combination',
      },
    );
    await loadOverview();
  }
}
