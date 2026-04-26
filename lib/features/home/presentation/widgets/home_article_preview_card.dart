import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';

class HomeArticlePreviewCard extends StatelessWidget {
  const HomeArticlePreviewCard({super.key, required this.article, this.onTap});

  final HomeArticlePreview article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: onTap != null,
      label: 'Artikel: ${article.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 212,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFE8F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1.62,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF6CDC8), Color(0xFFCBEFE8)],
                        ),
                      ),
                      child: article.imageAssetPath == null
                          ? const SizedBox.shrink()
                          : Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                article.imageAssetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
