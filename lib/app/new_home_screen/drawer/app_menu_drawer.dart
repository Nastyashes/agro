import 'package:agro/app/new_home_screen/drawer/menu_item.dart';
import 'package:agro/generated/assets.dart';
import 'package:agro/ui/components/coming_soon_sheet.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// Hidden side menu (client requirement), «Чорнозем» v3+ layout. Items
/// that are not built yet are shown muted with «Незабаром».
class AppMenuDrawer extends StatelessWidget {
  final String userName;
  final String phone;
  final String? tariffLabel;
  final int balance;
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

  /// Tap on a «Незабаром» item.
  final ValueChanged<ComingSoon>? onComingSoon;

  const AppMenuDrawer({
    super.key,
    required this.userName,
    required this.phone,
    this.tariffLabel,
    this.balance = 0,
    this.unreadNotifications = 0,
    this.adsPrice = AppConstants.adsPrice,
    this.showTopUp = true,
    this.showDisableAds = false,
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
    this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Palette.bg1,
        image: DecorationImage(
          image: AssetImage(Assets.bgZerno),
          opacity: 0.14,
          alignment: Alignment.bottomCenter,
          fit: BoxFit.fitWidth,
        ),
      ),
      child: SafeArea(
        // Fills the screen height when it fits (items spread evenly) and
        // scrolls on short screens.
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    // The logo gives way to the tariff chip on narrow drawers.
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(Assets.pictureLogo,
                            height: 32, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (tariffLabel != null && tariffLabel!.isNotEmpty)
                      _TariffChip(
                          label: tariffLabel!,
                          onTap: showTariffs ? onTariffs : null),
                  ]),
                  const SizedBox(height: 8),
                  Text(userName, style: AppText.headline),
                  const SizedBox(height: 2),
                  Text(phone,
                      style:
                          AppText.body.copyWith(color: Palette.textSecondary)),
                  if (showTopUp) ...[
                    const SizedBox(height: 8),
                    _BalanceStrip(balance: balance, onTopUp: onTopUp),
                  ],
                  const SizedBox(height: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MenuItem(
                          icon: Icons.warehouse_outlined,
                          title: l.intake,
                          mark: MenuItemMark.soon,
                          onPressed: () => onComingSoon?.call(ComingSoon(
                              icon: Icons.warehouse_outlined,
                              title: l.intake,
                              description: l.comingSoonIntake)),
                        ),
                        if (showMyPrice)
                          MenuItem(
                            icon: Icons.bar_chart_rounded,
                            title: l.myPrice,
                            mark: MenuItemMark.isNew,
                            onPressed: onMyPrice,
                          ),
                        MenuItem(
                          icon: Icons.assignment_outlined,
                          title: l.myBids,
                          mark: MenuItemMark.soon,
                          onPressed: () => onComingSoon?.call(ComingSoon(
                              icon: Icons.assignment_outlined,
                              title: l.myBids,
                              description: l.comingSoonMyBids)),
                        ),
                        MenuItem(
                          icon: Icons.bookmark_border_rounded,
                          title: l.savedBids,
                          mark: MenuItemMark.soon,
                          onPressed: () => onComingSoon?.call(ComingSoon(
                              icon: Icons.bookmark_border_rounded,
                              title: l.savedBids,
                              description: l.comingSoonSaved)),
                        ),
                        if (showDeals)
                          MenuItem(
                            icon: Icons.handshake_outlined,
                            title: l.deals,
                            onPressed: onDeals,
                          ),
                        MenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: l.messages,
                          badge: unreadNotifications,
                          onPressed: onInfoMessages,
                        ),
                        if (showTariffs)
                          MenuItem(
                            icon: Icons.workspace_premium_outlined,
                            title: l.tariffs,
                            onPressed: onTariffs,
                          ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Divider(height: 1),
                        ),
                        MenuItem(
                          icon: Icons.qr_code_scanner_rounded,
                          title: l.scanQrCode,
                          onPressed: onQrScan,
                        ),
                        MenuItem(
                          icon: Icons.language_rounded,
                          title: l.ourSite,
                          onPressed: onSite,
                        ),
                        MenuItem(
                          icon: Icons.support_agent_rounded,
                          title: l.support,
                          onPressed: onSupport,
                        ),
                        MenuItem(
                          icon: Icons.policy_outlined,
                          title: l.privacyPolicy,
                          onPressed: onPrivacy,
                        ),
                      ],
                    ),
                  ),
                  if (showDisableAds) ...[
                    const SizedBox(height: 8),
                    _OutlineGreenButton(
                      label: '${l.disableBanner.trim()} · '
                          '${context.uahAmount(adsPrice)}',
                      onPressed: onDisableAds,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Wraps to two lines when the labels do not fit.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    children: [
                      _FooterAction(
                        icon: Icons.logout_rounded,
                        label: l.logOut,
                        color: Palette.textSecondary,
                        onTap: onLogout,
                      ),
                      _FooterAction(
                        icon: Icons.delete_outline_rounded,
                        label: l.deleteProfile,
                        color: Palette.red,
                        onTap: onDeleteAccount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TariffChip extends StatelessWidget {
  const _TariffChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Palette.wheatSoft,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: AppText.label.copyWith(color: Palette.wheat)),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: Palette.wheat),
              ],
            ]),
          ),
        ),
      );
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.balance, required this.onTopUp});

  final int balance;
  final VoidCallback? onTopUp;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
        decoration: BoxDecoration(
          color: Palette.bg2,
          borderRadius: BorderRadius.circular(Radii.button),
        ),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet_rounded,
              size: 22, color: Palette.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l.balance,
                    style:
                        AppText.caption.copyWith(color: Palette.textTertiary)),
                Text(context.uahAmount(balance), style: AppText.headline),
              ],
            ),
          ),
          AppButton(
            label: context.l.topUp,
            size: AppButtonSize.small,
            onPressed: onTopUp,
          ),
        ]),
      );
}

class _OutlineGreenButton extends StatelessWidget {
  const _OutlineGreenButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(minTouchTarget),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          foregroundColor: Palette.green,
          side: const BorderSide(color: Palette.green),
        ),
        child: Text(label,
            style: AppText.button.copyWith(color: Palette.green),
            textAlign: TextAlign.center),
      );
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minTouchTarget),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Flexible(
                child: Text(label,
                    style: AppText.bodyMedium.copyWith(color: color))),
          ]),
        ),
      );
}
