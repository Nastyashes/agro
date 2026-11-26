import 'package:agro/model/message/created.dart';
import 'package:agro/model/my_price/my_price_order_meta.dart';
import 'package:agro/model/my_price/my_price_parse.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';

class BidItem extends Created {
  final int? id;
  final int? created;
  final int? userId;
  final int? orderId;
  final int? currencyId;
  final double? priceNal;
  final double? priceBzn;
  final double? price3f;
  final int? amountMin;
  final int? sphereId;
  final int? paymentType;
  final String? deliveryType;
  final int? regionId;
  final int? operatorId;
  final int? opened;
  final String? companyName;
  final int? asId;
  final int? processed;
  final String? productTitle;
  final String? alias;
  final int? ordPaymentType;
  final int? amount;
  final int? year;
  final int? orderCreated;

  final int? regionOid;
  final String? openedDate;
  final String? openedPhon;
  final int? openedUsid;
  final String? orderCreatedHum;
  final int? dayNumber;
  final String? dayLabel;
  final String? dayColor;
  final int? contactPrice;
  final String? regionName;

  // --- Нові поля ---
  final String? fermerCompany;
  final String? fermerName;
  final String? fermerPhone;
  final String? fermerEmail;
  final int? fermerRegionId;
  final BidContacts? contacts;
  final MyPriceOrderMeta? myPrice;

  BidItem({
    this.regionName,
    this.id,
    this.created,
    this.userId,
    this.orderId,
    this.currencyId,
    this.priceNal,
    this.priceBzn,
    this.price3f,
    this.amountMin,
    this.sphereId,
    this.paymentType,
    this.deliveryType,
    this.regionId,
    this.operatorId,
    this.opened,
    this.companyName,
    this.asId,
    this.processed,
    this.productTitle,
    this.alias,
    this.ordPaymentType,
    this.amount,
    this.orderCreated,
    this.year,
    this.regionOid,
    this.openedDate,
    this.openedPhon,
    this.openedUsid,
    this.orderCreatedHum,
    this.dayNumber,
    this.dayLabel,
    this.dayColor,
    this.contactPrice,
    this.fermerCompany,
    this.fermerName,
    this.fermerPhone,
    this.fermerEmail,
    this.fermerRegionId,
    this.contacts,
    this.myPrice,
  });

  BidItem copyWith({
    int? opened,
    String? openedPhon,
    String? openedDate,
    int? openedUsid,
    String? fermerCompany,
    String? fermerName,
    String? fermerPhone,
    String? fermerEmail,
    int? fermerRegionId,
    BidContacts? contacts,
    MyPriceOrderMeta? myPrice,
  }) {
    return BidItem(
      id: id,
      created: created,
      userId: userId,
      orderId: orderId,
      currencyId: currencyId,
      priceNal: priceNal,
      priceBzn: priceBzn,
      price3f: price3f,
      amountMin: amountMin,
      sphereId: sphereId,
      paymentType: paymentType,
      deliveryType: deliveryType,
      regionId: regionId,
      operatorId: operatorId,
      opened: opened ?? this.opened,
      companyName: companyName,
      asId: asId,
      processed: processed,
      productTitle: productTitle,
      alias: alias,
      ordPaymentType: ordPaymentType,
      amount: amount,
      year: year,
      orderCreated: orderCreated,
      regionOid: regionOid,
      openedDate: openedDate ?? this.openedDate,
      openedPhon: openedPhon ?? this.openedPhon,
      openedUsid: openedUsid ?? this.openedUsid,
      orderCreatedHum: orderCreatedHum,
      dayNumber: dayNumber,
      dayLabel: dayLabel,
      dayColor: dayColor,
      contactPrice: contactPrice,
      regionName: regionName,
      fermerCompany: fermerCompany ?? this.fermerCompany,
      fermerName: fermerName ?? this.fermerName,
      fermerPhone: fermerPhone ?? this.fermerPhone,
      fermerEmail: fermerEmail ?? this.fermerEmail,
      fermerRegionId: fermerRegionId ?? this.fermerRegionId,
      contacts: contacts ?? this.contacts,
      myPrice: myPrice ?? this.myPrice,
    );
  }

