import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/config/home_page_contract.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets(
    'phase 4 assembles home page sections from contract and mock data',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-header-greeting')), findsOneWidget);
      expect(find.byKey(const Key('home-mood-insight-card')), findsOneWidget);
      expect(find.byKey(const Key('home-support-prompt-card')), findsOneWidget);

      expect(
        find.byKey(const Key('home-activity-section-header')),
        findsOneWidget,
      );
      expect(find.text(HomePageContract.activitySectionTitle), findsOneWidget);
      expect(find.byKey(const Key('home-activity-section')), findsOneWidget);
      expect(
        find.byKey(const Key('home-activity-metric-aktivitas')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-activity-metric-selesai')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-activity-metric-belum')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('home-latest-articles-section-header')),
        findsOneWidget,
      );
      expect(
        find.text(HomePageContract.latestArticlesSectionTitle),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-latest-articles-section')),
        findsOneWidget,
      );

      expect(find.byKey(const Key('home-bottom-nav-beranda')), findsOneWidget);
      expect(
        find.byKey(const Key('home-bottom-nav-konsultasi')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-bottom-nav-aktivitas')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-bottom-nav-profil')), findsOneWidget);
    },
  );

  testWidgets('phase 4 layout remains stable on compact viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text(HomePageContract.latestArticlesSectionTitle),
      findsOneWidget,
    );
  });
}
