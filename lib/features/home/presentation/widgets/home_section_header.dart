import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.actionButtonKey,
    this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final Key? actionButtonKey;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedLayout =
            constraints.maxWidth < 340 || textScaleFactor > 1.2;

        final titleText = Text(
          title,
          maxLines: useStackedLayout ? null : 2,
          overflow: useStackedLayout
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1B1F2D),
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.08,
          ),
        );

        final actionButton = TextButton(
          key: actionButtonKey,
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPurple,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        );

        if (useStackedLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              const SizedBox(height: 6),
              Align(alignment: Alignment.centerLeft, child: actionButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleText),
            const SizedBox(width: 8),
            actionButton,
          ],
        );
      },
    );
  }
}
