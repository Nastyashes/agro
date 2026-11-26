import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Edit price / team member of a combination or reservation.
class EditMyPriceController extends BaseController {
  EditMyPriceController({
    MyPriceApi? api,
    MainController? mainController,
    Future<void> Function(Future<void> Function() action)? withLoader,
    void Function(dynamic result)? close,
    Map<dynamic, dynamic>? arguments,
  })  : _api = api ?? MyPriceApi(),
        _mainController = mainController,
        _withLoader = withLoader,
        _close = close ?? ((result) => Get.back(result: result)),
        _arguments = arguments;

  final MyPriceApi _api;
  final MainController? _mainController;
  final Future<void> Function(Future<void> Function() action)? _withLoader;
  final void Function(dynamic result) _close;
  final Map<dynamic, dynamic>? _arguments;

  late MyPriceUi ui;

  MainController get mainController =>
      _mainController ?? Get.find<MainController>();

  late MyPriceOverview overview;
  late MyPriceEntry entry;
  late String targetType;
  late TextEditingController priceController;
  final RxnInt teamUserId = RxnInt();

  /// The typed price is not a valid price; nothing is sent (BUG-008).
  final RxBool priceError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = _arguments ?? (Get.arguments as Map?) ?? const {};
    overview = args['overview'] as MyPriceOverview? ?? const MyPriceOverview();
    entry = args['entry'] as MyPriceEntry? ?? const MyPriceEntry();
    targetType = args['targetType'] as String? ?? 'combination';
    teamUserId.value = entry.teamUserId;
    priceController =
        TextEditingController(text: entry.pricePerTon?.toString() ?? '');
  }

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }

  Future<void> onSave() async {
    if (entry.id == null) return;
    final price = parsePricePerTon(priceController.text);
    priceError.value = price == null;
    if (price == null) return;
    await (_withLoader ?? loadIfValid)(() async {
      final result = await _api.update(
        targetType: targetType,
        targetId: entry.id!,
        pricePerTon: price,
        teamUserId: teamUserId.value,
      );
      if (!result.ok) {
        await ui.showError(result);
        return;
      }
      _close(true);
    });
  }
}
