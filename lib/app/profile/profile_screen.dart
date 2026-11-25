import 'package:agro/data/session_storage.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/valid_themes.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../generated/assets.dart';
import 'components/block_setting.dart';
import 'components/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();

    controller.setState = setState;
    controller.initPage(context);
  }

  @override
  Widget build(BuildContext context) {
    final String? selectedCountry = SessionStorage.instance.country;

    return Scaffold(
        appBar: AppBar(
          title:
              readText(text: context.l.profile, style: AppFonts.title1.white),
          centerTitle: true,
          backgroundColor: AppColors.mainGreen,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: ValidThemes(
            theme: const SystemUiOverlayStyle(
                statusBarColor: AppColors.mainGreen,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark),
            child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Stack(alignment: Alignment.topCenter, children: [
                      Container(color: AppColors.mainGreen, height: 170),
                      Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 40),
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Card(
                                elevation: 2,
                                shape: const CircleBorder(),
                                child: SvgPicture.asset(Assets.profile,
                                    width: 200, height: 200),
                              ))),
                      Positioned(
                        bottom: 0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              readText(
                                  text: context.l.myTariff,
                                  style: AppFonts.body1medium,
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 10)),
                              Container(
                                decoration: BoxDecoration(
                                    color: controller.tariff?.isVip == true
                                        ? AppColors.tariffVip
                                        : controller.tariff?.isPremium == true
                                            ? AppColors.tariffPremium
                                            : AppColors.tariffBezlim,
                                    borderRadius: BorderRadius.circular(100)),
                                child: readText(
                                    text: controller.tariff?.isVip == true
                                        ? 'VIP'
                                        : controller.tariff?.isPremium == true
                                            ? 'Premium'
                                            : controller.tariff?.isFree == true
                                                ? 'Free'
                                                : context.l.myTariff,
                                    style: AppFonts.body2medium.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5)),
                              ),
                            ]),
                      ),
                    ]),
                    readText(
                        text: controller.modelUser.value.phone.toString(),
                        style: AppFonts.title2,
                        padding: const EdgeInsets.only(
                          top: 20,
                        )),
                    if (controller.isAdsDisabled)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: readText(
                          text: context.l
                              .adsDisabledUntil(controller.adsDisabledUntilText),
                          style: AppFonts.body1medium.copyWith(
                            color: AppColors.mainGreen,
                          ),
                        ),
                      )
                    else if (controller.shouldShowAds)
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Stack(
                                children: [
                                  bStyle(
                                    text: "${context.l.disableBanner} (${context.uahAmount(controller.adsPrice)})",
                                    c: context,
                                    colorText: AppColors.white,
                                    vertical: 15,
                                    onPressed: () => showDisableAdsConfirm(
                                      context,
                                      amount: controller.adsPrice,
                                      onConfirm: () =>
                                          controller.disableAds(context),
                                    ),
                                  ),
                                  Positioned(
                                    left: -7,
                                    top: -8,
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(Assets.newBadge),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ))),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 0, bottom: 35),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              BlockSetting(
                                header: context.l.scanQrCode,
                                icon: Assets.qrScan,
                                onPressed: () => controller.onQrScan(),
                              ),
                              BlockSetting(
                                  header: context.l.ourSite,
                                  icon: Assets.accountSite,
                                  onPressed: controller.onSite),
                              BlockSetting(
                                  header: context.l.support,
                                  icon: Assets.accountQuestion,
                                  onPressed: controller.onHelp),
                              BlockSetting(
                                  header: context.l.privacyPolicy,
                                  icon: Assets.accountPrivacy,
                                  onPressed: controller.onPrivacy),
                              controller.modelUser.value.isTraider ||
                                      selectedCountry == Country.ukraine.name
                                  ? BlockSetting(
                                      header: context.l.tariffs,
                                      icon: Assets.accountTariffs,
                                      onPressed: controller.onTariffs)
                                  : const SizedBox(),
                              BlockSetting(
                                  header: context.l.deleteProfile,
                                  icon: Assets.accountDelete,
                                  onPressed: () =>
                                      controller.onDeleteAccount(context)),
                              BlockSetting(
                                header: context.l.logOutOfProfile,
                                icon: Assets.accountExit,
                                onPressed: () => controller.onExit(context),
                              )
                            ],
                          ),
                        ))
                  ],
                )))));
  }
}
