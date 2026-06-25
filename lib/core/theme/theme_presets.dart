import 'package:flutter/material.dart';

class AppThemePreset {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color backgroundDark;
  final Color backgroundLight;
  final Color cardDark;
  final Color cardLight;

  const AppThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.backgroundDark,
    required this.backgroundLight,
    required this.cardDark,
    required this.cardLight,
  });
}

class AppThemePresets {
  static const List<AppThemePreset> presets = [
    AppThemePreset(
      name: 'Ink Wash',
      primary: Color(0xFF1E1E22),
      secondary: Color(0xFF8E8E98),
      accent: Color(0xFFFFFDF5),
      backgroundDark: Color(0xFF0F0F11),
      backgroundLight: Color(0xFFFFFDF9),
      cardDark: Color(0xFF1A1A1E),
      cardLight: Color(0xFFF2ECE0),
    ),
    AppThemePreset(
      name: 'Cosmic Aurora',
      primary: Color(0xFF9E86FF),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFFF85A2),
      backgroundDark: Color(0xFF0B0816),
      backgroundLight: Color(0xFFF9F8FD),
      cardDark: Color(0xFF15102A),
      cardLight: Color(0xFFF1EEFA),
    ),
    AppThemePreset(
      name: 'Emerald Mint',
      primary: Color(0xFF00F5A0),
      secondary: Color(0xFF00D9F5),
      accent: Color(0xFFFFD166),
      backgroundDark: Color(0xFF040B08),
      backgroundLight: Color(0xFFF4F9F6),
      cardDark: Color(0xFF0C1D17),
      cardLight: Color(0xFFE5F5ED),
    ),
    AppThemePreset(
      name: 'Deep Ocean',
      primary: Color(0xFF2575FC),
      secondary: Color(0xFF6A11CB),
      accent: Color(0xFF00E5FF),
      backgroundDark: Color(0xFF040614),
      backgroundLight: Color(0xFFF2F5FC),
      cardDark: Color(0xFF0B0F2A),
      cardLight: Color(0xFFE4ECFA),
    ),
    AppThemePreset(
      name: 'Sunset Coral',
      primary: Color(0xFFFA5252),
      secondary: Color(0xFFFF8E53),
      accent: Color(0xFFFFD200),
      backgroundDark: Color(0xFF0D0505),
      backgroundLight: Color(0xFFFAF2F2),
      cardDark: Color(0xFF1E0C0C),
      cardLight: Color(0xFFF5E4E4),
    ),
    AppThemePreset(
      name: 'Orchid Blossom',
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      accent: Color(0xFFC084FC),
      backgroundDark: Color(0xFF0E060D),
      backgroundLight: Color(0xFFFAF2F7),
      cardDark: Color(0xFF1D0D1B),
      cardLight: Color(0xFFF5E4F0),
    ),
    AppThemePreset(
      name: 'Luxury Gold',
      primary: Color(0xFFD97706),
      secondary: Color(0xFF10B981),
      accent: Color(0xFFFFB703),
      backgroundDark: Color(0xFF0B0803),
      backgroundLight: Color(0xFFFAF9F2),
      cardDark: Color(0xFF1A1307),
      cardLight: Color(0xFFF5F3E3),
    ),
    AppThemePreset(
      name: 'Monochrome Slate',
      primary: Color(0xFF94A3B8),
      secondary: Color(0xFF64748B),
      accent: Color(0xFFCBD5E1),
      backgroundDark: Color(0xFF0F172A),
      backgroundLight: Color(0xFFF8FAFC),
      cardDark: Color(0xFF1E293B),
      cardLight: Color(0xFFF1F5F9),
    ),
  ];

  static AppThemePreset getByName(String name) {
    return presets.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => presets[0],
    );
  }
}
