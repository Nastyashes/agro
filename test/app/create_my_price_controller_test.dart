import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/create_my_price_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeMyPriceApi extends MyPriceApi {
  final List<MyPriceResult<MyPriceQuote>> quotes = [];
  final List<MyPriceResult<MyPriceActivateResult>> activations = [];
  final List<MyPriceActivateParams> quoted = [];
  final List<({String requestId, String action, double amount})> activated = [];

  @override
  Future<MyPriceResult<MyPriceQuote>> quote(
      MyPriceActivateParams params) async {
    quoted.add(params);
    return quotes.removeAt(0);
  }

  @override
  Future<MyPriceResult<MyPriceActivateResult>> activate({
    required MyPriceActivateParams params,
    required String requestId,
    required String expectedAction,
    required double expectedAmount,
  }) async {
    activated.add(
        (requestId: requestId, action: expectedAction, amount: expectedAmount));
    return activations.removeAt(0);
  }
}

class FakeUi implements MyPriceUi {
  bool confirm = true;
  MyPriceErrorAction errorAction = MyPriceErrorAction.message;
  final List<MyPriceResult> errors = [];
  final List<MyPriceQuote> confirmations = [];

  @override
  Future<bool> confirmActivation(MyPriceQuote quote) async {
    confirmations.add(quote);
    return confirm;
  }

  @override
  Future<bool> confirmDelete() async => confirm;

  @override
  Future<MyPriceErrorAction> showError(MyPriceResult result) async {
    errors.add(result);
    return errorAction;
  }
}

const quote150 = MyPriceQuote(
  action: 'activate',
  pricing: MyPriceQuotePricing(chargedAmount: 150),
);

MyPriceResult<MyPriceQuote> okQuote([MyPriceQuote q = quote150]) =>
    MyPriceResult(ok: true, data: q);

MyPriceResult<T> fail<T>(String code,
        {Map<String, String> fields = const {}}) =>
    MyPriceResult<T>(ok: false, errorCode: code, fields: fields);

