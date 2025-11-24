import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF1E1E1E);
  static const Color textMain = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF404040);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEF4444);
  
  static const Color panelBackground = Color(0xFF252525);
  static const Color borderColor = Color(0xFF333333);

  // Text Styles
  static const TextStyle title = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textMain,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textMain,
    height: 1.6,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 11,
    fontWeight: FontWeight.w300,
    color: textSecondary,
    height: 1.5,
  );

  // Teleprompter Specific Styles
  static const TextStyle prompterFocus = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 56,
    fontWeight: FontWeight.normal,
    color: textMain,
    height: 1.8,
  );

  static const TextStyle prompterLookAhead1 = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: Color(0x80E0E0E0), // 50% opacity
    height: 1.6,
  );

  static const TextStyle prompterLookAhead2 = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Color(0x4DE0E0E0), // 30% opacity
    height: 1.6,
  );
  
  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: panelBackground,
        error: warning,
        onSurface: textMain,
      ),
      fontFamily: 'SF Pro',
      dividerColor: borderColor,
      iconTheme: const IconThemeData(color: textMain),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: textDisabled,
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.2),
      ),
    );
  }
}
