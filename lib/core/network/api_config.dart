class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.loginPath,
    required this.registerPath,
    required this.verifyOtpPath,
    required this.resendOtpPath,
    required this.timeout,
  });

  final String baseUrl;
  final String loginPath;
  final String registerPath;
  final String verifyOtpPath;
  final String resendOtpPath;
  final Duration timeout;

  static const String _baseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _loginPathEnv = String.fromEnvironment(
    'API_LOGIN_PATH',
    defaultValue: '/auth/login',
  );
  static const String _registerPathEnv = String.fromEnvironment(
    'API_REGISTER_PATH',
    defaultValue: '/auth/register',
  );
  static const String _verifyOtpPathEnv = String.fromEnvironment(
    'API_VERIFY_OTP_PATH',
    defaultValue: '/auth/verify-otp',
  );
  static const String _resendOtpPathEnv = String.fromEnvironment(
    'API_RESEND_OTP_PATH',
    defaultValue: '/auth/resend-otp',
  );
  static const int _timeoutSecondsEnv = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 15,
  );

  static bool get isConfigured => _baseUrlEnv.trim().isNotEmpty;

  static ApiConfig get current {
    final normalizedBaseUrl = _normalizeBaseUrl(_baseUrlEnv);
    final normalizedLoginPath = _normalizePath(_loginPathEnv);
    final normalizedRegisterPath = _normalizePath(_registerPathEnv);
    final normalizedVerifyOtpPath = _normalizePath(_verifyOtpPathEnv);
    final normalizedResendOtpPath = _normalizePath(_resendOtpPathEnv);
    final timeoutSeconds = _timeoutSecondsEnv <= 0 ? 15 : _timeoutSecondsEnv;

    return ApiConfig(
      baseUrl: normalizedBaseUrl,
      loginPath: normalizedLoginPath,
      registerPath: normalizedRegisterPath,
      verifyOtpPath: normalizedVerifyOtpPath,
      resendOtpPath: normalizedResendOtpPath,
      timeout: Duration(seconds: timeoutSeconds),
    );
  }

  Uri get loginUri => Uri.parse('$baseUrl$loginPath');
  Uri get registerUri => Uri.parse('$baseUrl$registerPath');
  Uri get verifyOtpUri => Uri.parse('$baseUrl$verifyOtpPath');
  Uri get resendOtpUri => Uri.parse('$baseUrl$resendOtpPath');

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '/auth/login';
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
