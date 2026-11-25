import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:flutter/material.dart';

/// Back button, centered title, optional trailing button.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title, this.trailing, this.onBack});

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: AppText.headline,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        trailing ?? const SizedBox.square(dimension: 44),
      ]),
    );
  }
}
