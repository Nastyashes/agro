import 'dart:developer';

import 'package:agro/ui/pop_up/banner_dialog.dart';
import 'package:agro/ui/pop_up/inform_pop_up.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/app/my_price/components/my_price_match_style.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/generated/assets.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/trade_localizers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool orderingCarrier = false;
  bool carrierOrdered = false;

  final MainController _mainController = Get.find<MainController>();
  final NewHomeController _newHomeController = Get.find<NewHomeController>();

  @override
  void initState() {
    super.initState();
    _bidItem = widget.bidItem;
  }

  @override
  void didUpdateWidget(covariant BidListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bidItem != widget.bidItem) {
      _bidItem = widget.bidItem;
    }
  }

  Color get _dayBadgeColor => switch (_bidItem.dayColor) {
        'yellow' => AppColors.daysYellow,
        'pink' => AppColors.daysPink,
        'red' => AppColors.daysRed,
        _ => AppColors.daysBlue,
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

  // =========================
  // CONTACT
  // =========================

  Future<void> _onContactClick(BuildContext context) async {
    if (_bidItem.isOpened || _isLoading) return;

    setState(() => _isLoading = true);

    final String errorTariffMail = context.l.errorTariffMail;

    try {
      final contactPrice = _bidItem.contactPrice ?? 0;

      final isFree = _mainController.isFree;
      final isAdsDisabled = _mainController.isAdsDisabled;

      final shouldShowAd = contactPrice == 0 && isFree && !isAdsDisabled;

      log('contactPrice=$contactPrice');
      log('isFree=$isFree');
      log('isAdsDisabled=$isAdsDisabled');
      log('shouldShowAd=$shouldShowAd');

      // Якщо реклама не потрібна — одразу відкриваємо контакт.
      if (!shouldShowAd) {
        await _openContact(context);
        return;
      }

      OpenContactsAdResponse? res;

      try {
        res = await Api().traider.openContactsAd(
              orderId: _bidItem.orderId!,
            );

        log('OPEN Contacts Ad: ${res.toJson()}');
      } catch (e, stackTrace) {
        log(
          'openContactsAd failed, fallback to direct open: $e',
          error: e,
          stackTrace: stackTrace,
        );

        // Помилка завантаження реклами не блокує відкриття контакту.
        await _openContact(context);
        return;
      }

      if (res.status != true || res.adBanner == null) {
        await _openContact(context);
        return;
      }

      if (!context.mounted) return;

      final ad = res.adBanner!;

      final watched = await showAdBannerDialog(
        context,
        imageUrl: ad.image,
        phone: ad.phone,
        price: context.adsPriceLabel(),
        onDisableAds: () async {
          await _newHomeController.disableAds(context);
        },
      );

      if (watched == true && context.mounted) {
        await _openContact(context);
      }
    } catch (e, stackTrace) {
      log(
        'contact open failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        inAppNotification(
          text: errorTariffMail,
          c: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openContact(BuildContext context) async {
    try {
      final ApiAnswer apiAnswer = await Api().traider.openBidContact(
            orderId: _bidItem.orderId!,
          );

      log(apiAnswer.data.toString());

      if (apiAnswer.data['status'] == 'insufficient') {
        final String message = apiAnswer.data['message']?.toString() ??
            context.l.insufficientBalance;

        if (context.mounted) {
          inAppNotification(
            text: message,
            c: context,
          );
        }

        return;
      }

      if (apiAnswer.data['status'] != '+') {
        final String message = apiAnswer.data['message']?.toString() ??
            context.l.connectionErrorRetry;

        if (context.mounted) {
          inAppNotification(
            text: message,
            c: context,
          );
        }

        return;
      }

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

      // Оновлюємо заявку в обох списках NewHome:
      // "Всі заявки" та "Свіжі заявки".
      _newHomeController.updateBidItem(updated);
    } catch (e, stackTrace) {
      log(
        '_openContact error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        inAppNotification(
          text: context.l.connectionErrorRetry,
          c: context,
        );
      }
    }
  }

  // =========================
  // CARRIER
  // =========================

  Future<void> onOrderCarrier(BuildContext context) async {
    if (orderingCarrier || carrierOrdered) return;

    setState(() => orderingCarrier = true);

    try {
      final ApiAnswer apiAnswer = await Api().traider.orderCarrier();

      log('orderCarrier: ${apiAnswer.data}');

      final bool status = apiAnswer.data['status'] == true;

      final String message = apiAnswer.data['message']?.toString() ?? '';

      if (!mounted) return;

      setState(() {
        orderingCarrier = false;

        if (status) {
          carrierOrdered = true;
        }
      });

      if (context.mounted) {
        showInformPoUp(
          context,
          status ? context.l.done : context.l.error,
          message,
        );
      }
    } catch (e, stackTrace) {
      log(
        'onOrderCarrier error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() => orderingCarrier = false);
      }

      if (context.mounted) {
        notification(
          text: context.l.errorTariffMail,
        );
      }
    }
  }

  // =========================
  // OTHER ACTIONS
  // =========================

  void onReview() {
    Get.toNamed(
      Routes.review,
      arguments: _bidItem.orderId,
    );
  }
bool isSet(String? value) {
  return value != null && value.trim().isNotEmpty;
}
  void _onLaunchPhone(
    BuildContext context,
    String phone,
  ) {
    showCupertinoModalBottomSheet(
      topRadius: const Radius.circular(30),
      context: context,
      builder: (c) => LaunchPhone(
        contact: phone,
      ),
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final bool isDistrib = _newHomeController.modelUser.role == 'distrib';

    final bool showCopy = isDistrib &&
        (_typeOrder == OrderType.dobriva || _typeOrder == OrderType.zerno);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BTransparentScalableButton(
        onPressed: () => widget.onPressed(
          model: _bidItem,
        ),
        scale: ScaleFormat.small,
        child: Container(
          decoration: BoxDecoration(
            color: matchCardColor(
              _bidItem.myPrice,
              widget.isFresh
                  ? AppColors.backgroundFreshCand
                  : AppColors.backgroundOrderCard,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: matchBorderColor(
                _bidItem.myPrice,
                widget.isFresh
                    ? AppColors.borderFreshCand
                    : AppColors.borderOrderCard,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // HEADER
                // =========================
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(
                        child: readText(
                          text:
                              '${context.l.product}: ${_bidItem.productTitle ?? '—'}',
                          style: AppFonts.body1bold.black,
                        ),
                      ),
                      if (_bidItem.myPrice?.matched == true &&
                          _bidItem.myPrice!.badge.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _bidItem.myPrice!.badge,
                            style: AppFonts.body2bold.mainGreen,
                          ),
                        ),
                      Text(
                        '${_bidItem.dayLabel ?? ''}',
                        style: GoogleFonts.getFont('Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: _dayBadgeColor),
                      ),
                    ])),
                if (_bidItem.myPrice?.matched == true &&
                    _bidItem.myPrice!.responseLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: readText(
                      text: _bidItem.myPrice!.responseLabel,
                      style: AppFonts.body2medium.black,
                    ),
                  ),
                orderInfo(
                  header: context.l.volume,
                  text: '${_bidItem.amount ?? '—'} ${context.l.amountTypeTon}',
                ),
                orderInfo(
                  header: context.l.harvestYear,
                  text: '${_bidItem.year ?? '—'}',
                ),
                orderInfo(
                  header: context.l.region,
                  text: _bidItem.regionName ?? '—',
                ),

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
                    _bidItem.deliveryType ?? '-',
                    context,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: readText(
                          text:
                              '${context.l.applicationNo} ${_bidItem.orderId} '
                              '${context.l.from} ${_bidItem.orderCreatedHum}',
                          style: AppFonts.body1medium.black,
                        ),
                      ),
                      if (showCopy)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BTransparentScalableButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '${context.l.applicationNo} ${_bidItem.orderId}\n'
                                      '${context.l.from} ${_bidItem.orderCreatedHum}',
                                ),
                              );

                              inAppNotification(
                                text: context.l.copiedToClipboard,
                                c: context,
                              );
                            },
                            scale: ScaleFormat.big,
                            child: const Icon(
                              Icons.copy,
                              color: AppColors.yellow,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // =========================
                // CONTACT
                // =========================

                if (_bidItem.isOpened && _bidItem.openedPhon != null)
                  _contactWidget(context)
                else
                  _contactButton(context),

                // =========================
                // CARRIER
                // =========================

                if (_bidItem.isOpened)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: bStyle(
                        text: orderingCarrier
                            ? context.l.orderingCarrier
                            : carrierOrdered
                                ? context.l.carrierOrdered
                                : context.l.bookCarrier,
                        c: context,
                        vertical: 15,
                        active: !orderingCarrier && !carrierOrdered,
                        colorButt: !orderingCarrier && !carrierOrdered
                            ? AppColors.mainGreen
                            : AppColors.greyGreen,
                        onPressed: () {
                          if (orderingCarrier || carrierOrdered) {
                            return;
                          }

                          onOrderCarrier(context);
                        },
                      ),
                    ),
                  ),
                   const SizedBox(height: 12),
                bStyle(
                  text: context.l.additionally,
                  c: context,
                  colorText: AppColors.darkGreen,
                  vertical: 15,
                  border: Border.all(
                    color: widget.isFresh ? AppColors.dobriva : AppColors.zerno,
                    width: 1.5,
                  ),
                  colorButt: widget.isFresh
                      ? AppColors.backgroundFreshCand
                      : AppColors.backgroundOrderCard,
                  onPressed: () => widget.onPressed(
                    model: _bidItem,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // CONTACT INFO
  // =========================

  Widget _contactWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: GestureDetector(
        onTap: () => _onLaunchPhone(
          context,
          _bidItem.contacts?.phone ?? '',
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentCardGreen,
                borderRadius: BorderRadius.circular(12),
               
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               if   (isSet(_bidItem.fermerName))
                  orderInfo(header:  context.l.fullName, text: _bidItem.fermerName ?? '', ),

   if   (isSet(_bidItem.fermerCompany))
                  orderInfo(header:  context.l.company, text: _bidItem.fermerCompany ?? '', ),
   if   (isSet(_bidItem.contacts?.district))
                  orderInfo(header:  context.l.district, text: _bidItem.contacts?.district ?? '',),
   if   (isSet(_bidItem.contacts?.city))
                  orderInfo(header:  context.l.town, text: _bidItem.contacts?.city ?? '',),
 if   (isSet(_bidItem.contacts?.addr))
                  orderInfo(header:  context.l.address, text: _bidItem.contacts?.addr ?? '',),
 if   (isSet(_bidItem.contacts?.phone ))
                  orderInfo(header:  context.l.phone, text: _bidItem.contacts?.phone ?? '',),

                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  // =========================
  // CONTACT BUTTON
  // =========================

  Widget _contactButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.mainGreen,
              ),
            )
          : Column(
              children: [
                bStyle(
                  text: (_bidItem.contactPrice ?? 0) > 0
                      ? '${context.l.contacts} · ${_bidItem.contactPrice} ${AppConstants.currencySymbolUah}'
                      : context.l.contacts,
                  c: context,
                  colorText: AppColors.white,
                  vertical: 15,
                  colorButt: AppColors.mainGreen.withAlpha(
                    (0.7 * 255).round(),
                  ),
                  onPressed: () => _onContactClick(context),
                ),
               
              ],
            ),
    );
  }

  Widget orderInfo({
    required String header,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          readText(
            text: header,
            style: AppFonts.body4semibold.grey4,
          ),
          const Spacer(),
        Expanded(child:   readText(
            text: text,
            align: TextAlign.right,
            style: AppFonts.body4medium.black,
          )),
        ],
      ),
    );
  }
}
