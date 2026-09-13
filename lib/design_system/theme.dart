import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGreen,
        surface: AppColors.mintSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.nearBlack,
        onSurface: AppColors.bodyText,
      ),
      scaffoldBackgroundColor: AppColors.white,
      textTheme: TextTheme(
        displayLarge: AppTypography.headline1,
        displayMedium: AppTypography.headline2,
        titleLarge: AppTypography.sectionHeading,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.label,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.nearBlack,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
