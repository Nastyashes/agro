import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/my_price_deals_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPriceDealsScreen extends StatefulWidget {
  const MyPriceDealsScreen({super.key});

  @override
  State<MyPriceDealsScreen> createState() => _MyPriceDealsScreenState();
}

class _MyPriceDealsScreenState extends State<MyPriceDealsScreen> {
  late final MyPriceDealsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyPriceDealsController());
    controller.ui =
        ScreenMyPriceUi(context, mainController: Get.find<MainController>());
  }

  @override
  void dispose() {
    Get.delete<MyPriceDealsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Palette.bg0,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l.deals),
            Expanded(
              child: Obx(() {
                if (controller.initialLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadDeals(reset: true),
                  child: controller.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 80),
                          children: [
                            controller.loadFailed.value
                                ? EmptyState(
                                    icon: Icons.cloud_off_rounded,
                                    title: l.loadFailedTitle,
                                    text: l.checkInternet,
                                    actionLabel: l.retry,
                                    onAction: () =>
                                        controller.loadDeals(reset: true),
                                  )
                                : EmptyState(
                                    title: l.emptyDeals,
                                    text: l.emptyDealsText,
                                    icon: Icons.handshake_outlined,
                                  ),
                          ],
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n.metrics.pixels >
                                    n.metrics.maxScrollExtent - 80 &&
                                controller.hasMore &&
                                !controller.loadingMore.value) {
                              controller.loadDeals();
                            }
                            return false;
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              _DealsGroup(items: controller.items),
                              if (controller.loadingMore.value)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                            ],
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealsGroup extends StatelessWidget {
  const _DealsGroup({required this.items});

  final List<MyPriceDealItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            DealRow(item: items[i]),
          ],
        ]),
      ),
    );
  }
}

/// One deal: icon, bid title, region and time, amount charged; opens the bid.
class DealRow extends StatelessWidget {
  const DealRow({super.key, required this.item});

  final MyPriceDealItem item;

  @override
  Widget build(BuildContext context) {
    final orderId = item.orderId;
    final charged = item.chargedAmount;
    return InkWell(
      onTap: orderId == null
          ? null
          : () => Get.toNamed(
                Routes.bidItemScreen,
                arguments: {'orderId': orderId},
              ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Palette.bg3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.handshake_outlined,
                size: 20, color: Palette.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.orderTitle ?? item.productTitle ?? '#$orderId',
                    style: AppText.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(
                  [item.regionTitle, item.createdHuman]
                      .whereType<String>()
                      .where((e) => e.isNotEmpty)
                      .join(' · '),
                  style: AppText.caption.copyWith(color: Palette.textTertiary),
                ),
              ],
            ),
          ),
          if (charged != null) ...[
            const SizedBox(width: 8),
            Text(context.uahAmount(_amount(charged)),
                style: AppText.num.copyWith(color: Palette.textSecondary)),
          ],
          if (orderId != null)
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Palette.textTertiary),
        ]),
      ),
    );
  }

  static String _amount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
