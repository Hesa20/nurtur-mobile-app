import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/models/onboarding_form_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/config/onboarding_flow_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_foundation_scaffold.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_intro_content.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  int _currentPageIndex = 0;
  bool _isPageTransitioning = false;
  bool _isCompleting = false;

  String? _selectedAgeGroup;
  String? _selectedRole;
  OnboardingMood? _selectedMood;

  bool get _isFinalFormComplete {
    final hasAgeGroup =
        !OnboardingFlowContract.requiresAgeGroup || _selectedAgeGroup != null;
    final hasRole =
        !OnboardingFlowContract.requiresRole || _selectedRole != null;
    final hasMood =
        !OnboardingFlowContract.requiresMood || _selectedMood != null;

    return hasAgeGroup && hasRole && hasMood;
  }

  bool get _isPrimaryActionEnabled {
    if (_isCompleting || _isPageTransitioning) {
      return false;
    }

    if (_isFinalPage) {
      return _isFinalFormComplete;
    }

    return true;
  }

  String? get _finalValidationHint {
    if (!_isFinalPage || _isFinalFormComplete) {
      return null;
    }

    final missingFields = <String>[];
    if (OnboardingFlowContract.requiresAgeGroup && _selectedAgeGroup == null) {
      missingFields.add('kelompok umur');
    }
    if (OnboardingFlowContract.requiresRole && _selectedRole == null) {
      missingFields.add('peran');
    }
    if (OnboardingFlowContract.requiresMood && _selectedMood == null) {
      missingFields.add('perasaan');
    }

    if (missingFields.isEmpty) {
      return null;
    }

    final fieldsText = missingFields.join(', ');
    return 'Lengkapi $fieldsText untuk melanjutkan.';
  }

  bool get _isIntroPage =>
      _currentPageIndex < OnboardingFlowContract.introPageCount;

  bool get _isFinalPage =>
      _currentPageIndex == OnboardingFlowContract.totalPageCount - 1;

  String get _primaryActionLabel {
    if (_isFinalPage) {
      return OnboardingFlowContract.finalPrimaryButtonLabel;
    }

    return OnboardingFlowContract
        .introSlides[_currentPageIndex]
        .primaryButtonLabel;
  }

  String? get _secondaryActionLabel {
    if (!_isIntroPage) {
      return null;
    }

    final currentSlide = OnboardingFlowContract.introSlides[_currentPageIndex];
    if (!currentSlide.showSecondaryBackAction) {
      return null;
    }

    return OnboardingFlowContract.secondaryBackLabel;
  }

  String? get _topBackLabel {
    if (_isFinalPage && OnboardingFlowContract.showTopBackActionOnFinalPage) {
      return OnboardingFlowContract.secondaryBackLabel;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int targetPage) async {
    if (targetPage < 0 || targetPage >= OnboardingFlowContract.totalPageCount) {
      return;
    }

    if (_isPageTransitioning) {
      return;
    }

    setState(() {
      _isPageTransitioning = true;
    });

    try {
      await _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPageTransitioning = false;
        });
      }
    }
  }

  void _showFinishErrorFeedback() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text(
          'Terjadi gangguan saat menyelesaikan onboarding. Coba lagi.',
        ),
      ),
    );
  }

  Future<void> _goToNextPage() async {
    await _animateToPage(_currentPageIndex + 1);
  }

  Future<void> _goToPreviousPage() async {
    await _animateToPage(_currentPageIndex - 1);
  }

  Future<void> _handlePrimaryAction() async {
    if (_isCompleting) {
      return;
    }

    if (_isFinalPage) {
      if (!_isFinalFormComplete) {
        return;
      }

      setState(() {
        _isCompleting = true;
      });

      try {
        await widget.onFinished();
      } catch (_) {
        if (mounted) {
          _showFinishErrorFeedback();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCompleting = false;
          });
        }
      }
      return;
    }

    await _goToNextPage();
  }

  void _handlePageChanged(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
    });
  }

  Widget _buildPageContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: _handlePageChanged,
      children: [
        for (final slide in OnboardingFlowContract.introSlides)
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OnboardingIntroContent(
                title: slide.title,
                description: slide.description,
                imageAssetPath: slide.imageAssetPath,
              ),
            ),
          ),
        SingleChildScrollView(
          child: _OnboardingFinalFormContent(
            selectedAgeGroup: _selectedAgeGroup,
            selectedRole: _selectedRole,
            selectedMood: _selectedMood,
            validationHint: _finalValidationHint,
            onAgeGroupChanged: (value) {
              setState(() {
                _selectedAgeGroup = value;
              });
            },
            onRoleChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
            onMoodChanged: (value) {
              setState(() {
                _selectedMood = value;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressIndicator = _isIntroPage
        ? OnboardingProgressDots(
            totalDots: OnboardingFlowContract.introPageCount,
            activeIndex: _currentPageIndex,
          )
        : null;

    return PopScope(
      canPop: _currentPageIndex == 0 && !_isPageTransitioning,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop ||
            _currentPageIndex == 0 ||
            _isPageTransitioning ||
            _isCompleting) {
          return;
        }

        _goToPreviousPage();
      },
      child: OnboardingFoundationScaffold(
        appLabel: OnboardingFlowContract.appLabel,
        scrollContent: false,
        content: _buildPageContent(),
        progressIndicator: progressIndicator,
        primaryButtonLabel: _primaryActionLabel,
        onPrimaryPressed: _isPrimaryActionEnabled ? _handlePrimaryAction : null,
        secondaryButtonLabel: _secondaryActionLabel,
        onSecondaryPressed:
            _secondaryActionLabel == null ||
                _isPageTransitioning ||
                _isCompleting
            ? null
            : _goToPreviousPage,
        topBackLabel: _topBackLabel,
        onTopBackPressed:
            _topBackLabel == null || _isPageTransitioning || _isCompleting
            ? null
            : _goToPreviousPage,
      ),
    );
  }
}

class _OnboardingFinalFormContent extends StatelessWidget {
  const _OnboardingFinalFormContent({
    required this.selectedAgeGroup,
    required this.selectedRole,
    required this.selectedMood,
    this.validationHint,
    required this.onAgeGroupChanged,
    required this.onRoleChanged,
    required this.onMoodChanged,
  });

  final String? selectedAgeGroup;
  final String? selectedRole;
  final OnboardingMood? selectedMood;
  final String? validationHint;
  final ValueChanged<String?> onAgeGroupChanged;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<OnboardingMood> onMoodChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text(
            OnboardingFlowContract.finalPageTitle,
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            OnboardingFlowContract.finalPageSubtitle,
            style: TextStyle(
              color: Color(0xFF6D6D72),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: const Key('onboarding-age-group-field'),
            value: selectedAgeGroup,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9D9AA8),
              size: 24,
            ),
            hint: const Text(OnboardingFlowContract.ageGroupFieldLabel),
            items: OnboardingFlowContract.ageGroupOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
            onChanged: onAgeGroupChanged,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: const Key('onboarding-role-field'),
            value: selectedRole,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9D9AA8),
              size: 24,
            ),
            hint: const Text(OnboardingFlowContract.roleFieldLabel),
            items: OnboardingFlowContract.roleOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: 22),
          const Text(
            OnboardingFlowContract.moodFieldLabel,
            style: TextStyle(
              color: Color(0xFF6D6D72),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: OnboardingFlowContract.moodOptions
                .map(
                  (option) => _MoodChip(
                    key: Key('onboarding-mood-${option.mood.name}'),
                    emoji: option.emoji,
                    label: option.label,
                    isSelected: selectedMood == option.mood,
                    onTap: () => onMoodChanged(option.mood),
                  ),
                )
                .toList(growable: false),
          ),
          if (validationHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                validationHint!,
                key: const Key('onboarding-final-validation-hint'),
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Perasaan $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E9EC),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34, height: 1)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
