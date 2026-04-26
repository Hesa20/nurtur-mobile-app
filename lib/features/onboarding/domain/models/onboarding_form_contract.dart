enum OnboardingMood { sad, annoyed, neutral, happy, awesome }

class OnboardingSelectOption {
  const OnboardingSelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

class OnboardingMoodOption {
  const OnboardingMoodOption({
    required this.mood,
    required this.emoji,
    required this.label,
  });

  final OnboardingMood mood;
  final String emoji;
  final String label;
}
