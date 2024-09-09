import 'package:agro/app/components/block_page_screen.dart';
import 'package:agro/app/profile/tariffs/tariff_item.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/buttons/b_style.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TariffsController tariffsController = Get.find();
  late PageController _pageViewController;

  @override
  void initState() {
    tariffsController.initPage(context: context, set: setState);
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlockPageScreen(
        headerSize: 20,
        headerColor: AppColors.black,
        topbarColor: AppColors.white,
        header: context.l.tariffs,
        isBack: true,
        theme:
            SystemUiOverlayStyle.dark.copyWith(statusBarColor: AppColors.white),
        onPressedReturn: () {
          tariffsController.onBack(context);
        },
        child: Column(
          children: [
            Expanded(
                child: PageView(
                    controller: _pageViewController,
                    onPageChanged: (int page) {
                      tariffsController.onPageChanged(page);
                    },
                    children: [
                  ...tariffsController.tariffs.asMap().entries.map((entry) {
                    int index = entry.key;
                    ModelTariff item = entry.value;
                    return TariffItem(modelTariff: item, isMyTariff: getMyLabelVisible(index, tariffsController.tariff),);
                  }).toList(),
                ])),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            const SizedBox(height: 20),
            SizedBox(
                height: 60,
                child: tariffsController.buyButtonVisible
                    ? bStyle(
                        text: context.l.buyPackage,
                        c: context,
                        colorText: AppColors.white,
                        vertical: 15,
                        onPressed: () {
                          tariffsController.onPayTariff(
                              tariffsController
                                  .tariffs[tariffsController.currentPageIndex],
                              context);
                        })
                    : const SizedBox()),
            const SizedBox(height: 30)
          ],
        ));
  }

  Widget _indicator(bool isActive) {
    return SizedBox(
      height: 10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: AppColors.mainGreen.withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? AppColors.mainGreen : AppColors.grey2,
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 3; i++) {
      list.add(i == tariffsController.currentPageIndex
          ? _indicator(true)
          : _indicator(false));
    }
    return list;
  }
}

bool isDateBetween(DateTime date, DateTime startDate, DateTime endDate) {
  // Ensure that the startDate is before the endDate
  if (startDate.isAfter(endDate)) {
    throw ArgumentError('Start date must be before end date');
  }

  return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
      (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
}

bool getMyLabelVisible(int index, Tariff? tariff) {
  switch (index) {
    case 2:
      return tariff?.isVip == true;
    case 1:
      return tariff?.isPremium == true;
    case 0:
      return tariff?.isBeslim == true;
  }
  return true;
}
