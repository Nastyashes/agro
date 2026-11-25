import 'dart:developer';

import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/my_price_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/app_components/appbar_with_back.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
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
    return Obx(() => Scaffold(
          body: Stack(
            children: [
              const AppBackground(),
              SafeArea(
                child: Column(
                  children: [
                    appBarBack(
                      controller.tabIndex.value == 0
                          ? l.myCombinations
                          : l.reservations,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: bStyle(
                        colorButt: AppColors.yellow,
                        vertical: 12,
                        text: l.createCombination,
                        colorText: AppColors.backgroundGradient1,
                        c: context,
                        onPressed: controller.onCreate,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.mainGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              _tab(l.myCombinations, 0),
                              _tab(l.reservations, 1),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
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
            ],
          ),
        ));
  }

  Widget _tab(String title, int index) {
    final selected = controller.tabIndex.value == index;
    return Expanded(
        child: GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.body1medium.copyWith(
            color: selected ? AppColors.white : AppColors.mainGreen,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    ));
  }

  Widget _list() {
    final isReservations = controller.tabIndex.value == 1;
    final items = isReservations
        ? controller.overview.value.reservations
        : controller.overview.value.combinations;
    log(
      'MyPrice _list tab=${isReservations ? 'reservations' : 'combinations'} '
      'shown=${items.length} '
      'ids=${items.map((e) => '${e.id}:${e.status}').toList()}',
    );
    if (items.isEmpty) {
      return isReservations
          ? EmptyState(
              title: context.l.emptyReservations,
              icon: Icons.bookmark_border_rounded)
          : EmptyState(
              title: context.l.myPriceEmpty, icon: Icons.bar_chart_rounded);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return _card(items[index], reservation: isReservations);
      },
    );
  }

  Widget _card(MyPriceEntry entry, {required bool reservation}) {
    final overview = controller.overview.value;
    final l = context.l;
    final deleted = !reservation && entry.isDeleted;
    final cardColor = reservation
        ? AppColors.myPriceCardReserwBg
        : deleted
            ? AppColors.myPriceCardDelBg
            : AppColors.myPriceCardBg;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.5,
            color: cardColor,
          )),
      child: Column(
        children: [
          _row(l.productLabel, overview.productName(entry)),
          _row(l.region, overview.regionName(entry)),
          _row(l.paymentForm, overview.paymentName(entry)),
          _row(
            l.priceLabel,
            '${entry.pricePerTon ?? '—'} ${l.perTon}',
          ),
          if (reservation)
            _row(l.queuePosition, '${entry.queuePosition ?? '—'}'),
          _row(
            (reservation) ? l.willTakeEffect : l.validLabel,
            '${l.validFrom} ${entry.formatDate(entry.startsAt)}   ${l.validTo} ${entry.formatDate(entry.endsAt)}',
          ),
          if (!reservation && !deleted)
            Divider(
              height: 1,
              color: AppColors.myPriceCardBg,
            ),
          if (!reservation && !deleted) ...[
            const SizedBox(height: 8),
            Row(children: [
              TextButton.icon(
                onPressed: () =>
                    controller.onEdit(entry, reservation: reservation),
                icon: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.mainGreen,
                  size: 22,
                ),
                label: Text(l.edit,
                    style: AppFonts.body1semibold
                        .copyWith(color: AppColors.mainGreen)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => controller.deleteEntry(entry),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.daysRed,
                  size: 22,
                ),
                label: Text(l.delete,
                    style: AppFonts.body1semibold
                        .copyWith(color: AppColors.daysRed)),
              ),
            ]),
          ],
        ],
      ),
    );
    if (!deleted) return card;
    return Opacity(opacity: 0.7, child: card);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppFonts.body2medium.grey2)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppFonts.body2bold.white,
            ),
          ),
        ],
      ),
    );
  }
}
