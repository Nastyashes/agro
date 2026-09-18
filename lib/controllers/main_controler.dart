import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/server/api/api.dart';
import 'package:get/get.dart';

class MainController extends BaseController {
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

  bool get isAdsDisabled =>
      _userfield['is_ads_disabled'] == true;

  bool get shouldShowAds =>
      isFree && !isAdsDisabled;

  int get adsDisabledUntil =>
      int.tryParse(
        '${_userfield['ads_disabled_until'] ?? 0}',
      ) ??
      0;

  bool _userDataLoaded = false;
  Future<void>? _userDataLoading;

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
    await Future.wait([
      loadTariff(),
      loadBalance(),
    ]);

    _userDataLoaded = true;
  }

  Future<void> refreshUserData() {
    return initUserData(force: true);
  }

  Future<void> loadTariff() async {
    try {
      final apiAnswer =
          await Api().traider.getTariff();

      _tariff.value = Tariff.fromJson(
        apiAnswer.data['payload'],
      );
    } catch (e, stackTrace) {
      log(
        'MainController loadTariff error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadBalance() async {
    try {
      final apiAnswer =
          await Api().common.getBalance();

      _balance.value =
          int.tryParse(
            '${apiAnswer.data['balance'] ?? 0}',
          ) ??
          0;
    } catch (e, stackTrace) {
      log(
        'MainController loadBalance error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void updateUserfield(
    Map<String, dynamic>? value,
  ) {
    _userfield.assignAll(
      value ?? <String, dynamic>{},
    );
  }

  void updateBalance(dynamic value) {
    _balance.value =
        int.tryParse('${value ?? 0}') ?? 0;
  }

  void updateTariff(Tariff value) {
    _tariff.value = value;
  }

  void invalidateUserData() {
    _userDataLoaded = false;
  }

  void disableMyPrice() {
    myPriceEnabled.value = false;
  }
}