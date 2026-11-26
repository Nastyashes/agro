import 'dart:async';

import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:agro/app/bid_detail/components/bid_detail_ui.dart';
import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeBids extends BidsRepository {
  Completer<void>? gate;
  OpenContactsAdResponse ad =
      OpenContactsAdResponse(status: true, message: '', adBanner: null);
  OpenContactResult open = const OpenContactResult(OpenContactStatus.failed);
  AnalysisResult analysis = const AnalysisResult(AnalysisStatus.ordered);
  Object? openError;
  int opens = 0, analyses = 0;

  @override
  Future<OrderView> view(int orderId) async => const OrderView();

  @override
  Future<OpenContactsAdResponse> contactAd(int orderId) async => ad;

  @override
  Future<OpenContactResult> openContact(int orderId) async {
    opens++;
    if (gate != null) await gate!.future;
    if (openError != null) throw openError!;
    return open;
  }

  @override
  Future<AnalysisResult> orderAnalysis(int orderId) async {
    analyses++;
    return analysis;
  }
}

class FakeMyPrice extends MyPriceApi {
  MyPriceResult<MyPriceDealQuote> dealQuoteResult = const MyPriceResult(
      ok: true, data: MyPriceDealQuote(amount: 200, balanceAfter: 50));
  final List<MyPriceResult<dynamic>> confirms = [];
  final List<double> confirmed = [];
  int quotes = 0;

  @override
  Future<MyPriceResult<MyPriceDealQuote>> dealQuote(
      {required int orderId}) async {
    quotes++;
    return dealQuoteResult;
  }

  @override
  Future<MyPriceResult<dynamic>> dealConfirm({
    required int orderId,
    required double expectedAmount,
  }) async {
    confirmed.add(expectedAmount);
    return confirms.removeAt(0);
  }
}

class FakeMain extends MainController {
  bool free = true;
  bool adsOff = false;

  @override
  bool get isFree => free;

  @override
  bool get isAdsDisabled => adsOff;

  int refreshes = 0;
  @override
  Future<void> refreshUserData() async => refreshes++;
}

class FakeUi implements BidDetailUi {
  bool watched = true;
  bool confirm = true;
  bool confirmAnalysisAnswer = true;
  MyPriceErrorAction errorAction = MyPriceErrorAction.message;
  final List<String> log = [];

  @override
  Future<bool> watchContactAd(AdBannerModel ad) async {
    log.add('ad');
    return watched;
  }

  @override
  void notify(BidNotice fallback, {String? serverText}) =>
      log.add('notify:${fallback.name}:${serverText ?? ''}');

  @override
  void showCarrierResult(CarrierResult result) => log.add('carrier');

  @override
  Future<bool> confirmAnalysis() async {
    log.add('confirmAnalysis');
    return confirmAnalysisAnswer;
  }

  @override
  void showAnalysisResult(AnalysisResult result) =>
      log.add('analysis:${result.status.name}');

  @override
  Future<MyPriceErrorAction> showMyPriceError(MyPriceResult result) async {
    log.add('error:${result.errorCode}');
    return errorAction;
  }

  @override
  void showDealInsufficient(MyPriceDealQuote quote) => log.add('insufficient');

  @override
  Future<bool> confirmDeal(MyPriceDealQuote quote) async {
    log.add('confirm:${quote.amount}');
    return confirm;
  }
}

final opened = OpenContactResult(
  OpenContactStatus.opened,
  contact: BidContact(phone: '+380501112233', contacts: BidContacts()),
);

