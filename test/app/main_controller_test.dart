import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Contract: after logout or an expired token nothing of the previous
/// account survives in memory (BUG-005).
void main() {
  setUpAll(() => Get.testMode = true);

  test('resetSession forgets balance, tariff, flags and user fields', () {
    final c = MainController()
      ..updateBalance(500)
      ..updateTariff(Tariff.fromJson(const {'is_vip': 'Y'}))
      ..updateUserfield({'name': 'A', 'is_ads_disabled': 1})
      ..disableMyPrice();

    c.resetSession();

    expect(c.balance, 0);
    expect(c.tariff, isNull);
    expect(c.userfield, isEmpty);
    expect(c.isAdsDisabled, isFalse);
    expect(c.myPriceEnabled.value, isTrue);
  });

  test('a failed load is retried on the next init (BUG-027)', () async {
    final c = _FlakyMain();

    await c.initUserData();
    await c.initUserData();

    expect(c.tariffCalls, 2);
    await c.initUserData();
    expect(c.tariffCalls, 2, reason: 'loaded once it succeeded');
  });
}

class _FlakyMain extends MainController {
  int tariffCalls = 0;

  @override
  Future<bool> loadTariff() async => ++tariffCalls > 1;

  @override
  Future<bool> loadBalance() async => true;
}
