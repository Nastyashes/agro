import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Key facts of a bid as labelled tiles, two per row: every value has its
/// caption above it, so "Будь-який" or "1ф." are never left unexplained.
/// [dense] is the bid-card variant: tighter padding and smaller values.
class FactsGrid extends StatelessWidget {
  const FactsGrid({super.key, required this.facts, this.dense = false});

  final List<(String, String)> facts;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    Widget tile((String, String) f) => Padding(
          padding: dense
              ? const EdgeInsets.fromLTRB(10, 4, 8, 5)
              : const EdgeInsets.fromLTRB(12, 7, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                      color: Palette.textTertiary,
                      fontSize: dense ? 12 : null)),
              if (!dense) const SizedBox(height: 1),
              Text(f.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: dense
                      ? AppText.label.copyWith(color: Palette.textPrimary)
                      : AppText.headline),
            ],
          ),
        );
    final rows = <Widget>[];
    for (var i = 0; i < facts.length; i += 2) {
      if (i > 0) rows.add(const Divider(height: 1));
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: tile(facts[i])),
          const VerticalDivider(width: 1),
          Expanded(
              child: i + 1 < facts.length
                  ? tile(facts[i + 1])
                  : const SizedBox.shrink()),
        ]),
      ));
    }
    return Container(
      decoration: BoxDecoration(
        color: dense ? Palette.bg2 : Palette.bg1,
        borderRadius: BorderRadius.circular(dense ? 10 : 16),
        border: Border.all(color: Palette.line),
      ),
      child: Column(children: rows),
    );
  }
}
