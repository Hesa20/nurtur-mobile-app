import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/config/home_page_contract.dart';

class HomeMockDataSource {
  HomeMockDataSource._();

  static const List<HomeActivityMetric> activityMetrics = [
    HomeActivityMetric(
      type: HomeActivityMetricType.aktivitas,
      label: 'Aktivitas',
      count: 5,
    ),
    HomeActivityMetric(
      type: HomeActivityMetricType.selesai,
      label: 'Selesai',
      count: 3,
    ),
    HomeActivityMetric(
      type: HomeActivityMetricType.belum,
      label: 'Belum',
      count: 2,
    ),
  ];

  static const List<HomeArticlePreview> latestArticles = [
    HomeArticlePreview(
      id: 'time-management',
      title: '5 Tips Manajemen Waktu supaya kamu gak keteteran',
      imageAssetPath: 'assets/images/login_family_hero.png',
    ),
    HomeArticlePreview(
      id: 'self-checkin',
      title: 'Kenali gejala burnout sejak dini bersama ahlinya',
      imageAssetPath: 'assets/images/login_family_hero.png',
    ),
    HomeArticlePreview(
      id: 'sleep-quality',
      title: 'Pola tidur sehat untuk ibu agar energi tetap stabil',
      imageAssetPath: 'assets/images/login_family_hero.png',
    ),
  ];

  static const List<HomeBottomNavDestination> bottomNavigationDestinations =
      HomePageContract.bottomNavigationDestinations;
}
