import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/register_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.onSignUpWithEmail,
    required this.onVerifyOtp,
    required this.onResendOtp,
  });

  final Future<AuthResult> Function(
    String fullName,
    String email,
    String password,
  )
  onSignUpWithEmail;
  final Future<AuthResult> Function(String destination, String otpCode)
  onVerifyOtp;
  final Future<AuthResult> Function(String destination) onResendOtp;

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) {
    return onSignUpWithEmail(fullName, email, password);
  }

  @override
  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) {
    return onVerifyOtp(destination, otpCode);
  }

  @override
  Future<AuthResult> resendOtp({required String destination}) {
    return onResendOtp(destination);
  }
}

class _FakeOnboardingProgressRepository
    implements OnboardingProgressRepository {
  _FakeOnboardingProgressRepository({required bool isCompletedInitially})
    : _isCompleted = isCompletedInitially;

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

Future<void> _fillValidRegisterForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(4));

  await tester.enterText(fields.at(0), 'Ibu Hebat');
  await tester.enterText(fields.at(1), 'user@example.com');
  await tester.enterText(fields.at(2), 'Password123');
  await tester.enterText(fields.at(3), 'Password123');
  await tester.pump();

  final checkbox = find.byType(Checkbox);
  await tester.ensureVisible(checkbox);
  await tester.tap(checkbox);
  await tester.pump();
}

void main() {
  testWidgets('register success resets onboarding completion state', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      onSignUpWithEmail: (_, __, ___) async =>
          const AuthResult.success(message: 'Akun berhasil dibuat.'),
      onVerifyOtp: (_, __) async => const AuthResult.success(),
      onResendOtp: (_) async => const AuthResult.success(),
    );
    final onboardingRepository = _FakeOnboardingProgressRepository(
      isCompletedInitially: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(
          repository: repository,
          onboardingProgressRepository: onboardingRepository,
          otpPageBuilder: (_) =>
              const Scaffold(body: Center(child: Text('OTP TEST PAGE'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await onboardingRepository.isOnboardingCompleted(), isTrue);

    await _fillValidRegisterForm(tester);

    await tester.ensureVisible(find.text('Buat Akun'));
    await tester.tap(find.text('Buat Akun'));
    await tester.pumpAndSettle();

    expect(find.text('OTP TEST PAGE'), findsOneWidget);
    expect(await onboardingRepository.isOnboardingCompleted(), isFalse);
  });

  testWidgets('register success directly navigates to OTP page', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      onSignUpWithEmail: (_, __, ___) async =>
          const AuthResult.success(message: 'Akun berhasil dibuat.'),
      onVerifyOtp: (_, __) async => const AuthResult.success(),
      onResendOtp: (_) async => const AuthResult.success(),
    );
    final onboardingRepository = _FakeOnboardingProgressRepository(
      isCompletedInitially: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(
          repository: repository,
          onboardingProgressRepository: onboardingRepository,
          otpPageBuilder: (_) =>
              const Scaffold(body: Center(child: Text('OTP TEST PAGE'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _fillValidRegisterForm(tester);

    await tester.ensureVisible(find.text('Buat Akun'));
    await tester.tap(find.text('Buat Akun'));
    await tester.pumpAndSettle();

    expect(find.text('OTP TEST PAGE'), findsOneWidget);
  });

  testWidgets('OTP verification success pops back when route can pop', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      onSignUpWithEmail: (_, __, ___) async => const AuthResult.success(),
      onVerifyOtp: (_, __) async => const AuthResult.success(
        message: 'Verifikasi OTP berhasil. Akun Anda sudah aktif.',
      ),
      onResendOtp: (_) async => const AuthResult.success(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OtpVerificationPage(
                          destination: 'user@example.com',
                          repository: repository,
                        ),
                      ),
                    );
                  },
                  child: const Text('OPEN OTP'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN OTP'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '4');
    await tester.pump();

    await tester.ensureVisible(find.text('Verifikasi'));
    await tester.tap(find.text('Verifikasi'));

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Verifikasi Kode OTP'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('OPEN OTP'), findsOneWidget);
    expect(find.text('Verifikasi Kode OTP'), findsNothing);
  });
}
