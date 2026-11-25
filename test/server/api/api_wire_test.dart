import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'api_client_test.dart' show multipartFields;

/// Pins the wire format of every API call to what the app sent before the
/// ApiClient refactor (backend is production-only, so this is the safety net).
void main() {
  late http.Request last;

  setUp(() {
    Api.client = ApiClient(
      httpClient: MockClient((request) async {
        last = request;
        return http.Response('{"ok":true}', 200);
      }),
      baseUrl: () => 'https://uagro.trade/',
      token: () => 'tok',
      language: () => 'uk',
    );
  });

  void expectQuery(String path, Map<String, String> params) {
    expect(last.url.path, path);
    expect(last.url.queryParameters, params);
    expect(multipartFields(last), isEmpty);
  }

  void expectBody(String path, Map<String, String> fields) {
    expect(last.url.path, path);
    expect(last.url.query, isEmpty);
    expect(multipartFields(last), fields);
  }

  Map<String, String> q(String method, [Map<String, String> p = const {}]) =>
      {'method': method, 'key': 'tok', ...p, 'lang': 'uk'};

  final api = Api();

  test('auth keeps the legacy "+ means space" wire format', () async {
    await api.auth.loginNumber(number: '+380501112233');
    expect(last.url.query, contains('phone=+380501112233'));
    expectQuery('/apiapp.php', q('auth', {'phone': ' 380501112233'}));
    await api.auth.loginCode(code: '1234');
    expectQuery('/apiapp.php', q('auth', {'code': '1234'}));
    await api.traider.loginWithQr('a+b');
    expect(last.url.query, contains('secret=a+b'));
  });

  test('common', () async {
    await api.common.tariffPay(amount: 100);
    expectQuery(
        '/api.php', {'method': 'checkout', 'key': 'tok', 'amount': '100'});
    await api.common.balancePay(amount: 50);
    expectQuery('/api.php', q('uagro.wallet.topup', {'amount': '50'}));
    await api.common.getTariffs();
    expectQuery('/apiapp.php', q('voc.tariffs'));
    await api.common.getBalance();
    expectQuery('/api.php', q('balance'));
  });

  test('fermer', () async {
    await api.fermer.closePriceOrder(orderId: 2);
    expectQuery('/apiapp.php', q('fermer.closeorder', {'order_id': '2'}));
    await api.fermer.viewReview(orderId: 3);
    expectQuery('/apiapp.php', q('order.reviews', {'itemid': '3'}));
    await api.fermer
        .sendReviewFermer(orderId: 4, rating: 5, comment: 'ok & good');
    expectQuery(
        '/apiapp.php',
        q('order.comment',
            {'order_id': '4', 'rating': '5', 'comment': 'ok & good'}));
  });

  test('traider: query endpoints', () async {
    final t = api.traider;
    await t.loginWithQr('s3');
    expectQuery('/apiapp.php', q('qr_login', {'secret': 's3'}));
    await t.orderCarrier();
    expectQuery('/apiapp.php', q('order.carrier'));
    await t.getOrder(orderId: 7);
    expectQuery('/apiapp.php', q('order.view', {'order_id': '7'}));
    await t.getAllBids(limit: 20, offset: 40);
    expectQuery('/api.php', q('auth.my', {'limit': '20', 'offset': '40'}));
    await t.getAllBids();
    expectQuery('/api.php', q('auth.my'));
    await t.disableAds();
    expectQuery('/api.php', q('free.disable_ads'));
    await t.getMessages();
    expectQuery('/apiapp.php', q('push.getall', {'type': 'MESSAGE'}));
    await t.readMessage(9);
    expectQuery('/apiapp.php', q('push.setreaded', {'push_id': '9'}));
    await t.openContactsAd(orderId: 8);
    expectQuery('/apiapp.php', q('order.opencontacts', {'order_id': '8'}));
    await t.getTariff();
    expectQuery('/apiapp.php', q('tariff'));
    await t.sendDeviceToken(deviceToken: 'fcm');
    expectQuery('/apiapp.php', q('send_devicetoken', {'device_token': 'fcm'}));
    await t.getAdBanner();
    expectQuery('/apiapp.php', q('order.list'));
  });

  test('traider: searchBids trims and skips empty search', () async {
    await api.traider.searchBids(search: '  пшениця ', limit: 20, offset: 0);
    expectQuery(
        '/api.php',
        q('auth.bids.search',
            {'search': 'пшениця', 'limit': '20', 'offset': '0'}));
    await api.traider.searchBids(search: '   ', limit: 20);
    expectQuery('/api.php', q('auth.bids.search', {'limit': '20'}));
  });

  test('traider: body endpoints', () async {
    await api.traider.orderAnalysis(orderId: 5);
    expectBody('/api.php', {
      'method': 'uagro.order.analysis',
      'key': 'tok',
      'lang': 'uk',
      'order_id': '5'
    });
    await api.traider.openBidContact(orderId: 6);
    expectBody('/api.php', {
      'method': 'uagro.order.contacts',
      'key': 'tok',
      'lang': 'uk',
      'order_id': '6'
    });
  });

  test('my price goes through body transport', () async {
    final res = await api.myPrice.matchAck(11);
    expect(res.ok, isTrue);
    expectBody('/api.php', {
      'method': 'my_price.match.ack',
      'key': 'tok',
      'lang': 'uk',
      'match_id': '11'
    });
  });

  test('readMessage tolerates a non-JSON body', () async {
    Api.client = ApiClient(
      httpClient: MockClient((_) async => http.Response('OK', 200)),
      baseUrl: () => 'https://uagro.trade/',
      token: () => 'tok',
      language: () => 'uk',
    );
    final answer = await api.traider.readMessage(1);
    expect(answer.code, 200);
  });
}
