import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_startup_gate.dart';

class _FakeOnboardingProgressRepository
    implements OnboardingProgressRepository {
  _FakeOnboardingProgressRepository({required bool isCompleted})
    : _isCompleted = isCompleted;

  bool _isCompleted;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _isCompleted;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    _isCompleted = true;
  }

  @override
  Future<void> resetOnboardingCompletion() async {
    _isCompleted = false;
  }
}

void main() {
  const completedDestination = Scaffold(
    body: Center(child: Text('Completed Home')),
  );

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

  testWidgets('shows onboarding first when completion is false', (
    tester,
  ) async {
    final repository = _FakeOnboardingProgressRepository(isCompleted: false);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingStartupGate(
          repository: repository,
          completedBuilder: (_) => completedDestination,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );
    expect(find.text('Completed Home'), findsNothing);
  });

  testWidgets('navigates to login after onboarding completion action', (
    tester,
  ) async {
    final repository = _FakeOnboardingProgressRepository(isCompleted: false);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingStartupGate(
          repository: repository,
          completedBuilder: (_) => completedDestination,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsOneWidget,
    );

    await advanceToFinalPage(tester);

    expect(
      find.text(OnboardingFlowContract.finalPrimaryButtonLabel),
      findsOneWidget,
    );

    await fillRequiredFinalForm(tester);

    await tester.tap(find.text(OnboardingFlowContract.finalPrimaryButtonLabel));
    await tester.pumpAndSettle();

    expect(find.text('Completed Home'), findsOneWidget);
  });

  testWidgets('goes directly to login when already completed', (tester) async {
    final repository = _FakeOnboardingProgressRepository(isCompleted: true);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingStartupGate(
          repository: repository,
          completedBuilder: (_) => completedDestination,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Completed Home'), findsOneWidget);
    expect(
      find.text(OnboardingFlowContract.introSlides.first.title),
      findsNothing,
    );
  });
}
