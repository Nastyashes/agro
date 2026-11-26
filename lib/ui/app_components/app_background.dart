import 'package:agro/generated/assets.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// «Чорнозем» background: near-black with faint wheat at the bottom.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.bg0,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: 0.14,
        child: Image.asset(Assets.bgZerno,
            width: double.infinity, fit: BoxFit.fitWidth),
      ),
    );
  }
}
