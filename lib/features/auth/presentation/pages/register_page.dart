import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/repositories/auth_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/data/repositories/onboarding_progress_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';
import 'package:nurtur_app_wppl_agile/shared/widgets/custom_auth_text_field.dart';
import 'package:nurtur_app_wppl_agile/shared/widgets/custom_primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.repository,
    this.onboardingProgressRepository,
    this.otpPageBuilder,
  });

  final AuthRepository? repository;
  final OnboardingProgressRepository? onboardingProgressRepository;
  final Widget Function(String destination)? otpPageBuilder;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
  final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  late final AuthRepository _authRepository;
  late final OnboardingProgressRepository _onboardingProgressRepository;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isAuthError = false;
  bool _isSuccess = false;
  bool _agreeToTerms = false;
  String? _authMessage;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.repository ?? AuthRepositoryFactory.create();
    _onboardingProgressRepository =
        widget.onboardingProgressRepository ??
        OnboardingProgressRepositoryFactory.create();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (input.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!_emailRegex.hasMatch(input)) {
      return 'Format email belum valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (!_passwordRegex.hasMatch(input)) {
      return 'Min. 8 karakter dan mengandung huruf + angka';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (input != _passwordController.text.trim()) {
      return 'Konfirmasi kata sandi tidak sama';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() {
        _authMessage = null;
      });
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _isAuthError = true;
        _isSuccess = false;
        _authMessage = 'Silakan setujui syarat dan ketentuan terlebih dahulu.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();

    setState(() {
      _isSubmitting = true;
      _isAuthError = false;
      _isSuccess = false;
      _authMessage = null;
    });

    final authResult = await _authRepository.signUpWithEmail(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    setState(() {
      _isSubmitting = false;
      _isAuthError = !authResult.isSuccess;
      _isSuccess = authResult.isSuccess;
      _authMessage = authResult.isSuccess ? null : authResult.message;
    });

    if (authResult.isSuccess) {
      await _resetOnboardingCompletionForNewAccount();
      await _openOtpVerificationPage();
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text(authResult.message),
      ),
    );
  }

  void _backToLogin({required bool registered}) {
    Navigator.of(context).pop(registered);
  }

  Future<void> _resetOnboardingCompletionForNewAccount() async {
    try {
      await _onboardingProgressRepository.resetOnboardingCompletion();
    } catch (_) {
      // Best effort reset; registration and OTP flow should continue.
    }
  }

  Future<void> _openOtpVerificationPage() async {
    final destination = _emailController.text.trim();
    final otpPage =
        widget.otpPageBuilder?.call(destination) ??
        OtpVerificationPage(
          destination: destination,
          repository: _authRepository,
        );

    final isVerified = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => otpPage));

    if (!mounted || isVerified != true) {
      return;
    }

    _backToLogin(registered: true);
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
                  (constraints.maxHeight * (isCompact ? 0.33 : 0.37))
                      .clamp(220.0, 320.0)
                      .toDouble();
              final titleSize = (constraints.maxWidth * 0.108)
                  .clamp(38.0, 48.0)
                  .toDouble();
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: _RegisterHeroHeader(
                      onBackPressed: () => _backToLogin(registered: false),
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
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar',
                                    style: TextStyle(
                                      color: AppColors.primaryPurple,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 14 : 18),
                                  const Text(
                                    'Buat akun untuk mulai perjalanan dukungan kesehatan mental Anda.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 16 : 20),
                                  AutofillGroup(
                                    child: Column(
                                      children: [
                                        CustomAuthTextField(
                                          hintText: 'Nama Lengkap',
                                          controller: _fullNameController,
                                          enabled: !_isSubmitting,
                                          autofillHints: const [
                                            AutofillHints.name,
                                            AutofillHints.namePrefix,
                                          ],
                                          validator: _validateFullName,
                                        ),
                                        const SizedBox(height: 12),
                                        CustomAuthTextField(
                                          hintText: 'Email',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: _emailController,
                                          enabled: !_isSubmitting,
                                          autofillHints: const [
                                            AutofillHints.email,
                                            AutofillHints.username,
                                          ],
                                          validator: _validateEmail,
                                        ),
                                        const SizedBox(height: 12),
                                        CustomAuthTextField(
                                          hintText: 'Kata Sandi',
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          enabled: !_isSubmitting,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.newPassword,
                                          ],
                                          validator: _validatePassword,
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            onPressed: _isSubmitting
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _obscurePassword =
                                                          !_obscurePassword;
                                                    });
                                                  },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        CustomAuthTextField(
                                          hintText: 'Konfirmasi Kata Sandi',
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          enabled: !_isSubmitting,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.newPassword,
                                          ],
                                          validator: _validateConfirmPassword,
                                          onFieldSubmitted: (_) =>
                                              _handleRegister(),
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            onPressed: _isSubmitting
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _obscureConfirmPassword =
                                                          !_obscureConfirmPassword;
                                                    });
                                                  },
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: _isSubmitting
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _agreeToTerms =
                                                      value ?? false;
                                                });
                                              },
                                        activeColor: AppColors.primaryPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 12),
                                          child: Text(
                                            'Saya menyetujui syarat layanan dan kebijakan privasi Nurtur.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isCompact ? 10 : 14),
                                  CustomPrimaryButton(
                                    label: 'Buat Akun',
                                    fontSize: 18,
                                    isLoading: _isSubmitting,
                                    onPressed: _isSubmitting
                                        ? null
                                        : _handleRegister,
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _authMessage == null
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            key: ValueKey(_authMessage),
                                            padding: const EdgeInsets.only(
                                              top: 14,
                                            ),
                                            child: _AuthStatusBanner(
                                              message: _authMessage!,
                                              isError: _isAuthError,
                                            ),
                                          ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _isSuccess
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: OutlinedButton.icon(
                                                    onPressed:
                                                        _openOtpVerificationPage,
                                                    icon: const Icon(
                                                      Icons
                                                          .verified_user_outlined,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      'Lanjut Verifikasi OTP',
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      minimumSize:
                                                          const Size.fromHeight(
                                                            48,
                                                          ),
                                                      foregroundColor: AppColors
                                                          .primaryPurple,
                                                      side: const BorderSide(
                                                        color: AppColors
                                                            .primaryPurple,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextButton.icon(
                                                  onPressed: () => _backToLogin(
                                                    registered: true,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.arrow_back,
                                                    size: 18,
                                                  ),
                                                  label: const Text(
                                                    'Kembali ke Login',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(height: isCompact ? 18 : 24),
                                  _LoginPrompt(
                                    onTap: () =>
                                        _backToLogin(registered: false),
                                  ),
                                ],
                              ),
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

class _RegisterHeroHeader extends StatelessWidget {
  const _RegisterHeroHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = (constraints.maxWidth * 0.14)
              .clamp(34.0, 44.0)
              .toDouble();

          return DecoratedBox(
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
                  right: -95,
                  bottom: -120,
                  child: _DecorCircle(
                    diameter: 260,
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
                  alignment: const Alignment(0, -0.25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white.withValues(alpha: 0.96),
                        size: logoSize,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat Akun Nurtur',
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
          );
        },
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Sudah punya akun? ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPurple,
            minimumSize: const Size(0, 0),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Masuk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _AuthStatusBanner extends StatelessWidget {
  const _AuthStatusBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground = isError ? AppColors.danger : AppColors.success;
    final background = isError ? AppColors.dangerSoft : AppColors.successSoft;

    return Container(
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
    );
  }
}
