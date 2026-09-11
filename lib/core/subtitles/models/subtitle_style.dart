import 'package:flutter/material.dart';

/// Complete visual styling configuration for subtitles
class SubtitleStyle {
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final Color outlineColor;
  final double outlineWidth;
  final Color glowColor;
  final double glowRadius;
  final Color backgroundColor;
  final bool showBackgroundBox;
  final double boxPadding;
  final double borderRadius;
  final double verticalPositionPercentage; // 0.0 (top) to 1.0 (bottom)
  final Offset? customOffset; // Optional drag-and-drop manual coordinates
  final double letterSpacing;
  final double lineHeight;

  const SubtitleStyle({
    this.fontFamily = 'Cairo',
    this.fontSize = 22.0,
    this.fontWeight = FontWeight.w700,
    this.textColor = Colors.white,
    this.outlineColor = const Color(0xFF000000),
    this.outlineWidth = 2.5,
    this.glowColor = const Color(0x99000000),
    this.glowRadius = 4.0,
    this.backgroundColor = const Color(0x66000000),
    this.showBackgroundBox = false,
    this.boxPadding = 8.0,
    this.borderRadius = 8.0,
    this.verticalPositionPercentage = 0.88,
    this.customOffset,
    this.letterSpacing = 0.5,
    this.lineHeight = 1.3,
  });

  SubtitleStyle copyWith({
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? textColor,
    Color? outlineColor,
    double? outlineWidth,
    Color? glowColor,
    double? glowRadius,
    Color? backgroundColor,
    bool? showBackgroundBox,
    double? boxPadding,
    double? borderRadius,
    double? verticalPositionPercentage,
    Offset? customOffset,
    double? letterSpacing,
    double? lineHeight,
  }) {
    return SubtitleStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textColor: textColor ?? this.textColor,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      glowColor: glowColor ?? this.glowColor,
      glowRadius: glowRadius ?? this.glowRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showBackgroundBox: showBackgroundBox ?? this.showBackgroundBox,
      boxPadding: boxPadding ?? this.boxPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      verticalPositionPercentage:
          verticalPositionPercentage ?? this.verticalPositionPercentage,
      customOffset: customOffset ?? this.customOffset,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  // Preset styles
  static const SubtitleStyle classicWhite = SubtitleStyle(
    fontFamily: 'Cairo',
    fontSize: 22.0,
    textColor: Colors.white,
    outlineColor: Colors.black,
    outlineWidth: 3.0,
    showBackgroundBox: false,
  );

  static const SubtitleStyle animeYellow = SubtitleStyle(
    fontFamily: 'Tajawal',
    fontSize: 24.0,
    textColor: Color(0xFFFFD54F),
    outlineColor: Color(0xFF1E1400),
    outlineWidth: 3.2,
    glowColor: Color(0x66FFA000),
    glowRadius: 6.0,
    showBackgroundBox: false,
  );

  static const SubtitleStyle cyberNeon = SubtitleStyle(
    fontFamily: 'Outfit',
    fontSize: 23.0,
    textColor: Color(0xFF00F0FF),
    outlineColor: Color(0xFF003040),
    outlineWidth: 2.8,
    glowColor: Color(0xAA00E5FF),
    glowRadius: 10.0,
    showBackgroundBox: false,
  );

  static const SubtitleStyle netflixBoxed = SubtitleStyle(
    fontFamily: 'Roboto',
    fontSize: 20.0,
    textColor: Colors.white,
    outlineColor: Colors.transparent,
    outlineWidth: 0.0,
    showBackgroundBox: true,
    backgroundColor: Color(0xCC111111),
    boxPadding: 10.0,
    borderRadius: 6.0,
  );

  static const SubtitleStyle emeraldGlow = SubtitleStyle(
    fontFamily: 'Rubik',
    fontSize: 22.0,
    textColor: Color(0xFF6EE7B7),
    outlineColor: Color(0xFF064E3B),
    outlineWidth: 2.6,
    glowColor: Color(0x9910B981),
    glowRadius: 8.0,
    showBackgroundBox: false,
  );
}
