import 'package:agro/app/review/components/block_review.dart';
import 'package:agro/app/review/components/review_controller.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_review.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewController controller = Get.find();

  void _openAddReview() => showAddReviewSheet(context);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Palette.bg0,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(
            title: l.reviews,
            trailing: AppIconButton(
              icon: Icons.add_rounded,
              tooltip: l.addReview,
              style: AppIconButtonStyle.soft,
              onPressed: _openAddReview,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (!controller.loadPage.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Palette.green));
              }
              if (controller.reviews.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.only(top: 60),
                  children: [
                    EmptyState(
                      icon: Icons.reviews_outlined,
                      title: l.noReviews,
                      text: l.noReviewsHint,
                      actionLabel: l.addReview,
                      primaryAction: true,
                      onAction: _openAddReview,
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  for (final r in controller.reviews)
                    BlockReview(modelReview: r),
                ],
              );
            }),
          ),
        ]),
      ),
    );
  }
}
