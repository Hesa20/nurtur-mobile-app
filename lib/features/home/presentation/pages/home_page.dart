import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/home/data/sources/home_mock_data_source.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/config/home_page_contract.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_activity_metric_card.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_article_preview_card.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_info_cards.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/widgets/home_section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialSelectedTab = HomePageContract.defaultSelectedTab,
    this.onSeeAllActivityTap,
    this.onSeeAllArticlesTap,
    this.onMoodInsightTap,
    this.onSupportPromptTap,
    this.onArticleTap,
    this.onTabSelected,
  });

  final HomeTabId initialSelectedTab;
  final VoidCallback? onSeeAllActivityTap;
  final VoidCallback? onSeeAllArticlesTap;
  final VoidCallback? onMoodInsightTap;
  final VoidCallback? onSupportPromptTap;
  final ValueChanged<HomeArticlePreview>? onArticleTap;
  final ValueChanged<HomeTabId>? onTabSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeTabId _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialSelectedTab;
  }

  void _showFeatureMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  void _handleSeeAllActivityTap() {
    if (widget.onSeeAllActivityTap != null) {
      widget.onSeeAllActivityTap!();
      return;
    }

    _showFeatureMessage('Daftar aktivitas lengkap segera hadir.');
  }

  void _handleSeeAllArticlesTap() {
    if (widget.onSeeAllArticlesTap != null) {
      widget.onSeeAllArticlesTap!();
      return;
    }

    _showFeatureMessage('Daftar artikel lengkap segera hadir.');
  }

  void _handleMoodInsightTap() {
    if (widget.onMoodInsightTap != null) {
      widget.onMoodInsightTap!();
      return;
    }

    _showFeatureMessage('Rangkuman mood hari ini segera hadir.');
  }

  void _handleSupportPromptTap() {
    if (widget.onSupportPromptTap != null) {
      widget.onSupportPromptTap!();
      return;
    }

    _showFeatureMessage('Fitur teman cerita akan segera hadir.');
  }

  void _handleArticleTap(HomeArticlePreview article) {
    if (widget.onArticleTap != null) {
      widget.onArticleTap!(article);
      return;
    }

    _showFeatureMessage('Membuka artikel: ${article.title}');
  }

  String _tabLabel(HomeTabId tabId) {
    return HomeMockDataSource.bottomNavigationDestinations
        .firstWhere((destination) => destination.tabId == tabId)
        .label;
  }

  void _handleTabSelected(HomeTabId tabId) {
    if (_selectedTab != tabId) {
      setState(() {
        _selectedTab = tabId;
      });
    }

    widget.onTabSelected?.call(tabId);

    if (tabId != HomeTabId.beranda) {
      _showFeatureMessage('Fitur ${_tabLabel(tabId)} akan segera hadir.');
    }
  }

  IconData _iconForMetricType(HomeActivityMetricType type) {
    switch (type) {
      case HomeActivityMetricType.aktivitas:
        return Icons.assignment;
      case HomeActivityMetricType.selesai:
        return Icons.checklist_rounded;
      case HomeActivityMetricType.belum:
        return Icons.assignment_late_rounded;
    }
  }

  Color _metricBackgroundForType(HomeActivityMetricType type) {
    switch (type) {
      case HomeActivityMetricType.aktivitas:
        return const Color(0xFFEDE3F4);
      case HomeActivityMetricType.selesai:
        return const Color(0xFFE8F1D8);
      case HomeActivityMetricType.belum:
        return const Color(0xFFF6E8E8);
    }
  }

  Color _metricAccentForType(HomeActivityMetricType type) {
    switch (type) {
      case HomeActivityMetricType.aktivitas:
        return AppColors.primaryPurple;
      case HomeActivityMetricType.selesai:
        return const Color(0xFF74B413);
      case HomeActivityMetricType.belum:
        return const Color(0xFFE43C6A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeaderSection(
                greeting: HomePageContract.greeting,
                moodInsight: HomePageContract.moodInsight,
                supportPrompt: HomePageContract.supportPrompt,
                onMoodInsightTap: _handleMoodInsightTap,
                onSupportPromptTap: _handleSupportPromptTap,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSectionHeader(
                      key: const Key('home-activity-section-header'),
                      title: HomePageContract.activitySectionTitle,
                      actionLabel: HomePageContract.seeAllActionLabel,
                      actionButtonKey: const Key(
                        'home-activity-see-all-action',
                      ),
                      onActionTap: _handleSeeAllActivityTap,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      key: const Key('home-activity-section'),
                      children: [
                        for (
                          var i = 0;
                          i < HomeMockDataSource.activityMetrics.length;
                          i++
                        ) ...[
                          Expanded(
                            child: HomeActivityMetricCard(
                              key: Key(
                                'home-activity-metric-${HomeMockDataSource.activityMetrics[i].type.name}',
                              ),
                              metric: HomeMockDataSource.activityMetrics[i],
                              icon: _iconForMetricType(
                                HomeMockDataSource.activityMetrics[i].type,
                              ),
                              backgroundColor: _metricBackgroundForType(
                                HomeMockDataSource.activityMetrics[i].type,
                              ),
                              accentColor: _metricAccentForType(
                                HomeMockDataSource.activityMetrics[i].type,
                              ),
                            ),
                          ),
                          if (i < HomeMockDataSource.activityMetrics.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    HomeSectionHeader(
                      key: const Key('home-latest-articles-section-header'),
                      title: HomePageContract.latestArticlesSectionTitle,
                      actionLabel: HomePageContract.seeAllActionLabel,
                      actionButtonKey: const Key(
                        'home-articles-see-all-action',
                      ),
                      onActionTap: _handleSeeAllArticlesTap,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      key: const Key('home-latest-articles-section'),
                      height: 238,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: HomeMockDataSource.latestArticles.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final article =
                              HomeMockDataSource.latestArticles[index];
                          return HomeArticlePreviewCard(
                            key: Key('home-article-${article.id}'),
                            article: article,
                            onTap: () => _handleArticleTap(article),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        destinations: HomeMockDataSource.bottomNavigationDestinations,
        selectedTab: _selectedTab,
        onTabSelected: _handleTabSelected,
      ),
    );
  }
}

class _HomeHeaderSection extends StatelessWidget {
  const _HomeHeaderSection({
    required this.greeting,
    required this.moodInsight,
    required this.supportPrompt,
    required this.onMoodInsightTap,
    required this.onSupportPromptTap,
  });

  final HomeGreetingContent greeting;
  final HomeMoodInsightContent moodInsight;
  final HomeSupportPromptContent supportPrompt;
  final VoidCallback onMoodInsightTap;
  final VoidCallback onSupportPromptTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurpleLight,
            AppColors.primaryPurple,
            AppColors.primaryPurpleDark,
          ],
          stops: [0, 0.5, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -62,
            top: -98,
            child: _DecorCircle(
              diameter: 200,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            right: -95,
            bottom: -122,
            child: _DecorCircle(
              diameter: 250,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  key: const Key('home-header-greeting'),
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: '${greeting.salutation}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFEAD9FF),
                              ),
                            ),
                            TextSpan(
                              text: greeting.userDisplayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 20,
                      ),
                      splashRadius: 18,
                      tooltip: 'Notifikasi',
                    ),
                    const SizedBox(width: 4),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/login_family_hero.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.3, -0.2),
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                HomeMoodInsightCard(
                  key: const Key('home-mood-insight-card'),
                  content: moodInsight,
                  onTap: onMoodInsightTap,
                ),
                const SizedBox(height: 12),
                HomeSupportPromptCard(
                  key: const Key('home-support-prompt-card'),
                  content: supportPrompt,
                  onTap: onSupportPromptTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
