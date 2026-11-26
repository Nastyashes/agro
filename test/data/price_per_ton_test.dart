import 'package:agro/model/my_price/my_price_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: only a positive, finite price with up to two decimals passes.
void main() {
  test('valid prices', () {
    expect(parsePricePerTon('9200'), 9200);
    expect(parsePricePerTon('9 200'), 9200);
    expect(parsePricePerTon('4000,5'), 4000.5);
    expect(parsePricePerTon('4000.55'), 4000.55);
    expect(parsePricePerTon('4000.0'), 4000);
  });

  test('invalid prices are null', () {
    for (final bad in [
      '',
      ' ',
      '0',
      '0.00',
      '-5',
      'NaN',
      'Infinity',
      '1e9',
      'abc',
      '1.234',
      '1,2,3',
      '20000000',
    ]) {
      expect(parsePricePerTon(bad), isNull, reason: bad);
    }
  });
}
