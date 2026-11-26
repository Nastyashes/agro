import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/review_controller.dart';

/// Opens the "add review" sheet above the keyboard.
void showAddReviewSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const AddReviewScreen(),
    );

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final ReviewController controller = Get.find();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.addReview,
                textAlign: TextAlign.center, style: AppText.headline),
            const SizedBox(height: 12),
            Obx(() {
              final value = controller.countStar.value.round();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: '$i',
                      onPressed: () => controller.onChangeStar(i.toDouble()),
                      icon: Icon(
                        i <= value
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color:
                            i <= value ? Palette.wheat : Palette.textTertiary,
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: controller.reviewController,
              autofocus: true,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body,
              decoration: InputDecoration(hintText: l.startWriting),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l.addReview,
              loading: _sending,
              onPressed: _sending ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    final result = await controller.submitReview();
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case ReviewSubmitResult.emptyComment:
        inAppNotification(text: context.l.needWriteReview, c: context);
      case ReviewSubmitResult.failed:
        inAppNotification(text: context.l.errorAddingReview, c: context);
      case ReviewSubmitResult.added:
        Navigator.pop(context);
        inAppNotification(text: context.l.feedbackAdded, c: context);
    }
  }
}
