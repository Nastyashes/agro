import 'dart:developer';

import 'package:agro/app/home/components/home_controller.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/generated/assets.dart';
import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/adds.dart';
import 'package:agro/ui/buttons/b_style.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/trade_localizers.dart';
import 'package:flutter/material.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BidListItem extends StatefulWidget {
  final BidItem bidItem;
  final Function({required BidItem model}) onPressed;
  final bool isFresh;

  const BidListItem({
    super.key,
    required this.isFresh,
    required this.bidItem,
    required this.onPressed,
  });

  @override
  State<BidListItem> createState() => _BidListItemState();
}

class _BidListItemState extends State<BidListItem> {
  late BidItem _bidItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bidItem = widget.bidItem;
  }

  Color get _dayBadgeColor => switch (_bidItem.dayColor) {
        'yellow' => AppColors.yellow,
        'pink' => AppColors.pink,
        'red' => AppColors.red,
        _ => AppColors.blue,
      };

  OrderType get _typeOrder => switch (_bidItem.sphereId) {
        15 => OrderType.zerno,
        12 => OrderType.dobriva,
        13 => OrderType.seeds,
        14 => OrderType.oil,
        _ => OrderType.unknown,
      };

  String? get _iconAsset => switch (_typeOrder) {
        OrderType.dobriva => Assets.dobriva,
        OrderType.oil => Assets.oil,
        OrderType.seeds => Assets.seeds,
        OrderType.zerno => Assets.zerno,
        OrderType.unknown => null,
      };
  Color get _borderColor => switch (_typeOrder) {
        OrderType.dobriva => AppColors.dobriva,
        OrderType.oil => AppColors.oil,
        OrderType.seeds => AppColors.seeds,
        OrderType.unknown => AppColors.grey2,
        OrderType.zerno => AppColors.zerno,
      };
  Future<void> _onContactClick(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final controller = Get.find<HomeController>();

      final contactPrice = _bidItem.contactPrice ?? 0;
      final tariff = controller.tariff;

      final isFree = tariff?.isFree == true;

      final isAdsDisabled = controller.userfield['is_ads_disabled'] == true;

      final shouldShowAd = contactPrice == 0 && isFree && !isAdsDisabled;

      log('contactPrice=$contactPrice');
      log('isFree=$isFree');
      log('isAdsDisabled=$isAdsDisabled');
      log('shouldShowAd=$shouldShowAd');

      if (shouldShowAd) {
        final interstitial = Interstitial();

        await interstitial.loadRewardedAd(
          doAfter: () async => await _openContact(context),
          onFailed: () async => await _openContact(context),
        );
      } else {
        await _openContact(context);
      }
    } catch (e) {
      log('contact open failed: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void onReview() => Get.toNamed(Routes.review, arguments: _bidItem.orderId);

  Future<void> _openContact(BuildContext context) async {
    try {
      ApiAnswer apiAnswer = await Api().traider.openBidContact(
            orderId: _bidItem.orderId!,
          );

      log(apiAnswer.data.toString());

      if (apiAnswer.data['status'] != '+') return;

      final payload = apiAnswer.data['payload'];

      final updated = _bidItem.copyWith(
        opened: 1,
        openedPhon: payload['phone']?.toString(),
        fermerCompany: payload['company']?.toString(),
        fermerName: payload['name']?.toString(),
        fermerPhone: payload['phone']?.toString(),
        fermerEmail: payload['email']?.toString(),
        contacts: BidContacts.fromJson(payload),
      );

      if (!mounted) return;

      setState(() {
        _bidItem = updated;
      });

      Get.find<HomeController>().updateBidItem(updated);
    } catch (e) {
      log('_openContact error: $e');
    }
  }

  void _onLaunchPhone(BuildContext context, String phone) =>
      showCupertinoModalBottomSheet(
        topRadius: const Radius.circular(30),
        context: context,
        builder: (c) => LaunchPhone(contact: phone),
      );
  @override
  void didUpdateWidget(covariant BidListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bidItem != widget.bidItem) {
      _bidItem = widget.bidItem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final bool isDistrib = controller.modelUser.role == 'distrib';
    final bool showCopy = isDistrib &&
        (_typeOrder == OrderType.dobriva || _typeOrder == OrderType.zerno);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BTransparentScalableButton(
        onPressed: () => widget.onPressed(model: _bidItem),
        scale: ScaleFormat.small,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isFresh
                ? AppColors.dobriva.withOpacity(0.06)
                : AppColors.zerno.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isFresh ? AppColors.dobriva : AppColors.zerno,
            ),
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
                        text: '${context.l.applicationNo} ${_bidItem.orderId}\n'
                            '${context.l.from} ${_bidItem.orderCreatedHum}',
                        style: AppFonts.body1bold.black,
                      ),
                    ),
                    if (showCopy) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BTransparentScalableButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text:
                                    '${context.l.applicationNo} ${_bidItem.orderId}\n'
                                    '${context.l.from} ${_bidItem.orderCreatedHum}'));
                            inAppNotification(
                                text: context.l.copiedToClipboard, c: context);
                          },
                          scale: ScaleFormat.big,
                          child: const Icon(Icons.copy,
                              color: AppColors.yellow, size: 24),
                        ),
                      ),
                    ],
                  ]),
                ),

                // --- Бейдж віку ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    readText(
                        text: context.l.age, style: AppFonts.body1medium.grey3),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: _dayBadgeColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: readText(
                        text: _bidItem.dayLabel ?? '',
                        style: AppFonts.body2medium.white,
                      ),
                    ),
                  ]),
                ),

                // --- Інфо ---
                orderInfo(
                    header: context.l.region, text: _bidItem.regionName ?? '—'),
                orderInfo(
                    header: context.l.product,
                    text: _bidItem.productTitle ?? '—'),
                orderInfo(
                    header: context.l.volume,
                    text:
                        '${_bidItem.amount ?? '—'} ${context.l.amountTypeTon}'),
                orderInfo(
                  header: context.l.formOfPayment,
                  text: _bidItem.ordPaymentType == 1
                      ? context.l.paymentFormF1
                      : _bidItem.ordPaymentType == 2
                          ? context.l.paymentFormF2
                          : context.l.allPaymentForm,
                ),
                orderInfo(
                    header: context.l.typeOfDelivery,
                    text: localizeDeliveryType(
                        _bidItem.deliveryType ?? '-', context)),

                // --- Контакт або кнопка ---
                if (_bidItem.isOpened && _bidItem.openedPhon != null)
                  _contactWidget(context)
                else
                  _contactButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactWidget(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GestureDetector(
            onTap: () =>
                _onLaunchPhone(context, _bidItem.contacts?.phone ?? ''),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.mainGreen.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.mainGreen),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        readText(
                            text: context.l.fullName,
                            style: AppFonts.body1medium.darkGreen),
                        const SizedBox(width: 24),
                        Expanded(
                            child: readText(
                          align: TextAlign.end,
                          text: _bidItem.fermerName ?? '',
                          style: AppFonts.body1bold.mainGreen,
                        )),
                      ]),
                      Row(children: [
                        readText(
                            text: context.l.company,
                            style: AppFonts.body1medium.darkGreen),
                        const SizedBox(width: 24),
                        Expanded(
                            child: readText(
                          align: TextAlign.end,
                          text: _bidItem.fermerCompany ?? '',
                          style: AppFonts.body1bold.mainGreen,
                        )),
                      ]),
                      Row(children: [
                        readText(
                            text: context.l.district,
                            style: AppFonts.body1medium.darkGreen),
                        const SizedBox(width: 24),
                        Expanded(
                            child: readText(
                          align: TextAlign.end,
                          text: _bidItem.contacts?.district ?? '',
                          style: AppFonts.body1bold.mainGreen,
                        )),
                      ]),
                      if (_bidItem.contacts?.city != null &&
                          _bidItem.contacts!.city!.isNotEmpty)
                        Row(children: [
                          readText(
                              text: context.l.town,
                              style: AppFonts.body1medium.darkGreen),
                          const SizedBox(width: 24),
                          Expanded(
                              child: readText(
                            align: TextAlign.end,
                            text: _bidItem.contacts?.city ?? '',
                            style: AppFonts.body1bold.mainGreen,
                          )),
                        ]),
                      if (_bidItem.contacts?.addr != null &&
                          _bidItem.contacts!.addr!.isNotEmpty)
                        Row(children: [
                          readText(
                              text: context.l.address,
                              style: AppFonts.body1medium.darkGreen),
                          const SizedBox(width: 24),
                          Expanded(
                              child: readText(
                            align: TextAlign.end,
                            text: _bidItem.contacts?.addr ?? '',
                            style: AppFonts.body1bold.mainGreen,
                          )),
                        ])
                      else
                        const SizedBox(),
                      Row(children: [
                        readText(
                            text: context.l.phone,
                            style: AppFonts.body1medium.darkGreen),
                        const SizedBox(width: 24),
                        Expanded(
                            child: readText(
                          align: TextAlign.end,
                          text: _bidItem.contacts?.phone ?? '',
                          style: AppFonts.body1bold.mainGreen,
                        )),
                      ]),
                    ]),
              ),
              Padding(
                  padding: EdgeInsetsGeometry.only(top: 10),
                  child: Row(children: [
                    Expanded(
                      child: bStyle(
                        text: context.l.reviews,
                        c: context,
                        colorText: AppColors.darkGreen,
                        vertical: 15,
                        border: Border.all(
                            color: widget.isFresh
                                ? AppColors.dobriva
                                : AppColors.zerno,
                            width: 1),
                        colorButt: widget.isFresh
                            ? AppColors.dobriva.withOpacity(0.5)
                            : AppColors.zerno.withOpacity(0.5),
                        onPressed: onReview,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: bStyle(
                        text: context.l.additionally,
                        c: context,
                        colorText: AppColors.darkGreen,
                        vertical: 15,
                        border: Border.all(
                            color: widget.isFresh
                                ? AppColors.dobriva
                                : AppColors.zerno,
                            width: 1),
                        colorButt: widget.isFresh
                            ? AppColors.dobriva.withOpacity(0.5)
                            : AppColors.zerno.withOpacity(0.5),
                        onPressed: () => widget.onPressed(model: _bidItem),
                      ),
                    ),
                  ]))
            ])),
      );

  Widget _contactButton(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.mainGreen))
          : Row(children: [
              Expanded(
                child: bStyle(
                    text: (_bidItem.contactPrice ?? 0) > 0
                        ? '${context.l.contacts} · ${_bidItem.contactPrice} ₴'
                        : context.l.contacts,
                    c: context,
                    colorText: AppColors.white,
                    vertical: 15,
                    // border: Border.all(color: AppColors.darkGreen, width: 1),
                    colorButt:
                        AppColors.mainGreen.withAlpha((0.7 * 255).round()),
                    onPressed: () => _onContactClick(context)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: bStyle(
                  text: context.l.additionally,
                  c: context,
                  colorText: AppColors.darkGreen,
                  vertical: 15,
                  border: Border.all(
                      color:
                          widget.isFresh ? AppColors.dobriva : AppColors.zerno,
                      width: 1),
                  colorButt: widget.isFresh
                      ? AppColors.dobriva.withOpacity(0.5)
                      : AppColors.zerno.withOpacity(0.5),
                  onPressed: () => widget.onPressed(model: _bidItem),
                ),
              ),
            ]));

  Widget orderInfo({required String header, required String text}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          readText(text: header, style: AppFonts.body1medium.grey3),
          const Spacer(),
          readText(text: text, style: AppFonts.body1medium.black),
        ]),
      );
}
