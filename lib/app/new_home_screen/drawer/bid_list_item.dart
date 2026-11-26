import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:agro/app/bid_detail/components/bid_detail_ui.dart';
import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/app/my_price/components/my_price_match_style.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/components/app_tag.dart';
import 'package:agro/ui/components/product_type.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/trade_localizers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BidListItem extends StatefulWidget {
  final BidItem bidItem;
  final Function({required BidItem model}) onPressed;
  final bool isFresh;

  /// Injected in tests; the card builds its own otherwise.
  final BidItemController? actions;

  const BidListItem({
    super.key,
    required this.isFresh,
    required this.bidItem,
    required this.onPressed,
    this.actions,
  });

  @override
  State<BidListItem> createState() => _BidListItemState();
}

class _BidListItemState extends State<BidListItem> {
  /// Same tested contact/carrier logic as the bid screen.
  late final BidItemController _actions;

  final NewHomeController _newHomeController = Get.find<NewHomeController>();

  BidItem get _bidItem => _actions.bidItem;

  @override
  void initState() {
    super.initState();
    _actions = (widget.actions ?? BidItemController())
      ..ui = ScreenBidDetailUi(context);
    _actions.bid.value = widget.bidItem;
  }

  @override
  void didUpdateWidget(covariant BidListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bidItem != widget.bidItem) {
      _actions.bid.value = widget.bidItem;
    }
  }

  @override
  void dispose() {
    _actions.onClose();
    super.dispose();
  }

  ProductType get _type => ProductType.fromSphere(_bidItem.sphereId);

  /// Server day colors mapped onto the palette; null keeps the tag neutral.
  Color? get _dayColor => switch (_bidItem.dayColor) {
        'yellow' => Palette.wheat,
        'pink' => Palette.tariffVip,
        'red' => Palette.red,
        _ => null,
      };

  // =========================
  // CONTACT
  // =========================

  void _onLaunchPhone(
    BuildContext context,
    String phone,
  ) {
    showCallSheet(context, phone);
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) => Obx(() => _buildCard(context));

  Widget _buildCard(BuildContext context) {
    final bool isDistrib = _newHomeController.modelUser.role == 'distrib';
    final bool showCopy = isDistrib &&
        (_type == ProductType.fertilizer || _type == ProductType.grain);
    final meta = _bidItem.myPrice;
    final matched = meta?.matched == true;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: BTransparentScalableButton(
        onPressed: () => widget.onPressed(model: _bidItem),
        scale: ScaleFormat.small,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: matchCardColor(meta, Palette.bg1),
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(
              color: matchBorderColor(
                  meta, widget.isFresh ? Palette.green : Palette.line),
              width: widget.isFresh || matched ? 1.2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _top(context, showCopy: showCopy),
              if (matched && meta!.responseLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(meta.responseLabel,
                    style:
                        AppText.label.copyWith(color: Palette.textSecondary)),
              ],
              const SizedBox(height: 10),
              _numbers(context),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              if (_bidItem.isOpened) _seller(context) else _actionsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _top(BuildContext context, {required bool showCopy}) {
    final meta = _bidItem.myPrice;
    final region = _bidItem.regionName;
    return Row(children: [
      TypeBadge(_type),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_bidItem.productTitle ?? '—',
                style: AppText.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text.rich(
              TextSpan(children: [
                if (isSet(region))
                  TextSpan(
                      text: '${region!}  ',
                      style: AppText.bodyMedium
                          .copyWith(color: Palette.textSecondary)),
                TextSpan(
                    text: '№${_bidItem.orderId ?? ''}',
                    style:
                        AppText.caption.copyWith(color: Palette.textTertiary)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      if (meta?.matched == true && meta!.badge.isNotEmpty) ...[
        AppTag(meta.badge, color: Palette.green),
        const SizedBox(width: 6),
      ],
      if (widget.isFresh)
        AppTag(context.l.freshBid, color: Palette.green)
      else if (isSet(_bidItem.dayLabel))
        AppTag(_bidItem.dayLabel!, color: _dayColor),
      if (showCopy)
        IconButton(
          tooltip: context.l.copiedToClipboard,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
              width: minTouchTarget, height: minTouchTarget),
          icon: const Icon(Icons.copy_rounded,
              size: 20, color: Palette.textSecondary),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _toText(context)));
            inAppNotification(
              text: context.l.copiedToClipboard,
              c: context,
              type: SnackType.success,
            );
          },
        ),
    ]);
  }

  Widget _numbers(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // A big volume shrinks to fit instead of pushing the details out.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${_bidItem.amount ?? '—'}', style: AppText.numL),
              TextSpan(
                  text: ' ${context.l.amountTypeTon}',
                  style:
                      AppText.headline.copyWith(color: Palette.textSecondary)),
            ])),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_paymentForm(context),
                    textAlign: TextAlign.end, style: AppText.bodyMedium),
                // Always labelled: a bare «Будь-який» says nothing.
                Text(
                    '${context.l.typeOfDelivery}: '
                    '${localizeDeliveryType(_bidItem.deliveryType ?? '', context)}',
                    textAlign: TextAlign.end,
                    style:
                        AppText.label.copyWith(color: Palette.textSecondary)),
                if (_bidItem.year != null)
                  Text(context.l.harvestOf('${_bidItem.year}'),
                      style: AppText.caption
                          .copyWith(color: Palette.textTertiary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? get _phone => [
        _bidItem.contacts?.phone,
        _bidItem.fermerPhone,
        _bidItem.openedPhon,
      ].firstWhere(isSet, orElse: () => null);

  Widget _seller(BuildContext context) {
    final who =
        [_bidItem.fermerName, _bidItem.fermerCompany].where(isSet).join(' · ');
    final phone = _phone;
    if (who.isEmpty && phone == null) {
      // Opened but nothing to show here: the details screen has it all.
      return AppButton(
        label: context.l.additionally,
        style: AppButtonStyle.secondary,
        size: AppButtonSize.small,
        expand: false,
        onPressed: () => widget.onPressed(model: _bidItem),
      );
    }
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (who.isNotEmpty) Text(who, style: AppText.bodyMedium),
            if (phone != null)
              Text(phone, style: AppText.num.copyWith(color: Palette.green)),
          ],
        ),
      ),
      if (phone != null)
        AppIconButton(
          icon: Icons.call_rounded,
          tooltip: context.l.call,
          style: AppIconButtonStyle.filled,
          onPressed: () => _onLaunchPhone(context, phone),
        ),
    ]);
  }

  Widget _actionsRow(BuildContext context) {
    final price = _bidItem.contactPrice ?? 0;
    return Row(children: [
      Expanded(
        child: AppButton(
          label: price > 0
              ? '${context.l.openContact} · $price ${AppConstants.currencySymbolUah}'
              : context.l.openContact,
          size: AppButtonSize.small,
          loading: _actions.openingContact.value,
          onPressed: _actions.onContactClick,
        ),
      ),
      const SizedBox(width: 8),
      AppIconButton(
        icon: Icons.chevron_right_rounded,
        tooltip: context.l.additionally,
        onPressed: () => widget.onPressed(model: _bidItem),
      ),
    ]);
  }

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

    if (_bidItem.isOpened) {
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
      final phone = _phone;
      if (phone != null) addRow(context.l.phone, phone);
    }

    return lines.join('\n');
  }
}
