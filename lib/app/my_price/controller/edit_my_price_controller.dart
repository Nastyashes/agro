import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/server/api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditMyPriceController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  late MyPriceOverview overview;
  late MyPriceEntry entry;
  late String targetType;
  late TextEditingController priceController;
  int? teamUserId;

  final MainController mainController = Get.find<MainController>();

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) {
    this.context = context;
    setState = set;
    final args = (Get.arguments as Map?) ?? {};
    overview = args['overview'] as MyPriceOverview? ?? const MyPriceOverview();
    entry = args['entry'] as MyPriceEntry? ?? const MyPriceEntry();
    targetType = args['targetType'] as String? ?? 'combination';
    teamUserId = entry.teamUserId;
    priceController = TextEditingController(
      text: entry.pricePerTon?.toString() ?? '',
    );
  }

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }

  Future<void> onSave() async {
    if (entry.id == null) return;
    final price = double.tryParse(priceController.text.replaceAll(',', '.'));
    await loadIfValid(() async {
      final result = await Api().myPrice.update(
        targetType: targetType,
        targetId: entry.id!,
        pricePerTon: price,
        teamUserId: teamUserId,
      );
      if (!result.ok) {
        if (context.mounted) {
          await showMyPriceError(
            context,
            result,
            mainController: mainController,
          );
        }
        return;
      }
      Get.back(result: true);
    });
  }
}
