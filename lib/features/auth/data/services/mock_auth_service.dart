class MockAuthService {
  const MockAuthService({this.latency = const Duration(milliseconds: 1100)});

  final Duration latency;

  Future<MockAuthServiceResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(latency);

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedEmail.endsWith('@blocked.local')) {
      return const MockAuthServiceResult.failure(
        message: 'Akun tidak dapat diakses saat ini.',
      );
    }

    if (normalizedPassword.length < 8) {
      return const MockAuthServiceResult.failure(
        message: 'Kata sandi yang Anda masukkan tidak valid.',
      );
    }

    return MockAuthServiceResult.success(
      accessToken: 'mock_access_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<MockAuthServiceResult> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(latency);

    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedName.length < 3) {
      return const MockAuthServiceResult.failure(
        message: 'Nama lengkap minimal 3 karakter.',
      );
    }

    if (normalizedEmail.startsWith('taken.')) {
      return const MockAuthServiceResult.failure(
        message: 'Email sudah terdaftar. Gunakan email lain.',
      );
    }

    if (normalizedPassword.length < 8) {
      return const MockAuthServiceResult.failure(
        message: 'Kata sandi minimal 8 karakter.',
      );
    }

    return const MockAuthServiceResult.success(
      message: 'Akun berhasil dibuat. Silakan login.',
    );
  }

  Future<MockAuthServiceResult> verifyOtp({
    required String destination,
    required String otpCode,
  }) async {
    await Future.delayed(latency);

    final normalizedDestination = destination.trim().toLowerCase();
    final normalizedCode = otpCode.trim();

    if (normalizedDestination.isEmpty) {
      return const MockAuthServiceResult.failure(
        message: 'Tujuan verifikasi tidak valid. Ulangi pendaftaran.',
      );
    }

    if (normalizedCode == '0000') {
      return const MockAuthServiceResult.failure(
        message: 'Kode OTP sudah kedaluwarsa. Silakan kirim ulang kode.',
      );
    }

    if (normalizedCode.length != 4) {
      return const MockAuthServiceResult.failure(
        message: 'Kode OTP harus terdiri dari 4 digit.',
      );
    }

    if (!RegExp(r'^\d{4}$').hasMatch(normalizedCode)) {
      return const MockAuthServiceResult.failure(
        message: 'Kode OTP hanya boleh berisi angka.',
      );
    }

    final digits = normalizedCode.split('').map(int.parse).toList();
    final isEvenSum = digits.reduce((a, b) => a + b).isEven;

    if (!isEvenSum) {
      return const MockAuthServiceResult.failure(
        message: 'Kode OTP yang dimasukkan tidak sesuai.',
      );
    }

    return const MockAuthServiceResult.success(
      message: 'Verifikasi OTP berhasil. Akun Anda sudah aktif.',
    );
  }

  Future<MockAuthServiceResult> resendOtp({required String destination}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedDestination = destination.trim().toLowerCase();
    if (normalizedDestination.isEmpty) {
      return const MockAuthServiceResult.failure(
        message: 'Alamat tujuan OTP tidak valid.',
      );
    }

    if (normalizedDestination.endsWith('@blocked.local')) {
      return const MockAuthServiceResult.failure(
        message: 'Permintaan kirim ulang OTP dibatasi sementara.',
      );
    }

    return const MockAuthServiceResult.success(
      message: 'Kode OTP baru telah dikirim.',
    );
  }
}

class MockAuthServiceResult {
  final bool ok;
  final String message;
  final String? accessToken;

  const MockAuthServiceResult.success({
    this.message = 'Login berhasil. Selamat datang kembali.',
    this.accessToken,
  }) : ok = true;

  const MockAuthServiceResult.failure({
    this.message = 'Gagal masuk. Coba beberapa saat lagi.',
  }) : ok = false,
       accessToken = null;
}
