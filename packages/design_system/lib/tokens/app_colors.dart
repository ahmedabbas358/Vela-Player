import 'package:flutter/material.dart';

/// Vela Design System Master Color Tokens.
/// Designed for a cinematic, dark-first experience with full light-mode parity.
class AppColors {
  // Brand Primary & Accent
  static const Color primaryAccent =
      Color(0xFF6366F1); // Electric Indigo / Violet
  static const Color primaryAccentHover = Color(0xFF4F46E5);
  static const Color primaryAccentSubtle = Color(0xFF1E1B4B);
  static const Color secondaryAccent = Color(0xFF8B5CF6); // Amethyst Violet

  // --- Dark Mode Surfaces & Canvas ---
  static const Color darkCanvas = Color(0xFF090A0F); // Deep Obsidian Base
  static const Color darkSurfaceBase =
      Color(0xFF12141A); // Ground Level / Navigation
  static const Color darkSurfaceElevated = Color(0xFF1A1D26); // Cards, Drawers
  static const Color darkSurfaceActive =
      Color(0xFF222634); // Active / Hovered rows
  static const Color darkBorderSubtle =
      Color(0xFF202430); // Hairline dividers (1px)
  static const Color darkBorderFocus = Color(0xFF3B4259);

  // Dark Mode Typography
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // High emphasis
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Medium emphasis
  static const Color darkTextTertiary =
      Color(0xFF64748B); // Low emphasis / captions
  static const Color darkTextDisabled = Color(0xFF475569);

  // --- Light Mode Surfaces & Canvas ---
  static const Color lightCanvas = Color(0xFFF8F9FA); // Porcelain White
  static const Color lightSurfaceBase =
      Color(0xFFFFFFFF); // Pure White Elevated
  static const Color lightSurfaceElevated =
      Color(0xFFF1F3F7); // Secondary container
  static const Color lightSurfaceActive = Color(0xFFE5E8F0); // Selected row
  static const Color lightBorderSubtle =
      Color(0xFFE2E4EC); // Soft dividers (1px)
  static const Color lightBorderFocus = Color(0xFFCBD0DF);

  // Light Mode Typography
  static const Color lightTextPrimary =
      Color(0xFF0F172A); // High contrast slate
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightTextDisabled = Color(0xFFCBD5E1);

  // --- Shared Semantic Status ---
  static const Color statusSuccess = Color(0xFF10B981); // Emerald Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber Gold
  static const Color statusError = Color(0xFFEF4444); // Crimson Rose
  static const Color statusInfo = Color(0xFF3B82F6); // Technical Blue

  // Backward-compatible getters for default dark mode
  static const Color bgCanvas = darkCanvas;
  static const Color bgSurface = darkSurfaceBase;
  static const Color bgSurfaceElevated = darkSurfaceElevated;
  static const Color bgSurfaceCard = darkSurfaceElevated;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textTertiary = darkTextTertiary;
  static const Color textDisabled = darkTextDisabled;
  static const Color borderSubtle = darkBorderSubtle;
  static const Color borderMedium = darkBorderFocus;
}
