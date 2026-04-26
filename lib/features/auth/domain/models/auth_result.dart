class AuthResult {
  final bool isSuccess;
  final String message;
  final String? accessToken;
  final int? statusCode;
  final String? errorCode;
  final Map<String, List<String>> errorMap;

  const AuthResult.success({
    this.message = 'Login berhasil. Selamat datang kembali.',
    this.accessToken,
    this.statusCode,
  }) : isSuccess = true,
       errorCode = null,
       errorMap = const <String, List<String>>{};

  const AuthResult.failure({
    this.message = 'Gagal masuk. Coba beberapa saat lagi.',
    this.statusCode,
    this.errorCode,
    this.errorMap = const <String, List<String>>{},
  }) : isSuccess = false,
       accessToken = null;
}
