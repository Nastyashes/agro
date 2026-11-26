import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: a bid from the backend parses whatever JSON type a field comes
/// in (PHP sends numbers as strings and back); one odd field never drops
/// the whole list.
void main() {
  group('BidItem.fromJson', () {
    test('numbers as strings, ints or doubles', () {
      final bid = BidItem.fromJson(const {
        'order_id': '184522',
        'amount': 500.0,
        'year': 2025,
        'price_nal': '7200.5',
        'price_bzn': 7000,
        'contact_price': '25',
        'opened': '0',
      });

      expect(bid.orderId, 184522);
      expect(bid.amount, 500);
      expect(bid.year, 2025);
      expect(bid.priceNal, 7200.5);
      expect(bid.priceBzn, 7000.0);
      expect(bid.contactPrice, 25);
      expect(bid.isOpened, isFalse);
    });

    test('garbage numbers become null, not an exception', () {
      final bid = BidItem.fromJson(const {
        'order_id': 'abc',
        'amount': '',
        'price_nal': 'n/a',
        'opened': null,
      });

      expect(bid.orderId, isNull);
      expect(bid.amount, isNull);
      expect(bid.priceNal, isNull);
    });

    test('text fields that come as numbers are kept as text', () {
      final bid = BidItem.fromJson(const {
        'order_id': 1,
        'region_name': 12,
        'product_title': 2025,
        'fermer_phone': 380671234567,
        'delivery_type': 1,
        'contacts': {'phone': 380671234567, 'name': 'Іван', 'city': null},
      });

      expect(bid.regionName, '12');
      expect(bid.productTitle, '2025');
      expect(bid.fermerPhone, '380671234567');
      expect(bid.deliveryType, '1');
      expect(bid.contacts?.phone, '380671234567');
      expect(bid.contacts?.name, 'Іван');
      expect(bid.contacts?.city, isNull);
    });

    test('contacts: an object opens the bid, anything else is ignored', () {
      final opened = BidItem.fromJson(const {
        'opened': 0,
        'contacts': {'phone': '+380671234567'},
      });
      expect(opened.isOpened, isTrue);
      expect(opened.phone, '+380671234567');

      final none = BidItem.fromJson(const {'contacts': false});
      expect(none.contacts, isNull);
      expect(none.isOpened, isFalse);
    });

    test('phone falls back from contacts to opened_phon to fermer_phone', () {
      expect(BidItem.fromJson(const {'opened_phon': '1'}).phone, '1');
      expect(BidItem.fromJson(const {'fermer_phone': '2'}).phone, '2');
      expect(BidItem.fromJson(const {}).phone, isNull);
    });

    test('my_price meta parses; missing meta is the neutral default', () {
      final bid = BidItem.fromJson(const {
        'my_price': {
          'matched': '1',
          'match_id': '9',
          'tone': 'agreed',
          'proposed_price': '7100',
          'can_acknowledge': 1,
        },
      });
      expect(bid.myPrice!.matched, isTrue);
      expect(bid.myPrice!.matchId, 9);
      expect(bid.myPrice!.isAgreed, isTrue);
      expect(bid.myPrice!.proposedPrice, 7100);
      expect(bid.myPrice!.canAcknowledge, isTrue);

      final plain = BidItem.fromJson(const {});
      expect(plain.myPrice!.matched, isFalse);
      expect(plain.myPrice!.tone, 'neutral');
    });

    test('created is a unix time in seconds', () {
      final bid = BidItem.fromJson(const {'created': 1700000000});
      expect(bid.createdAt,
          DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000));
    });
  });

  group('BidsResponse.fromJson', () {
    test('both lists; missing lists are empty', () {
      final res = BidsResponse.fromJson(const {
        'bids': [
          {'order_id': 1},
          {'order_id': 2},
        ],
        'bids_fresh': [
          {'order_id': 3},
        ],
      });
      expect(res.bids.map((b) => b.orderId), [1, 2]);
      expect(res.bidsFresh.single.orderId, 3);
      expect(res.hasFresh, isTrue);

      final empty = BidsResponse.fromJson(const {});
      expect(empty.bids, isEmpty);
      expect(empty.hasFresh, isFalse);
    });

    test('a non-object entry is skipped, the rest of the page stays', () {
      final res = BidsResponse.fromJson(const {
        'bids': [
          {'order_id': 1},
          null,
          'oops',
          {'order_id': 2},
        ],
      });
      expect(res.bids.map((b) => b.orderId), [1, 2]);
    });
  });

  group('BidItem.fromOrderView', () {
    test('reads the payload wrapper and keeps an outer my_price', () {
      final bid = BidItem.fromOrderView(const {
        'payload': {'order_id': '7', 'product_title': 'Кукурудза'},
        'my_price': {'matched': true, 'tone': 'declined'},
      });
      expect(bid?.orderId, 7);
      expect(bid?.productTitle, 'Кукурудза');
      expect(bid!.myPrice!.isDeclined, isTrue);
    });

    test('a bare object works too', () {
      expect(BidItem.fromOrderView(const {'id': 5})?.id, 5);
    });

    test('no bid in the answer is null', () {
      expect(BidItem.fromOrderView(null), isNull);
      expect(BidItem.fromOrderView('error'), isNull);
      expect(BidItem.fromOrderView(const {'ok': false}), isNull);
    });
  });
}
