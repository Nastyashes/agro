import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/app/profile/tariffs/tariff_item.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TariffsScreen extends StatefulWidget {
  const TariffsScreen({super.key});

  @override
  State<TariffsScreen> createState() {
    return TariffsScreenState();
  }
}

class TariffsScreenState extends State<TariffsScreen>
    with TickerProviderStateMixin {
  final TariffsController tariffsController = Get.find();
  late PageController _pageViewController;

  @override
  void initState() {
    super.initState();
    // Neighbour cards peek in from the sides: the list is swipeable.
    _pageViewController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg0,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: context.l.tariffs),
            Expanded(
              child: Obx(() => PageView(
                    controller: _pageViewController,
                    onPageChanged: tariffsController.onPageChanged,
                    children: [
                      for (final entry
                          in tariffsController.tariffs.asMap().entries)
                        TariffItem(
                          modelTariff: entry.value,
                          isMyTariff: getMyLabelVisible(
                              entry.key, tariffsController.tariff),
                        ),
                    ],
                  )),
            ),
            const SizedBox(height: 14),
            Obx(() => _PageDots(
                  count: tariffsController.tariffs.length,
                  current: tariffsController.currentPageIndex.value,
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == current ? Palette.green : Palette.lineStrong,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      );
}

bool getMyLabelVisible(int index, Tariff? tariff) {
  switch (index) {
    case 2:
      return tariff?.isVip == true;
    case 1:
      return tariff?.isPremium == true;
    case 0:
      return tariff?.isFree == true;
  }
  return true;
}
