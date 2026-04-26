import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/config/home_page_contract.dart';

void main() {
  test('phase 1 contract defines required section order', () {
    expect(HomePageContract.sectionOrder, [
      HomeSectionId.greetingHeader,
      HomeSectionId.moodInsightCard,
      HomeSectionId.supportPromptCard,
      HomeSectionId.activitySummarySection,
      HomeSectionId.latestArticlesSection,
      HomeSectionId.bottomNavigation,
    ]);
  });

  test('phase 1 contract locks core labels from high-fidelity reference', () {
    expect(HomePageContract.appLabel, 'Nurtur');
    expect(HomePageContract.activitySectionTitle, 'Aktivitas Hari Ini');
    expect(HomePageContract.latestArticlesSectionTitle, 'Artikel terbaru');
    expect(HomePageContract.seeAllActionLabel, 'Lihat Semua');

    expect(HomePageContract.greeting.salutation, 'Hai ibu hebat,');
    expect(HomePageContract.moodInsight.title, 'Mood Hari Ini');
    expect(HomePageContract.supportPrompt.title, 'Butuh teman cerita?');
  });

  test('phase 1 contract locks bottom navigation destinations', () {
    expect(HomePageContract.bottomNavigationDestinations.length, 4);
    expect(
      HomePageContract.bottomNavigationDestinations
          .map((destination) => destination.label)
          .toList(),
      ['Beranda', 'Konsultasi', 'Aktivitas', 'Profil'],
    );
    expect(HomePageContract.defaultSelectedTab, HomeTabId.beranda);
  });
}
