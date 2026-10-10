// File: lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralised palette. Widgets should read colours from
/// `Theme.of(context).colorScheme` and only use these for brand accents.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C4DFF);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Light
  static const Color lightBackground = Color(0xFFF6F7FF);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF14152B);
  static const Color lightMutedText = Color(0xFF6B7092);
  static const Color lightOutline = Color(0xFFDCDFF2);

  // Dark
  static const Color darkBackground = Color(0xFF0E0F1A);
  static const Color darkSurface = Color(0xFF181A2E);
  static const Color darkText = Color(0xFFF1F2FF);
  static const Color darkMutedText = Color(0xFF9A9EC4);
  static const Color darkOutline = Color(0xFF2E3050);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryBlue],
  );

  static LinearGradient backgroundGradient(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [Color(0xFF0E0F1A), Color(0xFF151733)]
          : const [Color(0xFFF6F7FF), Color(0xFFE9ECFF)],
    );
  }
}
