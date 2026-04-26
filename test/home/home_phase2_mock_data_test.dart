import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/home/data/sources/home_mock_data_source.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/config/home_page_contract.dart';

void main() {
  test('phase 2 provides required activity metrics for Home summary cards', () {
    final metrics = HomeMockDataSource.activityMetrics;

    expect(metrics, hasLength(HomePageContract.requiredActivityMetricCount));
    expect(metrics.every((metric) => metric.count >= 0), isTrue);
    expect(metrics.map((metric) => metric.type).toSet(), {
      HomeActivityMetricType.aktivitas,
      HomeActivityMetricType.selesai,
      HomeActivityMetricType.belum,
    });
  });

  test('phase 2 provides latest article data for horizontal list', () {
    final articles = HomeMockDataSource.latestArticles;

    expect(
      articles.length,
      greaterThanOrEqualTo(HomePageContract.minimumLatestArticleCount),
    );
    expect(
      articles.map((article) => article.id).toSet().length,
      articles.length,
    );
    expect(
      articles.every((article) => article.title.trim().isNotEmpty),
      isTrue,
    );
  });

  test('phase 2 mock data stays aligned with contract navigation', () {
    expect(
      HomeMockDataSource.bottomNavigationDestinations,
      HomePageContract.bottomNavigationDestinations,
    );
    expect(
      HomePageContract.supportPrompt.illustrationAssetPath,
      'assets/images/login_family_hero.png',
    );
  });
}
