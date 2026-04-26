import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nurtur_app_wppl_agile/core/network/api_config.dart';

enum _AuthOperation { login, register, verifyOtp, resendOtp }

class RemoteAuthService {
  RemoteAuthService({required http.Client client, required ApiConfig config})
    : _client = client,
      _config = config;

  final http.Client _client;
  final ApiConfig _config;

  Future<RemoteAuthServiceResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _postAuthRequest(
      operation: _AuthOperation.login,
      uri: _config.loginUri,
      body: {'email': email, 'password': password},
      successFallbackMessage: 'Login berhasil. Selamat datang kembali.',
      failedFallbackMessage: 'Gagal masuk. Coba beberapa saat lagi.',
    );
  }

  Future<RemoteAuthServiceResult> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _postAuthRequest(
      operation: _AuthOperation.register,
      uri: _config.registerUri,
      body: {
        'full_name': fullName,
        'name': fullName,
        'email': email,
        'password': password,
      },
      successFallbackMessage: 'Akun berhasil dibuat. Silakan login.',
      failedFallbackMessage: 'Pendaftaran gagal. Coba beberapa saat lagi.',
    );
  }

  Future<RemoteAuthServiceResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) async {
    return _postAuthRequest(
      operation: _AuthOperation.verifyOtp,
      uri: _config.verifyOtpUri,
      body: {'email': destination, 'otp_code': otpCode},
      successFallbackMessage: 'Verifikasi OTP berhasil. Akun Anda sudah aktif.',
      failedFallbackMessage: 'Kode OTP tidak valid atau sudah kedaluwarsa.',
    );
  }

  Future<RemoteAuthServiceResult> resendOtp({
    required String destination,
  }) async {
    return _postAuthRequest(
      operation: _AuthOperation.resendOtp,
      uri: _config.resendOtpUri,
      body: {'email': destination},
      successFallbackMessage: 'Kode OTP baru telah dikirim.',
      failedFallbackMessage: 'Gagal mengirim ulang OTP. Coba lagi nanti.',
    );
  }

  Future<RemoteAuthServiceResult> _postAuthRequest({
    required _AuthOperation operation,
    required Uri uri,
    required Map<String, dynamic> body,
    required String successFallbackMessage,
    required String failedFallbackMessage,
  }) async {
    if (_config.baseUrl.isEmpty) {
      return const RemoteAuthServiceResult.failure(
        message: 'API belum dikonfigurasi. Silakan set API_BASE_URL.',
      );
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_config.timeout);

      final payload = _decodePayload(response.body);
      final statusCode = _extractStatusCode(
        payload,
        fallback: response.statusCode,
      );
      final errorCode = _extractErrorCode(payload);
      final errorMap = _extractErrorMap(payload);
      final message = _extractMessage(payload);

      if (statusCode >= 200 && statusCode < 300) {
        final isSuccess = _extractSuccess(payload, fallback: true);
        if (!isSuccess) {
          return RemoteAuthServiceResult.failure(
            message: _resolveFailureMessage(
              operation: operation,
              statusCode: statusCode,
              messageFromPayload: message,
              failedFallbackMessage: failedFallbackMessage,
              errorCode: errorCode,
              errorMap: errorMap,
            ),
            statusCode: statusCode,
            errorCode: errorCode,
            errorMap: errorMap,
          );
        }

        return RemoteAuthServiceResult.success(
          message: message ?? successFallbackMessage,
          accessToken: _extractToken(payload),
          statusCode: statusCode,
        );
      }

      return RemoteAuthServiceResult.failure(
        message: _resolveFailureMessage(
          operation: operation,
          statusCode: statusCode,
          messageFromPayload: message,
          failedFallbackMessage: failedFallbackMessage,
          errorCode: errorCode,
          errorMap: errorMap,
        ),
        statusCode: statusCode,
        errorCode: errorCode,
        errorMap: errorMap,
      );
    } on TimeoutException {
      return const RemoteAuthServiceResult.failure(
        message: 'Permintaan ke server timeout. Periksa koneksi Anda.',
        errorCode: 'NETWORK_TIMEOUT',
      );
    } catch (_) {
      return const RemoteAuthServiceResult.failure(
        message: 'Tidak dapat terhubung ke server saat ini.',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  Map<String, dynamic> _decodePayload(String body) {
    if (body.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } on FormatException {
      return const {};
    }

    return const {};
  }

  int _extractStatusCode(
    Map<String, dynamic> payload, {
    required int fallback,
  }) {
    final value = _findValue(payload, const [
      ['status_code'],
      ['statusCode'],
      ['status', 'code'],
      ['meta', 'status_code'],
      ['meta', 'statusCode'],
      ['meta', 'http_status'],
      ['code'],
    ]);

    if (value is int && value >= 100 && value <= 599) {
      return value;
    }

    if (value is num) {
      final statusCode = value.toInt();
      if (statusCode >= 100 && statusCode <= 599) {
        return statusCode;
      }
    }

    if (value is String) {
      final statusCode = int.tryParse(value.trim());
      if (statusCode != null && statusCode >= 100 && statusCode <= 599) {
        return statusCode;
      }
    }

    return fallback;
  }

  bool _extractSuccess(Map<String, dynamic> payload, {required bool fallback}) {
    final value = _findValue(payload, const [
      ['success'],
      ['ok'],
      ['status'],
      ['data', 'success'],
      ['data', 'ok'],
      ['meta', 'success'],
      ['meta', 'ok'],
    ]);

    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'success' ||
          normalized == 'ok' ||
          normalized == 'true') {
        return true;
      }
      if (normalized == 'failed' ||
          normalized == 'error' ||
          normalized == 'false') {
        return false;
      }
    }

    return fallback;
  }

  String? _extractMessage(Map<String, dynamic> payload) {
    final value = _findValue(payload, const [
      ['message'],
      ['msg'],
      ['detail'],
      ['error'],
      ['error', 'message'],
      ['data', 'message'],
      ['meta', 'message'],
      ['errors', 'message'],
    ]);

    if (value == null) {
      return null;
    }

    if (value is String) {
      final normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }

    if (value is num || value is bool) {
      return '$value';
    }

    return null;
  }

  String? _extractErrorCode(Map<String, dynamic> payload) {
    final value = _findValue(payload, const [
      ['error_code'],
      ['errorCode'],
      ['code'],
      ['error', 'code'],
      ['meta', 'error_code'],
      ['meta', 'errorCode'],
      ['data', 'error_code'],
      ['data', 'errorCode'],
    ]);

    if (value == null) {
      return null;
    }

    final normalized = '$value'.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Map<String, List<String>> _extractErrorMap(Map<String, dynamic> payload) {
    final value = _findValue(payload, const [
      ['errors'],
      ['error_map'],
      ['errorMap'],
      ['error', 'errors'],
      ['error', 'fields'],
      ['error', 'details'],
      ['data', 'errors'],
      ['meta', 'errors'],
    ]);

    return _normalizeErrorMap(value);
  }

  Map<String, List<String>> _normalizeErrorMap(dynamic value) {
    final normalized = <String, List<String>>{};

    void appendMessages(String key, List<String> messages) {
      if (messages.isEmpty) {
        return;
      }

      final current = normalized.putIfAbsent(key, () => <String>[]);
      for (final message in messages) {
        if (!current.contains(message)) {
          current.add(message);
        }
      }
    }

    if (value is Map) {
      value.forEach((key, dynamic mapValue) {
        appendMessages('$key', _normalizeErrorMessages(mapValue));
      });
      return normalized;
    }

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          final field =
              item['field'] ??
              item['name'] ??
              item['key'] ??
              item['param'] ??
              'general';
          final source =
              item['message'] ??
              item['messages'] ??
              item['msg'] ??
              item['detail'] ??
              item['error'] ??
              item;

          appendMessages('$field', _normalizeErrorMessages(source));
        } else {
          appendMessages('general', _normalizeErrorMessages(item));
        }
      }
      return normalized;
    }

    appendMessages('general', _normalizeErrorMessages(value));
    return normalized;
  }

  List<String> _normalizeErrorMessages(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is String) {
      final message = value.trim();
      return message.isEmpty ? const [] : <String>[message];
    }

    if (value is num || value is bool) {
      return <String>['$value'];
    }

    if (value is List) {
      final messages = <String>[];
      for (final item in value) {
        for (final message in _normalizeErrorMessages(item)) {
          if (!messages.contains(message)) {
            messages.add(message);
          }
        }
      }
      return messages;
    }

    if (value is Map) {
      for (final key in const [
        'message',
        'messages',
        'msg',
        'detail',
        'error',
        'description',
      ]) {
        if (value.containsKey(key)) {
          return _normalizeErrorMessages(value[key]);
        }
      }

      final messages = <String>[];
      for (final nestedValue in value.values) {
        for (final message in _normalizeErrorMessages(nestedValue)) {
          if (!messages.contains(message)) {
            messages.add(message);
          }
        }
      }
      return messages;
    }

    final message = '$value'.trim();
    return message.isEmpty ? const [] : <String>[message];
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final value = _findValue(payload, const [
      ['access_token'],
      ['accessToken'],
      ['token'],
      ['data', 'access_token'],
      ['data', 'accessToken'],
      ['data', 'token'],
      ['result', 'token'],
    ]);

    if (value == null) {
      return null;
    }
    return '$value';
  }

  String _resolveFailureMessage({
    required _AuthOperation operation,
    required int statusCode,
    required String? messageFromPayload,
    required String failedFallbackMessage,
    required String? errorCode,
    required Map<String, List<String>> errorMap,
  }) {
    final firstErrorMessage = _firstErrorMessage(errorMap);
    if (firstErrorMessage != null) {
      return firstErrorMessage;
    }

    final payloadMessage = _cleanMessage(messageFromPayload);
    if (payloadMessage != null) {
      return payloadMessage;
    }

    switch (operation) {
      case _AuthOperation.verifyOtp:
        return _otpVerifyFallbackMessage(
          statusCode: statusCode,
          errorCode: errorCode,
          defaultMessage: failedFallbackMessage,
        );
      case _AuthOperation.resendOtp:
        return _otpResendFallbackMessage(
          statusCode: statusCode,
          errorCode: errorCode,
          defaultMessage: failedFallbackMessage,
        );
      case _AuthOperation.login:
      case _AuthOperation.register:
        return _authFallbackMessage(
          statusCode: statusCode,
          defaultMessage: failedFallbackMessage,
        );
    }
  }

  String _authFallbackMessage({
    required int statusCode,
    required String defaultMessage,
  }) {
    if (statusCode == 401 || statusCode == 403) {
      return 'Data autentikasi tidak valid.';
    }

    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat.';
    }

    return defaultMessage;
  }

  String _otpVerifyFallbackMessage({
    required int statusCode,
    required String? errorCode,
    required String defaultMessage,
  }) {
    final normalizedErrorCode = _normalizeErrorCode(errorCode);

    if (normalizedErrorCode == 'OTP_EXPIRED' ||
        normalizedErrorCode == 'EXPIRED_OTP') {
      return 'Kode OTP sudah kedaluwarsa. Minta OTP baru.';
    }

    if (normalizedErrorCode == 'OTP_INVALID' ||
        normalizedErrorCode == 'INVALID_OTP') {
      return 'Kode OTP tidak valid. Periksa kembali kode yang dimasukkan.';
    }

    if (normalizedErrorCode == 'OTP_ATTEMPT_LIMIT' ||
        normalizedErrorCode == 'TOO_MANY_ATTEMPTS') {
      return 'Terlalu banyak percobaan. Tunggu beberapa saat sebelum mencoba lagi.';
    }

    if (normalizedErrorCode == 'OTP_ALREADY_VERIFIED') {
      return 'Akun sudah terverifikasi.';
    }

    switch (statusCode) {
      case 400:
      case 422:
        return 'Kode OTP tidak valid. Periksa kembali kode yang dimasukkan.';
      case 401:
      case 403:
        return 'Sesi verifikasi tidak valid. Minta OTP baru lalu coba lagi.';
      case 404:
        return 'Tujuan verifikasi tidak ditemukan.';
      case 409:
        return 'Akun sudah terverifikasi.';
      case 410:
        return 'Kode OTP sudah kedaluwarsa. Minta OTP baru.';
      case 429:
        return 'Terlalu banyak percobaan. Tunggu beberapa saat sebelum mencoba lagi.';
      default:
        if (statusCode >= 500) {
          return 'Server sedang bermasalah. Coba lagi beberapa saat.';
        }
        return defaultMessage;
    }
  }

  String _otpResendFallbackMessage({
    required int statusCode,
    required String? errorCode,
    required String defaultMessage,
  }) {
    final normalizedErrorCode = _normalizeErrorCode(errorCode);

    if (normalizedErrorCode == 'RESEND_TOO_SOON' ||
        normalizedErrorCode == 'OTP_RESEND_COOLDOWN') {
      return 'Terlalu sering mengirim OTP. Tunggu sampai cooldown selesai.';
    }

    if (normalizedErrorCode == 'OTP_ALREADY_VERIFIED') {
      return 'Akun sudah terverifikasi. Tidak perlu kirim ulang OTP.';
    }

    if (normalizedErrorCode == 'OTP_DESTINATION_NOT_FOUND') {
      return 'Tujuan verifikasi tidak ditemukan.';
    }

    switch (statusCode) {
      case 400:
      case 422:
        return 'Permintaan kirim ulang OTP tidak valid.';
      case 404:
        return 'Tujuan verifikasi tidak ditemukan.';
      case 409:
        return 'Akun sudah terverifikasi. Tidak perlu kirim ulang OTP.';
      case 429:
        return 'Terlalu sering mengirim OTP. Tunggu sampai cooldown selesai.';
      default:
        if (statusCode >= 500) {
          return 'Server sedang bermasalah. Coba lagi beberapa saat.';
        }
        return defaultMessage;
    }
  }

  String? _normalizeErrorCode(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return raw.replaceAll('-', '_').replaceAll(' ', '_').toUpperCase();
  }

  String? _cleanMessage(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String? _firstErrorMessage(Map<String, List<String>> errorMap) {
    for (final messages in errorMap.values) {
      if (messages.isNotEmpty) {
        return messages.first;
      }
    }

    return null;
  }

  dynamic _findValue(
    Map<String, dynamic> payload,
    List<List<String>> keyPaths,
  ) {
    for (final path in keyPaths) {
      dynamic current = payload;
      var exists = true;

      for (final segment in path) {
        if (current is Map && current.containsKey(segment)) {
          current = current[segment];
        } else {
          exists = false;
          break;
        }
      }

      if (exists) {
        return current;
      }
    }

    return null;
  }
}

class RemoteAuthServiceResult {
  final bool ok;
  final String message;
  final String? accessToken;
  final int? statusCode;
  final String? errorCode;
  final Map<String, List<String>> errorMap;

  const RemoteAuthServiceResult.success({
    this.message = 'Login berhasil. Selamat datang kembali.',
    this.accessToken,
    this.statusCode,
  }) : ok = true,
       errorCode = null,
       errorMap = const <String, List<String>>{};

  const RemoteAuthServiceResult.failure({
    this.message = 'Gagal masuk. Coba beberapa saat lagi.',
    this.statusCode,
    this.errorCode,
    this.errorMap = const <String, List<String>>{},
  }) : ok = false,
       accessToken = null;
}
