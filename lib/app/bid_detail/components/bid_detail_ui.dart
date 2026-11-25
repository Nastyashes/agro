import 'package:agro/app/new_home_screen/home_actions.dart';
import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_error.dart' as mp;
import 'package:agro/app/my_price/components/my_price_error.dart'
    show MyPriceErrorAction;
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/pop_up/banner_dialog.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:agro/ui/pop_up/inform_pop_up.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Fallback texts when the server gives none.
enum BidNotice {
  openContactRetry,
  insufficientBalance,
  failedOpenContact,
  connectionErrorRetry,
  carrierError,
}

/// Everything the bid screen controller needs to show or ask. The screen
/// provides [ScreenBidDetailUi]; tests provide a fake.
abstract class BidDetailUi {
  /// Shows the ad that unlocks a free contact; true if it was watched.
  Future<bool> watchContactAd(AdBannerModel ad);

  void notify(BidNotice fallback, {String? serverText});

  void showCarrierResult(CarrierResult result);

  void showAnalysisResult(AnalysisResult result);

  Future<MyPriceErrorAction> showMyPriceError(MyPriceResult result);

  void showDealInsufficient(MyPriceDealQuote quote);

  /// Shows the deal amount; true if the user confirms the charge.
  Future<bool> confirmDeal(MyPriceDealQuote quote);
}

class ScreenBidDetailUi implements BidDetailUi {
  ScreenBidDetailUi(this.context);

  final BuildContext context;

  MainController? get _main =>
      Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

  @override
  Future<bool> watchContactAd(AdBannerModel ad) async {
    if (!context.mounted) return false;
    final watched = await showAdBannerDialog(
      context,
      imageUrl: ad.image,
      phone: ad.phone,
      price: context.adsPriceLabel(),
      onDisableAds: () async {
        if (!context.mounted || !Get.isRegistered<NewHomeController>()) {
          return;
        }
        showDisableAdsConfirm(
          context,
          amount: AppConstants.adsPrice,
          onConfirm: () => disableAdsWithFeedback(context),
        );
      },
    );
    return watched == true;
  }

  @override
  void notify(BidNotice fallback, {String? serverText}) {
    if (!context.mounted) return;
    final l = context.l;
    notification(
      text: serverText ??
          switch (fallback) {
            BidNotice.openContactRetry => l.failedOpenContactRetry,
            BidNotice.insufficientBalance => l.insufficientBalance,
            BidNotice.failedOpenContact => l.failedOpenContact,
            BidNotice.connectionErrorRetry => l.connectionErrorRetry,
            BidNotice.carrierError => l.errorTariffMail,
          },
    );
  }

  @override
  void showCarrierResult(CarrierResult result) {
    if (!context.mounted) return;
    showInformPoUp(
      context,
      result.ok ? context.l.done : context.l.error,
      result.message,
    );
  }

  @override
  void showAnalysisResult(AnalysisResult result) {
    if (!context.mounted) return;
    final l = context.l;
    switch (result.status) {
      case AnalysisStatus.ordered:
        showInformPoUp(context, l.done,
            l.analysisOrderedMessage(result.balanceAfter ?? '—'));
      case AnalysisStatus.insufficient:
        showInformPoUp(context, l.error,
            l.insufficientFunds(result.balance ?? '—', result.price ?? '—'));
      case AnalysisStatus.failed:
        showInformPoUp(context, l.error, result.message ?? l.error);
        notification(text: l.failedOpenContact);
    }
  }

  @override
  Future<MyPriceErrorAction> showMyPriceError(MyPriceResult result) async {
    if (!context.mounted) return MyPriceErrorAction.message;
    return mp.showMyPriceError(context, result, mainController: _main);
  }

  @override
  void showDealInsufficient(MyPriceDealQuote quote) {
    if (!context.mounted) return;
    inAppNotification(
      text: context.l
          .insufficientFunds('${quote.balance ?? 0}', '${quote.amount ?? 0}'),
      c: context,
    );
  }

  @override
  Future<bool> confirmDeal(MyPriceDealQuote quote) async {
    if (!context.mounted) return false;
    final amount = quote.amount ?? 0;
    return showMyPriceConfirmDialog(
      context: context,
      title: context.l.confirmDealTitle,
      body: context.l.confirmDealBody(amount.toString()),
      confirmEnabled: quote.hasEnoughBalance,
    );
  }
}
