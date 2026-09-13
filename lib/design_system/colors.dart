import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF1A5C38);
  static const Color mintSurface = Color(0xFFE8F9EE);
  static const Color mintCard = Color(0xFFD4F5E1);
  static const Color accentGreen = Color(0xFF3DDC84);

  // Neutrals
  static const Color nearBlack = Color(0xFF1A1A2E);
  static const Color bodyText = Color(0xFF3D3D3D);
  static const Color mutedGrey = Color(0xFF8A8A8A);
  static const Color white = Color(0xFFFFFFFF);

  // Accent
  static const Color goldAccent = Color(0xFFF5A623);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGreen, primaryGreen],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mintSurface, white],
  );
}
