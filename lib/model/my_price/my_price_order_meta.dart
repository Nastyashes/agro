import 'package:agro/model/my_price/my_price_parse.dart';

class MyPriceOrderMeta {
  final bool matched;
  final int? matchId;
  final String? farmerResponse;
  final double? proposedPrice;
  final String badge;
  final String responseLabel;
  final String tone;
  final bool viewerIsSelected;
  final bool canAcknowledge;

  const MyPriceOrderMeta({
    this.matched = false,
    this.matchId,
    this.farmerResponse,
    this.proposedPrice,
    this.badge = '',
    this.responseLabel = '',
    this.tone = 'neutral',
    this.viewerIsSelected = false,
    this.canAcknowledge = false,
  });

  bool get isAgreed => matched && tone == 'agreed';
  bool get isDeclined => matched && tone == 'declined';

  factory MyPriceOrderMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MyPriceOrderMeta();
    }
    return MyPriceOrderMeta(
      matched: parseMyPriceBool(json['matched']),
      matchId: parseMyPriceInt(json['match_id']),
      farmerResponse: parseMyPriceString(json['farmer_response']),
      proposedPrice: parseMyPriceDouble(json['proposed_price']),
      badge: parseMyPriceString(json['badge']) ?? '',
      responseLabel: parseMyPriceString(json['response_label']) ?? '',
      tone: parseMyPriceString(json['tone']) ?? 'neutral',
      viewerIsSelected: parseMyPriceBool(json['viewer_is_selected']),
      canAcknowledge: parseMyPriceBool(json['can_acknowledge']),
    );
  }
}
