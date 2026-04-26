import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';

class HomeActivityMetricCard extends StatelessWidget {
  const HomeActivityMetricCard({
    super.key,
    required this.metric,
    required this.icon,
    required this.backgroundColor,
    required this.accentColor,
  });

  final HomeActivityMetric metric;
  final IconData icon;
  final Color backgroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Statistik ${metric.label}',
      value: '${metric.count}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 74;

            final countText = Text(
              '${metric.count}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accentColor,
                fontSize: 22,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            );

            final metricIcon = Icon(
              icon,
              color: accentColor.withValues(alpha: 0.38),
              size: 24,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompact) ...[
                  countText,
                  const SizedBox(height: 4),
                  metricIcon,
                ] else
                  Row(
                    children: [
                      Expanded(child: countText),
                      const SizedBox(width: 6),
                      metricIcon,
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  metric.label,
                  maxLines: isCompact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
