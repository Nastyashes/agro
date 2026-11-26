int? parseMyPriceInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;
    return int.tryParse(trimmed);
  }
  return null;
}

double? parseMyPriceDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;
    return double.tryParse(trimmed);
  }
  return null;
}

bool parseMyPriceBool(dynamic value) {
  if (value == true || value == 1 || value == '1' || value == 'true') {
    return true;
  }
  return false;
}

DateTime? parseMyPriceUnix(dynamic value) {
  final seconds = parseMyPriceInt(value);
  if (seconds == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
}

String? parseMyPriceString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text == 'null') return null;
  return text;
}

Map<String, dynamic>? parseMyPriceMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

List<Map<String, dynamic>> parseMyPriceMapList(dynamic value) {
  if (value is Map) {
    return value.values
        .map(parseMyPriceMap)
        .whereType<Map<String, dynamic>>()
        .toList();
  }
  if (value is! List) return const [];
  return value.map(parseMyPriceMap).whereType<Map<String, dynamic>>().toList();
}

int? parseMyPriceNestedId(dynamic value) {
  if (value is Map) {
    return parseMyPriceInt(value['id'] ?? value['value']);
  }
  return parseMyPriceInt(value);
}

String? parseMyPriceNestedName(dynamic value) {
  if (value is Map) {
    return parseMyPriceString(
      value['name'] ?? value['title'] ?? value['label'] ?? value['text'],
    );
  }
  if (value is num) return null;
  return parseMyPriceString(value);
}

int? parseMyPriceTimestamp(dynamic value) {
  final asInt = parseMyPriceInt(value);
  if (asInt != null) {
    if (asInt > 9999999999) {
      return asInt ~/ 1000;
    }
    return asInt;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return parsed.millisecondsSinceEpoch ~/ 1000;
    }
  }
  return null;
}
