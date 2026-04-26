import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';

void main() {
  test(
    'phase 1 contract defines exactly three intro pages and one final page',
    () {
      expect(OnboardingFlowContract.introPageCount, 3);
      expect(OnboardingFlowContract.introSlides.length, 3);
      expect(OnboardingFlowContract.totalPageCount, 4);
    },
  );

  test('intro pages use expected CTA and back action behavior', () {
    expect(
      OnboardingFlowContract.introSlides.first.primaryButtonLabel,
      OnboardingFlowContract.introPrimaryButtonLabel,
    );
    expect(
      OnboardingFlowContract.introSlides.first.showSecondaryBackAction,
      isFalse,
    );
    expect(
      OnboardingFlowContract.introSlides[1].showSecondaryBackAction,
      isTrue,
    );
    expect(
      OnboardingFlowContract.introSlides[2].showSecondaryBackAction,
      isTrue,
    );
  });

  test('final page contract requires all profile fields', () {
    expect(OnboardingFlowContract.requiresAgeGroup, isTrue);
    expect(OnboardingFlowContract.requiresRole, isTrue);
    expect(OnboardingFlowContract.requiresMood, isTrue);

    expect(OnboardingFlowContract.ageGroupOptions, isNotEmpty);
    expect(OnboardingFlowContract.roleOptions, isNotEmpty);
    expect(OnboardingFlowContract.moodOptions, hasLength(5));
    expect(OnboardingFlowContract.finalPrimaryButtonLabel, 'Mulai Sekarang');
  });
}
