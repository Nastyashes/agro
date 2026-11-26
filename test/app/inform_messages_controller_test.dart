import 'dart:async';

import 'package:agro/app/inform_messages/inform_messages_controller.dart';
import 'package:agro/data/repositories/messages_repository.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Message msg(int id, {required bool read, required String date}) =>
    Message.fromJson({
      'id': '$id',
      'readed': read ? '1' : '0',
      'tender_id': null,
      'type': 'MESSAGE',
      'title': 't$id',
      'message': 'm$id',
      'created_human': date,
    });

class FakeMessagesRepository extends MessagesRepository {
  List<Message> next = [];
  Object? fetchError;
  Object? markError;
  Completer<void>? gate;
  int fetchCalls = 0;
  final List<int?> marked = [];

  @override
  Future<List<Message>> fetchAll() async {
    fetchCalls++;
    if (gate != null) await gate!.future;
    if (fetchError != null) throw fetchError!;
    return List.of(next);
  }

  @override
  Future<void> markRead(int? id) async {
    if (markError != null) throw markError!;
    marked.add(id);
  }
}

/// Contract: the controller owns the list as reactive state, publishes the
/// unread count, never needs a BuildContext, and reports failures as an
/// event the screen turns into a message.
void main() {
  setUpAll(() => Get.testMode = true);

  late FakeMessagesRepository repo;
  late List<int> published;
  late InformMessagesController controller;

  setUp(() {
    repo = FakeMessagesRepository();
    published = [];
    controller = InformMessagesController(
      repository: repo,
      onUnreadChanged: published.add,
    );
  });

  test('load sorts unread first, newest first, and publishes unread count',
      () async {
    repo.next = [
      msg(1, read: true, date: '03.11.2026 10:00'),
      msg(2, read: false, date: '01.11.2026 10:00'),
      msg(3, read: false, date: '02.11.2026 10:00'),
    ];

    await controller.loadMessages();

    expect(controller.sortedMessages.map((m) => m.id), [3, 2, 1]);
    expect(controller.unreadCount, 2);
    expect(published, [2]);
    expect(controller.failures.value, 0);
  });

  test('failure keeps the previous list and raises a failure event', () async {
    repo.next = [msg(1, read: false, date: '01.11.2026 10:00')];
    await controller.loadMessages();

    repo.fetchError = const ApiException(ApiErrorKind.network);
    await controller.loadMessages();

    expect(controller.messages.map((m) => m.id), [1]);
    expect(controller.failures.value, 1);
    // There is a list to show, so no error state.
    expect(controller.loadFailed.value, isFalse);
  });

  test('a failed first load is an error, not "no messages"', () async {
    repo.fetchError = const ApiException(ApiErrorKind.network);

    await controller.loadMessages();

    expect(controller.loadFailed.value, isTrue);
  });

  test('a second load while one is running is ignored', () async {
    repo.gate = Completer<void>();

    final first = controller.loadMessages();
    final second = controller.loadMessages();
    repo.gate!.complete();
    await Future.wait([first, second]);

    expect(repo.fetchCalls, 1);
  });

  test('reading a message marks it and reloads the list', () async {
    final message = msg(5, read: false, date: '01.11.2026 10:00');
    repo.next = [msg(5, read: true, date: '01.11.2026 10:00')];

    await controller.onReadMessage(message);

    expect(repo.marked, [5]);
    expect(repo.fetchCalls, 1);
    expect(controller.unreadCount, 0);
  });

  test('a failed read raises a failure event and does not reload', () async {
    repo.markError = const ApiException(ApiErrorKind.timeout);

    await controller
        .onReadMessage(msg(5, read: false, date: '01.11.2026 10:00'));

    expect(controller.failures.value, 1);
    expect(repo.fetchCalls, 0);
  });

  test('messages is reactive', () async {
    var notified = 0;
    final worker = ever(controller.messages, (_) => notified++);
    repo.next = [msg(1, read: false, date: '01.11.2026 10:00')];

    await controller.loadMessages();

    expect(notified, greaterThan(0));
    worker.dispose();
  });
}
