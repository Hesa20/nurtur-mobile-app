import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/otp_verification_page.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({required this.onVerifyOtp, required this.onResendOtp});

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
    throw UnimplementedError();
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

void main() {
  Future<void> pumpOtpPage(
    WidgetTester tester, {
    required AuthRepository repository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OtpVerificationPage(
          destination: 'user@example.com',
          repository: repository,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders OTP page and 4 OTP fields', (tester) async {
    final repository = FakeAuthRepository(
      onVerifyOtp: (_, __) async => const AuthResult.success(),
      onResendOtp: (_) async => const AuthResult.success(),
    );

    await pumpOtpPage(tester, repository: repository);

    expect(find.text('Verifikasi Kode OTP'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Verifikasi'), findsOneWidget);
  });

  testWidgets('shows message when OTP is incomplete', (tester) async {
    final repository = FakeAuthRepository(
      onVerifyOtp: (_, __) async => const AuthResult.success(),
      onResendOtp: (_) async => const AuthResult.success(),
    );

    await pumpOtpPage(tester, repository: repository);

    await tester.ensureVisible(find.text('Verifikasi'));
    await tester.tap(find.text('Verifikasi'));
    await tester.pump();

    expect(
      find.textContaining('Masukkan 4 digit kode OTP terlebih dahulu.'),
      findsOneWidget,
    );
  });

  testWidgets('increments attempt info on failed verification', (tester) async {
    final repository = FakeAuthRepository(
      onVerifyOtp: (_, __) async =>
          const AuthResult.failure(message: 'Kode OTP tidak valid.'),
      onResendOtp: (_) async => const AuthResult.success(),
    );

    await pumpOtpPage(tester, repository: repository);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '5');
    await tester.pump();

    await tester.ensureVisible(find.text('Verifikasi'));
    await tester.tap(find.text('Verifikasi'));
    await tester.pump();

    expect(find.textContaining('Percobaan verifikasi: 1/5'), findsOneWidget);
    expect(find.textContaining('Sisa percobaan 4 kali.'), findsWidgets);
  });

  testWidgets('resend timer counts down and resend works', (tester) async {
    final repository = FakeAuthRepository(
      onVerifyOtp: (_, __) async => const AuthResult.success(),
      onResendOtp: (_) async =>
          const AuthResult.success(message: 'Kode OTP baru telah dikirim.'),
    );

    await pumpOtpPage(tester, repository: repository);

    expect(find.textContaining('01:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('00:59'), findsOneWidget);

    await tester.pump(const Duration(seconds: 60));
    await tester.pump();

    expect(find.text('Kirim ulang OTP'), findsOneWidget);

    await tester.tap(find.text('Kirim ulang OTP'));
    await tester.pump();

    expect(find.text('Kode OTP baru telah dikirim.'), findsWidgets);
  });
}
