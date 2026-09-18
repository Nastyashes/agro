import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MyPriceController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  MyPriceOverview overview = const MyPriceOverview();
  int tabIndex = 0;
  bool loadPage = false;

  final MainController mainController = Get.find<MainController>();

  ModelUser get modelUser =>
      Hive.box('data').get('modelUser') as ModelUser? ?? ModelUser();

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) {
    this.context = context;
    setState = set;
    loadOverview();
  }

  Future<void> loadOverview() async {
    final result = await Api().myPrice.overview();
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
    setState(() => loadPage = true);
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
