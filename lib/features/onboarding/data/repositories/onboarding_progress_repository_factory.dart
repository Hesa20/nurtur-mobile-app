import 'package:nurtur_app_wppl_agile/features/onboarding/data/repositories/local_onboarding_progress_repository.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';

class OnboardingProgressRepositoryFactory {
  OnboardingProgressRepositoryFactory._();

  static OnboardingProgressRepository create() {
    return LocalOnboardingProgressRepository();
  }
}
