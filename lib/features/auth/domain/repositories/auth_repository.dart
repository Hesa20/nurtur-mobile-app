import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  });

  Future<AuthResult> resendOtp({required String destination});
}
