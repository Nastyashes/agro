import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/my_price_deals_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/app_components/appbar_with_back.dart';
import 'package:agro/ui/app_components/empty_list_widget.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
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
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Column(
              children: [
                appBarBack(context.l.deals),
                Expanded(
                  child: Obx(() => controller.initialLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.items.isEmpty
                          ? emptyListDefault(l.emptyDeals, AppColors.darkGreen)
                          : NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification.metrics.pixels >
                                        notification.metrics.maxScrollExtent -
                                            80 &&
                                    controller.hasMore &&
                                    !controller.loadingMore.value) {
                                  controller.loadDeals();
                                }
                                return false;
                              },
                              child: RefreshIndicator(
                                onRefresh: () =>
                                    controller.loadDeals(reset: true),
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: controller.items.length +
                                      (controller.loadingMore.value ? 1 : 0),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, index) {
                                    if (index >= controller.items.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    return _dealCard(controller.items[index]);
                                  },
                                ),
                              ),
                            )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dealCard(MyPriceDealItem item) {
    return GestureDetector(
      onTap: item.orderId == null
          ? null
          : () => Get.toNamed(
                Routes.bidItemScreen,
                arguments: {'orderId': item.orderId},
              ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundGradient1.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.orderTitle ?? item.productTitle ?? '#${item.orderId}',
              style: AppFonts.body1bold.white,
            ),
            const SizedBox(height: 8),
            Text(
              [
                item.regionTitle,
                item.createdHuman,
                if (item.chargedAmount != null)
                  '${item.chargedAmount} ${context.l.uahShort}',
              ].whereType<String>().join(' · '),
              style: AppFonts.body3medium.white,
            ),
          ],
        ),
      ),
    );
  }
}
