import 'dart:async';

import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/account_repository.dart';
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

  test('a load for the previous user does not leak into the new session',
      () async {
    final account = _GatedAccount();
    final c = MainController(account: account);
    final stale = c.initUserData();

    c.resetSession();
    account.gate.complete();
    await stale;

    expect(c.balance, 0, reason: 'old balance must not be written');
  });

  test('refresh waits for a running load, then loads again', () async {
    final account = _GatedAccount();
    final c = MainController(account: account);
    final first = c.initUserData();
    final refresh = c.refreshUserData();

    account.gate.complete();
    await Future.wait([first, refresh]);

    expect(account.balanceCalls, 2);
    expect(c.balance, 42, reason: 'the later, post-charge balance wins');
  });
}

class _FlakyMain extends MainController {
  int tariffCalls = 0;

  @override
  Future<bool> loadTariff() async => ++tariffCalls > 1;

  @override
  Future<bool> loadBalance() async => true;
}

class _GatedAccount extends AccountRepository {
  final gate = Completer<void>();
  int balanceCalls = 0;

  @override
  Future<Tariff> currentTariff() async => Tariff.fromJson(const {});

  @override
  Future<int> balance() async {
    balanceCalls++;
    if (balanceCalls == 1) {
      await gate.future;
      return 500; // the previous user's balance
    }
    return 42;
  }
}
