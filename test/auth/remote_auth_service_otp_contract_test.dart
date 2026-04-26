import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nurtur_app_wppl_agile/core/network/api_config.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/services/remote_auth_service.dart';

void main() {
  ApiConfig buildConfig() {
    return const ApiConfig(
      baseUrl: 'https://api.example.com',
      loginPath: '/auth/login',
      registerPath: '/auth/register',
      verifyOtpPath: '/auth/verify-otp',
      resendOtpPath: '/auth/resend-otp',
      timeout: Duration(seconds: 3),
    );
  }

  Map<String, dynamic> decodeRequestBody(http.Request request) {
    final decoded = jsonDecode(request.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }

    return const {};
  }

  test('verifyOtp sends final payload and parses success status', () async {
    Map<String, dynamic>? capturedBody;

    final client = MockClient((request) async {
      capturedBody = decodeRequestBody(request);

      expect(request.method, 'POST');
      expect(request.url.path, '/auth/verify-otp');

      return http.Response(
        jsonEncode({
          'statusCode': 200,
          'message': 'Verifikasi OTP sukses.',
          'data': {'access_token': 'token-123'},
        }),
        200,
      );
    });

    final service = RemoteAuthService(client: client, config: buildConfig());

    final result = await service.verifyOtp(
      destination: 'user@example.com',
      otpCode: '1234',
    );

    expect(capturedBody, {'email': 'user@example.com', 'otp_code': '1234'});
    expect(result.ok, isTrue);
    expect(result.statusCode, 200);
    expect(result.message, 'Verifikasi OTP sukses.');
    expect(result.accessToken, 'token-123');
    expect(result.errorMap, isEmpty);
  });

  test('verifyOtp maps validation errors from error map', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'status_code': 422,
          'error_code': 'OTP_INVALID',
          'errors': {
            'otp_code': ['Kode OTP tidak valid.'],
            'email': ['Email tidak ditemukan.'],
          },
        }),
        422,
      );
    });

    final service = RemoteAuthService(client: client, config: buildConfig());

    final result = await service.verifyOtp(
      destination: 'user@example.com',
      otpCode: '9999',
    );

    expect(result.ok, isFalse);
    expect(result.statusCode, 422);
    expect(result.errorCode, 'OTP_INVALID');
    expect(result.errorMap['otp_code'], ['Kode OTP tidak valid.']);
    expect(result.errorMap['email'], ['Email tidak ditemukan.']);
    expect(result.message, 'Kode OTP tidak valid.');
  });

  test(
    'verifyOtp uses status and error code fallback when message is absent',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'statusCode': 410, 'errorCode': 'OTP_EXPIRED'}),
          410,
        );
      });

      final service = RemoteAuthService(client: client, config: buildConfig());

      final result = await service.verifyOtp(
        destination: 'user@example.com',
        otpCode: '1234',
      );

      expect(result.ok, isFalse);
      expect(result.statusCode, 410);
      expect(result.errorCode, 'OTP_EXPIRED');
      expect(result.message, 'Kode OTP sudah kedaluwarsa. Minta OTP baru.');
    },
  );

  test('resendOtp maps list-style error map and status code', () async {
    Map<String, dynamic>? capturedBody;

    final client = MockClient((request) async {
      capturedBody = decodeRequestBody(request);

      return http.Response(
        jsonEncode({
          'statusCode': 429,
          'errors': [
            {
              'field': 'email',
              'message': 'Tunggu 60 detik sebelum kirim ulang OTP.',
            },
          ],
        }),
        429,
      );
    });

    final service = RemoteAuthService(client: client, config: buildConfig());

    final result = await service.resendOtp(destination: 'user@example.com');

    expect(capturedBody, {'email': 'user@example.com'});
    expect(result.ok, isFalse);
    expect(result.statusCode, 429);
    expect(result.errorMap['email'], [
      'Tunggu 60 detik sebelum kirim ulang OTP.',
    ]);
    expect(result.message, 'Tunggu 60 detik sebelum kirim ulang OTP.');
  });
}
