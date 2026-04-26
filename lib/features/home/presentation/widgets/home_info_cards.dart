import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';

class HomeMoodInsightCard extends StatelessWidget {
  const HomeMoodInsightCard({super.key, required this.content, this.onTap});

  final HomeMoodInsightContent content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseInfoCard(
      backgroundColor: const Color(0xFFF4F4F8),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF9CE37),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'H',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
      title: content.title,
      message: content.message,
      titleColor: const Color(0xFF81818F),
      messageColor: const Color(0xFF33333E),
      trailingColor: AppColors.primaryPurple,
    );
  }
}

class HomeSupportPromptCard extends StatelessWidget {
  const HomeSupportPromptCard({super.key, required this.content, this.onTap});

  final HomeSupportPromptContent content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseInfoCard(
      backgroundColor: const Color(0xFFF2E08E),
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 72,
          height: 52,
          color: const Color(0xFFF5F1D6),
          child: content.illustrationAssetPath == null
              ? const Icon(Icons.support_agent, color: AppColors.primaryPurple)
              : Image.asset(
                  content.illustrationAssetPath!,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.support_agent,
                    color: AppColors.primaryPurple,
                  ),
                ),
        ),
      ),
      title: content.title,
      message: content.description,
      titleColor: const Color(0xFF4E421F),
      messageColor: const Color(0xFF7E6E42),
      trailingColor: const Color(0xFFAF943A),
    );
  }
}

class _BaseInfoCard extends StatelessWidget {
  const _BaseInfoCard({
    required this.backgroundColor,
    required this.leading,
    required this.title,
    required this.message,
    required this.titleColor,
    required this.messageColor,
    required this.trailingColor,
    this.onTap,
  });

  final Color backgroundColor;
  final Widget leading;
  final String title;
  final String message;
  final Color titleColor;
  final Color messageColor;
  final Color trailingColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: onTap != null,
      label: title,
      value: message,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: messageColor,
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: trailingColor,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
