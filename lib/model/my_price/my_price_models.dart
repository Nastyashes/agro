import 'dart:developer';

import 'package:agro/model/my_price/my_price_parse.dart';
import 'package:intl/intl.dart';

class MyPriceSettings {
  final double? activationPrice;
  final int? activeDays;

  const MyPriceSettings({this.activationPrice, this.activeDays});

  factory MyPriceSettings.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return MyPriceSettings(
      activationPrice: parseMyPriceDouble(json['activation_price']),
      activeDays: parseMyPriceInt(json['active_days']),
    );
  }
}

class MyPriceNamedItem {
  final int? id;
  final String name;
  final int? sphereId;

  const MyPriceNamedItem({this.id, this.name = '', this.sphereId});

  factory MyPriceNamedItem.fromJson(Map<String, dynamic> json) {
    return MyPriceNamedItem(
      id: parseMyPriceInt(json['id']),
      name: parseMyPriceString(json['name']) ?? '',
      sphereId: parseMyPriceInt(json['sphere_id']),
    );
  }
}

class MyPriceTeamMember {
  final int? id;
  final String parent;
  final String phone;
  final String name;
  final String company;

  const MyPriceTeamMember({
    this.id,
    this.parent = '0',
    this.phone = '',
    this.name = '',
    this.company = '',
  });

  factory MyPriceTeamMember.fromJson(Map<String, dynamic> json) {
    return MyPriceTeamMember(
      id: parseMyPriceInt(json['id']),
      parent: parseMyPriceString(json['parent']) ?? '0',
      phone: parseMyPriceString(json['phone']) ?? '',
      name: parseMyPriceString(json['name']) ?? '',
      company: parseMyPriceString(json['company']) ?? '',
    );
  }

  String get label {
    if (name.isNotEmpty && phone.isNotEmpty) return '$name ($phone)';
    if (phone.isNotEmpty) return phone;
    if (name.isNotEmpty) return name;
    return id?.toString() ?? '';
  }
}

class MyPriceEntry {
  final int? id;
  final int? slotId;
  final String status;
  final int? regionId;
  final int? productId;
  final int? paymentType;
  final double? pricePerTon;
  final int? teamUserId;
  final String? teamPhone;
  final int? startsAt;
  final int? endsAt;
  final int? queuePosition;
  final String? regionTitle;
  final String? productTitle;
  final String? paymentTitle;
  final int? lockVersion;

  const MyPriceEntry({
    this.id,
    this.slotId,
    this.status = '',
    this.regionId,
    this.productId,
    this.paymentType,
    this.pricePerTon,
    this.teamUserId,
    this.teamPhone,
    this.startsAt,
    this.endsAt,
    this.queuePosition,
    this.regionTitle,
    this.productTitle,
    this.paymentTitle,
    this.lockVersion,
  });

  bool get isActive => status == 'active';
  bool get isQueued => status == 'queued';
  bool get isDeleted => status == 'deleted';

