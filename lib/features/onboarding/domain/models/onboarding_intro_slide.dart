enum OnboardingIntroStepId { welcome, community, mentalHealth }

class OnboardingIntroSlide {
  const OnboardingIntroSlide({
    required this.id,
    required this.title,
    required this.description,
    required this.primaryButtonLabel,
    required this.showSecondaryBackAction,
    this.imageAssetPath,
  });

  final OnboardingIntroStepId id;
  final String title;
  final String description;
  final String primaryButtonLabel;
  final bool showSecondaryBackAction;
  final String? imageAssetPath;
}
