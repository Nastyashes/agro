import 'dart:developer';

import 'package:agro/app/bid_detail/components/bid_detail_ui.dart';
import 'package:agro/app/my_price/components/my_price_error.dart'
    show MyPriceErrorAction;
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/data/repositories/farmer_orders_repository.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:get/get.dart';

/// Bid detail: contact (paid or for an ad), carrier, analysis (paid), deal
/// (paid). Holds no BuildContext; everything shown goes through [ui].
class BidItemController extends BaseController {
  BidItemController({
    BidsRepository? bids,
    MyPriceApi? myPrice,
    FarmerOrdersRepository? farmerOrders,
    MainController? mainController,
    Future<void> Function(Future<void> Function() action)? withLoader,
    void Function(BidItem item)? onBidUpdated,
  })  : _bids = bids ?? BidsRepository(),
        _myPrice = myPrice ?? MyPriceApi(),
        _farmerOrders = farmerOrders ?? FarmerOrdersRepository(),
        _mainController = mainController,
        _withLoader = withLoader,
        _onBidUpdated = onBidUpdated ?? _updateHomeList;

  final BidsRepository _bids;
  final MyPriceApi _myPrice;
  final FarmerOrdersRepository _farmerOrders;
  final MainController? _mainController;
  final Future<void> Function(Future<void> Function() action)? _withLoader;
  final void Function(BidItem item) _onBidUpdated;

  late BidDetailUi ui;

  MainController? get _main =>
      _mainController ??
      (Get.isRegistered<MainController>() ? Get.find<MainController>() : null);

  final Rx<BidItem> bid = BidItem().obs;
  final RxBool loadPage = false.obs;
  final RxBool contactOpened = false.obs;

  /// True while a (possibly paid) contact request is in flight.
  final RxBool openingContact = false.obs;
  final RxBool orderingCarrier = false.obs;
  final RxBool carrierOrdered = false.obs;
  final RxBool orderingAnalysis = false.obs;
  final RxBool analysisOrdered = false.obs;

  BidItem get bidItem => bid.value;

  Future<void> _loading(Future<void> Function() action) =>
      (_withLoader ?? loadIfValid)(action);

  Future<void> initPage({BidItem? item, int? orderId}) async {
    bid.value = item ?? BidItem(orderId: orderId);
    if (bidItem.isOpened) contactOpened.value = true;
    await refreshOrderView();
    loadPage.value = true;
  }

  Future<void> refreshOrderView() async {
    final orderId = bidItem.orderId;
    if (orderId == null) return;
    try {
      final view = await _bids.view(orderId);
      if (view.item != null) {
        bid.value = view.item!;
      } else if (view.myPrice != null) {
        bid.value = bidItem.copyWith(myPrice: view.myPrice);
      }
      if (bidItem.isOpened) contactOpened.value = true;
      final meta = bidItem.myPrice;
      if (meta != null && meta.canAcknowledge && meta.matchId != null) {
        await _myPrice.matchAck(meta.matchId!);
      }
    } catch (e) {
      log('refreshOrderView error: $e');
    }
  }

  // --- Contact ---

  /// Free-tariff users without ad-free pay for a free contact by watching
  /// an ad; everyone else opens it directly (it may be charged).
  Future<void> onContactClick() async {
    if (bidItem.isOpened || openingContact.value) return;
    openingContact.value = true;
    try {
      final main = _main;
      final shouldShowAd = (bidItem.contactPrice ?? 0) == 0 &&
          main?.isFree == true &&
          main?.isAdsDisabled != true;
      if (!shouldShowAd) {
        await _openContact();
        return;
      }

      AdBannerModel? ad;
      try {
        final res = await _bids.contactAd(bidItem.orderId!);
        ad = res.status == true ? res.adBanner : null;
      } catch (e) {
        log('openContactsAd failed, fallback to direct open: $e');
      }
      if (ad == null || await ui.watchContactAd(ad)) {
        await _openContact();
      }
    } catch (e) {
      log('contact open failed: $e');
      ui.notify(BidNotice.openContactRetry);
    } finally {
      openingContact.value = false;
    }
  }

