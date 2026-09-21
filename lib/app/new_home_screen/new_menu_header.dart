import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/text_field/text_field.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:agro/ui/utils/date_extensions.dart';

class NewHomeHeader extends StatelessWidget {
  const NewHomeHeader({
    super.key,
    required this.tariff,
    required this.onPressed,
    required this.baslance,
    required this.isSearchOpen,
    required this.searchController,
    required this.onToggleSearch,
    required this.onSearchChanged,
    this.searchFocusNode,
  });

  final Tariff? tariff;
  final int? baslance;
  final VoidCallback onPressed;
  final bool isSearchOpen;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final FocusNode? searchFocusNode;

  @override
  Widget build(BuildContext context) {
    final isByPiece = (tariff?.isPremium == true || tariff?.isVip == true);

    return Row(
      children: [
        InkWell(
          onTap: onPressed,
          child: const Icon(
            Icons.menu_rounded,
            color: AppColors.mainGreen,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isSearchOpen
                ? TextFieldWidget(
                    key: const ValueKey('header_search'),
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.backgroundGradient3),
                    text: context.l.search,
                    height: 46,
                    textStyle: AppFonts.body2medium.white,
                    hintStyle: AppFonts.body1medium.grey4,
                    openKeyboardAuto: true,
                    colorBg: AppColors.backgroundOrderCard,
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: onSearchChanged,
                  )
                : Row(
                    key: const ValueKey('header_info'),
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isByPiece)
                        headerItem(
                          tariff?.balanceEnd?.formatDateShort() ?? '',
                          context.l.tariffDuration,
                          isValid: tariff?.balanceEnd?.isActive() ?? true,
                        ),
                      headerItem(
                        context.uahAmount(baslance ?? 0),
                        context.l.youBalance,
                        isValid: true,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onToggleSearch,
          child: Icon(
            isSearchOpen ? Icons.close_rounded : Icons.search,
            color: AppColors.mainGreen,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget headerItem(String value, String description, {bool isValid = true}) {
    return Column(children: [
      readText(
        text: value,
        style: isValid ? AppFonts.body1bold.mainGreen : AppFonts.body1bold.red,
      ),
    ]);
  }
}
