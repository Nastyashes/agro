import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Material theme from the «Чорнозем» tokens, so stock widgets (dialogs,
/// fields, chips, progress, snackbars) look like the design by default.
ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: Palette.green,
    onPrimary: Palette.textInverse,
    primaryContainer: Palette.greenDeep,
    onPrimaryContainer: Palette.textPrimary,
    secondary: Palette.wheat,
    onSecondary: Palette.textInverse,
    error: Palette.red,
    onError: Palette.textInverse,
    surface: Palette.bg1,
    onSurface: Palette.textPrimary,
    onSurfaceVariant: Palette.textSecondary,
    surfaceContainerLowest: Palette.bg0,
    surfaceContainerLow: Palette.bg1,
    surfaceContainer: Palette.bg2,
    surfaceContainerHigh: Palette.bg2,
    surfaceContainerHighest: Palette.bg3,
    outline: Palette.lineStrong,
    outlineVariant: Palette.line,
    scrim: Palette.scrim,
  );

  final text = TextTheme(
    displaySmall: AppText.display,
    headlineSmall: AppText.title,
    titleLarge: AppText.title,
    titleMedium: AppText.headline,
    titleSmall: AppText.bodyMedium,
    bodyLarge: AppText.body,
    bodyMedium: AppText.body,
    bodySmall: AppText.caption.copyWith(color: Palette.textSecondary),
    labelLarge: AppText.button,
    labelMedium: AppText.label,
    labelSmall: AppText.tag,
  );

  RoundedRectangleBorder shape(double r, [BorderSide side = BorderSide.none]) =>
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r), side: side);

  const buttonSize = Size(64, 54);
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.bg0,
    canvasColor: Palette.bg0,
    textTheme: text,
    dividerColor: Palette.line,
    dividerTheme: const DividerThemeData(color: Palette.line, thickness: 1),
    iconTheme: const IconThemeData(color: Palette.textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.bg0,
      foregroundColor: Palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppText.headline,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.green,
        foregroundColor: Palette.textInverse,
        disabledBackgroundColor: Palette.bg3,
        disabledForegroundColor: Palette.textTertiary,
        minimumSize: buttonSize,
        padding: buttonPadding,
        textStyle: AppText.button,
        shape: shape(Radii.button),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette.green,
        foregroundColor: Palette.textInverse,
        disabledBackgroundColor: Palette.bg3,
        disabledForegroundColor: Palette.textTertiary,
        elevation: 0,
        minimumSize: buttonSize,
        padding: buttonPadding,
        textStyle: AppText.button,
        shape: shape(Radii.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.textPrimary,
        minimumSize: buttonSize,
        padding: buttonPadding,
        textStyle: AppText.button,
        side: const BorderSide(color: Palette.lineStrong),
        shape: shape(Radii.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.green,
        minimumSize: const Size(48, 48),
        textStyle: AppText.bodyMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.bg2,
      hintStyle: AppText.body.copyWith(color: Palette.textTertiary),
      labelStyle: AppText.label.copyWith(color: Palette.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.button),
        borderSide: const BorderSide(color: Palette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.button),
        borderSide: const BorderSide(color: Palette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.button),
        borderSide: const BorderSide(color: Palette.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.button),
        borderSide: const BorderSide(color: Palette.red),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Palette.bg2,
      surfaceTintColor: Colors.transparent,
      shape: shape(Radii.sheet, const BorderSide(color: Palette.line)),
      titleTextStyle: AppText.title,
      contentTextStyle: AppText.body.copyWith(color: Palette.textSecondary),
      barrierColor: Palette.scrim,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.bg2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.bg3,
      contentTextStyle: AppText.bodyMedium,
      actionTextColor: Palette.green,
      behavior: SnackBarBehavior.floating,
      shape: shape(16, const BorderSide(color: Palette.lineStrong)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Palette.bg2,
      selectedColor: Palette.textPrimary,
      labelStyle: AppText.label.copyWith(color: Palette.textSecondary),
      secondaryLabelStyle: AppText.label.copyWith(color: Palette.textInverse),
      side: const BorderSide(color: Palette.line),
      shape: shape(Radii.pill),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Palette.green,
      linearTrackColor: Palette.bg3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Palette.textInverse : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Palette.green : null),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Palette.green,
      selectionHandleColor: Palette.green,
    ),
  );
}
