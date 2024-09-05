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

    DateFormat format = DateFormat('dd.MM.yyyy');
    balanceEnd =
        json['balance_end'] != null ? format.parse(json['balance_end']) : null;
  }
}

extension TariffX on Tariff {
  bool get isPremium =>
      tafiffId == 10 && balanceEnd?.isAfter(DateTime.now()) == true;
  bool get isVip => vip == "Y" && balanceEnd?.isAfter(DateTime.now()) == true;
  bool get isBeslim =>
      tafiffId == 8 && balanceEnd?.isBefore(DateTime.now()) == true;
  bool get isFree =>
      tafiffId == 0 && balanceEnd?.isBefore(DateTime.now()) == true;
}