/// Contract: money is charged only after the user confirmed the quoted
/// amount; retries reuse the same request id; cancel charges nothing.
void main() {
  setUpAll(() => Get.testMode = true);

  late FakeMyPriceApi api;
  late FakeUi ui;
  late MainController main;
  late List<dynamic> closed;
  late CreateMyPriceController c;

  setUp(() {
    api = FakeMyPriceApi();
    ui = FakeUi();
    main = MainController();
    closed = [];
    c = CreateMyPriceController(
      api: api,
      mainController: main,
      withLoader: (action) => action(),
      close: closed.add,
      currentUserId: 0,
      overview: const MyPriceOverview(
        team: [MyPriceTeamMember(id: 7)],
      ),
    )..onInit();
    c.ui = ui;
  });

  void fillForm() {
    c.productId.value = 1;
    c.regionId.value = 2;
    c.paymentType.value = 3;
    c.priceController.text = '4000,5';
  }

  test('first team member is preselected', () {
    expect(c.teamUserId.value, 7);
  });

  test('contact person is the current user, not just the first member', () {
    final own = CreateMyPriceController(
      api: api,
      mainController: main,
      withLoader: (action) => action(),
      close: closed.add,
      currentUserId: 42,
      overview: const MyPriceOverview(team: [
        MyPriceTeamMember(id: 7, parent: '42'),
        MyPriceTeamMember(id: 42),
      ]),
    )..onInit();
    expect(own.teamUserId.value, 42);
  });

  test('a picked value clears that field error at once', () async {
    await c.onSubmit();
    expect(c.fieldErrors.keys,
        containsAll(['product_id', 'region_id', 'payment_type']));

    c.productId.value = 1;
    expect(c.fieldErrors.containsKey('product_id'), isFalse);
    expect(c.fieldErrors.containsKey('region_id'), isTrue);

    c.priceController.text = '4000';
    expect(c.fieldErrors.containsKey('price_per_ton'), isFalse);
  });

  test('missing fields are flagged and nothing is sent', () async {
    await c.onSubmit();

    expect(
        c.fieldErrors.keys,
        containsAll(
            ['product_id', 'region_id', 'payment_type', 'price_per_ton']));
    expect(api.quoted, isEmpty);
  });

  test('confirmed quote activates with the quoted action and amount', () async {
    fillForm();
    api.quotes.add(okQuote());
    api.activations.add(const MyPriceResult(
        ok: true, data: MyPriceActivateResult(walletBalance: 50)));

    await c.onSubmit();

    expect(api.quoted.single.pricePerTon, 4000.5);
    expect(ui.confirmations.single.pricing.chargedAmount, 150);
    expect(api.activated.single.action, 'activate');
    expect(api.activated.single.amount, 150);
    expect(main.balance, 50);
    expect(closed, [true]);
  });

  test('cancelling the confirmation charges nothing', () async {
    fillForm();
    ui.confirm = false;
    api.quotes.add(okQuote());

    await c.onSubmit();

    expect(api.activated, isEmpty);
    expect(closed, isEmpty);
  });

  test('database_error retries once with the same request id', () async {
    fillForm();
    api.quotes.add(okQuote());
    api.activations
      ..add(fail('database_error'))
      ..add(const MyPriceResult(ok: true, data: MyPriceActivateResult()));

    await c.onSubmit();

    expect(api.activated, hasLength(2));
    expect(api.activated[0].requestId, api.activated[1].requestId);
    expect(closed, [true]);
  });

  test('promo_unavailable clears the promo and re-quotes', () async {
    fillForm();
    c.promoController.text = 'PROMO';
    api.quotes
      ..add(fail('promo_unavailable'))
      ..add(okQuote());
    api.activations.add(const MyPriceResult(ok: true));

    await c.onSubmit();

    expect(api.quoted.map((p) => p.promoCode), ['PROMO', '']);
    expect(closed, [true]);
  });

  test('quote validation error marks the server fields', () async {
    fillForm();
    ui.errorAction = MyPriceErrorAction.validation;
    api.quotes.add(fail('validation', fields: {'price_per_ton': 'too low'}));

    await c.onSubmit();

    expect(c.fieldErrors, {'price_per_ton': 'too low'});
    expect(api.activated, isEmpty);
  });

  test('retryQuote after a failed activation re-quotes with a new request id',
      () async {
    fillForm();
    api.quotes
      ..add(okQuote())
      ..add(okQuote());
    api.activations
      ..add(fail('price_changed'))
      ..add(const MyPriceResult(ok: true));
    ui.errorAction = MyPriceErrorAction.retryQuote;

    await c.onSubmit();

    expect(api.quoted, hasLength(2));
    expect(api.activated, hasLength(2));
    expect(api.activated[0].requestId, isNot(api.activated[1].requestId));
    expect(closed, [true]);
  });

  test('a failed activation without retry keeps the screen open', () async {
    fillForm();
    api.quotes.add(okQuote());
    api.activations.add(fail('insufficient_funds'));

    await c.onSubmit();

    expect(ui.errors.single.errorCode, 'insufficient_funds');
    expect(closed, isEmpty);
  });

  test('changed values after a failure get a new request id (BUG-007)',
      () async {
    fillForm();
    api.quotes
      ..add(okQuote())
      ..add(okQuote());
    api.activations
      ..add(fail('insufficient_funds'))
      ..add(const MyPriceResult(ok: true));

    await c.onSubmit();
    c.priceController.text = '3900';
    await c.onSubmit();

    expect(api.activated, hasLength(2));
    expect(api.activated[0].requestId, isNot(api.activated[1].requestId));
  });

  test('same values after a failure keep the request id', () async {
    fillForm();
    api.quotes
      ..add(okQuote())
      ..add(okQuote());
    api.activations
      ..add(fail('insufficient_funds'))
      ..add(const MyPriceResult(ok: true));

    await c.onSubmit();
    await c.onSubmit();

    expect(api.activated[0].requestId, api.activated[1].requestId);
  });

  for (final bad in ['', '0', '-5', 'NaN', 'Infinity', '1e9', 'abc', '1.234']) {
    test('price "$bad" is flagged and nothing is sent (BUG-009)', () async {
      fillForm();
      c.priceController.text = bad;

      await c.onSubmit();

      expect(c.fieldErrors.containsKey('price_per_ton'), isTrue);
      expect(api.activated, isEmpty);
    });
  }
}
