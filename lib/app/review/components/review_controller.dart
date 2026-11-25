import 'package:agro/controllers/abstract/from_controller.dart';
import 'package:agro/data/repositories/farmer_orders_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../controllers/app_input_controller.dart';
import '../../../model/model_review/model_review.dart';

enum ReviewSubmitResult { emptyComment, added, failed }

/// Reviews of an order. No BuildContext: the add-review sheet turns the
/// [ReviewSubmitResult] into navigation and messages.
class ReviewController extends FormController {
  ReviewController({FarmerOrdersRepository? repository, int? orderId})
      : _repository = repository ?? FarmerOrdersRepository(),
        _orderId = orderId;

  final FarmerOrdersRepository _repository;
  final int? _orderId;

  late int orderId;
  late TextEditingController reviewController;

  final RxList<ModelReview> reviews = <ModelReview>[].obs;
  final RxDouble countStar = 5.0.obs;
  final RxBool loadPage = false.obs;

  @override
  void onInit() {
    reviewController = AppInputController();
    orderId = _orderId ?? Get.arguments as int;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadIfValid(loadReviews);
  }

  Future<void> loadReviews() async {
    reviews.assignAll(await _repository.reviews(orderId));
    loadPage.value = true;
  }

  void onChangeStar(double value) => countStar.value = value;

  /// Sends the review; an empty comment is never sent.
  Future<ReviewSubmitResult> submitReview() async {
    if (reviewController.text.trim().isEmpty) {
      return ReviewSubmitResult.emptyComment;
    }
    final sent = await _repository.sendReview(
      orderId: orderId,
      rating: countStar.value.round(),
      comment: reviewController.text,
    );
    if (!sent) return ReviewSubmitResult.failed;

    reviewController.text = '';
    countStar.value = 5;
    await loadReviews();
    return ReviewSubmitResult.added;
  }
}
