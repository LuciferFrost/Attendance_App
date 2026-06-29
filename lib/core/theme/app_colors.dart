import 'package:flutter/material.dart';

/// CraftEdge HRMS Color System
/// Enterprise-grade palette — calm, productive, and premium
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ==================== PRIMARY PALETTE ====================
  // Cobalt Blue — brand color, navigation, CTAs, interactive elements
  static const Color primary50 = Color(0xFFEEF2FF);
  static const Color primary100 = Color(0xFFE0E7FF);
  static const Color primary200 = Color(0xFFC7D2FE);
  static const Color primary300 = Color(0xFFA5B4FC);
  static const Color primary400 = Color(0xFF818CF8);
  static const Color primary500 = Color(0xFF6366F1);
  static const Color primary600 = Color(0xFF4F46E5);
  static const Color primary700 = Color(0xFF4338CA); // Main brand color
  static const Color primary800 = Color(0xFF3730A3);
  static const Color primary900 = Color(0xFF312E81);
  static const Color primary = primary700;
  //#494F61

  // ==================== SECONDARY PALETTE ====================
  // Sage Green — success, growth, active employee states
  static const Color secondary50 = Color(0xFFF0FDF4);
  static const Color secondary100 = Color(0xFFDCFCE7);
  static const Color secondary200 = Color(0xFFBBF7D0);
  static const Color secondary300 = Color(0xFF86EFAC);
  static const Color secondary400 = Color(0xFF4ADE80);
  static const Color secondary500 = Color(0xFF22C55E);
  static const Color secondary600 = Color(0xFF16A34A);
  static const Color secondary700 = Color(0xFF15803D); // Success accent
  static const Color secondary800 = Color(0xFF166534);
  static const Color secondary900 = Color(0xFF145231);

  // ==================== NEUTRAL SCALE ====================
  // Blue-tinted neutrals for borders, surfaces, text hierarchy
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // ==================== SEMANTIC COLORS ====================
  // Feedback states for forms, notifications, and alerts
  static const Color success = Color(0xFF128886); // From design: Sage
  static const Color warning = Color(0xFFF5F100);
  static const Color error = Color(0xFFFA5252);
  static const Color info = Color(0xFF3B5B00);

  // ==================== SURFACE & BACKGROUND ====================
  // Surfaces for cards, containers, input backgrounds
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8F9FB);
  static const Color surfaceTertiary = Color(0xFFF1F3F7);
  static const Color background = neutral50;

  // Dark mode surfaces
  static const Color darkSurface = Color(0xFF0F172A); // Very dark blue
  static const Color darkSurfaceSecondary = Color(0xFF1E293B);
  static const Color darkSurfaceTertiary = Color(0xFF334155);

  // ==================== TEXT COLORS ====================
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFFC2C7CD);

  // Dark mode text
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);

  // ==================== BORDER COLORS ====================
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF4F46E5); // Primary on focus
  static const Color darkBorder = Color(0xFF334155);

  // ==================== ACCENT COLORS BY MODULE ====================
  // For feature-specific visual identification
  static const Color accentCobalt = Color(0xFF3B5DB0); // HR Core
  static const Color accentSage = Color(0xFF128886); // Attendance/Leave
  static const Color accentAmber = Color(0xFFF5F100); // Payroll/Finance

  // Backward-compatible aliases used by dashboard widgets.
  static const Color cobalt = accentCobalt;
  static const Color sage = accentSage;
  static const Color amber = accentAmber;

  static const Color accentSky = Color(0xFF33DAF8); // LMS/Training
  static const Color accentViolet = Color(0xFF9C36D5); // Analytics/Reports
  static const Color accentRose = Color(0xFFA5282); // Alerts/Critical

  // ==================== SHADOW COLORS ====================
  static const Color shadowXs = Color(0x0F000000);
  static const Color shadowSm = Color(0x14000000);
  static const Color shadowMd = Color(0x1F000000);
  static const Color shadowLg = Color(0x29000000);
  static const Color shadowXl = Color(0x33000000);

  // ==================== MISC =======================
  static const Color homeShift = Color(0xFF494F61);
//#494F61
  // ==================== UTILITY METHODS ====================
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get the appropriate text color based on background brightness
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : darkTextPrimary;
  }
}
