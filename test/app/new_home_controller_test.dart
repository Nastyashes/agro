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
  @override
  bool get isFree => free;
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

  @override
  Future<BidsPage> fresh({required int limit, required int offset}) async =>
      const BidsPage(items: []);
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
}
