import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalOnboardingProgressRepository
    implements OnboardingProgressRepository {
  LocalOnboardingProgressRepository({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  static const String _completionKey = 'onboarding.completed.v1';

  final Future<SharedPreferences> _preferences;

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool(_completionKey) ?? false;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(_completionKey, true);
  }

  @override
  Future<void> resetOnboardingCompletion() async {
    final prefs = await _preferences;
    await prefs.setBool(_completionKey, false);
  }
}
