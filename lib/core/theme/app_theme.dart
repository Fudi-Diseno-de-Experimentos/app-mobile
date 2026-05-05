import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        error: AppColors.destructive,
        onPrimary: Colors.white,
        onSecondary: AppColors.neutral,
        onSurface: AppColors.neutral,
        onError: Colors.white,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.neutral),
        titleTextStyle: AppTypography.textTheme.headlineMedium?.copyWith(
          color: AppColors.neutral,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.neutral,
        unselectedItemColor: AppColors.tertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.secondary, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
      iconTheme: const IconThemeData(color: AppColors.neutral),
    );
  }
}
