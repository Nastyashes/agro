import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles of the «Чорнозем» design: one family (Nunito), no letter
/// spacing, primary text color. Recolor with `.copyWith(color: …)`.
abstract final class AppText {
  static TextStyle _n(double size, FontWeight weight, double height,
          {bool tabular = false}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: 0,
        color: Palette.textPrimary,
        fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
      );

  static final display = _n(30, FontWeight.w800, 1.15);
  static final title = _n(21, FontWeight.w700, 1.25);
  static final headline = _n(17, FontWeight.w700, 1.3);
  static final body = _n(15, FontWeight.w500, 1.4);
  static final bodyMedium = _n(15, FontWeight.w600, 1.4);
  static final label = _n(13, FontWeight.w600, 1.3);
  static final caption = _n(12, FontWeight.w500, 1.3);
  static final overline = _n(13, FontWeight.w700, 1.3);
  static final button = _n(16, FontWeight.w700, 1.2);
  static final tag = _n(12, FontWeight.w700, 1.2);

  // Numbers: volumes, prices, phones. Tabular so columns line up.
  static final numXL = _n(38, FontWeight.w800, 1.05, tabular: true);
  static final numL = _n(24, FontWeight.w800, 1.15, tabular: true);
  static final num = _n(15, FontWeight.w600, 1.3, tabular: true);
}
