import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:get/get.dart';

/// Tariff cards carousel. No BuildContext or setState.
class TariffsController extends BaseController {
  TariffsController({
    AccountRepository? repository,
    MainController? mainController,
  })  : _repository = repository ?? AccountRepository(),
        _mainController = mainController;

  final AccountRepository _repository;
  final MainController? _mainController;

  MainController get mainController =>
      _mainController ?? Get.find<MainController>();

  final RxList<ModelTariff> tariffs = <ModelTariff>[].obs;
  final RxInt currentPageIndex = 0.obs;

  /// Current user's tariff (reactive via MainController).
  Tariff? get tariff => mainController.tariff;

  @override
  void onReady() {
    super.onReady();
    loadTariffs();
  }

  Future<void> loadTariffs() async {
    try {
      tariffs.assignAll(await _repository.tariffs());
    } catch (e, stackTrace) {
      log('TariffsController load error: $e', error: e, stackTrace: stackTrace);
    }
    if (mainController.tariff == null) {
      await mainController.initUserData();
    }
    currentPageIndex.value = 0;
  }

  void onPageChanged(int page) => currentPageIndex.value = page;
}
