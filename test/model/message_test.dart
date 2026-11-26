import 'package:agro/model/message/message.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: a message with missing text fields shows nothing there,
/// never the word "null"; a broken item is skipped, not the whole list.
void main() {
  test('missing title, text and type are null, not "null"', () {
    final m = Message.fromJson(const {
      'id': 1,
      'readed': 0,
      'title': null,
      'created_human': '01.11.2026 10:00',
    });
    expect(m.title, isNull);
    expect(m.message, isNull);
    expect(m.type, isNull);
    expect(m.tenderId, isNull);
    expect(m.isRead, isFalse);
    expect(m.createdAt, DateTime(2026, 11, 1, 10));
  });

  test('a broken item is skipped, the rest stay', () {
    final list = parseMessagesPayload({
      'payload': [
        {'id': 1, 'created_human': 'yesterday'},
        'oops',
        {'id': 2, 'readed': '1', 'created_human': '02.11.2026 11:30'},
      ],
    });
    expect(list.map((m) => m.id), [2]);
    expect(list.single.isRead, isTrue);
  });

  test('anything but a list or a payload list is empty', () {
    expect(parseMessagesPayload(null), isEmpty);
    expect(parseMessagesPayload({'payload': 'x'}), isEmpty);
  });
}
