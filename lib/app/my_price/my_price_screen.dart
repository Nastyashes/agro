import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/my_price_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/app_tag.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/components/segmented.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPriceScreen extends StatefulWidget {
  const MyPriceScreen({super.key});

  @override
  State<MyPriceScreen> createState() => _MyPriceScreenState();
}

class _MyPriceScreenState extends State<MyPriceScreen> {
  late final MyPriceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyPriceController());
    controller.ui =
        ScreenMyPriceUi(context, mainController: controller.mainController);
  }

  @override
  void dispose() {
    Get.delete<MyPriceController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Obx(() {
      final overview = controller.overview.value;
      return Scaffold(
        backgroundColor: Palette.bg0,
        body: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: l.myPrice,
                trailing: AppIconButton(
                  icon: Icons.add_rounded,
                  tooltip: l.createCombinationTitle,
                  style: AppIconButtonStyle.filled,
                  onPressed: controller.onCreate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Segmented(
                  items: [
                    SegmentItem(l.myCombinations,
                        count: controller.loadPage.value
                            ? overview.combinations.length
                            : null),
                    SegmentItem(l.reservations,
                        count: controller.loadPage.value
                            ? overview.reservations.length
                            : null),
                  ],
                  selected: controller.tabIndex.value,
                  onChanged: controller.selectTab,
                ),
              ),
              Expanded(
                child: !controller.loadPage.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: controller.loadOverview,
                        child: _list(),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _list() {
    final l = context.l;
    final isReservations = controller.tabIndex.value == 1;
    final items = isReservations
        ? controller.overview.value.reservations
        : controller.overview.value.combinations;
    if (items.isEmpty && controller.loadFailed.value) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: [
          EmptyState(
            icon: Icons.cloud_off_rounded,
            title: l.loadFailedTitle,
            text: l.checkInternet,
            actionLabel: l.retry,
            onAction: controller.loadOverview,
          ),
        ],
      );
    }
    if (items.isEmpty) {
      // Scrollable, so pull-to-refresh still works on an empty tab.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: [
          isReservations
              ? EmptyState(
                  title: l.emptyReservations,
                  icon: Icons.bookmark_border_rounded)
              : EmptyState(
                  title: l.emptyCombinationsTitle,
                  text: l.emptyCombinationsText,
                  icon: Icons.bar_chart_rounded,
                  actionLabel: l.createCombinationTitle,
                  onAction: controller.onCreate,
                  primaryAction: true,
                ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final entry = items[index];
        final overview = controller.overview.value;
        return CombinationCard(
          entry: entry,
          productName: overview.productName(entry),
          regionName: overview.regionName(entry),
          paymentName: overview.paymentName(entry),
          reservation: isReservations,
          onEdit: () => controller.onEdit(entry, reservation: isReservations),
          onDelete: () => controller.deleteEntry(entry),
        );
      },
    );
  }
}

/// One My price entry: status, term, product, price; Edit/Delete only for
/// an active (not deleted) combination, never for a reservation.
class CombinationCard extends StatelessWidget {
  const CombinationCard({
    super.key,
    required this.entry,
    required this.productName,
    required this.regionName,
    required this.paymentName,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
  });

  final MyPriceEntry entry;
  final String productName, regionName, paymentName;
  final bool reservation;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final deleted = !reservation && entry.isDeleted;
    final editable = !reservation && !deleted;
    final progress = editable
        ? combinationProgress(entry.startsAt, entry.endsAt,
            DateTime.now().millisecondsSinceEpoch ~/ 1000)
        : null;

    final card = Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, editable ? 6 : 14),
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: Palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (reservation)
              AppTag(l.reservations, color: Palette.blue)
            else if (entry.isActive)
              AppTag(l.statusActive, color: Palette.green)
            else if (deleted)
              AppTag(l.statusDeleted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${entry.formatDate(entry.startsAt)} → '
                '${entry.formatDate(entry.endsAt)}',
                style: AppText.num.copyWith(color: Palette.textTertiary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName, style: AppText.title),
                  const SizedBox(height: 2),
                  Text(
                    '$regionName · $paymentName',
                    style: AppText.label.copyWith(color: Palette.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // A long price shrinks to fit next to the product name.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: _price(entry.pricePerTon),
                    style: AppText.numL.copyWith(
                        color:
                            editable ? Palette.green : Palette.textSecondary),
                  ),
                  TextSpan(
                      text: ' ${l.uahShort}/${l.tonShort}',
                      style:
                          AppText.label.copyWith(color: Palette.textSecondary)),
                ])),
              ),
            ),
          ]),
          if (reservation && entry.queuePosition != null) ...[
            const SizedBox(height: 8),
            Text('${l.queuePosition}: ${entry.queuePosition}',
                style: AppText.label.copyWith(color: Palette.textSecondary)),
          ],
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: progress, minHeight: 3),
            ),
          ],
          if (editable) ...[
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: AppButton(
                  label: l.edit,
                  style: AppButtonStyle.ghost,
                  size: AppButtonSize.small,
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
              Expanded(
                child: AppButton(
                  label: l.delete,
                  style: AppButtonStyle.danger,
                  size: AppButtonSize.small,
                  icon: Icons.delete_outline_rounded,
                  onPressed: onDelete,
                ),
              ),
            ]),
          ],
        ],
      ),
    );
    return deleted ? Opacity(opacity: 0.5, child: card) : card;
  }

  static String _price(double? value) {
    if (value == null) return '—';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }
}

/// Share of the combination's term already passed (0..1), or null when
/// the dates are unknown or invalid.
double? combinationProgress(int? startsAt, int? endsAt, int nowSeconds) {
  if (startsAt == null || endsAt == null || endsAt <= startsAt) return null;
  return ((nowSeconds - startsAt) / (endsAt - startsAt)).clamp(0.0, 1.0);
}
