import 'package:agro/app/review/components/review_controller.dart';
import 'package:agro/data/repositories/farmer_orders_repository.dart';
import 'package:agro/model/model_review/model_review.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeRepo extends FarmerOrdersRepository {
  List<ModelReview> next = [];
  bool sendOk = true;
  final List<({int order, int rating, String comment})> sent = [];

  @override
  Future<List<ModelReview>> reviews(int orderId) async => List.of(next);

  @override
  Future<bool> sendReview({
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    sent.add((order: orderId, rating: rating, comment: comment));
    return sendOk;
  }
}

void main() {
  setUpAll(() => Get.testMode = true);

  late FakeRepo repo;
  late ReviewController c;

  setUp(() {
    repo = FakeRepo();
    c = ReviewController(repository: repo, orderId: 9)..onInit();
  });

  test('loads reviews into reactive state', () async {
    repo.next = [ModelReview(comment: 'ok')];

    await c.loadReviews();

    expect(c.reviews.single.comment, 'ok');
    expect(c.loadPage.value, isTrue);
  });

  test('empty comment is not sent', () async {
    c.reviewController.text = '   ';

    expect(await c.submitReview(), ReviewSubmitResult.emptyComment);
    expect(repo.sent, isEmpty);
  });

  test('sends rounded rating, resets the form and reloads', () async {
    c.reviewController.text = 'Добре';
    c.onChangeStar(3.6);
    repo.next = [ModelReview(comment: 'Добре')];

    expect(await c.submitReview(), ReviewSubmitResult.added);

    expect(repo.sent.single, (order: 9, rating: 4, comment: 'Добре'));
    expect(c.reviewController.text, '');
    expect(c.countStar.value, 5);
    expect(c.reviews, hasLength(1));
  });

  test('failed send keeps the text', () async {
    repo.sendOk = false;
    c.reviewController.text = 'Добре';

    expect(await c.submitReview(), ReviewSubmitResult.failed);
    expect(c.reviewController.text, 'Добре');
  });
}
