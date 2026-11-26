import 'dart:async';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'dart:io';

import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:hive/hive.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeMain extends MainController {
  bool free = true;
  Object? initError;
  Completer<void>? initGate;
  int initCalls = 0;
  @override
  bool get isFree => free;

  @override
  Future<void> initUserData({bool force = false}) async {
    initCalls++;
    if (initGate != null) await initGate!.future;
    if (initError != null) throw initError!;
  }
}

class FakeBids extends BidsRepository {
  int searches = 0;
  Object? error;
  @override
  Future<BidsPage> search(
      {String? query, required int limit, required int offset}) async {
    searches++;
    if (error != null) throw error!;
    return const BidsPage(items: []);
  }

  final List<int> freshOffsets = [];
  Completer<void>? freshGate;
  List<BidItem> freshNext = const [];

  @override
  Future<BidsPage> fresh({required int limit, required int offset}) async {
    freshOffsets.add(offset);
    final gate = freshGate;
    final items = freshNext;
    if (gate != null) await gate.future;
    return BidsPage(items: items, total: 100);
  }
}

class FakeAccount extends AccountRepository {
  DisableAdsResult? result;
  @override
  Future<DisableAdsResult> disableAds() async {
    if (result == null) throw const ApiException(ApiErrorKind.network);
    return result!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUpAll(() async {
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('home_controller_test');
    Hive.init(dir.path);
    Hive.registerAdapter(ModelUserAdapter());
    await Hive.openBox('data');
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  late FakeMain main;
  late FakeBids bids;
  late FakeAccount account;
  late NewHomeController c;

  setUp(() {
    Get.reset();
    main = FakeMain();
    Get.put<MainController>(main);
    bids = FakeBids();
    account = FakeAccount();
    c = NewHomeController(bids: bids, account: account)..onInit();
  });

  test('fresh tab is only for the free tariff', () {
    main.free = false;
    c.selectTab(NewHomeTab.fresh);
    expect(c.selectedTab.value, NewHomeTab.all);

    main.free = true;
    c.selectTab(NewHomeTab.fresh);
    expect(c.selectedTab.value, NewHomeTab.fresh);
  });

  test('opening search switches back to all bids', () {
    c.selectTab(NewHomeTab.fresh);

    c.toggleSearch();

    expect(c.isSearchOpen.value, isTrue);
    expect(c.selectedTab.value, NewHomeTab.all);
  });

  test('an updated bid is replaced in both lists', () {
    c.bids.add(BidItem(orderId: 1));
    c.bidsFresh.add(BidItem(orderId: 1));

    c.updateBidItem(BidItem(orderId: 1, opened: 1));

    expect(c.bids.single.isOpened, isTrue);
    expect(c.bidsFresh.single.isOpened, isTrue);
  });

  test('a failed search raises a failure event', () async {
    bids.error = const ApiException(ApiErrorKind.network);

    c.onSearch();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(c.failures.value, 1);
  });

  test('disableAds: success patches ads state and returns the message',
      () async {
    account.result = const DisableAdsResult(
        ok: true, message: 'Готово', userfieldPatch: {'is_ads_disabled': true});

    expect(await c.disableAds(), 'Готово');
    expect(main.isAdsDisabled, isTrue);
    expect(bids.searches, 1);
  });

  test('disableAds: refusal returns the server text, no refresh', () async {
    account.result = const DisableAdsResult(
        ok: false, message: 'Недостатньо коштів на балансі');

    expect(await c.disableAds(), 'Недостатньо коштів на балансі');
    expect(bids.searches, 0);
  });

  test('disableAds: network error returns null', () async {
    expect(await c.disableAds(), isNull);
  });

  group('offline', () {
    test('a network error with no bids shows the offline state', () async {
      bids.error = const ApiException(ApiErrorKind.network);

      await expectLater(
          c.loadAllBids(reset: true), throwsA(isA<ApiException>()));

      expect(c.offline.value, isTrue);
    });

    test('a server error is not "offline"', () async {
      bids.error = const ApiException(ApiErrorKind.badResponse);

      await expectLater(c.loadAllBids(reset: true), throwsA(anything));

      expect(c.offline.value, isFalse);
    });

    test('a successful load clears it', () async {
      c.offline.value = true;

      await c.loadAllBids(reset: true);

      expect(c.offline.value, isFalse);
    });

    test('initPage never throws; a failure becomes an event', () async {
      main.initError = const ApiException(ApiErrorKind.timeout);
      final before = c.failures.value;

      await c.initPage();

      expect(c.failures.value, before + 1);
    });

    test('a connection error at start-up shows the offline state', () async {
      main.initError = const ApiException(ApiErrorKind.network);

      await c.initPage();

      expect(c.offline.value, isTrue);
    });

    test('a later non-connection error clears a stale offline', () async {
      c.offline.value = true;
      bids.error = const ApiException(ApiErrorKind.badResponse);

      await expectLater(c.loadAllBids(reset: true), throwsA(anything));

      expect(c.offline.value, isFalse);
    });

    test('repeated retry taps run one reload', () async {
      main.initGate = Completer<void>();

      final first = c.retry();
      final second = c.retry();
      main.initGate!.complete();
      await Future.wait([first, second]);

      expect(main.initCalls, 1);
    });
  });

  test('refreshing Fresh while a page loads is not dropped (BUG-016)',
      () async {
    final firstPage = Completer<void>();
    bids.freshGate = firstPage;
    bids.freshNext = [BidItem(orderId: 1)];
    final paging = c.loadFreshBids();

    bids.freshGate = null;
    bids.freshNext = [BidItem(orderId: 2)];
    await c.loadFreshBids(reset: true);
    expect(c.bidsFresh.map((b) => b.orderId), [2]);

    // The stale page arrives later and is ignored.
    firstPage.complete();
    await paging;
    expect(bids.freshOffsets, [0, 0]);
    expect(c.bidsFresh.map((b) => b.orderId), [2]);
  });

  test('bidsLoaded turns on after the first successful load', () async {
    expect(c.bidsLoaded.value, isFalse);
    await c.loadAllBids(reset: true);
    expect(c.bidsLoaded.value, isTrue);
  });
}
