import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:agro/app/bid_detail/components/bid_detail_ui.dart';
import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/app/my_price/components/my_price_match_style.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/components/app_tag.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/info_group.dart';
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

class BidDetailScreen extends StatefulWidget {
  const BidDetailScreen({super.key, this.controller, this.item});

  /// Injected in tests; otherwise built here and read from route arguments.
  final BidItemController? controller;
  final BidItem? item;

  @override
  State<BidDetailScreen> createState() => _BidDetailScreenState();
}

class _BidDetailScreenState extends State<BidDetailScreen> {
  late final BidItemController controller;

  bool get _isTrader {
    return SessionStorage.instance.user?.isTraider ?? false;
  }

  @override
  void initState() {
    controller = widget.controller ?? Get.put(BidItemController());

    BidItem? item = widget.item;
    int? orderId;
    final args = Get.arguments;
    if (args is List && args.isNotEmpty) {
      if (args[0] is BidItem) {
        item = args[0] as BidItem;
      } else {
        orderId = int.tryParse('${args[0]}');
      }
    } else if (args is Map) {
      item = args['item'] as BidItem?;
      orderId = int.tryParse('${args['orderId'] ?? ''}') ?? item?.orderId;
    } else if (args is BidItem) {
      item = args;
    }

    controller.ui = ScreenBidDetailUi(context);
    controller.initPage(
      item: item,
      orderId: orderId ?? item?.orderId,
    );

    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) Get.delete<BidItemController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loaded = controller.loadPage.value;
      final item = controller.bidItem;
      return Scaffold(
        backgroundColor: Palette.bg0,
        bottomNavigationBar: loaded && _isTrader ? _bottomBar(context) : null,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            AppTopBar(
              title: item.orderId == null
                  ? context.l.bidDetails
                  : '${context.l.applicationNo}${item.orderId}',
              trailing: loaded
                  ? AppIconButton(
                      icon: Icons.content_copy_rounded,
                      tooltip: context.l.copiedToClipboard,
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _toText(context)));
                        inAppNotification(
                            text: context.l.copiedToClipboard,
                            c: context,
                            type: SnackType.success);
                      },
                    )
                  : null,
            ),
            Expanded(
              child: !loaded
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: _content(context, item),
                    ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _content(BuildContext context, BidItem item) {
    final meta = item.myPrice;
    final matched = meta?.matched == true;
    final type = ProductType.fromSphere(item.sphereId);
    final c = item.contacts;
    final phone = _phone(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          TypeBadge(type, size: 32),
          const SizedBox(width: 10),
          Text(type.label(context),
              style: AppText.overline.copyWith(color: type.color)),
          const SizedBox(width: 8),
          if (isSet(item.dayLabel)) AppTag(item.dayLabel!),
          if (matched && meta!.badge.isNotEmpty) ...[
            const SizedBox(width: 6),
            AppTag(meta.badge, color: Palette.green),
          ],
        ]),
        const SizedBox(height: 12),
        Text(item.productTitle ?? '—', style: AppText.display),
        if (matched && meta!.responseLabel.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: matchCardColor(meta, Palette.bg1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: matchBorderColor(meta, Palette.line)),
            ),
            child: Text(meta.responseLabel, style: AppText.bodyMedium),
          ),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _keyFigure(
            context.l.volume,
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '${item.amount ?? AppConstants.emDash}',
                  style: AppText.numXL),
              TextSpan(
                  text: ' ${context.l.tonShort}',
                  style: AppText.title.copyWith(color: Palette.textSecondary)),
            ])),
          ),
          const SizedBox(width: 24),
          if (item.year != null)
            _keyFigure(
                context.l.harvest, Text('${item.year}', style: AppText.numL)),
        ]),
        SectionLabel(context.l.conditions),
        InfoGroup(children: [
          InfoRow(context.l.region, item.regionName ?? '—'),
          if (isSet(c?.district)) InfoRow(context.l.district, c!.district!),
          InfoRow(
              context.l.payment, _paymentForm(context, item.ordPaymentType)),
          InfoRow(context.l.delivery,
              localizeDeliveryType(item.deliveryType ?? '-', context)),
        ]),
        if (item.isOpened) ...[
          SectionLabel(context.l.seller),
          InfoGroup(children: [
            if (isSet(item.fermerName))
              InfoRow(context.l.fullName, item.fermerName!),
            if (isSet(item.fermerCompany))
              InfoRow(context.l.company, item.fermerCompany!),
            if (isSet(c?.city)) InfoRow(context.l.town, c!.city!),
            if (isSet(c?.addr)) InfoRow(context.l.address, c!.addr!),
            if (phone != null)
              InfoRow(context.l.phoneNumber, phone,
                  valueColor: Palette.green,
                  onTap: () => _launchPhone(context, phone)),
            if (isSet(c?.email)) InfoRow(context.l.eMail, c!.email!),
          ]),
        ] else if (_isTrader) ...[
          SectionLabel(context.l.seller),
          _LockedSeller(text: context.l.sellerLocked),
        ],
        if (_isTrader) ...[
          SectionLabel(context.l.services),
          InfoGroup(children: [
            if (item.isOpened) _carrierRow(context),
            if (item.isOpened) _analysisRow(context),
            ActionRow(
              icon: Icons.reviews_outlined,
              title: context.l.reviews,
              onTap: controller.onReview,
            ),
          ]),
        ],
      ],
    );
  }

  Widget _keyFigure(String label, Widget value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.caption.copyWith(color: Palette.textTertiary)),
          value,
        ],
      );

  Widget _carrierRow(BuildContext context) {
    final busy = controller.orderingCarrier.value;
    final done = controller.carrierOrdered.value;
    return ActionRow(
      icon: Icons.local_shipping_outlined,
      title: done ? context.l.carrierOrdered : context.l.bookCarrier,
      trailing: busy ? context.l.orderingCarrier : null,
      done: done,
      onTap: busy || done ? null : controller.onOrderCarrier,
    );
  }

  Widget _analysisRow(BuildContext context) {
    final busy = controller.orderingAnalysis.value;
    final done = controller.analysisOrdered.value;
    return ActionRow(
      icon: Icons.science_outlined,
      title: context.l.qualityAnalysis,
      trailing: busy ? '…' : null,
      done: done,
      onTap: busy || done ? null : controller.onOrderAnalysis,
    );
  }

  Widget _bottomBar(BuildContext context) {
    final item = controller.bidItem;
    final price = item.contactPrice ?? 0;
    final phone = _phone(item);
    final Widget primary;
    if (!item.isOpened) {
      primary = AppButton(
        label: price > 0
            ? '${context.l.openContact} · $price ${AppConstants.currencySymbolUah}'
            : context.l.openContact,
        loading: controller.openingContact.value,
        onPressed: controller.onContactClick,
      );
    } else if (phone != null) {
      primary = AppButton(
        label: context.l.call,
        icon: Icons.call_rounded,
        onPressed: () => _launchPhone(context, phone),
      );
    } else {
      primary = const SizedBox.shrink();
    }
    final deal = AppButton(
      label: context.l.agreement,
      style: AppButtonStyle.secondary,
      expand: false,
      onPressed: controller.onDeal,
    );
    return Container(
      decoration: const BoxDecoration(
        color: Palette.bg0,
        border: Border(top: BorderSide(color: Palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            if (primary is SizedBox)
              Expanded(child: deal)
            else ...[
              // Sized by its label (at least 110), so ru/kk do not wrap.
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 110),
                child: deal,
              ),
              const SizedBox(width: 8),
              Expanded(child: primary),
            ],
          ]),
        ),
      ),
    );
  }

  String? _phone(BidItem item) => [
        item.contacts?.phone,
        item.fermerPhone,
        item.openedPhon,
      ].firstWhere(isSet, orElse: () => null);

  void _launchPhone(BuildContext context, String phone) {
    showCallSheet(context, phone);
  }

  String _paymentForm(BuildContext context, int? type) {
    if (type == 1) return context.l.paymentFormF1;
    if (type == 2) return context.l.paymentFormF2;
    return context.l.allPaymentForm;
  }

  String _toText(BuildContext context) {
    final item = controller.bidItem;
    final meta = item.myPrice;
    final lines = <String>[
      '${context.l.applicationNo} ${item.orderId ?? ''} '
              '${context.l.from} ${item.orderCreatedHum ?? ''}'
          .trim(),
      '${context.l.product}: ${item.productTitle ?? '—'}',
    ];

    if (meta != null && meta.matched && meta.badge.isNotEmpty) {
      lines.add(meta.badge);
    }
    if (meta != null && meta.matched && meta.responseLabel.isNotEmpty) {
      lines.add(meta.responseLabel);
    }

    void addRow(String header, String? value, {bool show = true}) {
      if (!show) return;
      final text = (value == null || value.isEmpty) ? '—' : value;
      lines.add('$header: $text');
    }

    final contacts = item.contacts;
    addRow(context.l.region, item.regionName);
    addRow(
      context.l.district,
      contacts?.district,
      show: contacts?.district != null && contacts!.district!.isNotEmpty,
    );
    addRow(
      context.l.town,
      contacts?.city,
      show: contacts?.city != null && contacts!.city!.isNotEmpty,
    );
    addRow(
      context.l.address,
      contacts?.addr,
      show: contacts?.addr != null && contacts!.addr!.isNotEmpty,
    );
    addRow(
      context.l.company,
      item.fermerCompany,
      show: item.fermerCompany != null && item.fermerCompany!.isNotEmpty,
    );
    addRow(
      context.l.fullName,
      item.fermerName,
      show: item.fermerName != null && item.fermerName!.isNotEmpty,
    );
    addRow(
      context.l.volume,
      '${item.amount ?? AppConstants.emDash} ${context.l.tonShort}',
    );
    addRow(context.l.harvestYear, '${item.year ?? '—'}');
    addRow(context.l.formOfPayment, _paymentForm(context, item.ordPaymentType));
    addRow(
      context.l.typeOfDelivery,
      localizeDeliveryType(item.deliveryType ?? '-', context),
    );
    final phone = _phone(item);
    addRow(context.l.phoneNumber, phone, show: phone != null);
    addRow(
      context.l.eMail,
      contacts?.email,
      show: contacts?.email != null && contacts!.email!.isNotEmpty,
    );

    return lines.join('\n');
  }
}

/// Dashed box that says what opens with the contact.
class _LockedSeller extends StatelessWidget {
  const _LockedSeller({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Icon(Icons.lock_outline_rounded,
                size: 20, color: Palette.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: AppText.body.copyWith(color: Palette.textSecondary)),
            ),
          ]),
        ),
      );
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16));
    canvas.drawRRect(rrect, Paint()..color = Palette.bg1);
    final paint = Paint()
      ..color = Palette.lineStrong
      ..style = PaintingStyle.stroke;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
