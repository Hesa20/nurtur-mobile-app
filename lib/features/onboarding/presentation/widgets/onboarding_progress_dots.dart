import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';

class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    super.key,
    required this.totalDots,
    required this.activeIndex,
  });

  final int totalDots;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Progress onboarding',
      value: 'Langkah ${activeIndex + 1} dari $totalDots',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalDots, (index) {
          final isActive = index == activeIndex;

          return AnimatedContainer(
            key: Key('onboarding-progress-dot-$index'),
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryPurple
                  : AppColors.primaryPurple.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}
