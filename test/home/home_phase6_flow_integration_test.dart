import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/login_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.signInResult});

  final AuthResult signInResult;

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return signInResult;
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> resendOtp({required String destination}) {
    throw UnimplementedError();
  }
}

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

class _FakeOnboardingFinishPage extends StatelessWidget {
  const _FakeOnboardingFinishPage({required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await onFinished();
          },
          child: const Text('FINISH ONBOARDING TEST'),
        ),
      ),
    );
  }
}

Future<void> _fillAndSubmitLoginForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(2));

  await tester.enterText(fields.at(0), 'user@example.com');
  await tester.enterText(fields.at(1), 'Password123');
  await tester.pump();

  await tester.ensureVisible(find.text('Masuk'));
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'phase 6 routes login success to home when onboarding completed',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        signInResult: const AuthResult.success(message: 'Login berhasil.'),
      );
      final onboardingRepository = _FakeOnboardingProgressRepository(
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            authRepository: authRepository,
            onboardingProgressRepository: onboardingRepository,
            homePageBuilder: (_) =>
                const Scaffold(body: Center(child: Text('HOME DESTINATION'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _fillAndSubmitLoginForm(tester);

      expect(find.text('HOME DESTINATION'), findsOneWidget);
    },
  );

  testWidgets('phase 6 routes login success via onboarding then to home', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      signInResult: const AuthResult.success(message: 'Login berhasil.'),
    );
    final onboardingRepository = _FakeOnboardingProgressRepository(
      isCompleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authRepository: authRepository,
          onboardingProgressRepository: onboardingRepository,
          homePageBuilder: (_) =>
              const Scaffold(body: Center(child: Text('HOME DESTINATION'))),
          onboardingPageBuilder: (onFinished) =>
              _FakeOnboardingFinishPage(onFinished: onFinished),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _fillAndSubmitLoginForm(tester);

    expect(find.text('FINISH ONBOARDING TEST'), findsOneWidget);

    await tester.tap(find.text('FINISH ONBOARDING TEST'));
    await tester.pumpAndSettle();

    expect(find.text('HOME DESTINATION'), findsOneWidget);
    expect(await onboardingRepository.isOnboardingCompleted(), isTrue);
  });
}
