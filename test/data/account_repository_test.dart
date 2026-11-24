import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  String method() => last.url.queryParameters['method']!;

  final repo = AccountRepository();

  group('balance', () {
    test('parses numeric and string balance', () async {
      serve('{"status":"+","balance":"29"}');
      expect(await repo.balance(), 29);
      expect(method(), 'balance');

      serve('{"balance":150}');
      expect(await repo.balance(), 150);
    });

    test('missing balance is 0', () async {
      serve('{"status":"+"}');
      expect(await repo.balance(), 0);
    });
  });

  group('currentTariff', () {
    test('parses payload', () async {
      serve('{"payload":{"tariff_id":"1","is_vip":"0","is_premium":"0",'
          '"balance_end":null}}');

      final tariff = await repo.currentTariff();

      expect(method(), 'tariff');
      expect(tariff.tafiffId, 1);
    });

    test('missing payload is a bad response', () async {
      serve('{"status":"-"}');

      await expectLater(
          repo.currentTariff(),
          throwsA(isA<ApiException>()
              .having((e) => e.kind, 'kind', ApiErrorKind.badResponse)));
    });
  });

  group('tariffs', () {
    test('parses items', () async {
      serve('{"items":[{"name":"FREE","price":"0","price_old":"0",'
          '"price_period":"на місяць","currency":"грн",'
          '"options_ok":["a"],"options_no":["b"]}]}');

      final tariffs = await repo.tariffs();

      expect(method(), 'voc.tariffs');
      expect(tariffs.single.name, 'FREE');
      expect(tariffs.single.advantages, ['a']);
    });

    test('no items is an empty list', () async {
      serve('{}');
      expect(await repo.tariffs(), isEmpty);
    });
  });

  group('payment links', () {
    test('tariff payment returns pay_url', () async {
      serve('{"order_id":5,"pay_url":"https://pay.example/x"}');

      expect(await repo.tariffPaymentUrl(3500), 'https://pay.example/x');
      expect(method(), 'checkout');
      expect(last.url.queryParameters['amount'], '3500');
    });

    test('top-up finds the url under known keys, also nested', () async {
      serve('{"data":{"payment_url":" https://pay.example/y "}}');

      expect(await repo.topUpPaymentUrl(100), 'https://pay.example/y');
      expect(method(), 'uagro.wallet.topup');
    });

    test('server error is PaymentRejected', () async {
      serve('{"error":"limit"}');

      await expectLater(
          repo.topUpPaymentUrl(100), throwsA(isA<PaymentRejected>()));
    });

    test('missing url is PaymentRejected', () async {
      serve('{"order_id":5}');

      await expectLater(
          repo.tariffPaymentUrl(3500), throwsA(isA<PaymentRejected>()));
    });

    test('non-map body is PaymentRejected', () async {
      serve('[]');

      await expectLater(
          repo.tariffPaymentUrl(3500), throwsA(isA<PaymentRejected>()));
    });
  });

  group('disableAds', () {
    test('failure keeps the server message, no userfield patch', () async {
      serve('{"status":"-","message":"Недостатньо коштів на балансі"}');

      final result = await repo.disableAds();

      expect(method(), 'free.disable_ads');
      expect(result.ok, isFalse);
      expect(result.message, 'Недостатньо коштів на балансі');
      expect(result.userfieldPatch, isEmpty);
    });

    test('success marks ads disabled and carries until + userfield', () async {
      serve('{"status":"+","message":"ok","ads_disabled_until":1800000000,'
          '"userfield":{"foo":"bar","is_ads_disabled":false}}');

      final result = await repo.disableAds();

      expect(result.ok, isTrue);
      expect(result.userfieldPatch, {
        'is_ads_disabled': true,
        'ads_disabled_until': 1800000000,
        'foo': 'bar',
      });
    });

    test('until may come inside userfield', () async {
      serve('{"status":"+","userfield":{"ads_disabled_until":"1800000001"}}');

      final result = await repo.disableAds();

      expect(result.userfieldPatch['ads_disabled_until'], '1800000001');
      expect(result.userfieldPatch['is_ads_disabled'], isTrue);
    });
  });

  group('userfield', () {
    test('reads userfield from auth.my', () async {
      serve('{"userfield":{"is_ads_disabled":true}}');

      expect(await repo.userfield(), {'is_ads_disabled': true});
      expect(method(), 'auth.my');
    });

    test('missing userfield is empty', () async {
      serve('{}');
      expect(await repo.userfield(), isEmpty);
    });
  });

  test('registerDeviceToken sends the token', () async {
    serve('{"status":"+"}');

    await repo.registerDeviceToken('fcm');

    expect(method(), 'send_devicetoken');
    expect(last.url.queryParameters['device_token'], 'fcm');
  });
}
