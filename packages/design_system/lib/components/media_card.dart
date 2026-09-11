import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// Premium cinematic media card for Continue Watching and Media Library views.
class MediaCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? durationText;
  final double progress; // 0.0 to 1.0
  final List<String> technicalTags; // e.g. ['MKV', '1080p', 'AR Subs']
  final VoidCallback? onTap;
  final Widget? thumbnailWidget;

  const MediaCard({
    super.key,
    required this.title,
    this.subtitle,
    this.durationText,
    this.progress = 0.0,
    this.technicalTags = const [],
    this.onTap,
    this.thumbnailWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedMd,
          splashColor: AppColors.primaryAccent.withAlpha(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Thumbnail Container (16:9 aspect ratio)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E2230),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                      ),
                      child: thumbnailWidget ??
                          Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: 42,
                              color: AppColors.textTertiary.withAlpha(120),
                            ),
                          ),
                    ),

                    // Technical tags overlay (e.g. MKV, AR)
                    if (technicalTags.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: technicalTags.map((tag) {
                            return Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(180),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // Progress Rail at bottom of thumbnail
                    if (progress > 0.0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.black.withAlpha(120),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                          minHeight: 3,
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Metadata Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                    if (subtitle != null || durationText != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (subtitle != null)
                            Expanded(
                              child: Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                              ),
                            ),
                          if (durationText != null)
                            Text(
                              durationText!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
