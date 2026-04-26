import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_foundation_scaffold.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

void main() {
  testWidgets('phase 3 foundation renders reusable onboarding scaffold', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingFoundationScaffold), findsOneWidget);
    expect(find.byType(OnboardingProgressDots), findsOneWidget);
    expect(find.text(OnboardingFlowContract.appLabel), findsOneWidget);
    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );
    expect(
      find.text(OnboardingFlowContract.introSlides.first.description),
      findsOneWidget,
    );
    expect(
      find.text(OnboardingFlowContract.introPrimaryButtonLabel),
      findsOneWidget,
    );
  });

  testWidgets('progress dots highlight first intro slide by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () async {})),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < OnboardingFlowContract.introPageCount; i++) {
      expect(find.byKey(Key('onboarding-progress-dot-$i')), findsOneWidget);
    }

    final activeSize = tester.getSize(
      find.byKey(const Key('onboarding-progress-dot-0')),
    );
    final inactiveSize = tester.getSize(
      find.byKey(const Key('onboarding-progress-dot-1')),
    );

    expect(activeSize.width, greaterThan(inactiveSize.width));
  });
}
