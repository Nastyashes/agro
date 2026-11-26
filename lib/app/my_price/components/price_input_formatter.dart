import 'package:flutter/services.dart';

final _partialPrice = RegExp(r'^(\d{1,8}([.,]\d{0,2})?)?$');

/// Keeps the price-per-ton field on the way to a value [parsePricePerTon]
/// accepts: digits, one ',' or '.', up to 2 decimals, up to 8 integer
/// digits. An edit that would break this is ignored (BUG-008/009).
final TextInputFormatter pricePerTonInputFormatter =
    TextInputFormatter.withFunction(
  (oldValue, newValue) =>
      _partialPrice.hasMatch(newValue.text) ? newValue : oldValue,
);