  String formatDate(int? seconds) {
    if (seconds == null) return '—';
    return DateFormat('dd.MM.yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
  }

  factory MyPriceEntry.fromJson(Map<String, dynamic> json) {
    final nested = parseMyPriceMap(json['combination']) ??
        parseMyPriceMap(json['slot']) ??
        parseMyPriceMap(json['item']);
    final source = <String, dynamic>{
      if (nested != null) ...nested,
      ...json,
    };
    final region = source['region'];
    final product = source['product'];
    final payment = source['payment'] ?? source['payment_form'];

    return MyPriceEntry(
      id: parseMyPriceInt(source['id']),
      slotId: parseMyPriceInt(source['slot_id']),
      status: parseMyPriceString(source['status']) ?? '',
      regionId: parseMyPriceInt(source['region_id']) ??
          parseMyPriceNestedId(region),
      productId: parseMyPriceInt(source['product_id']) ??
          parseMyPriceNestedId(product),
      paymentType: parseMyPriceInt(source['payment_type']) ??
          parseMyPriceInt(source['payment_id']) ??
          parseMyPriceNestedId(payment),
      pricePerTon: parseMyPriceDouble(source['price_per_ton']),
      teamUserId: parseMyPriceInt(source['team_user_id']),
      teamPhone: parseMyPriceString(source['team_phone'] ?? source['phone']),
      startsAt: parseMyPriceTimestamp(
        source['starts_at'] ?? source['start_at'] ?? source['valid_from'],
      ),
      endsAt: parseMyPriceTimestamp(
        source['ends_at'] ??
            source['end_at'] ??
            source['valid_to'] ??
            source['valid_until'] ??
            source['active_until'] ??
            source['expires_at'],
      ),
      queuePosition: parseMyPriceInt(
        source['queue_position'] ?? source['position'] ?? source['queue'],
      ),
      regionTitle: parseMyPriceString(source['region_title']) ??
          parseMyPriceString(source['region_name']) ??
          parseMyPriceNestedName(region),
      productTitle: parseMyPriceString(source['product_title']) ??
          parseMyPriceString(source['product_name']) ??
          parseMyPriceNestedName(product),
      paymentTitle: parseMyPriceString(source['payment_title']) ??
          parseMyPriceString(source['payment_name']) ??
          parseMyPriceNestedName(payment),
      lockVersion: parseMyPriceInt(source['lock_version']),
    );
  }

  MyPriceEntry withSlot(MyPriceEntry slot, {int? activeDays}) {
    final estimatedStart = startsAt ?? slot.endsAt;
    final estimatedEnd = endsAt ??
        (estimatedStart == null || activeDays == null
            ? null
            : estimatedStart + activeDays * 24 * 60 * 60);

    return MyPriceEntry(
      id: id,
      slotId: slotId ?? slot.slotId ?? slot.id,
      status: status,
      regionId: regionId ?? slot.regionId,
      productId: productId ?? slot.productId,
      paymentType: paymentType ?? slot.paymentType,
      pricePerTon: pricePerTon,
      teamUserId: teamUserId,
      teamPhone: teamPhone,
      startsAt: estimatedStart,
      endsAt: estimatedEnd,
      queuePosition: queuePosition,
      regionTitle: regionTitle ?? slot.regionTitle,
      productTitle: productTitle ?? slot.productTitle,
      paymentTitle: paymentTitle ?? slot.paymentTitle,
      lockVersion: lockVersion,
    );
  }
}

class MyPriceOverview {
  final MyPriceSettings settings;
  final List<MyPriceNamedItem> paymentTypes;
  final List<MyPriceTeamMember> team;
  final List<MyPriceNamedItem> regions;
  final List<MyPriceNamedItem> products;
  final List<MyPriceEntry> combinations;
  final List<MyPriceEntry> reservations;

  const MyPriceOverview({
    this.settings = const MyPriceSettings(),
    this.paymentTypes = const [],
    this.team = const [],
    this.regions = const [],
    this.products = const [],
    this.combinations = const [],
    this.reservations = const [],
  });

  factory MyPriceOverview.fromJson(dynamic json) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    log(
      'MyPriceOverview.fromJson keys=${map.keys.toList()} '
      'rawCombinations=${map['combinations']} '
      'rawReservations=${map['reservations']} '
      'rawSlots=${map['slots']}',
    );
    final settings = MyPriceSettings.fromJson(parseMyPriceMap(map['settings']));
    final combinations = parseMyPriceMapList(map['combinations'])
        .map(MyPriceEntry.fromJson)
        .toList();
    final slots = parseMyPriceMapList(map['slots'])
        .map(MyPriceEntry.fromJson)
        .toList();
    final reservations = parseMyPriceMapList(map['reservations'])
        .map(MyPriceEntry.fromJson)
        .map(
          (entry) => entry.withSlot(
            _slotFor(
              slotId: entry.slotId,
              slots: slots,
              combinations: combinations,
            ),
            activeDays: settings.activeDays,
          ),
        )
        .toList();
    return MyPriceOverview(
      settings: settings,
      paymentTypes: parseMyPriceMapList(map['payment_types'])
          .map(MyPriceNamedItem.fromJson)
          .toList(),
      team: parseMyPriceMapList(map['team'])
          .map(MyPriceTeamMember.fromJson)
          .toList(),
      regions: parseMyPriceMapList(map['regions'])
          .map(MyPriceNamedItem.fromJson)
          .toList(),
      products: parseMyPriceMapList(map['products'])
          .map(MyPriceNamedItem.fromJson)
          .toList(),
      combinations: combinations,
      reservations: reservations,
    );
  }

