import 'package:agro/model/my_price/my_price_parse.dart';

class MyPriceResult<T> {
  final bool ok;
  final T? data;
  final String? errorCode;
  final String? message;
  final Map<String, String> fields;
  final dynamic raw;

  const MyPriceResult({
    required this.ok,
    this.data,
    this.errorCode,
    this.message,
    this.fields = const {},
    this.raw,
  });

  factory MyPriceResult.fromJson(
    dynamic json, {
    T Function(dynamic data)? parse,
  }) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    final ok = parseMyPriceBool(map['ok']);
    final dataRaw = map['data'];
    T? data;
    if (ok && parse != null) {
      data = parse(dataRaw);
    }

    final fieldsRaw = parseMyPriceMap(map['fields']);
    final fields = <String, String>{};
    if (fieldsRaw != null) {
      fieldsRaw.forEach((key, value) {
        fields[key] = value?.toString() ?? '';
      });
    }

    return MyPriceResult<T>(
      ok: ok,
      data: data,
      errorCode: parseMyPriceString(map['error_code']),
      message: parseMyPriceString(map['message']),
      fields: fields,
      raw: json,
    );
  }

  String fallbackMessage(String generic) =>
      (message != null && message!.trim().isNotEmpty) ? message! : generic;
}
