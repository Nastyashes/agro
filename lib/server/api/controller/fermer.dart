import '../api.dart';

class Fermer extends Api {
  Future<ApiAnswer> closePriceOrder({required int orderId}) =>
      send('fermer.closeorder', query: {'order_id': '$orderId'});

  Future<ApiAnswer> viewReview({required int orderId}) =>
      send('order.reviews', query: {'itemid': '$orderId'});

  Future<ApiAnswer> sendReviewFermer({
    required int orderId,
    required int rating,
    required String comment,
  }) =>
      send('order.comment', query: {
        'order_id': '$orderId',
        'rating': '$rating',
        'comment': comment,
      });
}
