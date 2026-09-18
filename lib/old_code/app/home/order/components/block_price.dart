import 'package:agro/model/model_order_price/model_order_price.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:agro/generated/assets.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'order_controller.dart';

class BlockPriceOrder extends StatefulWidget {
  final ModelOrderPrice modelOrderPrice;

  const BlockPriceOrder({super.key, required this.modelOrderPrice});

  @override
  State<BlockPriceOrder> createState() => _BlockPriceOrderState();
}

class _BlockPriceOrderState extends State<BlockPriceOrder> {
  bool isOpenBlock = false;
  OrderController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: BTransparentScalableButton(
            onPressed: controller.modelUser?.role == 'distrib' ? () {} : () => setState(() => isOpenBlock = !isOpenBlock),
            scale: ScaleFormat.small,
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: const Color(0xff000000).withOpacity(0.08), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 0))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      readText(text: '${widget.modelOrderPrice.cost} ${context.l.uaht} ${widget.modelOrderPrice.createdAt}', color: Colors.black, size: 20),
                      const Spacer(),
                      if (controller.modelUser?.role == 'distrib') ...[
                        if (widget.modelOrderPrice.isMy!) ...[readText(text: context.l.yourPrice, color: const Color(0xff01CA20), size: 18)]
                      ] else ...[
                        SvgPicture.asset(!isOpenBlock ? Assets.componentsArrowRight : Assets.componentsArrowBot, width: !isOpenBlock ? 15 : 24)
                      ]
                    ]),
                    if (isOpenBlock) ...[
                      const SizedBox(height: 20),
                      priceInfo(header: context.l.fullName, text: widget.modelOrderPrice.traiderName.toString()),
                      priceInfo(header: context.l.phone, text: widget.modelOrderPrice.traiderPhone.toString())
                    ]
                  ]),
                ))));
  }

  Widget priceInfo({required String header, required String text}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        readText(text: header, color: const Color(0xffA9A9A9), size: 20),
        const Spacer(),
        readText(text: text, color: Colors.black, size: 20, fontWeight: FontWeight.w500)
      ]));
}
