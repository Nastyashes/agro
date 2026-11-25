import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/app/new_home_screen/widgets/home_tabs.dart';
import 'package:agro/app/new_home_screen/home_actions.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/pop_up/top_up_balance_popup.dart';
import 'package:agro/app/new_home_screen/drawer/app_menu_drawer.dart';
import 'package:agro/app/new_home_screen/banner_in_list.dart';
import 'package:agro/app/new_home_screen/drawer/bid_list_item.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/app/new_home_screen/widgets/home_header.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/app/profile/components/account_session_actions.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:agro/controllers/app_controller.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/app_components/complete_widget.dart';
import 'package:agro/ui/load/footer_load.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({
    super.key,
  });

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  late final NewHomeController controller;
  late final Worker _failureWorker;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<NewHomeController>()
        ? Get.find<NewHomeController>()
        : Get.put<NewHomeController>(NewHomeController(), permanent: true);

    if (Get.isRegistered<AppController>()) {
      Get.find<AppController>().initPage();
    }

    controller.initPage();
    _failureWorker = ever(controller.failures, (_) {
      if (mounted) {
        notification(text: context.l.somethingWentWrong, type: SnackType.error);
      }
    });
  }

  @override
  void dispose() {
    _failureWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg0,

      // =========================
      // DRAWER
      // =========================

      drawer: Drawer(
        width: MediaQuery.of(context).size.width > 500
            ? 380
            : MediaQuery.of(context).size.width * 0.85,
        backgroundColor: Palette.bg1,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: Obx(
          () => AppMenuDrawer(
            userName:
                controller.mainController.userfield['name']?.toString() ?? '',
            phone: controller.modelUser.phone ?? '',
            tariffLabel: _tariffLabel(),
            balance: controller.balance,
            onComingSoon: () => notification(text: context.l.comingSoonHint),
            adsPrice: AppConstants.adsPrice,
            showDisableAds: controller.shouldShowAds,
            showMyPrice: controller.modelUser.isTraider &&
                controller.mainController.myPriceEnabled.value,
            showDeals: controller.modelUser.isTraider &&
                controller.mainController.myPriceEnabled.value,
            showTariffs: controller.modelUser.isTraider ||
                SessionStorage.instance.country == Country.ukraine.name,
            onTariffs: () {
              Navigator.pop(context);
              AccountSessionActions.openTariffs();
            },
            onQrScan: () {
              Navigator.pop(context);
              AccountSessionActions.openQrScan();
            },
            onSite: () {
              Navigator.pop(context);
              AccountSessionActions.openSite();
            },
            onSupport: () {
              Navigator.pop(context);
              AccountSessionActions.openSupport();
            },
            onPrivacy: () {
              Navigator.pop(context);
              AccountSessionActions.openPrivacy();
            },
            onLogout: () {
              Navigator.pop(context);
              AccountSessionActions.confirmLogout(context);
            },
            onDeleteAccount: () {
              Navigator.pop(context);
              AccountSessionActions.confirmDeleteAccount(context);
            },
            onDisableAds: () {
              Navigator.pop(context);
              showDisableAdsConfirm(
                context,
                amount: AppConstants.adsPrice,
                onConfirm: () => disableAdsWithFeedback(context),
              );
            },
            onTopUp: () {
              Navigator.pop(context);
              _showTopUp();
            },
            onMyPrice: () {
              Navigator.pop(context);
              Get.toNamed(Routes.myPrice);
            },
            onDeals: () {
              Navigator.pop(context);
              Get.toNamed(Routes.myPriceDeals);
            },
            unreadNotifications: controller.unreadInformCount.value,
            onInfoMessages: () {
              Navigator.pop(context);
              Get.toNamed(Routes.informMessages);
            },
          ),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Builder(
              builder: (drawerContext) => Obx(
                () => HomeHeader(
                  balance: controller.balance,
                  tariff: controller.mainController.tariff,
                  unreadCount: controller.unreadInformCount.value,
                  isSearchOpen: controller.isSearchOpen.value,
                  searchController: controller.searchController,
                  searchFocusNode: controller.searchFocusNode,
                  onMenu: () => Scaffold.of(drawerContext).openDrawer(),
                  onTopUp: _showTopUp,
                  onToggleSearch: controller.toggleSearch,
                  onSearchChanged: (_) => controller.onSearch(),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => HomeTabs(
                    allCount: controller.mainController.tariff?.orderCount,
                    selectedTab: controller.selectedTab.value,
                    showFresh: controller.isFree,
                    onChanged: controller.selectTab,
                  )),
            ),

            // =========================
            // CONTENT
            // =========================

            Expanded(
              child: Obx(() =>
                  controller.selectedTab.value == NewHomeTab.fresh &&
                          controller.isFree
                      ? _buildFreshList()
                      : _buildAllList()),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ALL APPLICATIONS
  // ============================================================

  Widget _buildAllList() {
    return SmartRefresher(
      controller: controller.allRefreshController,
      scrollController: controller.allScrollController,
      enablePullUp: true,
      enablePullDown: true,
      onLoading: controller.onLoadAll,
      onRefresh: controller.onRefreshAll,
      footer: const FooterLoad(),
      header: const WaterDropHeader(
        complete: CompleteWidget(),
        waterDropColor: Palette.green,
      ),
      child: ListView(
        key: const PageStorageKey(
          'new_home_all_applications',
        ),
        controller: controller.allScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 4,
          bottom: 24,
        ),
        children: _buildBidWidgets(
          controller.bids,
          isFresh: false,
        ),
      ),
    );
  }

  // ============================================================
  // FRESH APPLICATIONS
  // ============================================================

  Widget _buildFreshList() {
    return SmartRefresher(
        controller: controller.freshRefreshController,
        scrollController: controller.freshScrollController,
        enablePullUp: true,
        enablePullDown: true,
        onLoading: controller.onLoadFresh,
        onRefresh: controller.onRefreshFresh,
        footer: const FooterLoad(),
        header: const WaterDropHeader(
          complete: CompleteWidget(),
          waterDropColor: Palette.green,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            key: const PageStorageKey(
              'new_home_fresh_applications',
            ),
            controller: controller.freshScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 24,
            ),
            children: controller.bidsFresh.isEmpty
                ? [
                    EmptyState(
                      title: context.l.noFreshApplications,
                      icon: Icons.schedule_rounded,
                    )
                  ]
                : _buildBidWidgets(
                    controller.bidsFresh,
                    isFresh: true,
                  ),
          ),
        ));
  }

  // ============================================================
  // BIDS + ADS
  // ============================================================

  List<Widget> _buildBidWidgets(
    List<BidItem> bids, {
    required bool isFresh,
  }) {
    if (bids.isEmpty) {
      return const [
        SizedBox(height: 40),
      ];
    }

    final result = <Widget>[];

    var bidCounter = 0;

    for (final item in bids) {
      result.add(
        BidListItem(
          key: ValueKey(
            '${isFresh ? 'fresh' : 'all'}_${item.orderId}',
          ),
          isFresh: isFresh,
          bidItem: item,
          onPressed: ({
            required BidItem model,
          }) {
            controller.onPageBidItem(
              item: model,
            );
          },
        ),
      );

      bidCounter++;

      if (controller.shouldShowAds &&
          bidCounter % AppConstants.adEveryBids == 0) {
        result.add(
          BannerItemForList(
            imageUrl: controller.adBanner.value?.image ??
                AppConstants.fallbackAdImage,
            phoneNumber: controller.adBanner.value?.phone ??
                AppConstants.fallbackAdPhone,
          ),
        );
      }
    }

    return result;
  }

  // ============================================================
  // OTHER
  // ============================================================

  void _showTopUp() {
    showTopUpDialog(
      context,
      controller.balance,
      (amount) {
        payBalance(amount, context);
      },
    );
  }

  String _tariffLabel() {
    if (controller.mainController.isVip) {
      return 'VIP';
    }

    if (controller.mainController.isPremium) {
      return 'Premium';
    }

    if (controller.mainController.isFree) {
      return 'Free';
    }

    return '';
  }
}
