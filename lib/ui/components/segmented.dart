import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

class SegmentItem {
  const SegmentItem(this.label, {this.count});

  final String label;
  final int? count;
}

/// Two or more equal tabs in one rounded track; the selected one is raised.
class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentItem> items;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.line),
      ),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected ? Palette.bg3 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(items[i].label,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodyMedium.copyWith(
                                color: i == selected
                                    ? Palette.textPrimary
                                    : Palette.textSecondary)),
                      ),
                      if (items[i].count != null) ...[
                        const SizedBox(width: 6),
                        Text('${items[i].count}',
                            style: AppText.num.copyWith(
                                color: Palette.textTertiary)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
