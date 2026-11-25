import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeAccount extends AccountRepository {
  Object? error;

  @override
  Future<List<ModelTariff>> tariffs() async {
    if (error != null) throw error!;
    return [ModelTariff(name: 'FREE'), ModelTariff(name: 'Premium')];
  }
}

class FakeMain extends MainController {
  int initCalls = 0;
  Tariff? current;

  @override
  Tariff? get tariff => current;

  @override
  Future<void> initUserData({bool force = false}) async => initCalls++;
}

void main() {
  setUpAll(() => Get.testMode = true);

  test('loads tariffs, starts on the first page, fetches user tariff once',
      () async {
    final main = FakeMain();
    final c =
        TariffsController(repository: FakeAccount(), mainController: main);
    c.onPageChanged(2);

    await c.loadTariffs();

    expect(c.tariffs.map((t) => t.name), ['FREE', 'Premium']);
    expect(c.currentPageIndex.value, 0);
    expect(main.initCalls, 1);
  });

  test('a failed list still loads the user tariff', () async {
    final main = FakeMain();
    final repo = FakeAccount()..error = Exception('offline');
    final c = TariffsController(repository: repo, mainController: main);

    await c.loadTariffs();

    expect(c.tariffs, isEmpty);
    expect(main.initCalls, 1);
  });

  test('page changes are reactive', () {
    final c = TariffsController(
        repository: FakeAccount(), mainController: FakeMain());

    c.onPageChanged(1);

    expect(c.currentPageIndex.value, 1);
  });
}
