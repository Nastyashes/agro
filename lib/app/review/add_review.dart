import 'package:agro/ui/text/read_text.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:get/get.dart';

import '../../ui/buttons/button_styles.dart';
import '../../../ui/text_field/text_field.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'components/review_controller.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  ReviewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 490 + MediaQuery.of(context).viewInsets.bottom,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 20),
                child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffEDEDED),
                            borderRadius: BorderRadius.circular(3)),
                        height: 10,
                        width: 100))),
            Center(
                child: readText(
                    text: context.l.addReview,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    size: 22,
                    padding: const EdgeInsets.only(bottom: 30))),
            Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Obx(() => RatingStars(
                    value: controller.countStar.value,
                    starBuilder: (index, color) =>
                        Icon(Icons.star, color: color, size: 40),
                    starCount: 5,
                    starSize: 40,
                    // valueLabelColor: const Color(0xff9b9b9b),
                    // valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                    // valueLabelRadius: 20,
                    maxValue: 5,
                    starSpacing: 0,
                    maxValueVisibility: false,
                    valueLabelVisibility: false,
                    animationDuration: const Duration(seconds: 2),
                    valueLabelPadding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                    valueLabelMargin: const EdgeInsets.only(right: 8),
                    starOffColor: const Color(0xffe7e8ea),
                    onValueChanged: controller.onChangeStar,
                    starColor: const Color(0xffFEBF2F)))),
            TextFieldWidget(
                height: 200,
                padding: const EdgeInsets.all(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent),
                text: context.l.startWriting,
                minLines: 7,
                maxLine: 7,
                openKeyboardAuto: true,
                colorBg: const Color(0xffF8F8F8),
                controller: controller.reviewController,
                sizeText: 20),
            bStyle(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                text: context.l.addReview,
                c: context,
                colorText: Colors.white,
                vertical: 15,
                colorButt: const Color(0xffFCD300),
                onPressed: () => controller.loadIfValid(_submit))
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final result = await controller.submitReview();
    if (!mounted) return;
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

  Widget orderInfo({required String header, required String text}) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
      child: Row(children: [
        readText(text: header, color: const Color(0xffA9A9A9), size: 20),
        Expanded(
            child: readText(
                text: text,
                color: Colors.black,
                size: 20,
                fontWeight: FontWeight.w500,
                align: TextAlign.end))
      ]));
}
