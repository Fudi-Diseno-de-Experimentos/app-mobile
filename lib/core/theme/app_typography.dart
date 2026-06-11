import 'package:app_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return GoogleFonts.manropeTextTheme().copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.neutral,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.neutral,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.neutral,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.neutral,
      ),
      bodySmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w400,
        color: AppColors.neutral,
      ),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.neutral,
        letterSpacing: 1.0,
      ),
      labelMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.neutral,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
        color: AppColors.neutral,
        letterSpacing: 1.2,
      ),
    );
  }
}
