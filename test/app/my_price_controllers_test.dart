import 'package:agro/app/my_price/controller/edit_my_price_controller.dart';
import 'package:agro/app/my_price/controller/my_price_controller.dart';
import 'package:agro/app/my_price/controller/my_price_deals_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'create_my_price_controller_test.dart' show FakeUi;

class FakeApi extends MyPriceApi {
  MyPriceResult<MyPriceOverview> overviewResult =
      const MyPriceResult(ok: true, data: MyPriceOverview());
  MyPriceResult<dynamic> deleteResult = const MyPriceResult(ok: true);
  MyPriceResult<dynamic> updateResult = const MyPriceResult(ok: true);
  final List<MyPriceResult<MyPriceDealsPage>> pages = [];
  int overviewCalls = 0;
  final List<int> deleted = [];
  final List<({int id, double? price, int? team})> updated = [];
  final List<int> offsets = [];

  @override
  Future<MyPriceResult<MyPriceOverview>> overview() async {
    overviewCalls++;
    return overviewResult;
  }

  @override
  Future<MyPriceResult<dynamic>> deleteCombination(int combinationId) async {
    deleted.add(combinationId);
    return deleteResult;
  }

  @override
  Future<MyPriceResult<dynamic>> update({
    required String targetType,
    required int targetId,
    double? pricePerTon,
    int? teamUserId,
  }) async {
    updated.add((id: targetId, price: pricePerTon, team: teamUserId));
    return updateResult;
  }

  @override
  Future<MyPriceResult<MyPriceDealsPage>> dealsList({
    int limit = 50,
    int offset = 0,
  }) async {
    offsets.add(offset);
    return pages.removeAt(0);
  }
}

MyPriceResult<MyPriceDealsPage> page(int n) => MyPriceResult(
      ok: true,
      data: MyPriceDealsPage(
          items: List.generate(n, (i) => const MyPriceDealItem())),
    );

void main() {
  setUpAll(() => Get.testMode = true);

  late FakeApi api;
  late FakeUi ui;

  setUp(() {
    api = FakeApi();
    ui = FakeUi();
  });

  group('MyPriceController', () {
    late MyPriceController c;

    setUp(() {
      c = MyPriceController(api: api, mainController: MainController());
      c.ui = ui;
    });

    test('load marks the page loaded even on error and shows it', () async {
      api.overviewResult = const MyPriceResult(ok: false, errorCode: 'x');

      await c.loadOverview();

      expect(c.loadPage.value, isTrue);
      expect(ui.errors.single.errorCode, 'x');
    });

    test('tab switches visible entries', () async {
      api.overviewResult = const MyPriceResult(
        ok: true,
        data: MyPriceOverview(
          combinations: [MyPriceEntry(id: 1)],
          reservations: [MyPriceEntry(id: 2), MyPriceEntry(id: 3)],
        ),
      );
      await c.loadOverview();

      expect(c.visibleEntries.map((e) => e.id), [1]);
      c.selectTab(1);
      expect(c.visibleEntries.map((e) => e.id), [2, 3]);
    });

    test('delete needs confirmation', () async {
      ui.confirm = false;

      await c.deleteEntry(const MyPriceEntry(id: 5));

      expect(api.deleted, isEmpty);
    });

    test('confirmed delete removes and reloads', () async {
      await c.deleteEntry(const MyPriceEntry(id: 5));

      expect(api.deleted, [5]);
      expect(api.overviewCalls, 1);
    });

    test('failed delete shows the error and does not reload', () async {
      api.deleteResult = const MyPriceResult(ok: false, errorCode: 'locked');

      await c.deleteEntry(const MyPriceEntry(id: 5));

      expect(ui.errors.single.errorCode, 'locked');
      expect(api.overviewCalls, 0);
    });
  });

  group('EditMyPriceController', () {
    late List<dynamic> closed;
    late EditMyPriceController c;

    setUp(() {
      closed = [];
      c = EditMyPriceController(
        api: api,
        mainController: MainController(),
        withLoader: (action) => action(),
        close: closed.add,
        arguments: {
          'entry': const MyPriceEntry(id: 9, pricePerTon: 4000, teamUserId: 3),
          'targetType': 'combination',
        },
      )..onInit();
      c.ui = ui;
    });

    test('starts from the entry values', () {
      expect(c.priceController.text, '4000.0');
      expect(c.teamUserId.value, 3);
    });

    test('save sends the new values and closes', () async {
      c.priceController.text = '4100,5';
      c.teamUserId.value = 4;

      await c.onSave();

      expect(api.updated.single, (id: 9, price: 4100.5, team: 4));
      expect(closed, [true]);
    });

    test('failed save shows the error and stays', () async {
      api.updateResult = const MyPriceResult(ok: false, errorCode: 'x');

      await c.onSave();

      expect(ui.errors, hasLength(1));
      expect(closed, isEmpty);
    });
  });

  group('MyPriceDealsController', () {
    late MyPriceDealsController c;

    setUp(() {
      c = MyPriceDealsController(api: api);
      c.ui = ui;
    });

    test('pages until a short page', () async {
      api.pages
        ..add(page(50))
        ..add(page(3));

      await c.loadDeals(reset: true);
      await c.loadDeals();
      await c.loadDeals();

      expect(api.offsets, [0, 50]);
      expect(c.items, hasLength(53));
      expect(c.hasMore, isFalse);
      expect(c.initialLoading.value, isFalse);
    });

    test('reset reloads from zero', () async {
      api.pages
        ..add(page(50))
        ..add(page(1));

      await c.loadDeals(reset: true);
      await c.loadDeals(reset: true);

      expect(api.offsets, [0, 0]);
      expect(c.items, hasLength(1));
    });
  });
}
