import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';

class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 58,
    this.borderRadius = 14,
    this.fontSize = 17,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? const [
                      AppColors.purpleGradientStart,
                      AppColors.purpleGradientEnd,
                    ]
                  : const [AppColors.border, AppColors.border],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isEnabled
                ? const [
                    BoxShadow(
                      color: AppColors.shadowPurple,
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          label,
                          key: const ValueKey('label'),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: isEnabled
                                ? Colors.white
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.85,
                                  ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
