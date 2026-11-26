import 'package:flutter/painting.dart';

/// Colors of the «Чорнозем» design (Figma: collection "UAGRO v3 Чорнозем",
/// source tools/figma-plugin-proposals/code.js). New UI uses only these;
/// [AppColors] stays until each old screen is moved over.
abstract final class Palette {
  // Surfaces, darkest first.
  static const bg0 = Color(0xFF050706);
  static const bg1 = Color(0xFF0C110E);
  static const bg2 = Color(0xFF141B16);
  static const bg3 = Color(0xFF1C251F);

  static const line = Color(0xFF222D25);
  static const lineStrong = Color(0xFF33423A);

  static const textPrimary = Color(0xFFEEF3EE);
  static const textSecondary = Color(0xFF9AA79C);
  static const textTertiary = Color(0xFF5E6B61);
  static const textInverse = Color(0xFF050706);

  static const green = Color(0xFF21D759);
  static const greenDeep = Color(0xFF0F7A33);
  static const greenSoft = Color(0x1F21D759); // 12%
  static const wheat = Color(0xFFE8C35A);
  static const wheatSoft = Color(0x21E8C35A); // 13%
  static const red = Color(0xFFFF5D5D);
  static const redSoft = Color(0x1FFF5D5D); // 12%
  static const blue = Color(0xFF7FA7FF);
  static const blueSoft = Color(0x217FA7FF); // 13%

  // Product types (bid card marks and filters).
  static const typeGrain = Color(0xFFE9C46A);
  static const typeFertilizer = Color(0xFF7CC6FE);
  static const typeSeeds = Color(0xFFB794F6);
  static const typeOil = Color(0xFFF4A261);

  // Tariffs.
  static const tariffPremium = Color(0xFF21D759);
  static const tariffVip = Color(0xFFFF7A9C);
  static const tariffUnlim = Color(0xFF7FA7FF);

  static const hot = Color(0xFFFF6B3D);
  static const telegram = Color(0xFF2AABEE);
  static const scrim = Color(0xA8000000); // 66%

  /// The same hue at [opacity], for the "soft" tag and icon backgrounds.
  static Color soft(Color c, [double opacity = 0.16]) =>
      c.withValues(alpha: opacity);
}

/// Corner radii used by the design.
abstract final class Radii {
  static const tag = 6.0;
  static const buttonSmall = 12.0;
  static const button = 14.0;
  static const card = 18.0;
  static const sheet = 24.0;
  static const pill = 100.0;
}

/// Smallest tappable size (iOS HIG 44 pt; Android asks 48 dp, 44 is the
/// floor used across the design).
const double minTouchTarget = 44;
