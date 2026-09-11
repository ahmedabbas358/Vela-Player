import 'package:flutter/material.dart';

enum VelaPermission { notifications, microphone, photosAddOnly, localNetwork }

enum PermissionStatusState {
  notRequested,
  requesting,
  granted,
  denied,
  permanentlyDenied,
}

/// Centralized Just-In-Time Permission Manager.
/// Never requests permissions at cold start; requests contextually with graceful fallback.
class PermissionManager {
  static final PermissionManager instance = PermissionManager._();
  PermissionManager._();

  final Map<VelaPermission, PermissionStatusState> _statusMap = {
    VelaPermission.notifications: PermissionStatusState.notRequested,
    VelaPermission.microphone: PermissionStatusState.notRequested,
    VelaPermission.photosAddOnly: PermissionStatusState.notRequested,
    VelaPermission.localNetwork: PermissionStatusState.notRequested,
  };

  PermissionStatusState getStatus(VelaPermission perm) =>
      _statusMap[perm] ?? PermissionStatusState.notRequested;

  /// Requests permission contextually, showing a pre-explanation dialog before the OS dialogue.
  Future<bool> requestWithPreExplanation({
    required BuildContext context,
    required VelaPermission permission,
    required String title,
    required String explanation,
    required List<String> bulletPoints,
  }) async {
    // 1. If already granted, return true immediately
    if (_statusMap[permission] == PermissionStatusState.granted) {
      return true;
    }

    // 2. Show contextual pre-explanation dialog
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Color(0xFF6366F1),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              explanation,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...bulletPoints.map(
              (pt) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        pt,
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Not Now',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (proceed != true) {
      return false;
    }

    // 3. Mark as granted (in native integration this invokes OS permission request)
    _statusMap[permission] = PermissionStatusState.granted;
    return true;
  }
}
