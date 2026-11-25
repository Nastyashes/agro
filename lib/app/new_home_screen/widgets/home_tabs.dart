import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/ui/components/app_filter_chip.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// "Заявки" title with the total, and All / Fresh chips (free tariff only).
class HomeTabs extends StatelessWidget {
  const HomeTabs({
    super.key,
    this.allCount,
    required this.selectedTab,
    required this.showFresh,
    required this.onChanged,
  });

  final NewHomeTab selectedTab;
  final bool showFresh;
  final ValueChanged<NewHomeTab> onChanged;
  final int? allCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(context.l.applications, style: AppText.display),
            if (allCount != null) ...[
              const SizedBox(width: 10),
              Text('$allCount',
                  style: AppText.num.copyWith(color: Palette.textTertiary)),
            ],
          ],
        ),
        if (showFresh) ...[
          const SizedBox(height: 12),
          Row(children: [
            AppFilterChip(
              label: context.l.all,
              icon: Icons.apps_rounded,
              solid: true,
              selected: selectedTab == NewHomeTab.all,
              onTap: () => onChanged(NewHomeTab.all),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: context.l.freshShort,
              icon: Icons.bolt_rounded,
              selected: selectedTab == NewHomeTab.fresh,
              onTap: () => onChanged(NewHomeTab.fresh),
            ),
          ]),
        ],
      ],
    );
  }
}
