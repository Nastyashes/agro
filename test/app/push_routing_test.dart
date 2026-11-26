import 'package:agro/controllers/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: Match pushes (new and old field) and legacy TENDER pushes open
/// their bid; anything else opens nothing.
void main() {
  test('new uagro_message_type MATCH', () {
    expect(
        bidIdFromPush({'uagro_message_type': 'MATCH', 'tender_id': '42'}), 42);
  });

  test('previous message_type MATCH', () {
    expect(bidIdFromPush({'message_type': 'MATCH', 'tender_id': 7}), 7);
  });

  test('legacy TENDER', () {
    expect(bidIdFromPush({'messagetype': 'TENDER', 'tender_id': '5'}), 5);
  });

  test('other or broken pushes open nothing', () {
    expect(bidIdFromPush({'uagro_message_type': 'NEWS', 'tender_id': '5'}),
        isNull);
    expect(bidIdFromPush({'uagro_message_type': 'MATCH'}), isNull);
    expect(bidIdFromPush('not a map'), isNull);
  });
}
