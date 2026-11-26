import 'package:agro/model/tariff/tariff.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: the tariff end date never breaks parsing (BUG-012).
void main() {
  test('dd.MM.yyyy from the API', () {
    expect(Tariff.parseBalanceEnd('25.05.2027'), DateTime(2027, 5, 25));
  });

  test('ISO fallback', () {
    expect(Tariff.parseBalanceEnd('2027-05-25'), DateTime(2027, 5, 25));
  });

  test('missing or unknown formats are null, not an exception', () {
    expect(Tariff.parseBalanceEnd(null), isNull);
    expect(Tariff.parseBalanceEnd(''), isNull);
    expect(Tariff.parseBalanceEnd('25/05/2027'), isNull);
    expect(() => Tariff.fromJson(const {'is_vip': 'Y', 'balance_end': 'soon'}),
        returnsNormally);
  });
}
