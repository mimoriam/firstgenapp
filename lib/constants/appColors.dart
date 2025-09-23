// ignore_for_file: file_names
import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient for Buttons and Accents
  static const Color primaryRed = Color(0xFFCB3839);
  static const Color primaryOrange = Color(0xFFE96F3C);

  // Blues used for the Free plan gradient
  static const Color primaryBlue = Color(0xFF2D8CF0);
  static const Color secondaryBlue = Color(0xFF6EC1FF);

  // Background Colors
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFFDF1F1);
  static const Color tertiaryBackground = Color(0xFFFDF2EE);
  static const Color inputFill = Color(0xFFFFFFFF);

// Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFFCB3839);

  static const Color inputBorder = Color(0xFFE0E0E0);

  static const Color error = Color(0xFFB00020);

  static const Color dotInactive = Color(0xFFFDF1F1);

  static const Color divider = Colors.grey;
}

const colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primaryOrange,      // The more vibrant part of the gradient
  secondary: AppColors.primaryRed,       // The deeper part of the gradient
  background: AppColors.primaryBackground,
  surface: AppColors.inputFill,          // For card/dialog/input backgrounds
  error: AppColors.error,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onBackground: AppColors.textPrimary,
  onSurface: AppColors.textPrimary,
  onError: Colors.white,
);