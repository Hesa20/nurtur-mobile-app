abstract class OnboardingProgressRepository {
  Future<bool> isOnboardingCompleted();

  Future<void> markOnboardingCompleted();

  Future<void> resetOnboardingCompletion();
}
