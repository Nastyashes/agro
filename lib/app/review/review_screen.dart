import 'package:agro/app/review/components/block_review.dart';
import 'package:agro/app/review/components/review_controller.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'add_review.dart';

import '../../model/model_review/model_review.dart';
import 'package:agro/ui/app_components/block_page_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewController controller = Get.find();

  void _openAddReview() => showCupertinoModalBottomSheet(
      topRadius: const Radius.circular(30),
      context: context,
      builder: (_) => const AddReviewScreen());

  @override
  Widget build(BuildContext context) {
    return BlockPageScreen(
        header: context.l.reviews,
        isBack: true,
        endWidget: BTransparentScalableButton(
            onPressed: _openAddReview,
            scale: ScaleFormat.big,
            child: const Icon(Icons.add, color: Color(0xffFCD300), size: 40)),
        theme: SystemUiOverlayStyle.dark,
        child: Obx(() => Column(
              children: [
                for (final ModelReview i in controller.reviews) ...[
                  BlockReview(modelReview: i)
                ]
              ],
            )));
  }
}
