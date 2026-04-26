import 'package:nurtur_app_wppl_agile/features/auth/data/services/mock_auth_service.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({required MockAuthService service}) : _service = service;

  final MockAuthService _service;

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _service.loginWithEmail(
        email: email,
        password: password,
      );

      if (result.ok) {
        return AuthResult.success(
          message: result.message,
          accessToken: result.accessToken,
        );
      }

      return AuthResult.failure(message: result.message);
    } catch (_) {
      return const AuthResult.failure(
        message: 'Terjadi gangguan. Mohon coba kembali.',
      );
    }
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _service.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (result.ok) {
        return AuthResult.success(
          message: result.message,
          accessToken: result.accessToken,
        );
      }

      return AuthResult.failure(message: result.message);
    } catch (_) {
      return const AuthResult.failure(
        message: 'Terjadi gangguan. Mohon coba kembali.',
      );
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) async {
    try {
      final result = await _service.verifyOtp(
        destination: destination,
        otpCode: otpCode,
      );

      if (result.ok) {
        return AuthResult.success(
          message: result.message,
          accessToken: result.accessToken,
        );
      }

      return AuthResult.failure(message: result.message);
    } catch (_) {
      return const AuthResult.failure(
        message: 'Terjadi gangguan. Mohon coba kembali.',
      );
    }
  }

  @override
  Future<AuthResult> resendOtp({required String destination}) async {
    try {
      final result = await _service.resendOtp(destination: destination);

      if (result.ok) {
        return AuthResult.success(
          message: result.message,
          accessToken: result.accessToken,
        );
      }

      return AuthResult.failure(message: result.message);
    } catch (_) {
      return const AuthResult.failure(
        message: 'Terjadi gangguan. Mohon coba kembali.',
      );
    }
  }
}
