import 'dart:async';

import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Extracts `name -> value` pairs from a multipart/form-data body.
Map<String, String> multipartFields(http.Request request) {
  final fields = <String, String>{};
  final re = RegExp(r'name="([^"]+)"\r\n\r\n(.*?)\r\n--', dotAll: true);
  for (final m in re.allMatches(request.body)) {
    fields[m.group(1)!] = m.group(2)!;
  }
  return fields;
}

void main() {
  late http.Request captured;
  late int unauthorizedCalls;

  ApiClient clientFor(
    MockClientHandler handler, {
    String token = 'tok',
    Duration timeout = const Duration(seconds: 5),
  }) {
    unauthorizedCalls = 0;
    return ApiClient(
      httpClient: MockClient((request) {
        captured = request;
        return handler(request);
      }),
      baseUrl: () => 'https://uagro.trade/',
      token: () => token,
      language: () => 'uk',
      onUnauthorized: () => unauthorizedCalls++,
      timeout: timeout,
    );
  }

  http.Response ok(String body, [int status = 200]) =>
      http.Response.bytes(body.codeUnits, status,
          headers: {'content-type': 'application/json'});

  group('query transport (legacy apiapp.php style)', () {
    test('puts method, key, params and lang in the URL, in that order',
        () async {
      final client = clientFor((_) async => ok('{"status":"+"}'));

      await client.post('order.view', query: {'order_id': '7'});

      expect(captured.method, 'POST');
      expect(captured.url.path, '/apiapp.php');
      expect(captured.url.queryParametersAll.keys.toList(),
          ['method', 'key', 'order_id', 'lang']);
      expect(captured.url.queryParameters, {
        'method': 'order.view',
        'key': 'tok',
        'order_id': '7',
        'lang': 'uk',
      });
      expect(multipartFields(captured), isEmpty);
    });

    test('escapes param values instead of breaking the query', () async {
      final client = clientFor((_) async => ok('{}'));

      await client.post('order.list', query: {'search': 'a&b=c пшениця'});

      expect(captured.url.queryParameters['search'], 'a&b=c пшениця');
    });

    test('omits lang when withLang is false and uses the given endpoint',
        () async {
      final client = clientFor((_) async => ok('{}'));

      await client.post('checkout',
          endpoint: 'api.php', query: {'amount': '5'}, withLang: false);

      expect(captured.url.path, '/api.php');
      expect(captured.url.queryParameters.containsKey('lang'), isFalse);
    });

    test('sends an empty key when there is no session', () async {
      final client = clientFor((_) async => ok('{}'), token: '');

      await client.post('auth', query: {'phone': '380'});

      expect(captured.url.queryParameters['key'], '');
    });
  });

  group('body transport (api.php style)', () {
    test('puts method, key, lang and fields in the multipart body', () async {
      final client = clientFor((_) async => ok('{"ok":true}'));

      await client.post(
        'uagro.order.analysis',
        endpoint: 'api.php',
        transport: ApiTransport.body,
        fields: {'order_id': '9'},
      );

      expect(captured.url.query, isEmpty);
      expect(multipartFields(captured), {
        'method': 'uagro.order.analysis',
        'key': 'tok',
        'lang': 'uk',
        'order_id': '9',
      });
    });
  });

  group('response handling', () {
    test('returns status code and decoded JSON', () async {
      final client = clientFor((_) async => ok('{"balance":12}', 201));

      final res = await client.post('balance');

      expect(res.statusCode, 201);
      expect(res.data, {'balance': 12});
    });

    test('decodes UTF-8 bodies', () async {
      final client = clientFor((_) async => http.Response(
          '{"name":"Пшениця"}', 200,
          headers: {'content-type': 'application/json; charset=utf-8'}));

      final res = await client.post('order.view');

      expect(res.data, {'name': 'Пшениця'});
    });

    test('non-JSON body throws ApiException.badResponse with status', () async {
      final client =
          clientFor((_) async => http.Response('<html>502</html>', 502));

      await expectLater(
        client.post('order.view'),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.badResponse)
            .having((e) => e.statusCode, 'statusCode', 502)),
      );
    });

    test('slow server throws ApiException.timeout', () async {
      final client = clientFor(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        client.post('order.view'),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.timeout)),
      );
    });

    test('transport failure throws ApiException.network', () async {
      final client =
          clientFor((_) async => throw http.ClientException('offline'));

      await expectLater(
        client.post('order.view'),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.network)),
      );
    });
  });

  group('unauthorized', () {
    test('calls onUnauthorized once and still returns the response', () async {
      final client =
          clientFor((_) async => ok('{"message":"Unauthorized"}', 401));

      final res = await client.post('order.view');

      expect(unauthorizedCalls, 1);
      expect(res.data, {'message': 'Unauthorized'});
    });

    test('does not call onUnauthorized when handleUnauthorized is false',
        () async {
      final client =
          clientFor((_) async => ok('{"message":"Unauthorized"}', 401));

      await client.post('auth', handleUnauthorized: false);

      expect(unauthorizedCalls, 0);
    });

    test('ignores other messages and non-map bodies', () async {
      final client = clientFor((_) async => ok('[1,2]'));

      await client.post('order.view');

      expect(unauthorizedCalls, 0);
    });
  });
}
