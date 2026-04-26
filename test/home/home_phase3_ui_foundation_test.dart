import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_activity_metric_card.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_info_cards.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_section_header.dart';

void main() {
  testWidgets('phase 3 renders reusable home widgets', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const HomeSectionHeader(
                title: 'Aktivitas Hari Ini',
                actionLabel: 'Lihat Semua',
              ),
              const HomeMoodInsightCard(
                content: HomeMoodInsightContent(
                  title: 'Mood Hari Ini',
                  message: 'Sedih.. tetap semangat ya!',
                ),
              ),
              const HomeSupportPromptCard(
                content: HomeSupportPromptContent(
                  title: 'Butuh teman cerita?',
                  description:
                      'Tenang, kamu gak sendirian kok. Ada kami yang siap mendengar ceritamu.',
                  illustrationAssetPath: 'assets/images/login_family_hero.png',
                ),
              ),
              const HomeActivityMetricCard(
                metric: HomeActivityMetric(
                  type: HomeActivityMetricType.aktivitas,
                  label: 'Aktivitas',
                  count: 5,
                ),
                icon: Icons.assignment,
                backgroundColor: Color(0xFFEDE3F4),
                accentColor: Color(0xFF8F45E8),
              ),
              HomeBottomNavigationBar(
                destinations: const [
                  HomeBottomNavDestination(
                    tabId: HomeTabId.beranda,
                    label: 'Beranda',
                  ),
                  HomeBottomNavDestination(
                    tabId: HomeTabId.konsultasi,
                    label: 'Konsultasi',
                  ),
                  HomeBottomNavDestination(
                    tabId: HomeTabId.aktivitas,
                    label: 'Aktivitas',
                  ),
                  HomeBottomNavDestination(
                    tabId: HomeTabId.profil,
                    label: 'Profil',
                  ),
                ],
                selectedTab: HomeTabId.beranda,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(HomeSectionHeader), findsOneWidget);
    expect(find.byType(HomeMoodInsightCard), findsOneWidget);
    expect(find.byType(HomeSupportPromptCard), findsOneWidget);
    expect(find.byType(HomeActivityMetricCard), findsOneWidget);
    expect(find.byType(HomeBottomNavigationBar), findsOneWidget);

    expect(find.text('Aktivitas Hari Ini'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
    expect(find.byKey(const Key('home-bottom-nav-beranda')), findsOneWidget);
    expect(find.byKey(const Key('home-bottom-nav-konsultasi')), findsOneWidget);
    expect(find.byKey(const Key('home-bottom-nav-aktivitas')), findsOneWidget);
    expect(find.byKey(const Key('home-bottom-nav-profil')), findsOneWidget);
  });
}
