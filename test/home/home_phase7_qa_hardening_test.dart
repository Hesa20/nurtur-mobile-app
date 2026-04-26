import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets(
    'phase 7 home avoids overflow on narrow Android viewport with high text scaling',
    (tester) async {
      tester.view.physicalSize = const Size(280, 620);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.45)),
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('home-mood-insight-card')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('home-support-prompt-card')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final articleSeeAll = find.byKey(
        const Key('home-articles-see-all-action'),
      );
      await tester.ensureVisible(articleSeeAll);
      expect(articleSeeAll, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('home-bottom-nav-aktivitas')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phase 7 semantics expose home card, metric, article, and nav metadata',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const HomePage(),
          ),
        );
        await tester.pumpAndSettle();

        final moodCardNode = tester.getSemantics(
          find.byKey(const Key('home-mood-insight-card')),
        );
        expect(moodCardNode.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(moodCardNode.label, contains('Mood Hari Ini'));

        final supportCardNode = tester.getSemantics(
          find.byKey(const Key('home-support-prompt-card')),
        );
        expect(supportCardNode.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(supportCardNode.label, contains('Butuh teman cerita?'));

        final activityMetricNode = tester.getSemantics(
          find.byKey(const Key('home-activity-metric-aktivitas')),
        );
        expect(activityMetricNode.label, contains('Statistik Aktivitas'));
        expect(activityMetricNode.value, '5');

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        final articleCard = find.byKey(
          const Key('home-article-time-management'),
        );
        await tester.ensureVisible(articleCard);

        final articleNode = tester.getSemantics(articleCard);
        expect(articleNode.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(articleNode.label, contains('Artikel:'));

        final berandaNode = tester.getSemantics(
          find.byKey(const Key('home-bottom-nav-beranda')),
        );
        expect(berandaNode.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(berandaNode.hasFlag(SemanticsFlag.isSelected), isTrue);

        await tester.tap(find.byKey(const Key('home-bottom-nav-aktivitas')));
        await tester.pumpAndSettle();

        final aktivitasNode = tester.getSemantics(
          find.byKey(const Key('home-bottom-nav-aktivitas')),
        );
        expect(aktivitasNode.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(aktivitasNode.hasFlag(SemanticsFlag.isSelected), isTrue);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}
