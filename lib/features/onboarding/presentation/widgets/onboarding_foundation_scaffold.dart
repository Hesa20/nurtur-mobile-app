import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';

class OnboardingFoundationScaffold extends StatelessWidget {
  const OnboardingFoundationScaffold({
    super.key,
    required this.appLabel,
    required this.content,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.scrollContent = true,
    this.progressIndicator,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.topBackLabel,
    this.onTopBackPressed,
  });

  final String appLabel;
  final Widget content;
  final bool scrollContent;
  final Widget? progressIndicator;
  final String primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final String? topBackLabel;
  final VoidCallback? onTopBackPressed;

  bool get _showTopBack => topBackLabel != null;

  @override
  Widget build(BuildContext context) {
    const topSlotHeight = 36.0;
    const progressSlotHeight = 34.0;
    const secondarySlotHeight = 34.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceCard,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sidePadding = (constraints.maxWidth * 0.05)
                .clamp(20.0, 32.0)
                .toDouble();

            return Padding(
              padding: EdgeInsets.fromLTRB(sidePadding, 10, sidePadding, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: topSlotHeight,
                    child: _showTopBack
                        ? _TopBackBar(
                            appLabel: appLabel,
                            backLabel: topBackLabel!,
                            onBackPressed: onTopBackPressed,
                          )
                        : Center(
                            child: Text(
                              appLabel,
                              style: const TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: scrollContent
                        ? SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight * 0.52,
                              ),
                              child: content,
                            ),
                          )
                        : content,
                  ),
                  SizedBox(
                    height: progressSlotHeight,
                    child: progressIndicator == null
                        ? const SizedBox.shrink()
                        : Center(child: progressIndicator),
                  ),
                  const SizedBox(height: 14),
                  OnboardingPrimaryActionButton(
                    label: primaryButtonLabel,
                    onPressed: onPrimaryPressed,
                  ),
                  SizedBox(
                    height: secondarySlotHeight,
                    child: secondaryButtonLabel == null
                        ? const SizedBox.shrink()
                        : Center(
                            child: OnboardingSecondaryBackButton(
                              label: secondaryButtonLabel!,
                              onPressed: onSecondaryPressed,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBackBar extends StatelessWidget {
  const _TopBackBar({
    required this.appLabel,
    required this.backLabel,
    required this.onBackPressed,
  });

  final String appLabel;
  final String backLabel;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              appLabel,
              style: const TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBackPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF263241),
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(
                backLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
