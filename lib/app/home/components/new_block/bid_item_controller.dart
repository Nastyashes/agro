import 'dart:developer';

import 'package:agro/app/home/components/home_controller.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/app/home/order/components/set_answer.dart.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/model/call_result/call_result.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/adds.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BidItemController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BidItem bidItem;
  bool loadPage = false;

  Tariff? tariff;
  CallResult? result;
  bool contactOpened = false;

  final _localStorageRepository = LocalStorageRepository();
  final HomeController _homeController = Get.find();
  final _interstitial = Interstitial();

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
    required BidItem item,
  }) async {
    setState = set;
    bidItem = item;
    tariff = _homeController.tariff;

    // Якщо контакт вже відкритий — зберігаємо стан
    if (bidItem.isOpened) contactOpened = true;

    // Завантажуємо попередній результат дзвінка
    result =
        await _localStorageRepository.getResult(bidItem.orderId.toString());

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => loadPage = true);
  }

  Future<void> onContactClick(BuildContext context) async {
    final String errorTariffMail = context.l.errorTariffMail;

    if (bidItem.isOpened) return;

    try {
      final contactPrice = bidItem.contactPrice ?? 0;

      final isPremium = tariff?.isPremium == true || tariff?.isVip == true;

      final isFree = tariff?.isFree == true;

      final isAdsDisabled =
          _homeController.userfield['is_ads_disabled'] == true;

      final shouldShowAd = contactPrice == 0 && isFree && !isAdsDisabled;

      log('contactPrice=$contactPrice');
      log('isFree=$isFree');
      log('isAdsDisabled=$isAdsDisabled');
      log('isPremium=$isPremium');
      log('shouldShowAd=$shouldShowAd');

      if (shouldShowAd) {
        await _interstitial.loadRewardedAd(
          doAfter: () async => await _openContact(context),
          onFailed: () async => await _openContact(context),
        );
        return;
      }

      await _openContact(context);
    } catch (e) {
      log("contact open failed: $e");
      notification(text: errorTariffMail);
    }
  }

  Future<void> _openContact(BuildContext context) async {
    try {
      ApiAnswer apiAnswer = await Api().traider.openBidContact(
            orderId: bidItem.orderId!,
          );

      log(apiAnswer.data.toString());

      if (apiAnswer.data['status'] == 'insufficient') {
        notification(text: 'Недостатньо коштів');
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

        _homeController.updateBidItem(bidItem);

        contactOpened = true;
        setState(() {});
      }
    } catch (e) {
      log("_openContact error: $e");
    }
  }

  // --- Зателефонувати ---
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
/*  void onDeal(BuildContext context) => loadIfValid(() async {
        final String errorAgreement = context.l.errorAgreement;
        ApiAnswer apiAnswer =
            await Api().traider.deal(tenderId: bidItem.orderId!);
        log(apiAnswer.data.toString());
        if (apiAnswer.data['status'].toString() != 'true') {
          notification(text: errorAgreement);
        }
      });
*/
  void onDeal(BuildContext context) => loadIfValid(() async {
        final String errorAgreement = context.l.errorAgreement;
        ApiAnswer apiAnswer = await Api().traider.dealNew(
              orderId: bidItem.orderId!,
            );
        log(apiAnswer.data.toString());
        if (apiAnswer.data['status'].toString() != 'true') {
          notification(text: errorAgreement);
        }
      });
  // --- Відгуки ---
  void onReview() => Get.toNamed(Routes.review, arguments: bidItem.orderId);

  // --- Додати ціну ---
//  void onAddPrice(BuildContext context, BidItem item) =>
  //     showCupertinoModalBottomSheet(
  //       topRadius: const Radius.circular(30),
  //       context: context,
  //      builder: (c) => AddPriceScreen(orderId: item.orderId),
  //    );

  // --- Кнопка "Продати" (для фермера) ---
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
