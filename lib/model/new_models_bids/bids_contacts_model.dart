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
        company: json['company'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        addr: json['addr'] as String?,
        region: json['region'] as String?,
        district: json['district'] as String?,
        city: json['city'] as String?,
        maps: json['maps'] as String?,
      );
}
