import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';

class OnboardingIntroContent extends StatelessWidget {
  const OnboardingIntroContent({
    super.key,
    required this.title,
    required this.description,
    this.imageAssetPath,
  });

  final String title;
  final String description;
  final String? imageAssetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageAssetPath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = (constraints.maxWidth * 0.72)
                    .clamp(190.0, 280.0)
                    .toDouble();

                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                    minHeight: 210,
                  ),
                  color: const Color(0xFFCEB8EA),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: SizedBox(
                    height: imageHeight,
                    child: Image.asset(
                      imageAssetPath!,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.self_improvement,
                            color: AppColors.primaryPurple,
                            size: 88,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 34),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF151E36),
            fontSize: 52,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4A5870),
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
