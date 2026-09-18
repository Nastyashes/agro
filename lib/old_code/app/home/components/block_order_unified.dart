import 'package:agro/old_code/app/home/components/home_controller.dart';
import 'package:agro/old_code/app/home/order/components/call_result_info.dart';
import 'package:agro/old_code/app/home/order/components/contact.dart';
import 'package:agro/generated/assets.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/ui/utils/date_extensions.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BlockOrderUnified extends StatefulWidget {
  final ModelOrder modelOrder;
  final Answer? answer;
  final OrderType orderType;
  final Function({required ModelOrder model}) onPressed;

  const BlockOrderUnified({
    super.key,
    required this.modelOrder,
    required this.onPressed,
    required this.orderType,
    this.answer,
  });

  @override
  State<BlockOrderUnified> createState() => _BlockOrderUnifiedState();
}

class _BlockOrderUnifiedState extends State<BlockOrderUnified> {
  var isProgressShow = false;

  // --- Конфіг за типом ---
  Color get _borderColor => switch (widget.orderType) {
        OrderType.dobriva => AppColors.dobriva,
        OrderType.oil => AppColors.oil,
        OrderType.seeds => AppColors.seeds,
        OrderType.unknown => AppColors.grey2,
        OrderType.zerno => AppColors.zerno,
      };

  Color get _bgColor => switch (widget.orderType) {
        OrderType.unknown => AppColors.white,
        OrderType.zerno => AppColors.zerno.withOpacity(0.01),
        _ => _borderColor.withOpacity(0.05),
      };

  String? get _iconAsset => switch (widget.orderType) {
        OrderType.dobriva => Assets.dobriva,
        OrderType.oil => Assets.oil,
        OrderType.seeds => Assets.seeds,
        OrderType.zerno => Assets.zerno,
        OrderType.unknown => null,
      };

  bool get _showHarvestYear =>
      widget.orderType == OrderType.unknown ||
      widget.orderType == OrderType.zerno;

  bool get _showRequestIcon =>
      widget.orderType == OrderType.oil ||
      widget.orderType == OrderType.seeds ||
      widget.orderType == OrderType.unknown;

  bool get _copyAlways =>
      widget.orderType == OrderType.dobriva ||
      widget.orderType == OrderType.zerno;

  bool get _showDealButton => widget.orderType == OrderType.zerno;

  String _cropLabel(BuildContext context) =>
      (widget.orderType == OrderType.oil || widget.orderType == OrderType.seeds)
          ? context.l.name
          : (widget.orderType == OrderType.dobriva)
              ? context.l.product
              : context.l.crop;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final order = widget.modelOrder;

    final bool priceAdded = order.priceAdded == true;
    final bool isExpired = DateTime.now().millisecondsSinceEpoch >
        order.endDate!.millisecondsSinceEpoch;
    final bool isDistrib = controller.modelUser.role == 'distrib';

    // Копіювати: завжди або тільки при priceAdded
    final bool showCopy = isDistrib && (_copyAlways || priceAdded);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BTransparentScalableButton(
        onPressed: () => widget.onPressed(model: order),
        scale: ScaleFormat.small,
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Заголовок ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    if (_iconAsset != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SvgPicture.asset(_iconAsset!, width: 32),
                      ),
                    Expanded(
                      child: readText(
                        text: '${context.l.applicationNo} ${order.id}\n'
                            '${context.l.from} ${order.startDate?.formatDateTimeShort()}',
                        style: AppFonts.body1bold.black,
                      ),
                    ),
                    if (isExpired)
                      readText(
                          text: context.l.expired,
                          style: AppFonts.body2semibold.red)
                    else if (priceAdded)
                      readText(
                          text: AppConstants.currencySymbolUah,
                          style: AppFonts.title1.mainGreen,
                          padding: const EdgeInsets.only(bottom: 7)),
                    if (showCopy) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BTransparentScalableButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: order.toText(context)));
                            inAppNotification(
                                text: context.l.copiedToClipboard, c: context);
                          },
                          scale: ScaleFormat.big,
                          child: const Icon(Icons.copy,
                              color: AppColors.yellow, size: 24),
                        ),
                      ),
                    ],
                    if (isDistrib && _showRequestIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: SvgPicture.asset(
                          order.request == true
                              ? Assets.appIsViewTrue
                              : Assets.appIsViewFalse,
                          height: order.request == true ? 30 : 28,
                        ),
                      ),
                  ]),
                ),

                // --- Інфо ---
                orderInfo(
                    header: context.l.region, text: order.region.toString()),
                orderInfo(
                    header: _cropLabel(context), text: order.crop.toString()),
                orderInfo(
                    header: context.l.volume, text: order.capacity.toString()),
                if (_showHarvestYear)
                  orderInfo(
                      header: context.l.harvestYear,
                      text: order.harvestYear.toString()),
                orderInfo(
                  header: context.l.formOfPayment,
                  text: order.payForm == 'beznal'
                      ? context.l.paymentNonCash
                      : order.payForm == 'nal'
                          ? context.l.paymentCash
                          : order.payment.toString(),
                ),
                orderInfo(
                    header: context.l.typeOfDelivery,
                    text: order.deliveryForm.toString()),

                if (order.comment != null && order.comment != '') ...[
                  readText(
                      text: context.l.comment,
                      style: AppFonts.body1medium.grey3),
                  readText(
                      text: order.comment!,
                      style: AppFonts.body1medium.black,
                      padding: const EdgeInsets.only(top: 4)),
                ],

                // --- Результат дзвінка (трейдер) ---
                if (controller.modelUser.isTraider && widget.answer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CallResultInfo(
                      text: widget.answer?.result?.getLabel(context) ??
                          context.l.notInstalled,
                      horizontalPadding: 0,
                      textColor: widget.answer?.result?.color,
                      onPressed: () {},
                    ),
                  ),

                // --- Блок дистриб'ютора ---
                if (isDistrib) ...[
                  if (order.contact != null)
                    ContactScreen(
                      isVip: true,
                      contact: order.contact!,
                      id: order.id.toString(),
                      onLauchPhone: () =>
                          controller.onLaunchPhone(context, order.contact!),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(children: [
                      if (order.contact == null)
                        Expanded(
                          child: isProgressShow
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.mainGreen))
                              : Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: bStyle(
                                    text: context.l.contacts,
                                    c: context,
                                    colorText: AppColors.darkGreen,
                                    vertical: 15,
                                    border: Border.all(
                                        color: AppColors.darkGreen, width: 1),
                                    colorButt: Colors.transparent,
                                    onPressed: () {
                                      setState(() => isProgressShow = true);
                                      controller.onContactClick(order, context);
                                    },
                                  ),
                                ),
                        ),
                      Expanded(
                        child: bStyle(
                          text: context.l.additionally,
                          c: context,
                          colorText: AppColors.additionalGreen,
                          vertical: 15,
                          border: Border.all(
                              color: AppColors.additionalGreen, width: 1),
                          colorButt: Colors.transparent,
                          onPressed: () => widget.onPressed(model: order),
                        ),
                      ),
                      if (_showDealButton && controller.tariff?.isVip == true)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: bStyle(
                              text: context.l.agreement,
                              c: context,
                              colorText: AppColors.white,
                              vertical: 15,
                              onPressed: () => controller.onDeal(
                                  order, context.l.errorAgreement),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget orderInfo({required String header, required String text}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          readText(text: header, style: AppFonts.body1medium.grey3),
          const Spacer(),
          readText(text: text, style: AppFonts.body1medium.black),
        ]),
      );
}
