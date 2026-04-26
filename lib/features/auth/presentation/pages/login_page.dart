import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/repositories/auth_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/register_page.dart';
import 'package:nurtur_app_wppl_agile/features/home/presentation/pages/home_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/data/repositories/onboarding_progress_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nurtur_app_wppl_agile/shared/widgets/custom_auth_text_field.dart';
import 'package:nurtur_app_wppl_agile/shared/widgets/custom_primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.authRepository,
    this.onboardingProgressRepository,
    this.homePageBuilder,
    this.onboardingPageBuilder,
  });

  final AuthRepository? authRepository;
  final OnboardingProgressRepository? onboardingProgressRepository;
  final WidgetBuilder? homePageBuilder;
  final Widget Function(Future<void> Function() onFinished)?
  onboardingPageBuilder;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
  late final AuthRepository _authRepository;
  late final OnboardingProgressRepository _onboardingProgressRepository;

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isAuthError = false;
  String? _authMessage;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepositoryFactory.create();
    _onboardingProgressRepository =
        widget.onboardingProgressRepository ??
        OnboardingProgressRepositoryFactory.create();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    if (input.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }

  Future<void> _handleLogin() async {
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

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();

    setState(() {
      _isSubmitting = true;
      _isAuthError = false;
      _authMessage = null;
    });

    final authResult = await _authRepository.signInWithEmail(
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
      _authMessage = authResult.message;
    });

    if (authResult.isSuccess) {
      final isReadyForHome = await _ensureOnboardingCompleted();
      if (!mounted || !isReadyForHome) {
        return;
      }

      _openHomePage();
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

  Future<bool> _ensureOnboardingCompleted() async {
    final isCompleted = await _onboardingProgressRepository
        .isOnboardingCompleted();

    if (!mounted) {
      return false;
    }

    if (isCompleted) {
      return true;
    }

    return _openOnboardingFlow();
  }

  Future<bool> _openOnboardingFlow() async {
    if (!mounted) {
      return false;
    }

    Future<void> finishOnboarding() async {
      await _onboardingProgressRepository.markOnboardingCompleted();
      if (!mounted) {
        return;
      }

      final currentNavigator = Navigator.of(context);
      if (currentNavigator.canPop()) {
        currentNavigator.pop(true);
      }
    }

    final onboardingPage =
        widget.onboardingPageBuilder?.call(finishOnboarding) ??
        OnboardingPage(onFinished: finishOnboarding);

    final navigator = Navigator.of(context);
    final finished = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => onboardingPage),
    );

    if (!mounted) {
      return false;
    }

    if (finished == true) {
      return true;
    }

    return _onboardingProgressRepository.isOnboardingCompleted();
  }

  void _openHomePage() {
    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: widget.homePageBuilder ?? (_) => const HomePage(),
      ),
    );
  }

  void _handleForgotPassword() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Fitur reset kata sandi akan segera tersedia.'),
      ),
    );
  }

  Future<void> _openRegisterPage() async {
    final registered = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const RegisterPage()));

    if (!mounted || registered != true) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text('Akun berhasil dibuat. Silakan masuk.'),
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
                  (constraints.maxHeight * (isCompact ? 0.4 : 0.44))
                      .clamp(250.0, 380.0)
                      .toDouble();
              final titleSize =
                  (constraints.maxWidth * (isCompact ? 0.115 : 0.12))
                      .clamp(40.0, 52.0)
                      .toDouble();
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: const _HeroHeader(),
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
                              keyboardInset + 22,
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      color: AppColors.primaryPurple,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 16 : 22),
                                  AutofillGroup(
                                    child: Column(
                                      children: [
                                        CustomAuthTextField(
                                          hintText: 'Email',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          autofillHints: const [
                                            AutofillHints.email,
                                            AutofillHints.username,
                                          ],
                                          controller: _emailController,
                                          enabled: !_isSubmitting,
                                          validator: _validateEmail,
                                        ),
                                        const SizedBox(height: 14),
                                        CustomAuthTextField(
                                          hintText: 'Kata Sandi',
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          enabled: !_isSubmitting,
                                          validator: _validatePassword,
                                          onFieldSubmitted: (_) =>
                                              _handleLogin(),
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
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _handleForgotPassword,
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.primaryPurple,
                                        minimumSize: const Size(0, 0),
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Lupa Kata Sandi?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 16 : 22),
                                  CustomPrimaryButton(
                                    label: 'Masuk',
                                    fontSize: 18,
                                    isLoading: _isSubmitting,
                                    onPressed: _isSubmitting
                                        ? null
                                        : _handleLogin,
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
                                  SizedBox(height: isCompact ? 18 : 24),
                                  const Center(
                                    child: Text(
                                      'Atau',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  _GoogleLoginButton(
                                    onPressed: _isSubmitting ? null : () {},
                                  ),
                                  const SizedBox(height: 24),
                                  _SignUpPrompt(onTap: _openRegisterPage),
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = (constraints.maxWidth * 0.16)
              .clamp(46.0, 64.0)
              .toDouble();
          final illustrationTop = (constraints.maxHeight * 0.22)
              .clamp(74.0, 112.0)
              .toDouble();
          final illustrationHeight =
              (constraints.maxHeight - illustrationTop - 6)
                  .clamp(130.0, 250.0)
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
                  right: -105,
                  bottom: -130,
                  child: _DecorCircle(
                    diameter: 280,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 8,
                  child: Center(
                    child: Text(
                      'nurtur',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: logoSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: illustrationTop,
                  child: Center(
                    child: Image.asset(
                      'assets/images/login_family_hero.png',
                      height: illustrationHeight,
                      fit: BoxFit.contain,
                    ),
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

class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        backgroundColor: Colors.white.withValues(alpha: 0.74),
        side: BorderSide(color: AppColors.primaryPurple.withValues(alpha: 0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppColors.primaryPurple,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _GoogleBadge(),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              'Masuk dengan akun Google',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/google_logo.png',
        width: 21,
        height: 21,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: [
        const Text(
          'Belum memiliki akun? ',
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
            'Daftar disini',
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
