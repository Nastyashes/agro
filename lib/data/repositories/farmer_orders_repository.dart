import 'package:agro/model/model_review/model_review.dart';
import 'package:agro/model/model_review/struct_review.dart';
import 'package:agro/server/api/api.dart';

/// Reviews on an order and closing it ("sold").
class FarmerOrdersRepository {
  FarmerOrdersRepository([Api? api]) : _api = api ?? Api();

  final Api _api;

  Future<List<ModelReview>> reviews(int orderId) async {
    final data = (await _api.fermer.viewReview(orderId: orderId)).data;
    final payload = data is Map ? data['payload'] : null;
    final items = payload is Map ? payload['items'] : null;
    if (items is! List) return const [];
    return [for (final item in items) structReview(data: item) as ModelReview];
  }

  Future<bool> sendReview({
    required int orderId,
    required int rating,
    required String comment,
  }) async =>
      _isTrue((await _api.fermer.sendReviewFermer(
              orderId: orderId, rating: rating, comment: comment))
          .data);

  Future<bool> closeOrder(int orderId) async =>
      _isTrue((await _api.fermer.closePriceOrder(orderId: orderId)).data);

  static bool _isTrue(dynamic data) =>
      data is Map && data['status'].toString() == 'true';
}
