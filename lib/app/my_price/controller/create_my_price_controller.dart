import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Create (activate or reserve) a My price combination. Charges money:
/// quote -> user confirms the amount -> activate with an idempotent
/// request id. Holds no BuildContext; dialogs go through [MyPriceUi].
class CreateMyPriceController extends BaseController {
  CreateMyPriceController({
    MyPriceApi? api,
    MainController? mainController,
    Future<void> Function(Future<void> Function() action)? withLoader,
    void Function(dynamic result)? close,
    MyPriceOverview? overview,
  })  : _api = api ?? MyPriceApi(),
        _mainController = mainController,
        _withLoader = withLoader,
        _close = close ?? ((result) => Get.back(result: result)),
        _initialOverview = overview;

  final MyPriceApi _api;
  final MainController? _mainController;
  final Future<void> Function(Future<void> Function() action)? _withLoader;
  final void Function(dynamic result) _close;
  final MyPriceOverview? _initialOverview;

  late MyPriceUi ui;

  MainController get mainController =>
      _mainController ?? Get.find<MainController>();

  final Rx<MyPriceOverview> overview = const MyPriceOverview().obs;
  final RxnInt productId = RxnInt();
  final RxnInt regionId = RxnInt();
  final RxnInt paymentType = RxnInt();
  final RxnInt teamUserId = RxnInt();
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final priceController = TextEditingController();
  final promoController = TextEditingController();

  /// Kept across retries so the backend can deduplicate the charge.
  String? requestId;

  @override
  void onInit() {
    super.onInit();
    final args = _initialOverview ?? Get.arguments;
    overview.value = args is MyPriceOverview ? args : const MyPriceOverview();
    if (overview.value.team.isNotEmpty) {
      teamUserId.value = overview.value.team.first.id;
    }
  }

  @override
  void onClose() {
    priceController.dispose();
    promoController.dispose();
    super.onClose();
  }

  Future<void> _loading(Future<void> Function() action) =>
      (_withLoader ?? loadIfValid)(action);

  Future<void> ensureOverview() async {
    if (overview.value.products.isNotEmpty) return;
    final result = await _api.overview();
    if (result.ok && result.data != null) {
      overview.value = result.data!;
      teamUserId.value ??=
          overview.value.team.isNotEmpty ? overview.value.team.first.id : null;
    } else {
      await ui.showError(result);
    }
  }

  double? get _price =>
      double.tryParse(priceController.text.replaceAll(',', '.'));

  MyPriceActivateParams? buildParams() {
    final price = _price;
    if (regionId.value == null ||
        productId.value == null ||
        paymentType.value == null ||
        teamUserId.value == null ||
        price == null) {
      return null;
    }
    return MyPriceActivateParams(
      regionId: regionId.value!,
      productId: productId.value!,
      paymentType: paymentType.value!,
      pricePerTon: price,
      teamUserId: teamUserId.value!,
      promoCode: promoController.text,
    );
  }

  Future<void> onSubmit() async {
    fieldErrors.clear();
    var params = buildParams();
    if (params == null) {
      fieldErrors.addAll({
        if (productId.value == null) 'product_id': 'required',
        if (regionId.value == null) 'region_id': 'required',
        if (paymentType.value == null) 'payment_type': 'required',
        if (teamUserId.value == null) 'team_user_id': 'required',
        if (_price == null) 'price_per_ton': 'required',
      });
      return;
    }

    MyPriceResult<MyPriceQuote>? quoteResult;
    await _loading(() async {
      quoteResult = await _api.quote(params!);
      if (quoteResult?.errorCode == 'promo_unavailable') {
        promoController.clear();
        params = buildParams();
        if (params != null) quoteResult = await _api.quote(params!);
      }
    });

    final quoteData = quoteResult;
    if (quoteData == null || !quoteData.ok || quoteData.data == null) {
      if (quoteData != null) {
        final action = await ui.showError(quoteData);
        if (action == MyPriceErrorAction.validation) {
          fieldErrors.assignAll(quoteData.fields);
        }
      }
      return;
    }

    final quote = quoteData.data!;
    if (!await ui.confirmActivation(quote)) return;

    requestId ??= generateMyPriceRequestId();
    final activateParams = params;
    if (activateParams == null) return;
    final amount = quote.pricing.chargedAmount ?? 0;

    MyPriceResult<MyPriceActivateResult>? activateResult;
    await _loading(() async {
      activateResult = await _activate(activateParams, quote.action, amount);
      if (activateResult?.errorCode == 'database_error') {
        activateResult = await _activate(activateParams, quote.action, amount);
      }
    });

    final activated = activateResult;
    if (activated == null || !activated.ok) {
      if (activated != null) {
        final action = await ui.showError(activated);
        if (action == MyPriceErrorAction.retryQuote) {
          requestId = null;
          await onSubmit();
        }
      }
      return;
    }

    if (activated.data?.walletBalance != null) {
      mainController.updateBalance(activated.data!.walletBalance);
    }
    _close(true);
  }

  Future<MyPriceResult<MyPriceActivateResult>> _activate(
    MyPriceActivateParams params,
    String action,
    double amount,
  ) =>
      _api.activate(
        params: params,
        requestId: requestId!,
        expectedAction: action,
        expectedAmount: amount,
      );
}
