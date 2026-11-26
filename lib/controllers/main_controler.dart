import 'dart:developer';

import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:get/get.dart';

class MainController extends BaseController {
  MainController({AccountRepository? account}) : _accountOverride = account;

  final AccountRepository? _accountOverride;
  AccountRepository get _account => _accountOverride ?? AccountRepository();
  final Rxn<Tariff> _tariff = Rxn<Tariff>();
  final RxInt _balance = 0.obs;
  final RxMap<String, dynamic> _userfield = <String, dynamic>{}.obs;
  final RxBool myPriceEnabled = true.obs;

  Tariff? get tariff => _tariff.value;

  int get balance => _balance.value;

  Map<String, dynamic> get userfield => _userfield;

  bool get isFree => tariff?.isFree == true;

  bool get isPremium => tariff?.isPremium == true;

  bool get isVip => tariff?.isVip == true;

  bool get isAdsDisabled => _isTruthy(_userfield['is_ads_disabled']);

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil =>
      int.tryParse(
        '${_userfield['ads_disabled_until'] ?? 0}',
      ) ??
      0;

  bool _userDataLoaded = false;
  Future<void>? _userDataLoading;

  /// Bumped on [resetSession]; a load started for the previous user does
  /// not write its result into the new session.
  int _generation = 0;

  Future<void> initUserData({
    bool force = false,
  }) {
    if (_userDataLoaded && !force) {
      return Future.value();
    }

    if (_userDataLoading != null) {
      return _userDataLoading!;
    }

    _userDataLoading = _loadUserData();

    return _userDataLoading!.whenComplete(() {
      _userDataLoading = null;
    });
  }

  Future<void> _loadUserData() async {
    final results = await Future.wait([
      loadTariff(),
      loadBalance(),
    ]);

    // A failed part (e.g. offline start) is retried on the next refresh
    // instead of leaving 0 UAH / no tariff until restart (BUG-027).
    _userDataLoaded = results.every((ok) => ok);
  }

  /// Fresh data after something changed (payment, pull-to-refresh): waits
  /// for a load already running, then loads again, so it never returns
  /// the older, pre-charge balance.
  Future<void> refreshUserData() async {
    final running = _userDataLoading;
    if (running != null) await running;
    return initUserData(force: true);
  }

  /// True if loaded; errors are logged, the old value is kept.
  Future<bool> loadTariff() async {
    final generation = _generation;
    try {
      final tariff = await _account.currentTariff();
      if (generation != _generation) return false;
      _tariff.value = tariff;
      return true;
    } catch (e, stackTrace) {
      log(
        'MainController loadTariff error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// True if loaded; errors are logged, the old value is kept.
  Future<bool> loadBalance() async {
    final generation = _generation;
    try {
      final balance = await _account.balance();
      if (generation != _generation) return false;
      _balance.value = balance;
      return true;
    } catch (e, stackTrace) {
      log(
        'MainController loadBalance error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void updateUserfield(
    Map<String, dynamic>? value,
  ) {
    _userfield.assignAll(
      value ?? <String, dynamic>{},
    );
  }

  void patchUserfield(Map<String, dynamic> value) {
    _userfield.addAll(value);
  }

  /// Accepts int, double ("50.0") or numeric strings from the backend.
  void updateBalance(dynamic value) {
    _balance.value = (num.tryParse('${value ?? 0}') ?? 0).round();
  }

  void updateTariff(Tariff value) {
    _tariff.value = value;
  }

  void invalidateUserData() {
    _userDataLoaded = false;
  }

  /// Forgets everything about the signed-in user (logout, expired token),
  /// so the next account never sees the previous one's balance or tariff.
  void resetSession() {
    _generation++;
    _userDataLoading = null;
    _userDataLoaded = false;
    _balance.value = 0;
    _tariff.value = null;
    _userfield.clear();
    myPriceEnabled.value = true;
  }

  void disableMyPrice() {
    myPriceEnabled.value = false;
  }
}

bool _isTruthy(dynamic value) {
  return value == true || value == 1 || value == '1' || value == 'true';
}
