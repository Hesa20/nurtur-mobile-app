import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

void main() {
  Future<void> advanceToFinalPage(WidgetTester tester) async {
    for (var i = 0; i < OnboardingFlowContract.introPageCount; i++) {
      final nextCta = find.text(OnboardingFlowContract.introPrimaryButtonLabel);
      if (nextCta.evaluate().isEmpty) {
        break;
      }

      await tester.ensureVisible(nextCta);
      await tester.tap(nextCta);
      await tester.pumpAndSettle();
    }
  }

  Future<void> fillRequiredFinalForm(WidgetTester tester) async {
    final ageField = find.byKey(const Key('onboarding-age-group-field'));
    await tester.ensureVisible(ageField);
    await tester.tap(ageField);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(OnboardingFlowContract.ageGroupOptions.first.label).last,
    );
    await tester.pumpAndSettle();

    final roleField = find.byKey(const Key('onboarding-role-field'));
    await tester.ensureVisible(roleField);
    await tester.tap(roleField);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(OnboardingFlowContract.roleOptions.first.label).last,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        Key(
          'onboarding-mood-${OnboardingFlowContract.moodOptions.first.mood.name}',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phase 4 renders full onboarding flow and final form', (
    tester,
  ) async {
    var didFinish = false;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(
          onFinished: () async {
            didFinish = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(OnboardingProgressDots), findsOneWidget);
    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );

    await advanceToFinalPage(tester);

    expect(
      find.text(OnboardingFlowContract.finalPrimaryButtonLabel),
      findsOneWidget,
    );
    expect(find.byType(OnboardingProgressDots), findsNothing);
    expect(find.byKey(const Key('onboarding-age-group-field')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-role-field')), findsOneWidget);
    expect(
      find.byKey(const Key('onboarding-final-validation-hint')),
      findsOneWidget,
    );

    for (final option in OnboardingFlowContract.moodOptions) {
      expect(
        find.byKey(Key('onboarding-mood-${option.mood.name}')),
        findsOneWidget,
      );
      expect(find.text(option.label), findsOneWidget);
    }

    await fillRequiredFinalForm(tester);
    expect(
      find.byKey(const Key('onboarding-final-validation-hint')),
      findsNothing,
    );

    await tester.tap(find.text(OnboardingFlowContract.finalPrimaryButtonLabel));
    await tester.pumpAndSettle();

    expect(didFinish, isTrue);
  });

  testWidgets('final page top back returns to previous intro page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () async {})),
    );
    await tester.pumpAndSettle();

    await advanceToFinalPage(tester);

    expect(
      find.text(OnboardingFlowContract.finalPrimaryButtonLabel),
      findsOneWidget,
    );

    await tester.tap(find.text(OnboardingFlowContract.secondaryBackLabel));
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides[2].title),
      findsOneWidget,
    );
  });
}
