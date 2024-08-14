import 'package:agro/app/home/order/components/call_result_info.dart';
import 'package:agro/app/home/order/components/contact.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/buttons/b_style.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/ui/utils/date_extensions.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import '../../../ui/buttons/b_transparent_scalable_button.dart';
import 'home_controller.dart';

class BlockOrderUnknown extends StatefulWidget {
  final ModelOrder modelOrder;
  final Answer? answer;
  final Function({required ModelOrder model}) onPressed;

  const BlockOrderUnknown(
      {super.key,
      required this.modelOrder,
      required this.onPressed,
      this.answer});

  @override
  State<BlockOrderUnknown> createState() => _BlockOrderUnknownState();
}

class _BlockOrderUnknownState extends State<BlockOrderUnknown> {
  var isProgressShow = false;
  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BTransparentScalableButton(
          onPressed: () => widget.onPressed(model: widget.modelOrder),
          scale: ScaleFormat.small,
          child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey2),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Expanded(
                            child: readText(
                              text:
                                  '${context.l.applicationNo} ${widget.modelOrder.id}\n${context.l.from} ${widget.modelOrder.startDate?.formatDateTimeShort()}',
                              style: AppFonts.body1bold.black,
                            ),
                          ),
                          if (DateTime.now().millisecondsSinceEpoch >
                              widget.modelOrder.endDate!.millisecondsSinceEpoch) ...[
                            readText(
                              text: context.l.expired,
                              style: AppFonts.body2semibold.red,
                            )
                          ] else if (widget.modelOrder.priceAdded != null &&
                              widget.modelOrder.priceAdded!) ...[
                            readText(
                                text: '₴',
                                style: AppFonts.title1.mainGreen,
                                padding: const EdgeInsets.only(bottom: 7)),
                            if (controller.modelUser.role == 'distrib') ...[
                              const SizedBox(width: 10),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: BTransparentScalableButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: (widget.modelOrder.toText())));
                                        inAppNotification(
                                            text:
                                                context.l.copiedToClipboard,
                                            c: context);
                                      },
                                      scale: ScaleFormat.big,
                                      child: const Icon(Icons.copy,
                                          color: AppColors.yellow, size: 24)))
                            ]
                          ],
                          if (controller.modelUser.role == 'distrib') ...[
                            const SizedBox(width: 10),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SvgPicture.asset(
                                    widget.modelOrder.request != null &&
                                            widget.modelOrder.request!
                                        ? Assets.appIsViewTrue
                                        : Assets.appIsViewFalse,
                                    height: widget.modelOrder.request != null &&
                                            widget.modelOrder.request!
                                        ? 30
                                        : 28))
                          ]
                        ]),
                      ),
                      orderInfo(
                          header: context.l.region,
                          text: widget.modelOrder.region.toString()),
                      orderInfo(
                          header: context.l.crop, text: widget.modelOrder.crop.toString()),
                      orderInfo(
                          header: context.l.volume,
                          text: widget.modelOrder.capacity.toString()),
                      orderInfo(
                          header:  context.l.harvestYear,
                          text: widget.modelOrder.harvestYear.toString()),
                      orderInfo(
                          header: context.l.formOfPayment,
                          text: widget.modelOrder.payForm == 'beznal'
                              ? context.l.paymentNonCash
                              : widget.modelOrder.payForm == 'nal'
                                  ? context.l.paymentCash
                                  : widget.modelOrder.payment.toString()),
                      orderInfo(
                          header: context.l.typeOfDelivery,
                          text: widget.modelOrder.deliveryForm.toString()),
                      if (widget.modelOrder.comment != null &&
                          widget.modelOrder.comment != '') ...[
                        readText(
                          text: context.l.comment,
                          style: AppFonts.body1medium.grey3,
                        ),
                        readText(
                            text: widget.modelOrder.comment!,
                            style: AppFonts.body1medium.black,
                            padding: const EdgeInsets.only(top: 4)),
                      ],
                      controller.modelUser.isTraider && widget.answer != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: CallResultInfo(
                                  text:
                                      widget.answer?.result?.getLabel(context) ?? context.l.notInstalled,
                                  horizontalPadding: 0,
                                  textColor: widget.answer?.result?.color,
                                  onPressed: () {}))
                          : const SizedBox(),
                      if (controller.modelUser.role == 'distrib') ...[
                        //контакти
                        widget.modelOrder.contact != null
                            ? ContactScreen(
                                isVip: widget.modelOrder.contact != null,
                                contact: widget.modelOrder.contact!,
                                onLauchPhone: () => controller.onLaunchPhone(
                                    context, widget.modelOrder.contact!))
                            : const SizedBox(),

                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                //кнопка контакти
                                widget.modelOrder.contact == null
                                    ? Expanded(
                                        child: isProgressShow
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                color: AppColors.mainGreen,
                                              ))
                                            : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: bStyle(
                                                text: context.l.contacts,
                                                c: context,
                                                colorText: AppColors.darkGreen,
                                                vertical: 15,
                                                border: Border.all(
                                                    color: AppColors.darkGreen,
                                                    width: 1),
                                                colorButt: Colors.transparent,
                                                onPressed: () {
                                                  setState(() {
                                                        isProgressShow = true;
                                                      });
                                                  controller.onContactClick(
                                                      widget.modelOrder, context);
                                                })))
                                    : const SizedBox(),

                                //кнопка додатково
                                Expanded(
                                    child: bStyle(
                                        text: context.l.additionally,
                                        c: context,
                                        colorText: AppColors.additionalGreen,
                                        vertical: 15,
                                        border: Border.all(
                                            color: AppColors.additionalGreen,
                                            width: 1),
                                        colorButt: Colors.transparent,
                                        onPressed: () =>
                                            widget.onPressed(model: widget.modelOrder))),

                                //додаткові кнопки
                  
                              ],
                            )),
                      ]
                    ]),
              ))),
    );
  }

  Widget orderInfo({required String header, required String text}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          readText(
            text: header,
            style: AppFonts.body1medium.grey3,
          ),
          const Spacer(),
          readText(text: text, style: AppFonts.body1medium.black)
        ]),
      );
}
