import 'package:intl/intl.dart';

class Tariff {
  String? vip, premium, balanceName;
  int? balanceContacts,
      balanceSms,
      balanceContactsDayTotal,
      balanceContactsDayOsttk,
      tafiffId,
      orderCount;
  DateTime? balanceEnd;

  var isByPiece;

  Tariff.fromJson(Map<String, dynamic> json) {
    vip = json['is_vip'];
    premium = json['is_premium'];
    balanceName = json['balance_name'];
    orderCount = json['orders_count'];

    balanceContacts = int.tryParse(json['balance_contacts'].toString());
    balanceSms = int.tryParse(json['balance_sms'].toString());
    balanceContactsDayTotal =
        int.tryParse(json['balance_contacts_day_total'].toString());
    balanceContactsDayOsttk =
        int.tryParse(json['balance_contacts_day_osttk'].toString());
    tafiffId = int.tryParse(json['tariff_id'].toString());

    balanceEnd = parseBalanceEnd(json['balance_end']);
  }

  /// `dd.MM.yyyy` from the API, ISO as a fallback. An unexpected format is
  /// null instead of throwing, which used to drop the whole tariff and show
  /// a paying user as Free (BUG-012).
  static DateTime? parseBalanceEnd(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    try {
      return DateFormat('dd.MM.yyyy').parseStrict(text);
    } on FormatException {
      return DateTime.tryParse(text);
    }
  }
}

extension TariffX on Tariff {
  bool get isVip =>
      vip == "Y" && (balanceEnd?.isAfter(DateTime.now()) ?? false);

  bool get isPremium =>
      premium == "Y" && (balanceEnd?.isAfter(DateTime.now()) ?? false);

  bool get isFree => !isVip && !isPremium;
}
