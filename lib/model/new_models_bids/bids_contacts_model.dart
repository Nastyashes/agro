import 'package:agro/model/my_price/my_price_parse.dart';

class BidContacts {
  final String? company;
  final String? name;
  final String? phone;
  final String? email;
  final String? addr;
  final String? region;
  final String? district;
  final String? city;
  final String? maps;

  BidContacts({
    this.company,
    this.name,
    this.phone,
    this.email,
    this.addr,
    this.region,
    this.district,
    this.city,
    this.maps,
  });

  factory BidContacts.fromJson(Map<String, dynamic> json) => BidContacts(
        company: parseMyPriceString(json['company']),
        name: parseMyPriceString(json['name']),
        phone: parseMyPriceString(json['phone']),
        email: parseMyPriceString(json['email']),
        addr: parseMyPriceString(json['addr']),
        region: parseMyPriceString(json['region']),
        district: parseMyPriceString(json['district']),
        city: parseMyPriceString(json['city']),
        maps: parseMyPriceString(json['maps']),
      );
}
