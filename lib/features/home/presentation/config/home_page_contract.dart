import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';

class HomePageContract {
  HomePageContract._();

  static const String appLabel = 'Nurtur';

  static const List<HomeSectionId> sectionOrder = [
    HomeSectionId.greetingHeader,
    HomeSectionId.moodInsightCard,
    HomeSectionId.supportPromptCard,
    HomeSectionId.activitySummarySection,
    HomeSectionId.latestArticlesSection,
    HomeSectionId.bottomNavigation,
  ];

  static const HomeGreetingContent greeting = HomeGreetingContent(
    salutation: 'Hai ibu hebat,',
    userDisplayName: 'Sofia Nabila!',
  );

  static const HomeMoodInsightContent moodInsight = HomeMoodInsightContent(
    title: 'Mood Hari Ini',
    message: 'Sedih.. tetap semangat ya!',
  );

  static const HomeSupportPromptContent
  supportPrompt = HomeSupportPromptContent(
    title: 'Butuh teman cerita?',
    description:
        'Tenang, kamu gak sendirian kok. Ada kami yang siap mendengar ceritamu.',
    illustrationAssetPath: 'assets/images/login_family_hero.png',
  );

  static const String activitySectionTitle = 'Aktivitas Hari Ini';
  static const String latestArticlesSectionTitle = 'Artikel terbaru';
  static const String seeAllActionLabel = 'Lihat Semua';

  static const int requiredActivityMetricCount = 3;
  static const int minimumLatestArticleCount = 2;

  static const List<HomeBottomNavDestination> bottomNavigationDestinations = [
    HomeBottomNavDestination(tabId: HomeTabId.beranda, label: 'Beranda'),
    HomeBottomNavDestination(tabId: HomeTabId.konsultasi, label: 'Konsultasi'),
    HomeBottomNavDestination(tabId: HomeTabId.aktivitas, label: 'Aktivitas'),
    HomeBottomNavDestination(tabId: HomeTabId.profil, label: 'Profil'),
  ];

  static const HomeTabId defaultSelectedTab = HomeTabId.beranda;
}
