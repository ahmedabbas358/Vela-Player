import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

enum VelaButtonVariant { primary, secondary, makeBeautiful, ghost }

/// Signature button component across Vela application views.
class VelaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VelaButtonVariant variant;
  final bool isLoading;

  const VelaButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = VelaButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == VelaButtonVariant.makeBeautiful) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withAlpha(80),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else ...[
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Color bgColor = AppColors.primaryAccent;
    Color textColor = Colors.white;

    if (variant == VelaButtonVariant.secondary) {
      bgColor = AppColors.bgSurfaceCard;
      textColor = AppColors.textPrimary;
    } else if (variant == VelaButtonVariant.ghost) {
      bgColor = Colors.transparent;
      textColor = AppColors.textSecondary;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: variant == VelaButtonVariant.primary ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: variant == VelaButtonVariant.secondary
              ? const BorderSide(color: AppColors.borderSubtle)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
            )
          else if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