  factory BidItem.fromJson(
    Map<String, dynamic> json, {
    Map<String, int>? regions,
  }) {
    // region_name тепер приходить напряму з API
    final regionName = parseMyPriceString(json['region_name']);

    // contacts — null або об'єкт
    final contactsRaw = parseMyPriceMap(json['contacts']);
    final contacts =
        contactsRaw == null ? null : BidContacts.fromJson(contactsRaw);

    final myPriceRaw = parseMyPriceMap(json['my_price']);

    return BidItem(
      regionName: regionName,
      id: _parseInt(json['id']),
      created: _parseInt(json['created']),
      userId: _parseInt(json['user_id']),
      orderId: _parseInt(json['order_id']),
      currencyId: _parseInt(json['currency_id']),
      priceNal: _parseDouble(json['price_nal']),
      priceBzn: _parseDouble(json['price_bzn']),
      price3f: _parseDouble(json['price_3f']),
      amountMin: _parseInt(json['amount_min']),
      sphereId: _parseInt(json['sphere_id']),
      paymentType: _parseInt(json['payment_type']),
      deliveryType: parseMyPriceString(json['delivery_type']),
      regionId: _parseInt(json['region_id']),
      operatorId: _parseInt(json['operator_id']),
      opened: _parseInt(json['opened']),
      companyName: parseMyPriceString(json['company_name']),
      asId: _parseInt(json['as_id']),
      processed: _parseInt(json['processed']),
      productTitle: parseMyPriceString(json['product_title']),
      alias: parseMyPriceString(json['alias']),
      ordPaymentType: _parseInt(json['ord_payment_type']),
      amount: _parseInt(json['amount']),
      orderCreated: _parseInt(json['order_created']),
      regionOid: _parseInt(json['region_oid']),
      openedDate: parseMyPriceString(json['opened_date']),
      openedPhon: parseMyPriceString(json['opened_phon']),
      openedUsid: _parseInt(json['opened_usid']),
      year: _parseInt(json['year']),
      orderCreatedHum: parseMyPriceString(json['order_created_hum']),
      dayNumber: _parseInt(json['day_number']),
      dayLabel: parseMyPriceString(json['day_label']),
      dayColor: parseMyPriceString(json['day_color']),
      contactPrice: _parseInt(json['contact_price']),
      fermerCompany: parseMyPriceString(json['fermer_company']),
      fermerName: parseMyPriceString(json['fermer_name']),
      fermerPhone: parseMyPriceString(json['fermer_phone']),
      fermerEmail: parseMyPriceString(json['fermer_email']),
      fermerRegionId: _parseInt(json['fermer_region_id']),
      contacts: contacts,
      myPrice: MyPriceOrderMeta.fromJson(myPriceRaw),
    );
  }

  static BidItem? fromOrderView(dynamic json) {
    final map = parseMyPriceMap(json);
    if (map == null) return null;

    final payload = parseMyPriceMap(map['payload']) ?? map;
    final source = Map<String, dynamic>.from(payload);
    if (map['my_price'] != null && source['my_price'] == null) {
      source['my_price'] = map['my_price'];
    }
    if (!source.containsKey('order_id') &&
        !source.containsKey('id') &&
        !source.containsKey('product_title')) {
      return null;
    }
    return BidItem.fromJson(source);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  DateTime? get createdAt => created != null
      ? DateTime.fromMillisecondsSinceEpoch(created! * 1000)
      : null;

  DateTime? get orderCreatedAt => orderCreated != null
      ? DateTime.fromMillisecondsSinceEpoch(orderCreated! * 1000)
      : null;

  // contacts != null означає що вже відкрито і є дані
  bool get isOpened => contacts != null || opened == 1;
  bool get isProcessed => processed == 1;

  /// Seller name/company: the order fields, else the opened contacts.
  String? get sellerName => _firstSet(fermerName, contacts?.name);
  String? get sellerCompany => _firstSet(fermerCompany, contacts?.company);

  static String? _firstSet(String? a, String? b) =>
      (a != null && a.trim().isNotEmpty) ? a : b;

  // Зручний геттер для телефону з будь-якого джерела
  String? get phone => contacts?.phone ?? openedPhon ?? fermerPhone;
}

class BidsResponse {
  final List<BidItem> bids;
  final List<BidItem> bidsFresh;

  BidsResponse({required this.bids, required this.bidsFresh});

  factory BidsResponse.fromJson(Map<String, dynamic> json) {
    return BidsResponse(
      bids: parseMyPriceMapList(json['bids']).map(BidItem.fromJson).toList(),
      bidsFresh: parseMyPriceMapList(json['bids_fresh'])
          .map(BidItem.fromJson)
          .toList(),
    );
  }

  bool get hasFresh => bidsFresh.isNotEmpty;
}
