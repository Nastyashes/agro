import 'package:agro/old_code/app/home/order/components/block_price.dart';
import 'package:agro/old_code/app/home/order/components/call_result_info.dart';
import 'package:agro/old_code/app/home/order/components/contact.dart';
import 'package:agro/old_code/app/home/order/components/order_info.dart';
import 'package:agro/old_code/app/home/order/components/order_controller.dart';
import 'package:agro/old_code/app/home/order/components/sphere/seeds.dart';
import 'package:agro/model/model_order_price/model_order_price.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

class ZernoOrder extends StatelessWidget {
  final OrderController controller;

  const ZernoOrder({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      orderInfo(header: context.l.region, text: controller.modelOrder?.region ?? ''),
      orderInfo(header: context.l.crop, text: controller.modelOrder?.crop ?? ''),
      orderInfo(header: context.l.volume, text: controller.modelOrder?.capacity ?? ""),
      orderInfo(
          header: context.l.harvestYear,
          text: controller.modelOrder?.harvestYear.toString() ?? ''),
      orderInfo(
          header: context.l.formOfPayment, text: controller.modelOrder?.payment ?? ''),
      orderInfo(
          header: context.l.typeOfDelivery,
          text: controller.modelOrder?.deliveryForm ?? ''),
      if (controller.modelOrder?.comment != null &&
          controller.modelOrder?.comment != '') ...[
        readText(text: context.l.comment, color: const Color(0xffA9A9A9), size: 20),
        readText(
            text: controller.modelOrder?.comment ?? '',
            color: Colors.black,
            size: 20,
            fontWeight: FontWeight.w500,
            padding: const EdgeInsets.only(top: 10))
      ],
      (controller.tariff?.isVip == true ||
              controller.tariff?.isPremium == true ||
              controller.contactOpened)
          ? ContactScreen(
              contact: controller.contact,
              id: controller.modelOrder?.id?.toString() ?? "",
              onLauchPhone: () => controller.onLaunchPhone(
                  context, controller.contact.userPhone))
          : const SizedBox(),
      const SizedBox(height: 10),
      controller.modelUser!.isTraider
          ? CallResultInfo(
              text: controller.result?.getLabel(context) ?? context.l.establish,
              textColor: controller.result?.color,
              onPressed: () => controller.onSetAnswer(context),
            )
          : const SizedBox(),
      if (controller.modelUser!.isTraider) ...[
        traidersButton(controller, context)
      ] else ...[
        fermersButton(controller, context)
      ],
      controller.modelOrder?.quality != null
          ? statisticWidget(controller.modelOrder!.quality!, context)
          : const SizedBox(),
      Row(children: [
        readText(
            text: context.l.suggestedPrices,
            style: AppFonts.body1bold.black,
            padding: const EdgeInsets.only(top: 25)),
        const Spacer(),
        readText(
            text: controller.totalPrice.toString(),
            style: AppFonts.title2.grey3,
            padding: const EdgeInsets.only(top: 25))
      ]),
      for (ModelOrderPrice i in controller.modelOrderPrice) ...[
        BlockPriceOrder(modelOrderPrice: i)
      ]
    ]);
  }

  Widget traidersButton(OrderController controller, BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(children: [
            controller.tariff?.isVip == true ||
                    controller.tariff?.isPremium == true
                ? const SizedBox()
                : Expanded(
                    child: bStyle(
                        text: controller.contactOpened ?  context.l.hide : context.l.contacts,
                        c: context,
                        colorText: AppColors.darkGreen,
                        vertical: 15,
                        border:
                            Border.all(color: AppColors.darkGreen, width: 1),
                        colorButt: Colors.transparent,
                        onPressed: () {
                          controller.onContactClick(context);
                        })),
            controller.tariff?.isVip == true
                ? Expanded(
                    child: bStyle(
                        text: context.l.agreement,
                        c: context,
                        colorText: AppColors.white,
                        vertical: 15,
                        onPressed: () {
                          controller.onDeal(context);
                        }))
                : const SizedBox(),
            SizedBox(
                width: controller.tariff?.isPremium == false ||
                        controller.tariff?.isVip == true
                    ? 25
                    : 0),
            Expanded(
                child: bStyle(
                    text: context.l.reviews,
                    c: context,
                    colorText: AppColors.darkGreen,
                    vertical: 15,
                    border: Border.all(color: AppColors.darkGreen, width: 1),
                    colorButt: Colors.transparent,
                    onPressed: controller.onReview))
          ])),
      const SizedBox(height: 16),
      bStyle(
          key: UniqueKey(),
          text: context.l.addPrice,
          c: context,
          vertical: 15,
          colorButt: AppColors.yellow,
          onPressed: () =>
              controller.onAddPrice(context, controller.modelOrder!))
    ]);
  }

  Widget fermersButton(OrderController controller, BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 20),
      bStyle(
          key: UniqueKey(),
          padding: const EdgeInsets.only(top: 35),
          text: DateTime.now().millisecondsSinceEpoch >
                  (controller.modelOrder?.endDate?.millisecondsSinceEpoch ?? 0)
              ? context.l.sold
              : context.l.sell,
          c: context,
          active: DateTime.now().millisecondsSinceEpoch <
              (controller.modelOrder?.endDate!.millisecondsSinceEpoch ?? 0),
          colorButt: DateTime.now().millisecondsSinceEpoch >
                  (controller.modelOrder?.endDate?.millisecondsSinceEpoch ?? 0)
              ? const Color(0xffF2F2F2)
              : const Color(0xffFCD300),
          onPressed: controller.onSell),
    ]);
  }

}
