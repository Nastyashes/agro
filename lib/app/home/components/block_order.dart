import 'package:agro/model/model_order/application.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:agro/ui/text/read_text.dart';

import '../../../ui/buttons/b_transparent_scalable_button.dart';

class BlockOrder extends StatefulWidget {
  final Application application;
  final Function({required Application model}) onPressed;

  const BlockOrder({
    super.key,
    required this.application,
    required this.onPressed,
  });

  @override
  State<BlockOrder> createState() => _BlockOrderState();
}

class _BlockOrderState extends State<BlockOrder> {
  var isProgressShow = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BTransparentScalableButton(
          onPressed: () => widget.onPressed(model: widget.application),
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
                                  '${context.l.applicationNo} ${widget.application.id}\n${context.l.from} ${widget.application.createdHuman}',
                              style: AppFonts.body1bold.black,
                            ),
                          ),
                        ])),
                    orderInfo(
                        header: context.l.region,
                        text: widget.application.regionTitle.toString()),
                    orderInfo(
                        header: context.l.product,
                        text: widget.application.productTitle.toString()),
                    orderInfo(
                        header: context.l.volume,
                        text: widget.application.amount.toString()),
                    orderInfo(
                        header: context.l.harvestYear,
                        text: widget.application.year.toString()),
                    orderInfo(
                        header: context.l.formOfPayment,
                        text: widget.application.paymentType == '1'
                            ? context.l.paymentFormF1
                            : widget.application.paymentType == '2'
                                ? context.l.paymentFormF2
                                : context.l.allPaymentForm),
                    orderInfo(
                        header: context.l.typeOfDelivery,
                        text: widget.application.deliveryHuman.toString()),
                    if (widget.application.comment != null &&
                        widget.application.comment != '') ...[
                      readText(
                        text: context.l.comment,
                        style: AppFonts.body1medium.grey3,
                      ),
                      readText(
                          text: widget.application.comment!,
                          style: AppFonts.body1medium.black,
                          padding: const EdgeInsets.only(top: 4)),
                    ],
                  ],
                )),
          )),
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
