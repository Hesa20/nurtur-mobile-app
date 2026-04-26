import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/repositories/auth_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/otp_flow_config.dart';
import 'package:nurtur_app_wppl_agile/shared/widgets/custom_primary_button.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.destination,
    this.repository,
  });

  final String destination;
  final AuthRepository? repository;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late final AuthRepository _authRepository;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  Timer? _resendTimer;
  int _remainingResendSeconds = OtpFlowConfig.resendCooldown.inSeconds;
  int _verificationAttempts = 0;

  bool _isCodeComplete = false;
  bool _isErrorStatus = false;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _isVerified = false;
  String? _statusMessage;

  String get _otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  bool get _isAttemptLocked =>
      _verificationAttempts >= OtpFlowConfig.maxVerificationAttempts;

  bool get _isInputEnabled =>
      !_isVerifying && !_isResending && !_isVerified && !_isAttemptLocked;

  bool get _canVerify =>
      _isCodeComplete &&
      !_isVerifying &&
      !_isResending &&
      !_isVerified &&
      !_isAttemptLocked;

  bool get _canResend =>
      _remainingResendSeconds == 0 &&
      !_isResending &&
      !_isVerifying &&
      !_isVerified;

  int get _remainingAttemptCount {
    final value = OtpFlowConfig.maxVerificationAttempts - _verificationAttempts;
    return value < 0 ? 0 : value;
  }

  String get _resendTimeText {
    final minutes = (_remainingResendSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingResendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _authRepository = widget.repository ?? AuthRepositoryFactory.create();
    _otpControllers = List.generate(
      OtpFlowConfig.otpLength,
      (_) => TextEditingController(),
    );
    _otpFocusNodes = List.generate(OtpFlowConfig.otpLength, (_) => FocusNode());

    _startResendCountdown(reset: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _otpFocusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown({required bool reset}) {
    _resendTimer?.cancel();
    if (reset) {
      _remainingResendSeconds = OtpFlowConfig.resendCooldown.inSeconds;
    }

    if (_remainingResendSeconds <= 0) {
      return;
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingResendSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingResendSeconds = 0;
        });
        return;
      }

      setState(() {
        _remainingResendSeconds--;
      });
    });
  }

  void _resetOtpInputs({required bool requestFocus}) {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _updateOtpCompletionState();

    if (requestFocus) {
      _otpFocusNodes.first.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _clearOtpStatusWhileEditing() {
    if (_statusMessage == null && !_isErrorStatus) {
      return;
    }

    setState(() {
      _statusMessage = null;
      _isErrorStatus = false;
    });
  }

  void _updateOtpCompletionState() {
    final isComplete = _otpControllers.every(
      (controller) => controller.text.length == 1,
    );
    if (_isCodeComplete == isComplete) {
      return;
    }

    setState(() {
      _isCodeComplete = isComplete;
    });

    if (isComplete && OtpFlowConfig.autoSubmitWhenComplete && _canVerify) {
      _handleVerify();
    }
  }

  void _fillOtpFromString(String rawValue) {
    if (!_isInputEnabled) {
      return;
    }

    final digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return;
    }

    final end = digits.length > OtpFlowConfig.otpLength
        ? OtpFlowConfig.otpLength
        : digits.length;

    for (var i = 0; i < OtpFlowConfig.otpLength; i++) {
      _otpControllers[i].text = i < end ? digits[i] : '';
    }

    if (end >= OtpFlowConfig.otpLength) {
      FocusScope.of(context).unfocus();
    } else {
      _otpFocusNodes[end].requestFocus();
    }

    _clearOtpStatusWhileEditing();
    _updateOtpCompletionState();
  }

  Future<void> _pasteOtpFromClipboard() async {
    if (!OtpFlowConfig.allowClipboardPaste || !_isInputEnabled) {
      return;
    }

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final value = clipboardData?.text ?? '';

    if (value.trim().isEmpty) {
      return;
    }

    _fillOtpFromString(value);

    if (_otpCode.length < OtpFlowConfig.otpLength) {
      setState(() {
        _isErrorStatus = true;
        _statusMessage =
            'Kode OTP dari clipboard belum lengkap. Pastikan ${OtpFlowConfig.otpLength} digit.';
      });
    }
  }

  void _onOtpChanged(String value, int index) {
    if (!_isInputEnabled) {
      return;
    }

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      _otpControllers[index].clear();
      _clearOtpStatusWhileEditing();
      _updateOtpCompletionState();
      return;
    }

    if (digits.length > 1) {
      _fillOtpFromString(digits);
      return;
    }

    final digit = digits[0];
    if (_otpControllers[index].text != digit) {
      _otpControllers[index].value = TextEditingValue(
        text: digit,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    if (index < OtpFlowConfig.otpLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }

    _clearOtpStatusWhileEditing();
    _updateOtpCompletionState();
  }

  KeyEventResult _handleOtpKeyEvent(KeyEvent event, int index) {
    if (!_isInputEnabled) {
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    if (_otpControllers[index].text.isNotEmpty || index == 0) {
      return KeyEventResult.ignored;
    }

    _otpControllers[index - 1].clear();
    _otpFocusNodes[index - 1].requestFocus();
    _clearOtpStatusWhileEditing();
    _updateOtpCompletionState();
    return KeyEventResult.handled;
  }

  Future<void> _handleVerify() async {
    if (_isVerifying || _isResending) {
      return;
    }

    if (_isAttemptLocked) {
      setState(() {
        _isErrorStatus = true;
        _statusMessage =
            'Batas percobaan tercapai. Silakan kirim ulang OTP untuk mencoba lagi.';
      });
      return;
    }

    if (!_isCodeComplete) {
      setState(() {
        _isErrorStatus = true;
        _statusMessage =
            'Masukkan ${OtpFlowConfig.otpLength} digit kode OTP terlebih dahulu.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
      _isErrorStatus = false;
      _statusMessage = null;
    });

    final authResult = await _authRepository.verifyOtp(
      destination: widget.destination,
      otpCode: _otpCode,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (authResult.isSuccess) {
      _resendTimer?.cancel();
      setState(() {
        _isVerifying = false;
        _isVerified = true;
        _isErrorStatus = false;
        _statusMessage = authResult.message;
      });

      final navigator = Navigator.of(context);
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.success,
          content: Text(authResult.message),
        ),
      );

      if (navigator.canPop()) {
        await Future<void>.delayed(const Duration(seconds: 3));
        if (!mounted) {
          return;
        }

        final currentNavigator = Navigator.of(context);
        if (currentNavigator.canPop()) {
          currentNavigator.pop(true);
        }
        return;
      }

      return;
    }

    setState(() {
      _isVerifying = false;
      _verificationAttempts++;
      _isErrorStatus = true;

      if (_isAttemptLocked) {
        _statusMessage =
            '${authResult.message} Batas percobaan tercapai. Kirim ulang OTP.';
      } else {
        _statusMessage =
            '${authResult.message} Sisa percobaan $_remainingAttemptCount kali.';
      }
    });

    _resetOtpInputs(requestFocus: !_isAttemptLocked);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text(_statusMessage ?? authResult.message),
      ),
    );
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) {
      return;
    }

    setState(() {
      _isResending = true;
      _isErrorStatus = false;
      _statusMessage = null;
    });

    final authResult = await _authRepository.resendOtp(
      destination: widget.destination,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (authResult.isSuccess) {
      setState(() {
        _isResending = false;
        _isVerified = false;
        _verificationAttempts = 0;
        _isErrorStatus = false;
        _statusMessage = authResult.message;
      });
      _resetOtpInputs(requestFocus: true);
      _startResendCountdown(reset: true);

      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(authResult.message),
        ),
      );
      return;
    }

    setState(() {
      _isResending = false;
      _isErrorStatus = true;
      _statusMessage = authResult.message;
    });

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text(authResult.message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 760;
              final sidePadding = (constraints.maxWidth * 0.055)
                  .clamp(16.0, 28.0)
                  .toDouble();
              final headerHeight =
                  (constraints.maxHeight * (isCompact ? 0.31 : 0.34))
                      .clamp(210.0, 300.0)
                      .toDouble();
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: _OtpHeroHeader(
                      onBackPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(isCompact ? 30 : 36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              sidePadding,
                              isCompact ? 18 : 24,
                              sidePadding,
                              keyboardInset + 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verifikasi Kode OTP',
                                  style: TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 12 : 16),
                                Text(
                                  'Masukkan ${OtpFlowConfig.otpLength} digit kode yang kami kirim ke ${widget.destination}.',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed:
                                          OtpFlowConfig.allowClipboardPaste &&
                                              _isInputEnabled
                                          ? _pasteOtpFromClipboard
                                          : null,
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.primaryPurple,
                                        minimumSize: const Size(0, 0),
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Tempel dari clipboard',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LayoutBuilder(
                                  builder: (context, otpConstraints) {
                                    const fieldSpacing = 8.0;
                                    final totalSpacing =
                                        fieldSpacing *
                                        (OtpFlowConfig.otpLength - 1);
                                    final calculatedFieldWidth =
                                        (otpConstraints.maxWidth -
                                            totalSpacing) /
                                        OtpFlowConfig.otpLength;
                                    final fieldWidth = calculatedFieldWidth
                                        .clamp(44.0, 64.0)
                                        .toDouble();

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        OtpFlowConfig.otpLength,
                                        (index) {
                                          final digit =
                                              _otpControllers[index].text;

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right:
                                                  index ==
                                                      OtpFlowConfig.otpLength -
                                                          1
                                                  ? 0
                                                  : fieldSpacing,
                                            ),
                                            child: SizedBox(
                                              width: fieldWidth,
                                              child: _OtpDigitField(
                                                fieldKey: Key(
                                                  'otp-digit-field-$index',
                                                ),
                                                semanticsLabel:
                                                    'Digit OTP ${index + 1} dari ${OtpFlowConfig.otpLength}',
                                                semanticsValue: digit.isEmpty
                                                    ? 'Kosong'
                                                    : 'Terisi $digit',
                                                controller:
                                                    _otpControllers[index],
                                                focusNode:
                                                    _otpFocusNodes[index],
                                                enabled: _isInputEnabled,
                                                onChanged: (value) =>
                                                    _onOtpChanged(value, index),
                                                onKeyEvent: (event) =>
                                                    _handleOtpKeyEvent(
                                                      event,
                                                      index,
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                if (_verificationAttempts > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      'Percobaan verifikasi: $_verificationAttempts/${OtpFlowConfig.maxVerificationAttempts}',
                                      style: TextStyle(
                                        color: _isAttemptLocked
                                            ? AppColors.danger
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: isCompact ? 16 : 20),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _canResend
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton(
                                                onPressed: _isResending
                                                    ? null
                                                    : _handleResendOtp,
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.primaryPurple,
                                                  minimumSize: const Size(0, 0),
                                                  padding: EdgeInsets.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                child: const Text(
                                                  'Kirim ulang OTP',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Kirim ulang tersedia dalam $_resendTimeText',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                    if (_isResending) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CustomPrimaryButton(
                                  key: const Key('otp-verify-button'),
                                  label: _isVerified
                                      ? 'Terverifikasi'
                                      : 'Verifikasi',
                                  fontSize: 18,
                                  isLoading: _isVerifying,
                                  onPressed:
                                      _isVerifying ||
                                          _isResending ||
                                          _isVerified
                                      ? null
                                      : _handleVerify,
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _statusMessage == null
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          key: ValueKey(_statusMessage),
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                          ),
                                          child: _OtpStatusBanner(
                                            message: _statusMessage!,
                                            isError: _isErrorStatus,
                                          ),
                                        ),
                                ),
                                if (_isVerified)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: TextButton.icon(
                                        onPressed: () {
                                          final navigator = Navigator.of(
                                            context,
                                          );
                                          if (navigator.canPop()) {
                                            navigator.pop(true);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 18,
                                        ),
                                        label: const Text('Kembali'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OtpHeroHeader extends StatelessWidget {
  const _OtpHeroHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurpleLight,
              AppColors.primaryPurple,
              AppColors.primaryPurpleDark,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -75,
              top: -95,
              child: _DecorCircle(
                diameter: 200,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              right: -90,
              bottom: -118,
              child: _DecorCircle(
                diameter: 250,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              left: 10,
              top: 8,
              child: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Kembali',
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.96),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifikasi Akun',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.fieldKey,
    required this.semanticsLabel,
    required this.semanticsValue,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final Key fieldKey;
  final String semanticsLabel;
  final String semanticsValue;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) => onKeyEvent(event),
      child: Semantics(
        key: fieldKey,
        textField: true,
        label: semanticsLabel,
        value: semanticsValue,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.primaryPurple,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: onChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _OtpStatusBanner extends StatelessWidget {
  const _OtpStatusBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground = isError ? AppColors.danger : AppColors.success;
    final background = isError ? AppColors.dangerSoft : AppColors.successSoft;

    return Semantics(
      container: true,
      liveRegion: true,
      label: isError ? 'Status verifikasi gagal' : 'Status verifikasi berhasil',
      value: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: foreground.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              size: 18,
              color: foreground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
