import 'package:flutter/material.dart';

class MKIColorConstv2 {
  // Primary Colors - Orange
  static Color primary = const Color(0xFFFA750D); // Logo Orange
  static Color primaryDark = const Color(0xFFE06200); // Darker Orange
  static Color primaryLight = const Color(0xFFFF9440); // Light Orange
  static Color primarySoft = const Color(0xFFFFEDE4); // Soft Orange (New)

  // Secondary Colors - Teals
  static Color secondary = const Color(0xFF2DAEA3); // Logo Teal
  static Color secondaryDark = const Color(0xFF063F50); // Logo Dark Teal
  static Color secondaryLight = const Color(0xFF45C5BA); // Light Teal
  static Color secondarySoft = const Color(0xFFE5F6F4); // Soft Teal (New)

  // Neutral Colors (Sedikit disesuaikan)
  static Color neutral100 = const Color(0xFFFFFFFF); // White
  static Color neutral200 = const Color(0xFFF8F9FA); // Light Gray
  static Color neutral300 = const Color(0xFFE9ECEF); // Mid Light Gray
  static Color neutral400 = const Color(0xFFCED4DA); // Mid Gray
  static Color neutral500 = const Color(0xFF6C757D); // Gray
  static Color neutral600 = const Color(0xFF495057); // Dark Gray
  static Color neutral700 = const Color(0xFF212529); // Almost Black

  // Accent Colors (New)
  static Color accent1 = const Color(0xFF00B8D4); // Cyan
  static Color accent2 = const Color(0xFF6200EA); // Purple
  static Color accent3 = const Color(0xFF00C853); // Green

  // Semantic Colors
  static Color success = const Color(0xFF2DAEA3); // Using Logo Teal
  static Color warning = const Color(0xFFFA750D); // Using Logo Orange
  static Color error = const Color(0xFFDC3545); // Red
  static Color info = const Color(0xFF063F50); // Using Logo Dark Teal

  // Background Colors
  static Color background = neutral200;
  static Color surface = neutral100;

  // Remove all gradient definitions since we're not using them anymore

  // Simple box decoration for cards
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: neutral600.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