  static MyPriceEntry _slotFor({
    required int? slotId,
    required List<MyPriceEntry> slots,
    required List<MyPriceEntry> combinations,
  }) {
    if (slotId == null) return const MyPriceEntry();
    for (final slot in slots) {
      if (slot.id == slotId || slot.slotId == slotId) {
        return slot;
      }
    }
    for (final combination in combinations) {
      if (combination.slotId == slotId) {
        return combination;
      }
    }
    return const MyPriceEntry();
  }

  String nameOf(List<MyPriceNamedItem> items, int? id) {
    if (id == null) return '—';
    for (final item in items) {
      if (item.id == id) return item.name;
    }
    return '—';
  }

  String regionName(MyPriceEntry entry) =>
      entry.regionTitle ?? nameOf(regions, entry.regionId);

  String productName(MyPriceEntry entry) =>
      entry.productTitle ?? nameOf(products, entry.productId);

  String paymentName(MyPriceEntry entry) =>
      entry.paymentTitle ?? nameOf(paymentTypes, entry.paymentType);
}

class MyPriceQuoteSlot {
  final int? id;
  final String? action;
  final int? activeUntil;
  final int? queueLength;

  const MyPriceQuoteSlot({
    this.id,
    this.action,
    this.activeUntil,
    this.queueLength,
  });

  factory MyPriceQuoteSlot.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return MyPriceQuoteSlot(
      id: parseMyPriceInt(json['id']),
      action: parseMyPriceString(json['action']),
      activeUntil: parseMyPriceInt(json['active_until']),
      queueLength: parseMyPriceInt(json['queue_length']),
    );
  }
}

class MyPriceQuotePricing {
  final double? baseAmount;
  final double? discountPercent;
  final double? chargedAmount;

  const MyPriceQuotePricing({
    this.baseAmount,
    this.discountPercent,
    this.chargedAmount,
  });

  factory MyPriceQuotePricing.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return MyPriceQuotePricing(
      baseAmount: parseMyPriceDouble(json['base_amount']),
      discountPercent: parseMyPriceDouble(json['discount_percent']),
      chargedAmount: parseMyPriceDouble(json['charged_amount']),
    );
  }
}

class MyPriceQuote {
  final String action;
  final MyPriceQuoteSlot slot;
  final MyPriceQuotePricing pricing;
  final String? promoCode;
  final double? promoDiscount;
  final int? teamUserId;
  final String? teamPhone;

  const MyPriceQuote({
    this.action = 'activate',
    this.slot = const MyPriceQuoteSlot(),
    this.pricing = const MyPriceQuotePricing(),
    this.promoCode,
    this.promoDiscount,
    this.teamUserId,
    this.teamPhone,
  });

  bool get isReserve => action == 'reserve';

  factory MyPriceQuote.fromJson(dynamic json) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    final promo = parseMyPriceMap(map['promo']) ?? const {};
    final team = parseMyPriceMap(map['team_member']) ?? const {};
    return MyPriceQuote(
      action: parseMyPriceString(map['action']) ?? 'activate',
      slot: MyPriceQuoteSlot.fromJson(parseMyPriceMap(map['slot'])),
      pricing: MyPriceQuotePricing.fromJson(parseMyPriceMap(map['pricing'])),
      promoCode: parseMyPriceString(promo['code']),
      promoDiscount: parseMyPriceDouble(promo['discount_percent']),
      teamUserId: parseMyPriceInt(team['id']),
      teamPhone: parseMyPriceString(team['phone']),
    );
  }
}

class MyPriceActivateResult {
  final String action;
  final int? id;
  final int? slotId;
  final double? chargedAmount;
  final double? walletBalance;
  final int? startsAt;
  final int? endsAt;
  final int? queuePosition;
  final bool idempotent;

  const MyPriceActivateResult({
    this.action = 'activate',
    this.id,
    this.slotId,
    this.chargedAmount,
    this.walletBalance,
    this.startsAt,
    this.endsAt,
    this.queuePosition,
    this.idempotent = false,
  });

  factory MyPriceActivateResult.fromJson(dynamic json) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    return MyPriceActivateResult(
      action: parseMyPriceString(map['action']) ?? 'activate',
      id: parseMyPriceInt(map['id']),
      slotId: parseMyPriceInt(map['slot_id']),
      chargedAmount: parseMyPriceDouble(map['charged_amount']),
      walletBalance: parseMyPriceDouble(map['wallet_balance']),
      startsAt: parseMyPriceInt(map['starts_at']),
      endsAt: parseMyPriceInt(map['ends_at']),
      queuePosition: parseMyPriceInt(map['queue_position']),
      idempotent: parseMyPriceBool(map['idempotent']),
    );
  }
}

