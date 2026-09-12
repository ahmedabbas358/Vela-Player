import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/subtitles/subtitle_manager.dart';

/// Live Subtitle Timeline Scrubber Bar:
/// Allows real-time interactive subtitle delay calibration while watching video,
/// showing current subtitle text, live delay readout, and instant offset adjustment buttons.
class SubtitleTimelineScrubberBar extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onOpenAutoSync;

  const SubtitleTimelineScrubberBar({
    super.key,
    this.onClose,
    this.onOpenAutoSync,
  });

  @override
  ConsumerState<SubtitleTimelineScrubberBar> createState() =>
      _SubtitleTimelineScrubberBarState();
}

class _SubtitleTimelineScrubberBarState
    extends ConsumerState<SubtitleTimelineScrubberBar> {
  void _adjustOffset(int deltaMs) {
    ref
        .read(subtitleProvider.notifier)
        .adjustOffset(Duration(milliseconds: deltaMs));
  }

  void _resetOffset() {
    ref.read(subtitleProvider.notifier).resetOffset();
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subtitleProvider);
    final activeText = subState.activeCue?.text;
    final currentText = activeText != null && activeText.isNotEmpty
        ? activeText
        : '... (لا يوجد نص ترجمة في هذا التوقيت) ...';

    final delaySeconds = subState.offset.inMilliseconds / 1000.0;
    final sign = delaySeconds >= 0 ? '+' : '';
    final delayFormatted = '$sign${delaySeconds.toStringAsFixed(2)}s';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xE614141E), // Deep glassmorphic dark
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Subtitle Live Badge & Close button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'شريط مزامنة الترجمة المباشر',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Current Delay Readout
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: delaySeconds == 0.0
                      ? Colors.white10
                      : (delaySeconds > 0
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.cyan.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: delaySeconds == 0.0
                        ? Colors.white24
                        : (delaySeconds > 0
                              ? Colors.amber.withValues(alpha: 0.5)
                              : Colors.cyan.withValues(alpha: 0.5)),
                  ),
                ),
                child: Text(
                  'التأخير الحالي: $delayFormatted',
                  style: TextStyle(
                    color: delaySeconds == 0.0
                        ? Colors.white70
                        : (delaySeconds > 0 ? Colors.amber : Colors.cyan),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onClose,
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Subtitle Preview Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.subtitles, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$currentText"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: [-1.0s] [-0.5s] [-0.1s] [Reset] [+0.1s] [+0.5s] [+1.0s]
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildAdjustButton('-1.0s', () => _adjustOffset(-1000)),
              _buildAdjustButton('-0.5s', () => _adjustOffset(-500)),
              _buildAdjustButton('-0.1s', () => _adjustOffset(-100)),
              InkWell(
                onTap: _resetOffset,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'تصفير (0.0s)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
              _buildAdjustButton('+0.1s', () => _adjustOffset(100)),
              _buildAdjustButton('+0.5s', () => _adjustOffset(500)),
              _buildAdjustButton('+1.0s', () => _adjustOffset(1000)),
            ],
          ),

          const SizedBox(height: 8),

          // Acoustic Auto-Sync Quick Trigger
          if (widget.onOpenAutoSync != null)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                icon: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 14,
                ),
                label: const Text(
                  'المزامنة الصوتية الذكية التلقائية (1-Tap Auto-Sync)',
                  style: TextStyle(color: AppColors.primary, fontSize: 11),
                ),
                onPressed: widget.onOpenAutoSync,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
