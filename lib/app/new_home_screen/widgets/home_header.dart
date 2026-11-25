import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/app_tag.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/ui/utils/date_extensions.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// Home header: menu (with unread dot), balance with the tariff, wallet
/// (top up) and search. In search mode the middle becomes a search field.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.balance,
    required this.tariff,
    required this.unreadCount,
    required this.isSearchOpen,
    required this.searchController,
    required this.onMenu,
    required this.onTopUp,
    required this.onToggleSearch,
    required this.onSearchChanged,
    this.searchFocusNode,
  });

  final int balance;
  final Tariff? tariff;
  final int unreadCount;
  final bool isSearchOpen;
  final TextEditingController searchController;
  final FocusNode? searchFocusNode;
  final VoidCallback onMenu;
  final VoidCallback onTopUp;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        AppIconButton(
          icon: Icons.menu_rounded,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: onMenu,
          badge: unreadCount > 0 ? const UnreadDot() : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isSearchOpen ? _search(context) : _balance(context),
          ),
        ),
        const SizedBox(width: 12),
        if (!isSearchOpen) ...[
          _WalletButton(onPressed: onTopUp),
          const SizedBox(width: 8),
        ],
        AppIconButton(
          icon: isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
          tooltip: isSearchOpen
              ? MaterialLocalizations.of(context).closeButtonTooltip
              : context.l.search,
          onPressed: onToggleSearch,
        ),
      ]),
    );
  }

  Widget _balance(BuildContext context) {
    final t = tariff;
    final paid = t != null && (t.isPremium || t.isVip);
    final until = t?.balanceEnd;
    return Column(
      key: const ValueKey('balance'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l.balance,
            style: AppText.caption.copyWith(color: Palette.textTertiary)),
        Row(children: [
          Flexible(
            child: Text(context.uahAmount(balance),
                style: AppText.numL,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          if (t != null)
            AppTag(
              t.isVip
                  ? 'VIP'
                  : t.isPremium
                      ? 'Premium'
                      : 'Free',
              color: t.isVip
                  ? Palette.tariffVip
                  : t.isPremium
                      ? Palette.tariffPremium
                      : Palette.wheat,
            ),
        ]),
        if (paid && until != null)
          Text(
            context.l.tariffUntil(until.formatDateShort()),
            style: AppText.caption.copyWith(
                color: until.isActive() ? Palette.textTertiary : Palette.red),
          ),
      ],
    );
  }

  Widget _search(BuildContext context) {
    return TextField(
      key: const ValueKey('search'),
      controller: searchController,
      focusNode: searchFocusNode,
      autofocus: true,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      style: AppText.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        hintText: context.l.search,
        prefixIcon: const Icon(Icons.search_rounded,
            size: 20, color: Palette.textSecondary),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

/// Wallet with a small "+": opens the top-up dialog.
class _WalletButton extends StatelessWidget {
  const _WalletButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.account_balance_wallet_rounded,
      tooltip: context.l.topUpBalance,
      style: AppIconButtonStyle.soft,
      onPressed: onPressed,
      badge: Transform.translate(
        offset: const Offset(2, 32),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Palette.green,
            shape: BoxShape.circle,
            border: Border.all(color: Palette.bg0, width: 2),
          ),
          child: const Icon(Icons.add_rounded,
              size: 12, color: Palette.textInverse),
        ),
      ),
    );
  }
}
