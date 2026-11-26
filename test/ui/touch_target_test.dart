import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_filter_chip.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/ui/theme/text_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contract (BUG-043): every tappable control is at least [minTouchTarget]
/// tall, drawn 1:1; text follows the system size between 1.0 and 1.3.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<Size> sizeOf(WidgetTester tester, Widget w, Finder f) async {
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(), home: Scaffold(body: Center(child: w))));
    return tester.getSize(f);
  }

  testWidgets('small and large buttons', (tester) async {
    for (final size in AppButtonSize.values) {
      final s = await sizeOf(
          tester,
          AppButton(label: 'OK', size: size, onPressed: () {}),
          find.byType(InkWell));
      expect(s.height, greaterThanOrEqualTo(minTouchTarget), reason: '$size');
    }
  });

  // Chips are a compact secondary control (owner asked for smaller ones,
  // 2026-11-26); they stay at least 32 tall and wide enough to hit.
  testWidgets('filter chip', (tester) async {
    final s = await sizeOf(
        tester,
        AppFilterChip(
            label: 'Всі', icon: Icons.apps, selected: true, onTap: () {}),
        find.byType(InkWell));
    expect(s.height, greaterThanOrEqualTo(32));
    expect(s.width, greaterThanOrEqualTo(minTouchTarget));
  });

  testWidgets('icon button default', (tester) async {
    final s = await sizeOf(
        tester,
        AppIconButton(icon: Icons.menu, tooltip: 'Меню', onPressed: () {}),
        find.byType(AppIconButton));
    expect(s.height, greaterThanOrEqualTo(minTouchTarget));
    expect(s.width, greaterThanOrEqualTo(minTouchTarget));
  });

  test('text scale: system size within 1.0…1.3', () {
    expect(appTextScaler(const TextScaler.linear(0.8)).scale(10), 10);
    expect(appTextScaler(const TextScaler.linear(1.15)).scale(10),
        closeTo(11.5, 1e-9));
    expect(appTextScaler(const TextScaler.linear(2.0)).scale(10), 13);
  });
}
