import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/data/repositories/local_onboarding_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'local onboarding progress repository persists completion flag',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = LocalOnboardingProgressRepository();

      expect(await repository.isOnboardingCompleted(), isFalse);

      await repository.markOnboardingCompleted();
      expect(await repository.isOnboardingCompleted(), isTrue);

      await repository.resetOnboardingCompletion();
      expect(await repository.isOnboardingCompleted(), isFalse);
    },
  );
}
