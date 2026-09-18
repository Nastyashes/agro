import 'package:agro/app/new_home_screen/drawer/menu_item.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

class AppMenuDrawer extends StatelessWidget {
  final String userName;
  final String phone;
  final String? tariffLabel;
  final int unreadNotifications;
  final String adsPrice;
  final bool showTopUp;
  final bool showDisableAds;
  final bool showMyPrice;
  final bool showDeals;
  final bool showTariffs;
  final VoidCallback? onTopUp;
  final VoidCallback? onMyPrice;
  final VoidCallback? onDeals;
  final VoidCallback? onInfoMessages;
  final VoidCallback? onTariffs;
  final VoidCallback? onSite;
  final VoidCallback? onQrScan;
  final VoidCallback? onSupport;
  final VoidCallback? onPrivacy;
  final VoidCallback? onLogout;
  final VoidCallback? onDisableAds;
  final VoidCallback? onDeleteAccount;

  const AppMenuDrawer({
    super.key,
    required this.userName,
    required this.phone,
    this.tariffLabel,
    this.unreadNotifications = 0,
    this.adsPrice =  AppConstants.adsPrice,
    this.showTopUp = true,
    this.showDisableAds = true,
    this.showMyPrice = true,
    this.showDeals = true,
    this.showTariffs = true,
    this.onTopUp,
    this.onMyPrice,
    this.onDeals,
    this.onInfoMessages,
    this.onTariffs,
    this.onSite,
    this.onQrScan,
    this.onSupport,
    this.onPrivacy,
    this.onLogout,
    this.onDisableAds,
    this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return Container(
      color: AppColors.backgroundDrawer,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DrawerHeader(
                userName: userName,
                phone: phone,
                tariffLabel: tariffLabel,
              ),
              if (showTopUp) ...[
                const SizedBox(height: 20),
                bStyle(
                  text: l.topUpBalance,
                  c: context,
                  vertical: 14,
                  onPressed: onTopUp ?? () {},
                ),
              ],
              const SizedBox(height: 12),
              if (showMyPrice)
                MenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: l.myPrice,
                  onPressed: onMyPrice,
                ),
              if (showDeals)
                MenuItem(
                  icon: Icons.article_outlined,
                  title: l.deals,
                  onPressed: onDeals,
                ),
              MenuItem(
                icon: Icons.error_outline,
                title: l.infoMessages,
                badge: unreadNotifications,
                onPressed: onInfoMessages,
              ),
              if (showTariffs)
                MenuItem(
                  icon: Icons.credit_card_outlined,
                  title: l.tariffs,
                  onPressed: onTariffs,
                ),
              MenuItem(
                icon: Icons.public_outlined,
                title: l.ourSite,
                onPressed: onSite,
              ),
              MenuItem(
                icon: Icons.qr_code_scanner_outlined,
                title: l.scanQrCode,
                onPressed: onQrScan,
              ),
              MenuItem(
                icon: Icons.headset_mic_outlined,
                title: l.support,
                onPressed: onSupport,
              ),
              MenuItem(
                icon: Icons.shield_outlined,
                title: l.privacyPolicy,
                onPressed: onPrivacy,
              ),
              MenuItem(
                icon: Icons.logout,
                title: l.logOutOfAccount,
                onPressed: onLogout,
              ),
              if (showDisableAds) ...[
                const SizedBox(height: 16),
                bStyle(
                  text: '${l.disableBanner}(${context.uahAmount(adsPrice)})',
                  c: context,
                  vertical: 14,
                  onPressed: onDisableAds ?? () {},
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: MenuItem(
                  icon: Icons.delete_outline,
                  title: l.deleteProfile,
                  iconColor: AppColors.red,
                  titleColor: AppColors.red,
                  showChevron: false,
                  showDivider: false,
                  onPressed: onDeleteAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String userName;
  final String phone;
  final String? tariffLabel;

  const _DrawerHeader({
    required this.userName,
    required this.phone,
    required this.tariffLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: AppFonts.title2.additionalGreen),
              const SizedBox(height: 4),
              Text(phone, style: AppFonts.body2medium.additionalGreen),
            ],
          ),
        ),
        if (tariffLabel != null && tariffLabel!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundOrderCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.yellow, width: 1.5),
            ),
            child: Text(
              tariffLabel!,
              style: AppFonts.body2bold.copyWith(color: AppColors.premiumText),
            ),
          ),
      ],
    );
  }
}
