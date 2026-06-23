import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.transparent, // Allow glowing background to show through
      primaryColor: const Color(0xFF3E82F7), // Stitch Primary Blue
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3E82F7),
        primaryContainer: Color(0xFF508EFF),
        secondary: Color(0xFFA7C8FF),
        secondaryContainer: Color(0xFF254A7A),
        tertiary: Color(0xFFFF4B7D),
        tertiaryContainer: Color(0xFFFF4D7E),
        surface: Color(0xFF131313),
        onPrimary: Color(0xFF002E6B),
        onPrimaryContainer: Color(0xFF00275E),
        onSecondary: Color(0xFF013060),
        onSecondaryContainer: Color(0xFF98BAF1),
        onSurface: Color(0xFFE5E2E1),
        onSurfaceVariant: Color(0xFFC2C6D6),
        outline: Color(0xFF8C909F),
        outlineVariant: Color(0xFF424754),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFC2C6D6)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE5E2E1),
          fontFamily: 'Inter',
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF3E82F7),
        inactiveTrackColor: Color(0xFF424754),
        thumbColor: Color(0xFF3E82F7),
        trackHeight: 4.0,
      ),
    );
  }
}
