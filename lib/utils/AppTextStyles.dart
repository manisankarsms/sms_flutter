import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.play(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.play(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: GoogleFonts.play(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.play(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.play(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.play(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.play(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.play(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.play(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.play(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.play(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: GoogleFonts.play(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  );
}
