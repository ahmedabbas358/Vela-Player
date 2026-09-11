import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Renders the Subtitle Health Score badge with dynamic color semantics.
class HealthBadge extends StatelessWidget {
  final int score;
  final bool compact;

  const HealthBadge({
    super.key,
    required this.score,
    this.compact = false,
  });

  Color get _badgeColor {
    if (score >= 90) return AppColors.statusSuccess;
    if (score >= 75) return AppColors.statusWarning;
    return AppColors.statusError;
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(120), width: 1),
        ),
        child: Text(
          '$score%',
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            score >= 90 ? Icons.verified_rounded : Icons.health_and_safety_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            'Health: $score/100',
            style: AppTypography.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
