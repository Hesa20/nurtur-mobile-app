import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/login_page.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/register_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return const AuthResult.success(message: 'Login berhasil.');
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return const AuthResult.success(message: 'Akun berhasil dibuat.');
  }

  @override
  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) async {
    return const AuthResult.success(message: 'Verifikasi OTP berhasil.');
  }

  @override
  Future<AuthResult> resendOtp({required String destination}) async {
    return const AuthResult.success(message: 'Kode OTP baru telah dikirim.');
  }
}

class _FakeOnboardingProgressRepository
    implements OnboardingProgressRepository {
  const _FakeOnboardingProgressRepository();

  @override
  Future<bool> isOnboardingCompleted() async {
    return true;
  }

  @override
  Future<void> markOnboardingCompleted() async {}

  @override
  Future<void> resetOnboardingCompletion() async {}
}

void main() {
  const authRepository = _FakeAuthRepository();
  const onboardingRepository = _FakeOnboardingProgressRepository();

  testWidgets(
    'phase 7 login remains stable on compact Android viewport and larger text scale',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const LoginPage(
              authRepository: authRepository,
              onboardingProgressRepository: onboardingRepository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Masuk'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phase 7 register remains stable on compact Android viewport and larger text scale',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const RegisterPage(repository: authRepository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Buat Akun'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('phase 7 OTP layout avoids overflow on narrow Android viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 620);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const OtpVerificationPage(
            destination: 'user@example.com',
            repository: authRepository,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    final otpFields = find.byType(TextField);
    await tester.enterText(otpFields.at(0), '1');
    await tester.enterText(otpFields.at(1), '2');
    await tester.enterText(otpFields.at(2), '3');
    await tester.enterText(otpFields.at(3), '4');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('phase 7 OTP semantics exposes field and button metadata', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const OtpVerificationPage(
            destination: 'user@example.com',
            repository: authRepository,
          ),
        ),
      );
      await tester.pump();

      final firstDigitNode = tester.getSemantics(
        find.byKey(const Key('otp-digit-field-0')),
      );
      expect(firstDigitNode.label, contains('Digit OTP 1 dari 4'));
      expect(firstDigitNode.hasFlag(SemanticsFlag.isTextField), isTrue);

      final verifyButtonNode = tester.getSemantics(
        find.byKey(const Key('otp-verify-button')),
      );
      expect(verifyButtonNode.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(verifyButtonNode.hasFlag(SemanticsFlag.isEnabled), isTrue);

      final otpFields = find.byType(TextField);
      await tester.enterText(otpFields.at(0), '7');
      await tester.enterText(otpFields.at(1), '8');
      await tester.enterText(otpFields.at(2), '9');
      await tester.enterText(otpFields.at(3), '1');
      await tester.pump();

      final firstDigitAfterInput = tester.getSemantics(
        find.byKey(const Key('otp-digit-field-0')),
      );
      expect(firstDigitAfterInput.value, contains('7'));
    } finally {
      semanticsHandle.dispose();
    }
  });
}
