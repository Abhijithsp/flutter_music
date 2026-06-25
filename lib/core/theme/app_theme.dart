import 'package:flutter/material.dart';
import 'theme_presets.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return generateTheme(AppThemePresets.presets[0], true);
  }

  static ThemeData get lightTheme {
    return generateTheme(AppThemePresets.presets[0], false);
  }

  static ThemeData generateTheme(AppThemePreset preset, bool isDark) {
    final isInkWash = preset.name == 'Ink Wash';
    
    // Invert primary and accent for ink wash in dark mode for high-contrast visibility
    final primaryColor = isInkWash
        ? (isDark ? preset.accent : preset.primary)
        : preset.primary;
    final secondaryColor = preset.secondary;
    final accentColor = isInkWash
        ? (isDark ? preset.primary : preset.secondary)
        : preset.accent;
        
    final surfaceColor = isDark ? preset.backgroundDark : preset.backgroundLight;
    final cardColor = isDark ? preset.cardDark : preset.cardLight;

    // Lighter surfaces for elevated containers (M3 containers)
    final double cardBrightnessOffset = isDark ? 0.05 : -0.04;
    Color adjustColorBrightness(Color base, double factor) {
      final hsv = HSVColor.fromColor(base);
      final double newV = (hsv.value + factor).clamp(0.0, 1.0);
      return hsv.withValue(newV).toColor();
    }
    
    final containerHigh = adjustColorBrightness(cardColor, cardBrightnessOffset);
    final containerHighest = adjustColorBrightness(cardColor, cardBrightnessOffset * 2);

    // Custom ink wash surface configurations
    final onSurfaceColor = isInkWash
        ? (isDark ? const Color(0xFFFFFDF5) : const Color(0xFF1E1E22))
        : (isDark ? const Color(0xFFE5E1E4) : const Color(0xFF1C1B1F));

    final onSurfaceVariantColor = isInkWash
        ? const Color(0xFF8E8E98)
        : (isDark ? const Color(0xFFCAC3D8) : const Color(0xFF49454F));

    final onPrimaryColor = isInkWash
        ? (isDark ? const Color(0xFF1E1E22) : const Color(0xFFFFFDF5))
        : (isDark ? Colors.black : Colors.white);

    final outlineColor = isInkWash
        ? const Color(0xFF8E8E98)
        : (isDark ? const Color(0xFF948EA1) : const Color(0xFF79747E));

    final outlineVariantColor = isInkWash
        ? (isDark ? const Color(0xFF2C2C32) : const Color(0xFFE5E5EA))
        : (isDark ? const Color(0xFF494455) : const Color(0xFFCAC4D0));

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            primaryContainer: primaryColor.withValues(alpha: 0.25),
            secondary: secondaryColor,
            secondaryContainer: secondaryColor.withValues(alpha: 0.15),
            tertiary: accentColor,
            tertiaryContainer: accentColor.withValues(alpha: 0.2),
            surface: surfaceColor,
            surfaceContainer: cardColor,
            surfaceContainerHigh: containerHigh,
            surfaceContainerHighest: containerHighest,
            onPrimary: onPrimaryColor,
            onSecondary: Colors.white,
            onSurface: onSurfaceColor,
            onSurfaceVariant: onSurfaceVariantColor,
            outline: outlineColor,
            outlineVariant: outlineVariantColor,
          )
        : ColorScheme.light(
            primary: primaryColor,
            primaryContainer: primaryColor.withValues(alpha: 0.15),
            secondary: secondaryColor,
            secondaryContainer: secondaryColor.withValues(alpha: 0.1),
            tertiary: accentColor,
            tertiaryContainer: accentColor.withValues(alpha: 0.15),
            surface: surfaceColor,
            surfaceContainer: cardColor,
            surfaceContainerHigh: containerHigh,
            surfaceContainerHighest: containerHighest,
            onPrimary: onPrimaryColor,
            onSecondary: Colors.white,
            onSurface: onSurfaceColor,
            onSurfaceVariant: onSurfaceVariantColor,
            outline: outlineColor,
            outlineVariant: outlineVariantColor,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: Colors.transparent, // Allow glowing/scaffold background to show through
      primaryColor: primaryColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: colorScheme.outlineVariant,
        thumbColor: primaryColor,
        trackHeight: 4.0,
      ),
    );
  }
}

