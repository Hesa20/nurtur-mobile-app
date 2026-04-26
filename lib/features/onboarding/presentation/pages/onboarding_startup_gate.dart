import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/login_page.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/data/repositories/onboarding_progress_repository_factory.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/repositories/onboarding_progress_repository.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/pages/onboarding_page.dart';

class OnboardingStartupGate extends StatefulWidget {
  const OnboardingStartupGate({
    super.key,
    this.repository,
    this.completedBuilder,
  });

  final OnboardingProgressRepository? repository;
  final WidgetBuilder? completedBuilder;

  @override
  State<OnboardingStartupGate> createState() => _OnboardingStartupGateState();
}

class _OnboardingStartupGateState extends State<OnboardingStartupGate> {
  late final OnboardingProgressRepository _repository;

  bool? _isOnboardingCompleted;
  bool _isPersistingCompletion = false;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? OnboardingProgressRepositoryFactory.create();
    _loadCompletionState();
  }

  Future<void> _loadCompletionState() async {
    final isCompleted = await _repository.isOnboardingCompleted();

    if (!mounted) {
      return;
    }

    setState(() {
      _isOnboardingCompleted = isCompleted;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_isPersistingCompletion) {
      return;
    }

    setState(() {
      _isPersistingCompletion = true;
    });

    await _repository.markOnboardingCompleted();

    if (!mounted) {
      return;
    }

    setState(() {
      _isPersistingCompletion = false;
      _isOnboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isOnboardingCompleted;

    if (isCompleted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isCompleted) {
      return widget.completedBuilder?.call(context) ?? const LoginPage();
    }

    return OnboardingPage(onFinished: _completeOnboarding);
  }
}