/// Contract: paid actions charge only through an explicit path (watched ad
/// or direct open, confirmed deal), record success even if the screen is
/// gone, and never allow a second paid analysis.
void main() {
  setUpAll(() => Get.testMode = true);

  late FakeBids bids;
  late FakeMyPrice myPrice;
  late FakeMain main;
  late FakeUi ui;
  late List<BidItem> updated;
  late BidItemController c;

  setUp(() async {
    bids = FakeBids();
    myPrice = FakeMyPrice();
    main = FakeMain();
    ui = FakeUi();
    updated = [];
    c = BidItemController(
      bids: bids,
      myPrice: myPrice,
      mainController: main,
      withLoader: (action) => action(),
      onBidUpdated: updated.add,
    )..ui = ui;
    await c.initPage(orderId: 7);
  });

  group('contact', () {
    test('free tariff: ad must be watched before opening', () async {
      bids.ad = OpenContactsAdResponse(
          status: true, message: '', adBanner: AdBannerModel(image: 'i'));
      ui.watched = false;

      await c.onContactClick();

      expect(ui.log, ['ad']);
      expect(bids.opens, 0);
    });

    test('watched ad opens the contact and updates the list', () async {
      bids.ad = OpenContactsAdResponse(
          status: true, message: '', adBanner: AdBannerModel(image: 'i'));
      bids.open = opened;

      await c.onContactClick();

      expect(bids.opens, 1);
      expect(c.contactOpened.value, isTrue);
      expect(c.bidItem.fermerPhone, '+380501112233');
      expect(updated, hasLength(1));
      // Paid: the header balance is reloaded (BUG-003).
      expect(main.refreshes, 1);
    });

    test('ads disabled: opens directly without an ad', () async {
      main.adsOff = true;
      bids.open = opened;

      await c.onContactClick();

      expect(ui.log, isEmpty);
      expect(bids.opens, 1);
    });

    test('insufficient balance shows the server text', () async {
      main.free = false;
      bids.open = const OpenContactResult(OpenContactStatus.insufficient,
          message: 'Поповніть');

      await c.onContactClick();

      expect(ui.log, ['notify:insufficientBalance:Поповніть']);
      expect(c.contactOpened.value, isFalse);
    });

    test('network error shows retry', () async {
      main.free = false;
      bids.openError = const ApiException(ApiErrorKind.network);

      await c.onContactClick();

      expect(ui.log, ['notify:connectionErrorRetry:']);
    });

    test('a double tap while opening sends one paid request', () async {
      main.free = false;
      bids.open = opened;
      bids.gate = Completer<void>();

      final first = c.onContactClick();
      final second = c.onContactClick();
      expect(c.openingContact.value, isTrue);
      bids.gate!.complete();
      await Future.wait([first, second]);

      expect(bids.opens, 1);
      expect(c.openingContact.value, isFalse);
    });

    test('already opened contact does nothing', () async {
      main.free = false;
      bids.open = opened;
      await c.onContactClick();

      await c.onContactClick();

      expect(bids.opens, 1);
    });
  });

  group('analysis', () {
    test('ordered once: a second tap is ignored', () async {
      await c.onOrderAnalysis();
      await c.onOrderAnalysis();

      expect(bids.analyses, 1);
      expect(c.analysisOrdered.value, isTrue);
      expect(c.orderingAnalysis.value, isFalse);
      expect(ui.log, ['confirmAnalysis', 'analysis:ordered']);
    });

    test('declining the confirm charges nothing', () async {
      ui.confirmAnalysisAnswer = false;

      await c.onOrderAnalysis();

      expect(bids.analyses, 0);
      expect(c.analysisOrdered.value, isFalse);
      expect(c.orderingAnalysis.value, isFalse);
    });

    test('ordered analysis applies the balance after (BUG-003)', () async {
      bids.analysis =
          const AnalysisResult(AnalysisStatus.ordered, balanceAfter: '125');

      await c.onOrderAnalysis();

      expect(main.balance, 125);
    });

    test('insufficient can be retried', () async {
      bids.analysis = const AnalysisResult(AnalysisStatus.insufficient);

      await c.onOrderAnalysis();
      await c.onOrderAnalysis();

      expect(bids.analyses, 2);
      expect(c.analysisOrdered.value, isFalse);
    });
  });

  group('deal', () {
    test('cancel charges nothing', () async {
      ui.confirm = false;

      await c.onDeal();

      expect(ui.log, ['confirm:200.0']);
      expect(myPrice.confirmed, isEmpty);
    });

    test('confirmed deal charges the quoted amount and updates balance',
        () async {
      myPrice.confirms
          .add(const MyPriceResult(ok: true, data: {'balance_after': '50.0'}));

      await c.onDeal();

      expect(myPrice.confirmed, [200.0]);
      expect(main.balance, 50);
    });

    test('not enough balance warns before the (disabled) confirm', () async {
      myPrice.dealQuoteResult = const MyPriceResult(
          ok: true, data: MyPriceDealQuote(amount: 200, balanceAfter: -171));
      ui.confirm = false;

      await c.onDeal();

      expect(ui.log, ['insufficient', 'confirm:200.0']);
      expect(myPrice.confirmed, isEmpty);
    });

    test('retryQuote re-quotes and asks again', () async {
      myPrice.confirms
        ..add(const MyPriceResult(ok: false, errorCode: 'price_changed'))
        ..add(const MyPriceResult(ok: true));
      ui.errorAction = MyPriceErrorAction.retryQuote;

      await c.onDeal();

      expect(myPrice.quotes, 2);
      expect(myPrice.confirmed, hasLength(2));
    });
  });
}
