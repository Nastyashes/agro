import 'dart:developer';

import 'package:agro/app/home/order/components/set_answer.dart.dart';
import 'package:agro/ui/pop_up/banner_dialog.dart';
import 'package:agro/ui/pop_up/inform_pop_up.dart';
import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/call_result/call_result.dart';
import 'package:agro/model/my_price/my_price_order_meta.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BidItemController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BidItem bidItem;
  bool loadPage = false;
  bool orderingCarrier = false;
  bool carrierOrdered = false;
  bool orderingAnalysis = false;
  bool analysisOrdered = false;
  CallResult? result;
  bool contactOpened = false;
  bool isProcessingContact = false;

  final _localStorageRepository = LocalStorageRepository();
  NewHomeController? get _homeController =>
      Get.isRegistered<NewHomeController>()
          ? Get.find<NewHomeController>()
          : null;

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
    BidItem? item,
    int? orderId,
  }) async {
    setState = set;
    bidItem = item ?? BidItem(orderId: orderId);
    if (bidItem.isOpened) contactOpened = true;

    result =
        await _localStorageRepository.getResult(bidItem.orderId.toString());

    await refreshOrderView();

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => loadPage = true);
  }

  Future<void> refreshOrderView() async {
    final orderId = bidItem.orderId;
    if (orderId == null) return;
    try {
      final apiAnswer = await Api().traider.getOrder(orderId: orderId);
      final parsed = BidItem.fromOrderView(apiAnswer.data);
      if (parsed != null) {
        bidItem = parsed;
      } else {
        final data = apiAnswer.data;
        if (data is Map && data['my_price'] != null) {
          bidItem = bidItem.copyWith(
            myPrice: MyPriceOrderMeta.fromJson(
              Map<String, dynamic>.from(data['my_price'] as Map),
            ),
          );
        }
      }
      if (bidItem.isOpened) contactOpened = true;
      final meta = bidItem.myPrice;
      if (meta != null && meta.canAcknowledge && meta.matchId != null) {
        await Api().myPrice.matchAck(meta.matchId!);
      }
    } catch (e) {
      log('refreshOrderView error: $e');
    }
  }

  Future<void> onContactClick(BuildContext context) async {
    final String errorTariffMail = context.l.errorTariffMail;

    if (bidItem.isOpened) return;

    try {
      final contactPrice = bidItem.contactPrice ?? 0;
      final main = Get.isRegistered<MainController>()
          ? Get.find<MainController>()
          : null;
      final isFree = main?.isFree == true;
      final isAdsDisabled = main?.isAdsDisabled == true;
      final shouldShowAd = contactPrice == 0 && isFree && !isAdsDisabled;

      String adsPrice = context.adsPriceLabel();

      if (!shouldShowAd) {
        await _openContact(context);
        return;
      }

      // 🔥 окремий try/catch саме навколо запиту банера —
      // будь-яка помилка тут (мережа, тайм-аут, невалідний JSON) не блокує відкриття контакту
      OpenContactsAdResponse? res;
      try {
        res = await Api().traider.openContactsAd(orderId: bidItem.orderId!);
        log('OPEN Contacts Ad: ${res.toJson()}');
      } catch (e) {
        log('openContactsAd failed, fallback to direct open: $e');
        await _openContact(context);
        return;
      }

      if (res.status != true) {
        await _openContact(context);
        return;
      }

      final ad = res.adBanner;
      if (ad == null) {
        await _openContact(context);
        return;
      }

      final watched = await showAdBannerDialog(
        context,
        imageUrl: ad.image,
        phone: ad.phone,
        price: adsPrice,
        onDisableAds: () async {
          await _homeController?.disableAds(context);
        },
      );

      if (watched == true) {
        await _openContact(context);
      }
    } catch (e) {
      log("contact open failed: $e");
      notification(text: context.l.failedOpenContactRetry);
    }
  }

  Future<void> _openContact(BuildContext context) async {
    try {
      ApiAnswer apiAnswer = await Api().traider.openBidContact(
            orderId: bidItem.orderId!,
          );

      log(apiAnswer.data.toString());

      if (apiAnswer.data['status'] == 'insufficient') {
        final String message = apiAnswer.data['message']?.toString() ??
            context.l.insufficientBalance;
        notification(text: message);
        return;
      }

      if (apiAnswer.data['status'] == '+') {
        final payload = apiAnswer.data['payload'];

        bidItem = bidItem.copyWith(
          opened: 1,
          openedPhon: payload['phone']?.toString(),
          fermerCompany: payload['company']?.toString(),
          fermerName: payload['name']?.toString(),
          fermerPhone: payload['phone']?.toString(),
          fermerEmail: payload['email']?.toString(),
          contacts: BidContacts.fromJson(payload),
        );

        _homeController?.updateBidItem(bidItem);

        contactOpened = true;
        setState(() {});
        return;
      }

      // 🔥 будь-який інший статус — показуємо меседж з бекенду, якщо є
      final String message =
          apiAnswer.data['message']?.toString() ?? context.l.failedOpenContact;
      if (context.mounted) {
        notification(text: message);
      }
    } catch (e) {
      log("_openContact error: $e");
      if (context.mounted) {
        notification(text: context.l.connectionErrorRetry);
      }
    }
  }

  Future<void> onOrderCarrier(BuildContext context) async {
    if (orderingCarrier || carrierOrdered) return;

    setState(() => orderingCarrier = true);

    try {
      final ApiAnswer apiAnswer = await Api().traider.orderCarrier();
      log('orderCarrier: ${apiAnswer.data}');

      final bool status = apiAnswer.data['status'] == true;
      final String message = apiAnswer.data['message']?.toString() ?? '';

      setState(() {
        orderingCarrier = false;
        if (status) carrierOrdered = true;
      });

      if (context.mounted) {
        showInformPoUp(
          context,
          status ? context.l.done : context.l.error,
          message,
        );
      }
    } catch (e) {
      log('onOrderCarrier error: $e');
      setState(() => orderingCarrier = false);
      if (context.mounted) {
        notification(text: context.l.errorTariffMail);
      }
    }
  }

  Future<void> onOrderAnalysis(BuildContext context) async {
    if (orderingAnalysis || analysisOrdered) return;

    setState(() => orderingAnalysis = true);

    try {
      final ApiAnswer apiAnswer =
          await Api().traider.orderAnalysis(orderId: bidItem.orderId!);
      log('orderAnalysis: ${apiAnswer.data}');

      final String status = apiAnswer.data['status']?.toString() ?? '';

      setState(() => orderingAnalysis = false);

      if (status == '+') {
        setState(() => analysisOrdered = true);
        if (context.mounted) {
          showInformPoUp(
            context,
            context.l.done,
            context.l.analysisOrderedMessage(
              apiAnswer.data['balance_after']?.toString() ?? '—',
            ),
          );
        }
      } else if (status == 'insufficient') {
        if (context.mounted) {
          showInformPoUp(
            context,
            context.l.error,
            context.l.insufficientFunds(
              apiAnswer.data['balance']?.toString() ?? '—',
              apiAnswer.data['price']?.toString() ?? '—',
            ),
          );
        }
      } else {
        final String message =
            apiAnswer.data['message']?.toString() ?? context.l.error;
        if (context.mounted) {
          showInformPoUp(context, context.l.error, message);
          notification(text: context.l.failedOpenContact);
        }
      }
    } catch (e) {
      log('onOrderAnalysis error: $e');
      setState(() => orderingAnalysis = false);
      if (context.mounted) {
        notification(text: context.l.connectionErrorRetry);
      }
    }
  }

  void onLaunchPhone(BuildContext context, String? phone) =>
      showCupertinoModalBottomSheet(
        topRadius: const Radius.circular(30),
        context: context,
        builder: (c) => LaunchPhone(contact: phone),
      );

  // --- Результат дзвінка ---
  void onSetAnswer(BuildContext context) => showCupertinoModalBottomSheet(
        topRadius: const Radius.circular(30),
        context: context,
        builder: (c) => SetAnswer(onAnswered: (p0) {
          _localStorageRepository.addNew(p0, bidItem.orderId.toString());
          result = p0;
          setState(() {});
          Navigator.pop(c);
        }),
      );

  // --- Угода (VIP) ---
  void onDeal(BuildContext context) => loadIfValid(() async {
        final orderId = bidItem.orderId;
        if (orderId == null) return;

        var quoteResult = await Api().myPrice.dealQuote(orderId: orderId);
        if (!quoteResult.ok || quoteResult.data == null) {
          if (context.mounted) {
            await showMyPriceError(
              context,
              quoteResult,
              mainController: Get.isRegistered<MainController>()
                  ? Get.find<MainController>()
                  : null,
            );
          }
          return;
        }

        var quote = quoteResult.data!;
        if (!quote.hasEnoughBalance && context.mounted) {
          inAppNotification(
            text: context.l.insufficientFunds(
              '${quote.balance ?? 0}',
              '${quote.amount ?? 0}',
            ),
            c: context,
          );
        }

        if (!context.mounted) return;
        final amount = quote.amount ?? 0;
        final confirmed = await showMyPriceConfirmDialog(
          context: context,
          title: context.l.confirmDealTitle,
          body: context.l.confirmDealBody(amount.toString()),
          confirmEnabled: quote.hasEnoughBalance,
        );
        if (!confirmed) return;

        var confirmResult = await Api().myPrice.dealConfirm(
              orderId: orderId,
              expectedAmount: amount,
            );

        if (!confirmResult.ok) {
          final action = await showMyPriceError(
            context,
            confirmResult,
            mainController: Get.isRegistered<MainController>()
                ? Get.find<MainController>()
                : null,
          );
          if (action == MyPriceErrorAction.retryQuote) {
            onDeal(context);
          }
          return;
        }

        if (Get.isRegistered<MainController>()) {
          final data = confirmResult.data;
          if (data is Map && data['balance_after'] != null) {
            Get.find<MainController>().updateBalance(data['balance_after']);
          }
        }
        await refreshOrderView();
        setState(() {});
      });
  // --- Відгуки ---
  void onReview() => Get.toNamed(Routes.review, arguments: bidItem.orderId);

  void onSell() => loadIfValid(() async {
        ApiAnswer apiAnswer =
            await Api().fermer.closePriceOrder(orderId: bidItem.orderId!);
        log(apiAnswer.data.toString());
        // після закриття повертаємось назад
        if (apiAnswer.data['status'].toString() == 'true') {
          Get.back();
        }
      });
}
