import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF), // Modern Purple Acetn
      background: const Color(0xFFF7F9FC), // Soft Blue-Grey Background
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F9FC),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF2D3436)),
      bodyMedium: GoogleFonts.inter(color: const Color(0xFF636E72)),
    ),
    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //   shadowColor: Colors.black.withOpacity(0.1),
    //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    // ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
      prefixIconColor: const Color(0xFF6C63FF),
      labelStyle: const TextStyle(color: Color(0xFF636E72)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}
