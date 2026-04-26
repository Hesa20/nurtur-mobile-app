class OtpFlowConfig {
  const OtpFlowConfig._();

  // Phase 1: flow definition for OTP page.
  static const int otpLength = 4;
  static const bool autoSubmitWhenComplete = false;
  static const bool allowClipboardPaste = true;
  static const int maxVerificationAttempts = 5;
  static const Duration resendCooldown = Duration(seconds: 60);
}
