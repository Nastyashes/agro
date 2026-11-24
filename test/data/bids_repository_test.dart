import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../server/api/api_client_test.dart' show multipartFields;

void main() {
  late http.Request last;

  void serve(String body, [int status = 200]) {
    Api.client = ApiClient(
      httpClient: MockClient((request) async {
        last = request;
        return http.Response(body, status,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }),
      baseUrl: () => 'https://uagro.trade/',
      token: () => 'tok',
      language: () => 'uk',
    );
  }

  String? method() =>
      last.url.queryParameters['method'] ?? multipartFields(last)['method'];

  final repo = BidsRepository();

  group('search', () {
    test('returns bids, total and userfield', () async {
      serve('{"status":"+","bids":[],"bids_total":"42",'
          '"userfield":{"is_ads_disabled":true}}');

      final page = await repo.search(query: 'soy', limit: 20, offset: 40);

      expect(method(), 'auth.bids.search');
      expect(last.url.queryParameters['offset'], '40');
      expect(page.items, isEmpty);
      expect(page.total, 42);
      expect(page.userfield, {'is_ads_disabled': true});
    });

    test('status "-" is an error carrying the server text', () async {
      serve('{"status":"-","error":"bad search"}');

      await expectLater(
        repo.search(limit: 20, offset: 0),
        throwsA(
            isA<ApiException>().having((e) => e.cause, 'cause', 'bad search')),
      );
    });

    test('missing total and userfield are null', () async {
      serve('{"bids":[]}');

      final page = await repo.search(limit: 20, offset: 0);

      expect(page.total, isNull);
      expect(page.userfield, isNull);
    });
  });

  test('fresh reads bids_fresh and its total', () async {
    serve('{"bids_fresh":[],"bids_fresh_total":7}');

    final page = await repo.fresh(limit: 20, offset: 0);

    expect(method(), 'auth.my');
    expect(page.items, isEmpty);
    expect(page.total, 7);
  });

  group('openContact', () {
    test('opened returns the contact', () async {
      serve('{"status":"+","payload":{"phone":"+380501112233",'
          '"company":"Агро","name":"Петро","email":"p@x.ua"}}');

      final result = await repo.openContact(5);

      expect(method(), 'uagro.order.contacts');
      expect(result.status, OpenContactStatus.opened);
      expect(result.contact!.phone, '+380501112233');
      expect(result.contact!.company, 'Агро');
      expect(result.contact!.name, 'Петро');
    });

    test('insufficient keeps the server message', () async {
      serve('{"status":"insufficient","message":"Поповніть баланс"}');

      final result = await repo.openContact(5);

      expect(result.status, OpenContactStatus.insufficient);
      expect(result.message, 'Поповніть баланс');
      expect(result.contact, isNull);
    });

    test('any other status is failed with the message', () async {
      serve('{"status":"-","message":"Заявку закрито"}');

      final result = await repo.openContact(5);

      expect(result.status, OpenContactStatus.failed);
      expect(result.message, 'Заявку закрито');
    });

    test('opened without payload is failed', () async {
      serve('{"status":"+"}');

      expect((await repo.openContact(5)).status, OpenContactStatus.failed);
    });
  });

  group('orderCarrier', () {
    test('ok only when status is true', () async {
      serve('{"status":true,"message":"Заявку передано"}');
      var result = await repo.orderCarrier();
      expect(method(), 'order.carrier');
      expect(result.ok, isTrue);
      expect(result.message, 'Заявку передано');

      serve('{"status":"+","message":"x"}');
      result = await repo.orderCarrier();
      expect(result.ok, isFalse);
    });
  });

  group('orderAnalysis', () {
    test('ordered carries balance_after', () async {
      serve('{"status":"+","balance_after":120}');

      final result = await repo.orderAnalysis(5);

      expect(method(), 'uagro.order.analysis');
      expect(result.status, AnalysisStatus.ordered);
      expect(result.balanceAfter, '120');
    });

    test('insufficient carries balance and price', () async {
      serve('{"status":"insufficient","balance":29,"price":"100"}');

      final result = await repo.orderAnalysis(5);

      expect(result.status, AnalysisStatus.insufficient);
      expect(result.balance, '29');
      expect(result.price, '100');
    });

    test('other status is failed with message', () async {
      serve('{"status":"-","message":"no"}');

      final result = await repo.orderAnalysis(5);

      expect(result.status, AnalysisStatus.failed);
      expect(result.message, 'no');
    });
  });

  test('contactAd parses the ad response', () async {
    serve('{"status":true,"message":"","ad_banner":null}');

    final res = await repo.contactAd(5);

    expect(method(), 'order.opencontacts');
    expect(res.status, isTrue);
    expect(res.adBanner, isNull);
  });

  test('view returns the raw order for parsing', () async {
    serve('{"my_price":null}');

    final view = await repo.view(9);

    expect(method(), 'order.view');
    expect(view.item, isNull);
    expect(view.myPrice, isNull);
  });
}
