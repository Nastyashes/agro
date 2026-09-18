import 'package:agro/app/home/bids_pages/bid_binding.dart';
import 'package:agro/app/home/bids_pages/bid_detail_screen.dart';
import 'package:agro/app/home/review/components/review_binding.dart';
import 'package:agro/app/home/review/review_screen.dart';
import 'package:agro/app/inform_messages/inform_messages_screen.dart';
import 'package:agro/app/my_price/create_my_price_screen.dart';
import 'package:agro/app/my_price/edit_my_price_screen.dart';
import 'package:agro/app/my_price/my_price_deals_screen.dart';
import 'package:agro/app/my_price/my_price_screen.dart';
import 'package:agro/app/new_home_screen/new_home_screen.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/load/start_screen.dart';
import 'package:agro/app/profile/components/profile_controller.dart';
import 'package:agro/app/profile/components/scan_qr_code.dart';
import 'package:agro/app/profile/profile_screen.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/app/profile/tariffs/tariffs_screen.dart';
import 'package:agro/auth/auth_confirmation/auth_confirmation_screen.dart';
import 'package:agro/auth/auth_confirmation/components/auth_confirmation_binding.dart';
import 'package:agro/auth/auth_register_ok/auth_register_ok_screen.dart';
import 'package:agro/auth/auth_register_ok/components/auth_register_ok_binding.dart';
import 'package:agro/auth/auth_screen.dart';
import 'package:agro/auth/components/auth_binding.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

part './app_routes.dart';

abstract class AppPages {
  static pages({required BuildContext context}) => [
        GetPage(
          name: '/',
          page: () => const StartScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: Routes.splash,
          page: () => const StartScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
            name: Routes.auth,
            page: () => const AuthScreen(),
            binding: AuthBinding()),
        GetPage(
            name: Routes.authConfirm,
            page: () => const AuthConfirmScreen(),
            binding: AuthConfirmationBinding()),
        GetPage(
          name: Routes.app,
          page: () => const NewHomeScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<NewHomeController>()) {
              Get.put<NewHomeController>(
                NewHomeController(),
                permanent: true,
              );
            }
          }),
        ),
        GetPage(
            name: Routes.authRegisterOk,
            page: () => const AuthRegisterOkScreen(),
            binding: AuthRegisterOkBinding()),
        GetPage(
            name: Routes.review,
            page: () => const ReviewScreen(),
            binding: ReviewBinding()),
        GetPage(
          name: Routes.tariffs,
          page: () => const TariffsScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<TariffsController>(() => TariffsController());
          }),
        ),
        GetPage(name: Routes.scanQrCode, page: () => const QRScannerScreen()),
        GetPage(
          name: Routes.profile,
          page: () => const ProfileScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<ProfileController>(() => ProfileController());
          }),
        ),
        GetPage(name: Routes.country, page: () => const CountryScreen()),
        GetPage(
            name: Routes.bidItemScreen,
            page: () => const BidDetailScreen(),
            binding: BidBinding()),
        GetPage(name: Routes.myPrice, page: () => const MyPriceScreen()),
        GetPage(
            name: Routes.myPriceCreate,
            page: () => const CreateMyPriceScreen()),
        GetPage(
            name: Routes.myPriceEdit, page: () => const EditMyPriceScreen()),
        GetPage(
            name: Routes.myPriceDeals, page: () => const MyPriceDealsScreen()),
        GetPage(
            name: Routes.informMessages,
            page: () => const InformMessagesScreen()),
      ];
}
