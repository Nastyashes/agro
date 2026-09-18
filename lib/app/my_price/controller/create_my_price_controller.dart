import 'dart:convert';
import 'dart:io';


import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void _agentLog(String hypothesisId, String location, String message, [Map<String, Object?> data = const {}]) {
  // #region agent log
  final payload = {
    'sessionId': 'ea8539',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'runId': 'post-fix',
  };
  try {
    File('/Users/siell/Documents/git/uagro/.cursor/debug-ea8539.log').writeAsStringSync(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  HttpClient()
      .postUrl(Uri.parse(
          'http://127.0.0.1:7706/ingest/73a61980-891c-4ed9-aaa0-f7eca662eae9'))
      .then((req) {
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('X-Debug-Session-Id', 'ea8539');
    req.add(utf8.encode(jsonEncode(payload)));
    return req.close();
  }).catchError((_) {});
  // #endregion
}

class CreateMyPriceController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  late MyPriceOverview overview;
  int? productId;
  int? regionId;
  int? paymentType;
  int? teamUserId;
  final priceController = TextEditingController();
  final promoController = TextEditingController();
  String? requestId;
  Map<String, String> fieldErrors = {};

  final MainController mainController = Get.find<MainController>();

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) {
    this.context = context;
    setState = set;
    final args = Get.arguments;
    overview = args is MyPriceOverview ? args : const MyPriceOverview();
    if (overview.team.isNotEmpty) {
      teamUserId = overview.team.first.id;
    }
  }

  @override
  void onClose() {
    priceController.dispose();
    promoController.dispose();
    super.onClose();
  }

  Future<void> ensureOverview() async {
    if (overview.products.isNotEmpty) return;
    final result = await Api().myPrice.overview();
    if (result.ok && result.data != null) {
      overview = result.data!;
      teamUserId ??= overview.team.isNotEmpty ? overview.team.first.id : null;
      setState(() {});
    } else if (context.mounted) {
      await showMyPriceError(context, result, mainController: mainController);
    }
  }

  MyPriceActivateParams? buildParams() {
    final price = double.tryParse(priceController.text.replaceAll(',', '.'));
    if (regionId == null ||
        productId == null ||
        paymentType == null ||
        teamUserId == null ||
        price == null) {
      return null;
    }
    return MyPriceActivateParams(
      regionId: regionId!,
      productId: productId!,
      paymentType: paymentType!,
      pricePerTon: price,
      teamUserId: teamUserId!,
      promoCode: promoController.text,
    );
  }

  Future<void> onSubmit() async {
    fieldErrors = {};
    var params = buildParams();
    if (params == null) {
      setState(() {
        if (productId == null) fieldErrors['product_id'] = 'required';
        if (regionId == null) fieldErrors['region_id'] = 'required';
        if (paymentType == null) fieldErrors['payment_type'] = 'required';
        if (teamUserId == null) fieldErrors['team_user_id'] = 'required';
        if (double.tryParse(priceController.text.replaceAll(',', '.')) == null) {
          fieldErrors['price_per_ton'] = 'required';
        }
      });
      return;
    }

    MyPriceResult<MyPriceQuote>? quoteResult;
    await loadIfValid(() async {
      _agentLog('A', 'create_my_price_controller.dart:onSubmit', 'quote_overlay_started', {
        'loading': loading.value,
      });
      quoteResult = await Api().myPrice.quote(params!);
      if (quoteResult?.errorCode == 'promo_unavailable') {
        promoController.clear();
        params = buildParams();
        if (params != null) {
          quoteResult = await Api().myPrice.quote(params!);
        }
      }
    });

    final quoteData = quoteResult;
    if (quoteData == null || !quoteData.ok || quoteData.data == null) {
      if (context.mounted && quoteData != null) {
        final action = await showMyPriceError(
          context,
          quoteData,
          mainController: mainController,
        );
        if (action == MyPriceErrorAction.validation) {
          fieldErrors = quoteData.fields;
          setState(() {});
        }
      }
      return;
    }

    final quote = quoteData.data!;
    if (!context.mounted) return;

    _agentLog('A', 'create_my_price_controller.dart:onSubmit', 'before_confirm_dialog', {
      'loading': loading.value,
      'dialogOutsideOverlay': true,
      'action': quote.action,
    });

    final amount = quote.pricing.chargedAmount ?? 0;
    final date = quote.slot.activeUntil == null
        ? '—'
        : DateFormat('dd.MM.yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(quote.slot.activeUntil! * 1000),
          );
    final body = StringBuffer()
      ..writeln(
        quote.isReserve
            ? context.l.combinationOccupied(date)
            : context.l.actionActivate,
      )
      ..writeln(context.l.confirmChargeBody(amount.toString()))
      ..writeln('${context.l.selectedPhone}: ${quote.teamPhone ?? ''}');

    final confirmed = await showMyPriceConfirmDialog(
      context: context,
      title: quote.isReserve ? context.l.actionReserve : context.l.actionActivate,
      body: body.toString(),
    );
    _agentLog('B', 'create_my_price_controller.dart:onSubmit', 'after_confirm_dialog', {
      'loading': loading.value,
      'confirmed': confirmed,
    });
    if (!confirmed || !context.mounted) return;

    requestId ??= generateMyPriceRequestId();
    final activateParams = params;
    if (activateParams == null) return;

    MyPriceResult<MyPriceActivateResult>? activateResult;
    await loadIfValid(() async {
      _agentLog('C', 'create_my_price_controller.dart:onSubmit', 'activate_overlay_started', {
        'loading': loading.value,
      });
      activateResult = await Api().myPrice.activate(
        params: activateParams,
        requestId: requestId!,
        expectedAction: quote.action,
        expectedAmount: amount,
      );

      if (activateResult?.errorCode == 'database_error') {
        activateResult = await Api().myPrice.activate(
          params: activateParams,
          requestId: requestId!,
          expectedAction: quote.action,
          expectedAmount: amount,
        );
      }
    });

    final activated = activateResult;
    if (activated == null || !activated.ok) {
      if (context.mounted && activated != null) {
        final action = await showMyPriceError(
          context,
          activated,
          mainController: mainController,
        );
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
    Get.back(result: true);
  }
}
