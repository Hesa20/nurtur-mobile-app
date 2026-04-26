import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';

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

  Finder primaryButtonTapTarget() {
    return find.descendant(
      of: find.byType(OnboardingPrimaryActionButton),
      matching: find.byType(InkWell),
    );
  }

  testWidgets('final CTA is disabled until required fields are complete', (
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

    await advanceToFinalPage(tester);

    final primaryBefore = tester.widget<InkWell>(primaryButtonTapTarget());
    expect(primaryBefore.onTap, isNull);
    expect(
      find.byKey(const Key('onboarding-final-validation-hint')),
      findsOneWidget,
    );

    await fillRequiredFinalForm(tester);

    final primaryAfter = tester.widget<InkWell>(primaryButtonTapTarget());
    expect(primaryAfter.onTap, isNotNull);
    expect(
      find.byKey(const Key('onboarding-final-validation-hint')),
      findsNothing,
    );

    await tester.tap(find.text(OnboardingFlowContract.finalPrimaryButtonLabel));
    await tester.pumpAndSettle();

    expect(didFinish, isTrue);
  });

  testWidgets('system back on intro flow navigates to previous page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () async {})),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );

    await tester.tap(find.text(OnboardingFlowContract.introPrimaryButtonLabel));
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides[1].title),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );
  });
}
