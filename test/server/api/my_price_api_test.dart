import 'dart:async';

import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'api_client_test.dart' show multipartFields;

/// Contract: every paid My price call sends an explicit confirmation and
/// the amount the user saw; a failed call is a result, never an exception,
/// and never carries raw exception text (BUG-006).
void main() {
  late http.Request last;

  void serve(Future<http.Response> Function(http.Request) handler) {
    Api.client = ApiClient(
      httpClient: MockClient((request) {
        last = request;
        return handler(request);
      }),
      baseUrl: () => 'https://uagro.trade/',
      token: () => 'tok',
      language: () => 'uk',
    );
  }

  void reply(String body, [int status = 200]) =>
      serve((_) async => http.Response(body, status,
          headers: {'content-type': 'application/json; charset=utf-8'}));

  final api = MyPriceApi();
  const params = MyPriceActivateParams(
    regionId: 1,
    productId: 2,
    paymentType: 3,
    pricePerTon: 7200.5,
    teamUserId: 4,
    promoCode: 'AGRO',
  );

  Map<String, String> sent() {
    expect(last.url.path, '/api.php');
    expect(last.url.query, isEmpty, reason: 'nothing in the URL');
    return multipartFields(last);
  }

  group('wire format of paid calls', () {
    setUp(() => reply('{"ok":true,"data":{}}'));

    test('activate sends params, request id, expected amount, confirmed',
        () async {
      await api.activate(
        params: params,
        requestId: 'req-1',
        expectedAction: 'activate',
        expectedAmount: 270,
      );
      expect(sent(), {
        'method': 'my_price.activate',
        'key': 'tok',
        'lang': 'uk',
        'region_id': '1',
        'product_id': '2',
        'payment_type': '3',
        'price_per_ton': '7200.5',
        'team_user_id': '4',
        'promo_code': 'AGRO',
        'request_id': 'req-1',
        'expected_action': 'activate',
        'expected_amount': '270.0',
        'confirmed': '1',
      });
    });

    test('quote sends the params only, no confirmation', () async {
      await api.quote(params);
      final f = sent();
      expect(f['method'], 'my_price.quote');
      expect(f.containsKey('confirmed'), isFalse);
      expect(f.containsKey('request_id'), isFalse);
    });

    test('deal: quote has no confirmation, confirm sends the amount', () async {
      await api.dealQuote(orderId: 7);
      expect(sent(), {
        'method': 'my_price.deal.quote',
        'key': 'tok',
        'lang': 'uk',
        'order_id': '7',
      });
      await api.dealConfirm(orderId: 7, expectedAmount: 50);
      expect(sent(), {
        'method': 'my_price.deal.confirm',
        'key': 'tok',
        'lang': 'uk',
        'order_id': '7',
        'expected_amount': '50.0',
        'confirmed': '1',
      });
    });

    test('delete is confirmed; update sends only what changed', () async {
      await api.deleteCombination(9);
      expect(sent()['combination_id'], '9');
      expect(sent()['confirmed'], '1');

      await api.update(targetType: 'combination', targetId: 9);
      expect(sent().keys, isNot(contains('price_per_ton')));
      expect(sent().keys, isNot(contains('team_user_id')));
      await api.update(
          targetType: 'combination',
          targetId: 9,
          pricePerTon: 7300,
          teamUserId: 4);
      expect(sent()['price_per_ton'], '7300.0');
      expect(sent()['team_user_id'], '4');
    });

    test('deals list pages', () async {
      await api.dealsList(limit: 20, offset: 40);
      expect(sent()['limit'], '20');
      expect(sent()['offset'], '40');
    });
  });

  group('results', () {
    test('ok answer is parsed into data', () async {
      reply('{"ok":true,"data":{"order_id":7,"amount":"50",'
          '"balance_after":"10"}}');
      final r = await api.dealQuote(orderId: 7);
      expect(r.ok, isTrue);
      expect(r.data?.amount, 50);
      expect(r.data?.hasEnoughBalance, isTrue);
    });

    test('server error keeps its code and message', () async {
      reply('{"ok":false,"error_code":"insufficient_funds",'
          '"message":"Недостатньо коштів"}');
      final r = await api.dealConfirm(orderId: 7, expectedAmount: 50);
      expect(r.ok, isFalse);
      expect(r.errorCode, 'insufficient_funds');
      expect(r.message, 'Недостатньо коштів');
    });

    test('no connection is network_error with no message', () async {
      serve((_) async => throw http.ClientException('Failed host lookup'));
      final r = await api.overview();
      expect(r.ok, isFalse);
      expect(r.errorCode, myPriceNetworkError);
      expect(r.message, isNull);
    });

    test('timeout is network_error too', () async {
      serve((_) async => throw TimeoutException('slow'));
      final r = await api.activate(
        params: params,
        requestId: 'req-1',
        expectedAction: 'activate',
        expectedAmount: 270,
      );
      expect(r.errorCode, myPriceNetworkError);
    });

    test('non-JSON answer is a generic failure, raw text never shown',
        () async {
      reply('<html>502 Bad Gateway</html>', 502);
      final r = await api.overview();
      expect(r.ok, isFalse);
      expect(r.errorCode, 'database_error');
      expect(r.message, isNull);
    });
  });

  test('request ids are unique and URL-safe', () {
    final ids = List.generate(200, (_) => generateMyPriceRequestId());
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(id, matches(RegExp(r"^mp\.\d+\.[A-Za-z0-9]{16}$")));
    }
  });
}
