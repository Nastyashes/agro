import 'package:agro/data/repositories/farmer_orders_repository.dart';
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

  final repo = FarmerOrdersRepository();

  group('reviews', () {
    test('parses payload items', () async {
      serve('{"payload":{"items":[{"trader_id":3,"rating":5,'
          '"date":"01.11.2026","comment":"Добре"}]}}');

      final reviews = await repo.reviews(9);

      expect(method(), 'order.reviews');
      expect(last.url.queryParameters['itemid'], '9');
      expect(reviews.single.comment, 'Добре');
    });

    test('no items is an empty list', () async {
      serve('{"payload":{}}');
      expect(await repo.reviews(9), isEmpty);
    });
  });

  group('sendReview', () {
    test('true when status is true (bool or string)', () async {
      serve('{"status":true}');
      expect(
          await repo.sendReview(orderId: 9, rating: 5, comment: 'ok'), isTrue);
      expect(method(), 'order.comment');

      serve('{"status":"true"}');
      expect(
          await repo.sendReview(orderId: 9, rating: 5, comment: 'ok'), isTrue);
    });

    test('false otherwise', () async {
      serve('{"status":false}');
      expect(
          await repo.sendReview(orderId: 9, rating: 5, comment: 'ok'), isFalse);
    });
  });

  group('closeOrder', () {
    test('true when status is true', () async {
      serve('{"status":true}');
      expect(await repo.closeOrder(9), isTrue);
      expect(method(), 'fermer.closeorder');
    });

    test('false otherwise', () async {
      serve('{"status":"-"}');
      expect(await repo.closeOrder(9), isFalse);
    });
  });
}
