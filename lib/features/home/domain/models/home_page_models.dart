enum HomeSectionId {
  greetingHeader,
  moodInsightCard,
  supportPromptCard,
  activitySummarySection,
  latestArticlesSection,
  bottomNavigation,
}

enum HomeTabId { beranda, konsultasi, aktivitas, profil }

enum HomeActivityMetricType { aktivitas, selesai, belum }

class HomeGreetingContent {
  const HomeGreetingContent({
    required this.salutation,
    required this.userDisplayName,
  });

  final String salutation;
  final String userDisplayName;
}

class HomeMoodInsightContent {
  const HomeMoodInsightContent({required this.title, required this.message});

  final String title;
  final String message;
}

class HomeSupportPromptContent {
  const HomeSupportPromptContent({
    required this.title,
    required this.description,
    this.illustrationAssetPath,
  });

  final String title;
  final String description;
  final String? illustrationAssetPath;
}

class HomeActivityMetric {
  const HomeActivityMetric({
    required this.type,
    required this.label,
    required this.count,
  });

  final HomeActivityMetricType type;
  final String label;
  final int count;
}

class HomeArticlePreview {
  const HomeArticlePreview({
    required this.id,
    required this.title,
    this.imageAssetPath,
  });

  final String id;
  final String title;
  final String? imageAssetPath;
}

class HomeBottomNavDestination {
  const HomeBottomNavDestination({required this.tabId, required this.label});

  final HomeTabId tabId;
  final String label;
}
