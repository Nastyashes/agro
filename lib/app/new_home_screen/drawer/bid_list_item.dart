import 'dart:developer';

import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/ui/app_components/bids_card_row.dart';
import 'package:agro/ui/pop_up/banner_dialog.dart';
import 'package:agro/ui/pop_up/inform_pop_up.dart';
import 'package:agro/app/my_price/components/my_price_match_style.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/trade_localizers.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        res = await BidsRepository().contactAd(_bidItem.orderId!);
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
          showDisableAdsConfirm(
            context,
            amount: AppConstants.adsPrice,
            onConfirm: () => _newHomeController.disableAds(context),
          );
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
      final result = await BidsRepository().openContact(_bidItem.orderId!);

      if (result.status != OpenContactStatus.opened) {
        if (context.mounted) {
          inAppNotification(
            text: result.message ??
                (result.status == OpenContactStatus.insufficient
                    ? context.l.insufficientBalance
                    : context.l.connectionErrorRetry),
            c: context,
          );
        }
        return;
      }

      final contact = result.contact!;
      final updated = _bidItem.copyWith(
        opened: 1,
        openedPhon: contact.phone,
        fermerCompany: contact.company,
        fermerName: contact.name,
        fermerPhone: contact.phone,
        fermerEmail: contact.email,
        contacts: contact.contacts,
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
      final result = await BidsRepository().orderCarrier();
      final bool status = result.ok;
      final String message = result.message;

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
                  ? AppColors.backgroundFreshCand.withValues(alpha: 0.1)
                  : AppColors.backgroundOrderCard,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: matchBorderColor(
                _bidItem.myPrice,
                widget.isFresh
                    ? AppColors.borderFreshCand.withValues(alpha: 0.7)
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
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      Expanded(
                        child: readText(
                          text:
                              '${context.l.product}: ${_bidItem.productTitle ?? '—'}',
                          style: AppFonts.title2.grey2,
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
                  text: _paymentForm(context),
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
                          style: AppFonts.body1medium.grey2,
                        ),
                      ),
                      if (showCopy)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BTransparentScalableButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _toText(context)),
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
               ,

                // =========================
                // CARRIER
                // =========================

                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [
                    if (_bidItem.isOpened)
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: bStyle(
                            text: context.l.logistician,
                            c: context,
                            vertical: 12,
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
                      )
                    else
                      Expanded(child: _contactButton(context)),
                    Expanded(
                      child: bStyle(

                        text: context.l.additionally,
                        c: context,
                        colorText: widget.isFresh
                            ? AppColors.dobriva
                            : AppColors.yellow,
                        vertical: 12,
                        border: Border.all(
                          color: widget.isFresh
                              ? AppColors.dobriva
                              : AppColors.yellow,
                          width: 1.5,
                        ),
                        colorButt: widget.isFresh
                            ? AppColors.backgroundFreshCand
                            : AppColors.backgroundOrderCard,
                        onPressed: () => widget.onPressed(
                          model: _bidItem,
                        ),
                      ),
                    )
                  ],
                )
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
                color:
                 AppColors.mainGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSet(_bidItem.fermerName))
                    orderInfo(
                      header: context.l.fullName,
                      text: _bidItem.fermerName ?? '',
                    ),
                  if (isSet(_bidItem.fermerCompany))
                    orderInfo(
                      header: context.l.company,
                      text: _bidItem.fermerCompany ?? '',
                    ),
                  if (isSet(_bidItem.contacts?.district))
                    orderInfo(
                      header: context.l.district,
                      text: _bidItem.contacts?.district ?? '',
                    ),
                  if (isSet(_bidItem.contacts?.city))
                    orderInfo(
                      header: context.l.town,
                      text: _bidItem.contacts?.city ?? '',
                    ),
                  if (isSet(_bidItem.contacts?.addr))
                    orderInfo(
                      header: context.l.address,
                      text: _bidItem.contacts?.addr ?? '',
                    ),
                  if (isSet(_bidItem.contacts?.phone))
                    orderInfo(
                      header: context.l.phone,
                      text: _bidItem.contacts?.phone ?? '',
                    ),
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

  String _paymentForm(BuildContext context) {
    if (_bidItem.ordPaymentType == 1) return context.l.paymentFormF1;
    if (_bidItem.ordPaymentType == 2) return context.l.paymentFormF2;
    return context.l.allPaymentForm;
  }

  String _toText(BuildContext context) {
    final lines = <String>[
      '${context.l.product}: ${_bidItem.productTitle ?? '—'}',
    ];

    if (_bidItem.myPrice?.matched == true &&
        _bidItem.myPrice!.badge.isNotEmpty) {
      lines.add(_bidItem.myPrice!.badge);
    }
    if (isSet(_bidItem.dayLabel)) {
      lines.add(_bidItem.dayLabel!);
    }
    if (_bidItem.myPrice?.matched == true &&
        _bidItem.myPrice!.responseLabel.isNotEmpty) {
      lines.add(_bidItem.myPrice!.responseLabel);
    }

    void addRow(String header, String text) {
      lines.add('$header: $text');
    }

    addRow(
      context.l.volume,
      '${_bidItem.amount ?? '—'} ${context.l.amountTypeTon}',
    );
    addRow(context.l.harvestYear, '${_bidItem.year ?? '—'}');
    addRow(context.l.region, _bidItem.regionName ?? '—');
    addRow(context.l.formOfPayment, _paymentForm(context));
    addRow(
      context.l.typeOfDelivery,
      localizeDeliveryType(_bidItem.deliveryType ?? '-', context),
    );
    lines.add(
      '${context.l.applicationNo} ${_bidItem.orderId} '
      '${context.l.from} ${_bidItem.orderCreatedHum ?? ''}',
    );

    if (_bidItem.isOpened && _bidItem.openedPhon != null) {
      if (isSet(_bidItem.fermerName)) {
        addRow(context.l.fullName, _bidItem.fermerName!);
      }
      if (isSet(_bidItem.fermerCompany)) {
        addRow(context.l.company, _bidItem.fermerCompany!);
      }
      if (isSet(_bidItem.contacts?.district)) {
        addRow(context.l.district, _bidItem.contacts!.district!);
      }
      if (isSet(_bidItem.contacts?.city)) {
        addRow(context.l.town, _bidItem.contacts!.city!);
      }
      if (isSet(_bidItem.contacts?.addr)) {
        addRow(context.l.address, _bidItem.contacts!.addr!);
      }
      if (isSet(_bidItem.contacts?.phone)) {
        addRow(context.l.phone, _bidItem.contacts!.phone!);
      }
    }

    return lines.join('\n');
  }

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
                  colorButt: AppColors.mainGreen,
                  onPressed: () => _onContactClick(context),
                ),
              ],
            ),
    );
  }
}
