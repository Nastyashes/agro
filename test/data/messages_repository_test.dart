import 'package:agro/data/repositories/messages_repository.dart';
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
        return http.Response(body, status);
      }),
      baseUrl: () => 'https://uagro.trade/',
      token: () => 'tok',
      language: () => 'uk',
    );
  }

  void serveUtf8(String body, [int status = 200]) {
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

  const msg1 = '{"id":"1","readed":"0","tender_id":"5","type":"MESSAGE",'
      '"title":"Нова заявка","message":"m1","created_human":"01.11.2026 10:00"}';
  const msg2 = '{"id":"2","readed":"1","tender_id":null,"type":"MESSAGE",'
      '"title":"t2","message":"m2","created_human":"02.11.2026 11:30"}';

  final repo = MessagesRepository();

  group('fetchAll', () {
    test('parses messages from payload', () async {
      serveUtf8('{"payload":[$msg1,$msg2]}');

      final messages = await repo.fetchAll();

      expect(last.url.queryParameters['method'], 'push.getall');
      expect(messages.map((m) => m.id), [1, 2]);
      expect(messages.first.title, 'Нова заявка');
      expect(messages.map((m) => m.isRead), [false, true]);
    });

    test('accepts a top-level list', () async {
      serveUtf8('[$msg2]');

      expect((await repo.fetchAll()).single.id, 2);
    });

    test('skips malformed items instead of failing the whole list', () async {
      serveUtf8('{"payload":[$msg1,{"id":"x"},"junk"]}');

      expect((await repo.fetchAll()).map((m) => m.id), [1]);
    });

    test('empty or missing payload is an empty list', () async {
      serve('{"status":"+"}');

      expect(await repo.fetchAll(), isEmpty);
    });

    test('non-200 throws ApiException with the status code', () async {
      serve('{"payload":[]}', 500);

      await expectLater(
        repo.fetchAll(),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });

  group('unreadCount', () {
    test('counts unread messages only', () async {
      serveUtf8('{"payload":[$msg1,$msg2]}');

      expect(await repo.unreadCount(), 1);
    });
  });

  group('markRead', () {
    test('sends push.setreaded with the id', () async {
      serve('OK');

      await repo.markRead(7);

      expect(last.url.queryParameters['method'], 'push.setreaded');
      expect(last.url.queryParameters['push_id'], '7');
    });

    test('non-200 does not throw (caller reloads the list)', () async {
      serve('{}', 500);

      await expectLater(repo.markRead(7), completes);
    });

    test('network failure still throws', () async {
      Api.client = ApiClient(
        httpClient: MockClient((_) async => throw http.ClientException('off')),
        baseUrl: () => 'https://uagro.trade/',
        token: () => 'tok',
        language: () => 'uk',
      );

      await expectLater(repo.markRead(7), throwsA(isA<ApiException>()));
    });
  });
}
