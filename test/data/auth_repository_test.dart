import 'package:agro/data/repositories/auth_repository.dart';
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
      token: () => '',
      language: () => 'uk',
    );
  }

  final repo = AuthRepository();

  group('requestCode', () {
    test('true when the server sent the SMS', () async {
      serve('{"status":true}');

      expect(await repo.requestCode('+380501112233'), isTrue);
      expect(last.url.queryParameters['method'], 'auth');
    });

    test('false when the number is not registered', () async {
      serve('{"status":false,"message":"not found"}');

      expect(await repo.requestCode('+380501112233'), isFalse);
    });

    test('reads JSON status even on non-200 (legacy behaviour)', () async {
      serve('{"status":false}', 404);

      expect(await repo.requestCode('+380501112233'), isFalse);
    });

    test('non-JSON body throws', () async {
      serve('<html>502</html>', 502);

      await expectLater(
          repo.requestCode('+380501112233'), throwsA(isA<ApiException>()));
    });
  });

  group('confirmCode', () {
    test('success returns user json and token', () async {
      serve('{"status":true,"payload":{"key":"T0K",'
          '"user":{"id":"9","name":"Іван","role":"distrib"}}}');

      final result = await repo.confirmCode('1234');

      expect(result.isSuccess, isTrue);
      expect(result.token, 'T0K');
      expect(result.user!['name'], 'Іван');
      expect(result.errorMessage, isNull);
    });

    test('wrong code returns the server message', () async {
      serve('{"status":false,"message":"Невірний код"}');

      final result = await repo.confirmCode('0000');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'Невірний код');
      expect(result.token, isNull);
    });

    test('success without token or user is a bad response', () async {
      serve('{"status":true,"payload":{}}');

      await expectLater(
          repo.confirmCode('1234'),
          throwsA(isA<ApiException>()
              .having((e) => e.kind, 'kind', ApiErrorKind.badResponse)));
    });
  });

  group('loginWithQr', () {
    test('true on 200', () async {
      serve('{"status":"+"}');

      expect(await repo.loginWithQr('s3'), isTrue);
      expect(last.url.queryParameters['method'], 'qr_login');
    });

    test('false on non-200', () async {
      serve('{"status":"-"}', 403);

      expect(await repo.loginWithQr('s3'), isFalse);
    });
  });
}