class MyPriceDealQuote {
  final int? orderId;
  final double? amount;
  final double? balance;
  final double? balanceAfter;
  final bool requiresConfirmation;
  final bool nonRefundable;
  final bool matched;
  final bool idempotent;

  const MyPriceDealQuote({
    this.orderId,
    this.amount,
    this.balance,
    this.balanceAfter,
    this.requiresConfirmation = true,
    this.nonRefundable = true,
    this.matched = false,
    this.idempotent = false,
  });

  bool get hasEnoughBalance => (balanceAfter ?? 0) >= 0;

  factory MyPriceDealQuote.fromJson(dynamic json) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    return MyPriceDealQuote(
      orderId: parseMyPriceInt(map['order_id']),
      amount: parseMyPriceDouble(map['amount']),
      balance: parseMyPriceDouble(map['balance']),
      balanceAfter: parseMyPriceDouble(map['balance_after']),
      requiresConfirmation: map['requires_confirmation'] == null
          ? true
          : parseMyPriceBool(map['requires_confirmation']),
      nonRefundable: map['non_refundable'] == null
          ? true
          : parseMyPriceBool(map['non_refundable']),
      matched: parseMyPriceBool(map['matched']),
      idempotent: parseMyPriceBool(map['idempotent']),
    );
  }
}

class MyPriceDealItem {
  final int? dealId;
  final int? orderId;
  final String? orderTitle;
  final String? productTitle;
  final String? regionTitle;
  final double? chargedAmount;
  final String? status;
  final String? createdHuman;
  final bool matched;
  final String? farmerResponse;
  final double? proposedPrice;

  const MyPriceDealItem({
    this.dealId,
    this.orderId,
    this.orderTitle,
    this.productTitle,
    this.regionTitle,
    this.chargedAmount,
    this.status,
    this.createdHuman,
    this.matched = false,
    this.farmerResponse,
    this.proposedPrice,
  });

  factory MyPriceDealItem.fromJson(Map<String, dynamic> json) {
    return MyPriceDealItem(
      dealId: parseMyPriceInt(json['deal_id']),
      orderId: parseMyPriceInt(json['order_id']),
      orderTitle: parseMyPriceString(json['order_title']),
      productTitle: parseMyPriceString(json['product_title']),
      regionTitle: parseMyPriceString(json['region_title']),
      chargedAmount: parseMyPriceDouble(json['charged_amount']),
      status: parseMyPriceString(json['status']),
      createdHuman: parseMyPriceString(json['created_human']),
      matched: parseMyPriceBool(json['matched']),
      farmerResponse: parseMyPriceString(json['farmer_response']),
      proposedPrice: parseMyPriceDouble(json['proposed_price']),
    );
  }
}

class MyPriceDealsPage {
  final List<MyPriceDealItem> items;
  final int limit;
  final int offset;

  const MyPriceDealsPage({
    this.items = const [],
    this.limit = 50,
    this.offset = 0,
  });

  factory MyPriceDealsPage.fromJson(dynamic json) {
    final map = parseMyPriceMap(json) ?? <String, dynamic>{};
    return MyPriceDealsPage(
      items: parseMyPriceMapList(map['items'])
          .map(MyPriceDealItem.fromJson)
          .toList(),
      limit: parseMyPriceInt(map['limit']) ?? 50,
      offset: parseMyPriceInt(map['offset']) ?? 0,
    );
  }
}

class MyPriceActivateParams {
  final int regionId;
  final int productId;
  final int paymentType;
  final double pricePerTon;
  final int teamUserId;
  final String? promoCode;

  const MyPriceActivateParams({
    required this.regionId,
    required this.productId,
    required this.paymentType,
    required this.pricePerTon,
    required this.teamUserId,
    this.promoCode,
  });

  Map<String, String> toFormData() {
    final data = <String, String>{
      'region_id': regionId.toString(),
      'product_id': productId.toString(),
      'payment_type': paymentType.toString(),
      'price_per_ton': pricePerTon.toString(),
      'team_user_id': teamUserId.toString(),
    };
    if (promoCode != null && promoCode!.trim().isNotEmpty) {
      data['promo_code'] = promoCode!.trim();
    }
    return data;
  }
}
