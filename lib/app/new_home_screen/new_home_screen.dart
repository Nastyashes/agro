import 'package:agro/ui/app_components/empty_list_widget.dart';
import 'package:agro/ui/pop_up/top_up_balance_popup.dart';
import 'package:agro/app/new_home_screen/drawer/app_menu_drawer.dart';
import 'package:agro/app/new_home_screen/banner_in_list.dart';
import 'package:agro/app/new_home_screen/drawer/bid_list_item.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/app/new_home_screen/new_menu_header.dart';
import 'package:agro/app/profile/components/account_session_actions.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:agro/controllers/app_controller.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/app_components/complete_widget.dart';
import 'package:agro/ui/load/footer_load.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<NewHomeController>()
        ? Get.find<NewHomeController>()
        : Get.put<NewHomeController>(NewHomeController(), permanent: true);

    if (Get.isRegistered<AppController>()) {
      Get.find<AppController>().initPage();
    }

    controller.initPage(
      context: context,
      set: setState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // =========================
      // DRAWER
      // =========================

      drawer: Drawer(
        width: MediaQuery.of(context).size.width > 500
            ? 380
            : MediaQuery.of(context).size.width * 0.85,
        child: Obx(
          () => AppMenuDrawer(
          userName:
              controller.mainController.userfield['name']?.toString() ?? '',
          phone: controller.modelUser.phone ?? '',
          tariffLabel: _tariffLabel(),
          adsPrice: AppConstants.adsPrice,
          showDisableAds: controller.shouldShowAds,
          showMyPrice: controller.modelUser.isTraider &&
              controller.mainController.myPriceEnabled.value,
          showDeals: controller.modelUser.isTraider &&
              controller.mainController.myPriceEnabled.value,
          showTariffs: controller.modelUser.isTraider ||
              Hive.box('data').get('selectedCountry') == Country.ukraine.name,
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
          onDisableAds: () async {
            Navigator.pop(context);
            await controller.disableAds(context);
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

      body: Stack(children: [
        const AppBackground(),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // =========================
              // HEADER
              // =========================

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (drawerContext) {
                          return Obx(
                            () => NewHomeHeader(
                              baslance: controller.balance,
                              tariff: controller.mainController.tariff,
                              unreadCount: controller.unreadInformCount.value,
                              isSearchOpen: controller.isSearchOpen,
                              searchController: controller.searchController,
                              searchFocusNode: controller.searchFocusNode,
                              onToggleSearch: controller.toggleSearch,
                              onSearchChanged: (_) => controller.onSearch(),
                              onPressed: () {
                                Scaffold.of(drawerContext).openDrawer();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // SEARCH
              // only All applications
              // =========================
             const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HomeTabs(
                  allCount: controller.mainController.tariff?.orderCount,
                  selectedTab: controller.selectedTab,
                  showFresh: controller.isFree,
                  onChanged: controller.selectTab,
                ),
              ),
      //        const SizedBox(height: 8),

              // =========================
              // CONTENT
              // =========================

              Expanded(
                child: controller.selectedTab == NewHomeTab.fresh &&
                        controller.isFree
                    ? _buildFreshList()
                    : _buildAllList(),
              ),
            ],
          ),
        ),
      ]),
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
        waterDropColor: AppColors.mainGreen,
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
          waterDropColor: AppColors.mainGreen,
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
                ? [ emptyListDefault(  context.l.noFreshApplications, AppColors.dobriva.withValues(alpha: 0.4),)]
           //         _EmptyFreshApplications(),
                  
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
            imageUrl:
                controller.adBanner?.image ?? AppConstants.fallbackAdImage,
            phoneNumber:
                controller.adBanner?.phone ?? AppConstants.fallbackAdPhone,
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
        print('topUp selected amount=$amount');
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

// ============================================================
// TABS
// ============================================================
class _HomeTabs extends StatelessWidget {
  final NewHomeTab selectedTab;
  final bool showFresh;
  final ValueChanged<NewHomeTab> onChanged;
  final int? allCount;
  final int? freshCount;

  const _HomeTabs({
    this.allCount,
    this.freshCount,
    required this.selectedTab,
    required this.showFresh,
    required this.onChanged,
  });

  String _title(String text, int? count) {
    return count != null ? '$text ($count)' : text;
  }

  @override
  Widget build(BuildContext context) {
    if (!showFresh) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _title(context.l.allApplications, allCount),
          style: AppFonts.title2.withColor(
            AppColors.mainGreen,
          ),
        ),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color:  AppColors.mainGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              text: _title(context.l.allApplications, allCount),
              selected: selectedTab == NewHomeTab.all,
              onPressed: () {
                onChanged(NewHomeTab.all);
              },
            ),
          ),
          Expanded(
            child: _TabItem(
              text: _title(context.l.freshApplications, freshCount),
              selected: selectedTab == NewHomeTab.fresh,
              onPressed: () {
                onChanged(NewHomeTab.fresh);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;

  const _TabItem({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.mainGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: AppFonts.body1medium.copyWith(
            color: selected ? AppColors.white : AppColors.mainGreen,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY FRESH
// ============================================================

class _EmptyFreshApplications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.dobriva.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.dobriva,
          ),
        ),
        child: Text(
          context.l.noFreshApplications,
          style: AppFonts.body1medium.black,
        ),
      ),
    );
  }
}
