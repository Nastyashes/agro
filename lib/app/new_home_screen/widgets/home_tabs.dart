import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// "All / Fresh" tab switch on the home screen.
class HomeTabs extends StatelessWidget {
  final NewHomeTab selectedTab;
  final bool showFresh;
  final ValueChanged<NewHomeTab> onChanged;
  final int? allCount;
  final int? freshCount;

  const HomeTabs({
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
        color: AppColors.mainGreen.withValues(alpha: 0.1),
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