  Future<void> _openContact() async {
    try {
      final result = await _bids.openContact(bidItem.orderId!);
      switch (result.status) {
        case OpenContactStatus.opened:
          // Paid: record it even if the user already left the screen.
          final contact = result.contact!;
          bid.value = bidItem.copyWith(
            opened: 1,
            openedPhon: contact.phone,
            fermerCompany: contact.company,
            fermerName: contact.name,
            fermerPhone: contact.phone,
            fermerEmail: contact.email,
            contacts: contact.contacts,
          );
          _onBidUpdated(bidItem);
          contactOpened.value = true;
        case OpenContactStatus.insufficient:
          ui.notify(BidNotice.insufficientBalance, serverText: result.message);
        case OpenContactStatus.failed:
          ui.notify(BidNotice.failedOpenContact, serverText: result.message);
      }
    } catch (e) {
      log('_openContact error: $e');
      ui.notify(BidNotice.connectionErrorRetry);
    }
  }

  // --- Carrier ---

  Future<void> onOrderCarrier() async {
    if (orderingCarrier.value || carrierOrdered.value) return;
    orderingCarrier.value = true;
    try {
      final result = await _bids.orderCarrier();
      if (result.ok) carrierOrdered.value = true;
      ui.showCarrierResult(result);
    } catch (e) {
      log('onOrderCarrier error: $e');
      ui.notify(BidNotice.carrierError);
    } finally {
      orderingCarrier.value = false;
    }
  }

  // --- Analysis (paid) ---

  Future<void> onOrderAnalysis() async {
    if (orderingAnalysis.value || analysisOrdered.value) return;
    orderingAnalysis.value = true;
    try {
      final result = await _bids.orderAnalysis(bidItem.orderId!);
      // Paid: mark it ordered first so the button cannot charge twice.
      if (result.status == AnalysisStatus.ordered) analysisOrdered.value = true;
      ui.showAnalysisResult(result);
    } catch (e) {
      log('onOrderAnalysis error: $e');
      ui.notify(BidNotice.connectionErrorRetry);
    } finally {
      orderingAnalysis.value = false;
    }
  }

  // --- Deal (VIP, paid) ---

  Future<void> onDeal() => _loading(_deal);

  Future<void> _deal() async {
    final orderId = bidItem.orderId;
    if (orderId == null) return;

    final quoteResult = await _myPrice.dealQuote(orderId: orderId);
    if (!quoteResult.ok || quoteResult.data == null) {
      await ui.showMyPriceError(quoteResult);
      return;
    }

    final quote = quoteResult.data!;
    if (!quote.hasEnoughBalance) ui.showDealInsufficient(quote);
    if (!await ui.confirmDeal(quote)) return;

    final confirmResult = await _myPrice.dealConfirm(
      orderId: orderId,
      expectedAmount: quote.amount ?? 0,
    );
    if (!confirmResult.ok) {
      final action = await ui.showMyPriceError(confirmResult);
      if (action == MyPriceErrorAction.retryQuote) await _deal();
      return;
    }

    final data = confirmResult.data;
    if (data is Map && data['balance_after'] != null) {
      _main?.updateBalance(data['balance_after']);
    }
    await refreshOrderView();
  }

  // --- Navigation ---

  void onReview() => Get.toNamed(Routes.review, arguments: bidItem.orderId);

  Future<void> onSell() => _loading(() async {
        // Back to the list once the order is closed.
        if (await _farmerOrders.closeOrder(bidItem.orderId!)) Get.back();
      });

  static void _updateHomeList(BidItem item) {
    if (Get.isRegistered<NewHomeController>()) {
      Get.find<NewHomeController>().updateBidItem(item);
    }
  }
}
