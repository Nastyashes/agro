import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_parse.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: My price answers parse from whatever JSON shape the backend
/// sends (numbers as strings, lists as id-keyed objects, nested refs);
/// money-related defaults are the safe ones.
void main() {
  group('parse helpers', () {
    test('int/double accept numbers and numeric strings only', () {
      expect(parseMyPriceInt('42'), 42);
      expect(parseMyPriceInt(' 7 '), 7);
      expect(parseMyPriceInt(3.9), 3);
      expect(parseMyPriceInt('null'), isNull);
      expect(parseMyPriceInt(''), isNull);
      expect(parseMyPriceInt('x'), isNull);
      expect(parseMyPriceInt(true), isNull);
      expect(parseMyPriceDouble('7200.5'), 7200.5);
      expect(parseMyPriceDouble(10), 10.0);
      expect(parseMyPriceDouble('null'), isNull);
    });

    test('bool is true only for true, 1, "1", "true"', () {
      for (final v in [true, 1, '1', 'true']) {
        expect(parseMyPriceBool(v), isTrue, reason: '$v');
      }
      for (final v in [false, 0, '0', 'false', 'yes', null, 2]) {
        expect(parseMyPriceBool(v), isFalse, reason: '$v');
      }
    });

    test('string: null and "null" are null', () {
      expect(parseMyPriceString(null), isNull);
      expect(parseMyPriceString('null'), isNull);
      expect(parseMyPriceString(5), '5');
    });

    test('timestamp: seconds, milliseconds or ISO date → seconds', () {
      expect(parseMyPriceTimestamp(1700000000), 1700000000);
      expect(parseMyPriceTimestamp(1700000000123), 1700000000);
      expect(parseMyPriceTimestamp('2026-11-01T00:00:00Z'),
          DateTime.utc(2026, 11, 1).millisecondsSinceEpoch ~/ 1000);
      expect(parseMyPriceTimestamp('soon'), isNull);
    });

    test('map list accepts a list or an id-keyed object', () {
      expect(
          parseMyPriceMapList([
            {'id': 1},
            'x',
            null
          ]).length,
          1);
      expect(
          parseMyPriceMapList({
            '5': {'id': 5},
            '6': {'id': 6}
          }).map((m) => m['id']),
          [5, 6]);
      expect(parseMyPriceMapList('nope'), isEmpty);
    });

    test('nested id/name read from objects or plain values', () {
      expect(parseMyPriceNestedId({'id': '3'}), 3);
      expect(parseMyPriceNestedId({'value': 4}), 4);
      expect(parseMyPriceNestedId('5'), 5);
      expect(parseMyPriceNestedName({'title': 'Київська'}), 'Київська');
      expect(parseMyPriceNestedName(12), isNull);
      expect(parseMyPriceNestedName('Пшениця'), 'Пшениця');
    });
  });

  group('MyPriceResult.fromJson', () {
    test('ok answer parses data', () {
      final r = MyPriceResult<int>.fromJson(
        const {'ok': 1, 'data': '9'},
        parse: (d) => parseMyPriceInt(d)!,
      );
      expect(r.ok, isTrue);
      expect(r.data, 9);
    });

    test('error answer keeps code, message and field errors; no data', () {
      final r = MyPriceResult<int>.fromJson(
        const {
          'ok': false,
          'data': 1,
          'error_code': 'insufficient_funds',
          'message': 'Недостатньо коштів',
          'fields': {'price_per_ton': 'too_low', 'n': 5, 'z': null},
        },
        parse: (_) => throw StateError('must not parse on error'),
      );
      expect(r.ok, isFalse);
      expect(r.data, isNull);
      expect(r.errorCode, 'insufficient_funds');
      expect(r.fields, {'price_per_ton': 'too_low', 'n': '5', 'z': ''});
      expect(r.fallbackMessage('generic'), 'Недостатньо коштів');
    });

    test('non-object answer is a failure with the generic message', () {
      final r = MyPriceResult<int>.fromJson('<html>');
      expect(r.ok, isFalse);
      expect(r.fallbackMessage('generic'), 'generic');
      expect(
          MyPriceResult<int>.fromJson(const {'ok': 0, 'message': ' '})
              .fallbackMessage('generic'),
          'generic');
    });
  });

  group('MyPriceOverview.fromJson', () {
    test('settings, dictionaries and combinations', () {
      final o = MyPriceOverview.fromJson(const {
        'settings': {'activation_price': '300', 'active_days': '30'},
        'regions': {
          '1': {'id': 1, 'name': 'Київська'}
        },
        'products': [
          {'id': '2', 'name': 'Пшениця', 'sphere_id': 15}
        ],
        'payment_types': [
          {'id': 3, 'name': 'Готівка'}
        ],
        'team': [
          {'id': 4, 'phone': '+380', 'name': 'Оля'}
        ],
        'combinations': [
          {
            'id': 10,
            'slot_id': 100,
            'status': 'active',
            'region': {'id': 1},
            'product_id': '2',
            'payment_id': 3,
            'price_per_ton': '7200',
            'active_until': 1700000000,
          }
        ],
      });

      expect(o.settings.activationPrice, 300);
      expect(o.settings.activeDays, 30);
      final c = o.combinations.single;
      expect(c.isActive, isTrue);
      expect(c.regionId, 1);
      expect(c.productId, 2);
      expect(c.paymentType, 3);
      expect(c.pricePerTon, 7200);
      expect(c.endsAt, 1700000000);
      expect(o.regionName(c), 'Київська');
      expect(o.productName(c), 'Пшениця');
      expect(o.paymentName(c), 'Готівка');
      expect(o.team.single.phone, '+380');
      expect(o.nameOf(o.regions, 99), '—');
    });

    test('a reservation takes its slot data and estimates its dates', () {
      final o = MyPriceOverview.fromJson(const {
        'settings': {'active_days': 30},
        'slots': [
          {
            'id': 100,
            'region_id': 1,
            'product_id': 2,
            'payment_type': 3,
            'ends_at': 1700000000,
          }
        ],
        'reservations': [
          {'id': 11, 'slot_id': 100, 'status': 'queued', 'queue_position': 2}
        ],
      });

      final r = o.reservations.single;
      expect(r.isQueued, isTrue);
      expect(r.regionId, 1);
      expect(r.productId, 2);
      expect(r.paymentType, 3);
      expect(r.queuePosition, 2);
      expect(r.startsAt, 1700000000, reason: 'starts when the slot ends');
      expect(r.endsAt, 1700000000 + 30 * 24 * 60 * 60);
    });

    test('empty or broken answer is an empty overview', () {
      final o = MyPriceOverview.fromJson(null);
      expect(o.combinations, isEmpty);
      expect(o.reservations, isEmpty);
      expect(o.regions, isEmpty);
    });
  });

  group('quotes and results', () {
    test('activation quote', () {
      final q = MyPriceQuote.fromJson(const {
        'action': 'reserve',
        'slot': {'id': '5', 'queue_length': 2},
        'pricing': {
          'base_amount': '300',
          'discount_percent': 10,
          'charged_amount': '270'
        },
        'promo': {'code': 'AGRO', 'discount_percent': '10'},
        'team_member': {'id': 4, 'phone': '+380'},
      });
      expect(q.isReserve, isTrue);
      expect(q.slot.id, 5);
      expect(q.pricing.chargedAmount, 270);
      expect(q.promoCode, 'AGRO');
      expect(q.teamUserId, 4);
      expect(MyPriceQuote.fromJson(null).action, 'activate');
    });

    test('activate result keeps the idempotent flag and new balance', () {
      final r = MyPriceActivateResult.fromJson(const {
        'id': 1,
        'charged_amount': '270',
        'wallet_balance': '30',
        'idempotent': 1,
      });
      expect(r.chargedAmount, 270);
      expect(r.walletBalance, 30);
      expect(r.idempotent, isTrue);
    });

    test('deal quote: confirmation and non-refundable default to true', () {
      final q = MyPriceDealQuote.fromJson(const {
        'order_id': '7',
        'amount': '50',
        'balance': '40',
        'balance_after': '-10',
      });
      expect(q.requiresConfirmation, isTrue);
      expect(q.nonRefundable, isTrue);
      expect(q.hasEnoughBalance, isFalse);

      final explicit = MyPriceDealQuote.fromJson(const {
        'balance_after': 0,
        'requires_confirmation': 0,
        'non_refundable': '0',
      });
      expect(explicit.requiresConfirmation, isFalse);
      expect(explicit.nonRefundable, isFalse);
      expect(explicit.hasEnoughBalance, isTrue);
    });

    test('deals page', () {
      final p = MyPriceDealsPage.fromJson(const {
        'items': [
          {
            'deal_id': '1',
            'order_id': 7,
            'charged_amount': '50',
            'matched': true,
            'proposed_price': '7100',
          }
        ],
        'limit': '20',
      });
      expect(p.items.single.dealId, 1);
      expect(p.items.single.chargedAmount, 50);
      expect(p.items.single.matched, isTrue);
      expect(p.limit, 20);
      expect(p.offset, 0);
      expect(MyPriceDealsPage.fromJson(null).items, isEmpty);
    });
  });

  test('activate params: promo is trimmed, a blank one is not sent', () {
    const base = MyPriceActivateParams(
      regionId: 1,
      productId: 2,
      paymentType: 3,
      pricePerTon: 7200.5,
      teamUserId: 4,
    );
    expect(base.toFormData(), {
      'region_id': '1',
      'product_id': '2',
      'payment_type': '3',
      'price_per_ton': '7200.5',
      'team_user_id': '4',
    });
    const blank = MyPriceActivateParams(
      regionId: 1,
      productId: 2,
      paymentType: 3,
      pricePerTon: 1,
      teamUserId: 4,
      promoCode: '  ',
    );
    expect(blank.toFormData().containsKey('promo_code'), isFalse);
    const promo = MyPriceActivateParams(
      regionId: 1,
      productId: 2,
      paymentType: 3,
      pricePerTon: 1,
      teamUserId: 4,
      promoCode: ' AGRO ',
    );
    expect(promo.toFormData()['promo_code'], 'AGRO');
  });
}
