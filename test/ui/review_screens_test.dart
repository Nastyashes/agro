import 'package:agro/app/review/components/block_review.dart';
import 'package:agro/app/review/components/review_controller.dart';
import 'package:agro/app/review/review_screen.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/model_review/model_review.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/review_controller_test.dart' show FakeRepo;

/// Contract: reviews are shown in the dark design with each review's own
/// rating; an empty list explains itself and offers to add one; the add
/// sheet never sends an empty comment.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
  });
  tearDown(Get.reset);

  late FakeRepo repo;

  Future<void> pump(WidgetTester tester, List<ModelReview> items) async {
    repo = FakeRepo()..next = items;
    Get.put(ReviewController(repository: repo, orderId: 9));
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const ReviewScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('each review shows its own rating, no white cards',
      (tester) async {
    await pump(tester, [
      ModelReview(rating: 3, comment: 'Нормально', date: '01.11.2026'),
      ModelReview(rating: 5, comment: 'Чудово', date: '02.11.2026'),
    ]);

    expect(find.text('Нормально'), findsOneWidget);
    expect(find.text('01.11.2026'), findsOneWidget);
    final stars = tester
        .widgetList<RatingStarsView>(find.byType(RatingStarsView))
        .map((w) => w.rating);
    expect(stars, [3, 5]);
    expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            (w.color == Colors.white ||
                (w.decoration is BoxDecoration &&
                    (w.decoration as BoxDecoration).color == Colors.white))),
        findsNothing);
  });

  testWidgets('empty: explains and offers to add; empty comment not sent',
      (tester) async {
    await pump(tester, const []);

    expect(find.text('Відгуків поки немає'), findsOneWidget);
    await tester.tap(find.widgetWithText(InkWell, 'Додати відгук').last);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Додати відгук').last);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
  });
}
