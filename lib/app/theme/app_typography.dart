import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textBlack,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textBlack,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textBlack,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textBlack,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textBlack,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textBlack,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textBlack,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
  );
}
