import 'package:agro/app/home/components/home_controller.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import 'components/butt_bottom_navigation.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    final isFreeTariff = homeController.tariff?.isPremium != true &&
        homeController.tariff?.isVip != true;
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xffE8E8E8).withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(color: AppColors.mainGreen),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SizedBox(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          buttBottomNavigation(
                              icon: Assets.bottomNavigationHome,
                              text: context.l.yourApplications,
                              buttNum: 0,
                              c: context,
                              isNew: false),
                          buttBottomNavigation(
                              icon: Assets.bottomNavigationAllApplications,
                              text: 'Fresh',
                              buttNum: 3,
                              c: context,
                              isNew: true),
                          buttBottomNavigation(
                              icon: Assets.bottomNavigationHelp,
                              text: context.l.support,
                              buttNum: 1,
                              c: context,
                              isNew: false),
                          buttBottomNavigation(
                              icon: Assets.bottomNavigationProfile,
                              text: context.l.profile,
                              buttNum: 2,
                              c: context,
                              isNew: isFreeTariff),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
