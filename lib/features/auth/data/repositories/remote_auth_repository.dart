import 'package:nurtur_app_wppl_agile/features/auth/data/services/remote_auth_service.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/models/auth_result.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({required RemoteAuthService service})
    : _service = service;

  final RemoteAuthService _service;

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _service.loginWithEmail(
      email: email,
      password: password,
    );

    if (result.ok) {
      return AuthResult.success(
        message: result.message,
        accessToken: result.accessToken,
        statusCode: result.statusCode,
      );
    }

    return AuthResult.failure(
      message: result.message,
      statusCode: result.statusCode,
      errorCode: result.errorCode,
      errorMap: result.errorMap,
    );
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final result = await _service.registerWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );

    if (result.ok) {
      return AuthResult.success(
        message: result.message,
        accessToken: result.accessToken,
        statusCode: result.statusCode,
      );
    }

    return AuthResult.failure(
      message: result.message,
      statusCode: result.statusCode,
      errorCode: result.errorCode,
      errorMap: result.errorMap,
    );
  }

  @override
  Future<AuthResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) async {
    final result = await _service.verifyOtp(
      destination: destination,
      otpCode: otpCode,
    );

    if (result.ok) {
      return AuthResult.success(
        message: result.message,
        accessToken: result.accessToken,
        statusCode: result.statusCode,
      );
    }

    return AuthResult.failure(
      message: result.message,
      statusCode: result.statusCode,
      errorCode: result.errorCode,
      errorMap: result.errorMap,
    );
  }

  @override
  Future<AuthResult> resendOtp({required String destination}) async {
    final result = await _service.resendOtp(destination: destination);

    if (result.ok) {
      return AuthResult.success(
        message: result.message,
        accessToken: result.accessToken,
        statusCode: result.statusCode,
      );
    }

    return AuthResult.failure(
      message: result.message,
      statusCode: result.statusCode,
      errorCode: result.errorCode,
      errorMap: result.errorMap,
    );
  }
}
