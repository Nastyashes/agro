import 'package:agro/app/my_price/components/price_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract: the price field only ever holds something on the way to a
/// valid price (digits, one ',' or '.', at most 2 decimals, at most 8
/// integer digits), so the user never types a value that is then rejected.
void main() {
  String type(String sequence) {
    var value = TextEditingValue.empty;
    for (final ch in sequence.split('')) {
      final text = value.text + ch;
      value = pricePerTonInputFormatter.formatEditUpdate(
        value,
        TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length)),
      );
    }
    return value.text;
  }

  test('digits and one decimal separator with up to 2 decimals', () {
    expect(type('7200'), '7200');
    expect(type('7200,5'), '7200,5');
    expect(type('7200.55'), '7200.55');
  });

  test('a third decimal, a second separator or letters are ignored', () {
    expect(type('1,234'), '1,23');
    expect(type('1,2,3'), '1,23');
    expect(type('1.,5'), '1.5');
    expect(type('12a3'), '123');
    expect(type('-5'), '5');
  });

  test('separator first and more than 8 integer digits are ignored', () {
    expect(type(',5'), '5');
    expect(type('123456789'), '12345678');
  });

  test('deleting is always allowed', () {
    final v = pricePerTonInputFormatter.formatEditUpdate(
      const TextEditingValue(text: '1,23'),
      const TextEditingValue(text: '1,2'),
    );
    expect(v.text, '1,2');
  });
}
