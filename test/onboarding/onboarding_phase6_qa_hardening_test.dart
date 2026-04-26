import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_action_buttons.dart';
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

  Finder primaryButtonTapTarget() {
    return find.descendant(
      of: find.byType(OnboardingPrimaryActionButton),
      matching: find.byType(InkWell),
    );
  }

  testWidgets(
    'renders without overflow on compact viewport and larger text scale',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
          child: MaterialApp(home: OnboardingPage(onFinished: () async {})),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await advanceToFinalPage(tester);
      expect(
        find.byKey(const Key('onboarding-age-group-field')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('progress semantics announces current intro step', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () async {})),
    );
    await tester.pumpAndSettle();

    final initialNode = tester.getSemantics(
      find.byType(OnboardingProgressDots),
    );
    expect(initialNode.label, 'Progress onboarding');
    expect(
      initialNode.value,
      'Langkah 1 dari ${OnboardingFlowContract.introPageCount}',
    );

    await tester.tap(find.text(OnboardingFlowContract.introPrimaryButtonLabel));
    await tester.pumpAndSettle();

    final secondStepNode = tester.getSemantics(
      find.byType(OnboardingProgressDots),
    );
    expect(secondStepNode.label, 'Progress onboarding');
    expect(
      secondStepNode.value,
      'Langkah 2 dari ${OnboardingFlowContract.introPageCount}',
    );

    semanticsHandle.dispose();
  });

  testWidgets('shows error feedback and re-enables CTA when completion fails', (
    tester,
  ) async {
    var attempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(
          onFinished: () async {
            attempts++;
            throw Exception('finish failed');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await advanceToFinalPage(tester);
    await fillRequiredFinalForm(tester);

    final primaryBefore = tester.widget<InkWell>(primaryButtonTapTarget());
    expect(primaryBefore.onTap, isNotNull);

    await tester.tap(find.text(OnboardingFlowContract.finalPrimaryButtonLabel));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(
      find.text('Terjadi gangguan saat menyelesaikan onboarding. Coba lagi.'),
      findsOneWidget,
    );

    final primaryAfter = tester.widget<InkWell>(primaryButtonTapTarget());
    expect(primaryAfter.onTap, isNotNull);
  });
}
