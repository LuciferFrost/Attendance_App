import 'package:flutter/material.dart';
import 'app_colors.dart';

/// CraftEdge Typography System
/// - Playfair Display: Hero & display headings
/// - DM Sans: Body, UI text, readable at every scale
/// - DM Mono: Code, tokens, data values
class AppTypography {
  AppTypography._();

  // Font families
  static const String displayFont = 'PlayfairDisplay';
  static const String bodyFont = 'DMSans';
  static const String monoFont = 'DMMono';

  // ==================== DISPLAY / HERO ====================
  // Large, impactful headings for main page titles
  static TextStyle get displayHero => TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayHeroDark =>
      displayHero.copyWith(color: AppColors.darkTextPrimary);

  // ==================== HEADING 1 ====================
  // Page titles, major section headers
  static TextStyle get heading1 => TextStyle(
    fontFamily: bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading1Dark =>
      heading1.copyWith(color: AppColors.darkTextPrimary);

  // ==================== HEADING 2 ====================
  // Subsection headers, card titles
  static TextStyle get heading2 => TextStyle(
    fontFamily: bodyFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading2Dark =>
      heading2.copyWith(color: AppColors.darkTextPrimary);

  // ==================== HEADING 3 ====================
  // Card titles, form section headers
  static TextStyle get heading3 => TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading3Dark =>
      heading3.copyWith(color: AppColors.darkTextPrimary);

  // ==================== BODY ====================
  // Primary body text for descriptions, content
  static TextStyle get body => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyDark =>
      body.copyWith(color: AppColors.darkTextPrimary);

  // ==================== BODY MEDIUM ====================
  // Slightly larger body text
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMediumDark =>
      bodyMedium.copyWith(color: AppColors.darkTextPrimary);

  // ==================== BODY SMALL ====================
  static TextStyle get bodySmall => TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmallDark =>
      bodySmall.copyWith(color: AppColors.darkTextSecondary);

  // ==================== LABEL / SMALL ====================
  // Form labels, field hints, captions
  static TextStyle get label => TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static TextStyle get labelDark =>
      label.copyWith(color: AppColors.darkTextSecondary);

  // ==================== CAPTION / OVERLINE ====================
  // Small labels, badges, overlines
  static TextStyle get caption => TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
  );

  static TextStyle get captionDark =>
      caption.copyWith(color: AppColors.darkTextTertiary);

  // ==================== CODE / MONO ====================
  // Code, token values, numeric data
  static TextStyle get code => TextStyle(
    fontFamily: monoFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get codeDark =>
      code.copyWith(color: AppColors.darkTextPrimary);

  // ==================== SECONDARY TEXT ====================
  // Supporting text, descriptions, helper text
  static TextStyle get secondary => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static TextStyle get secondaryDark =>
      secondary.copyWith(color: AppColors.darkTextSecondary);

  // ==================== BUTTON TEXT ====================
  // For interactive buttons
  static TextStyle get buttonText => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonTextSmall => TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: Colors.white,
  );

  // ==================== INPUT TEXT ====================
  // Form input field text
  static TextStyle get inputText => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputTextDark =>
      inputText.copyWith(color: AppColors.darkTextPrimary);

  static TextStyle get inputHint => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  static TextStyle get inputHintDark =>
      inputHint.copyWith(color: AppColors.darkTextTertiary);
  
}

/// Text theme for Material apps
TextTheme buildTextTheme() {
  return TextTheme(
    displayLarge: AppTypography.displayHero,
    displayMedium: AppTypography.heading1,
    displaySmall: AppTypography.heading2,
    headlineMedium: AppTypography.heading2,
    headlineSmall: AppTypography.heading3,
    titleLarge: AppTypography.heading1,
    titleMedium: AppTypography.heading2,
    titleSmall: AppTypography.heading3,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.label,
    labelLarge: AppTypography.label,
    labelMedium: AppTypography.caption,
    labelSmall: AppTypography.caption,
  );
}

TextTheme buildDarkTextTheme() {
  return TextTheme(
    displayLarge: AppTypography.displayHero,
    displayMedium: AppTypography.heading1Dark,
    displaySmall: AppTypography.heading2Dark,
    headlineMedium: AppTypography.heading2Dark,
    headlineSmall: AppTypography.heading3Dark,
    titleLarge: AppTypography.heading1Dark,
    titleMedium: AppTypography.heading2Dark,
    titleSmall: AppTypography.heading3Dark,
    bodyLarge: AppTypography.bodyDark,
    bodyMedium: AppTypography.bodyMediumDark,
    bodySmall: AppTypography.labelDark,
    labelLarge: AppTypography.labelDark,
    labelMedium: AppTypography.captionDark,
    labelSmall: AppTypography.captionDark,
  );
}
