import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('phase 5 wires section and card interactions', (tester) async {
    await tester.pumpWidget(const TestableHomeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-mood-insight-card')));
    await tester.pumpAndSettle();
    expect(find.text('Rangkuman mood hari ini segera hadir.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-support-prompt-card')));
    await tester.pumpAndSettle();
    expect(find.text('Fitur teman cerita akan segera hadir.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-activity-see-all-action')));
    await tester.pumpAndSettle();
    expect(find.text('Daftar aktivitas lengkap segera hadir.'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
    await tester.pumpAndSettle();

    final articlesSeeAllAction = find.byKey(
      const Key('home-articles-see-all-action'),
    );
    await tester.ensureVisible(articlesSeeAllAction);
    await tester.tap(articlesSeeAllAction);
    await tester.pumpAndSettle();
    expect(find.text('Daftar artikel lengkap segera hadir.'), findsOneWidget);

    final firstArticleCard = find.byKey(
      const Key('home-article-time-management'),
    );
    await tester.ensureVisible(firstArticleCard);
    await tester.tap(firstArticleCard);
    await tester.pumpAndSettle();
    expect(find.textContaining('Membuka artikel:'), findsOneWidget);
  });

  testWidgets('phase 5 updates selected bottom nav state on tap', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const TestableHomeApp());
    await tester.pumpAndSettle();

    final berandaNode = tester.getSemantics(
      find.byKey(const Key('home-bottom-nav-beranda')),
    );
    expect(berandaNode.hasFlag(SemanticsFlag.isSelected), isTrue);

    await tester.tap(find.byKey(const Key('home-bottom-nav-aktivitas')));
    await tester.pumpAndSettle();

    final berandaAfter = tester.getSemantics(
      find.byKey(const Key('home-bottom-nav-beranda')),
    );
    final aktivitasAfter = tester.getSemantics(
      find.byKey(const Key('home-bottom-nav-aktivitas')),
    );

    expect(berandaAfter.hasFlag(SemanticsFlag.isSelected), isFalse);
    expect(aktivitasAfter.hasFlag(SemanticsFlag.isSelected), isTrue);
    expect(find.text('Fitur Aktivitas akan segera hadir.'), findsOneWidget);

    semantics.dispose();
  });
}

class TestableHomeApp extends StatelessWidget {
  const TestableHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}
