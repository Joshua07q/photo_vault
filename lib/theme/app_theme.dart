import 'package:flutter/material.dart';

class AppTheme {
  // Neon Blue & Silver Color Scheme
  static const Color neonBlue = Color(0xFF00D9FF); // Bright neon blue for light mode
  static const Color neonBlueDark = Color(0xFF00B8D4);
  static const Color neonBlueLight = Color(0xFF0099CC); // Darker shade for light mode
  
  // Mature Dark Mode Blues
  static const Color darkModeBlue = Color(0xFF4A90E2); // Mature, sophisticated blue
  static const Color darkModeBlueDark = Color(0xFF357ABD); // Deeper blue
  static const Color darkModeBlueAccent = Color(0xFF5BA3F5); // Lighter accent
  
  static const Color silver = Color(0xFFE8E8E8);
  static const Color silverDark = Color(0xFFB0B0B0);
  
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Context-aware getters
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  
  static Color primaryBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkModeBlue : neonBlue;
  
  static Color primaryBlueDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkModeBlueDark : neonBlueDark;
  
  // Gradients
  static LinearGradient gradientNeon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [darkModeBlue, darkModeBlueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [neonBlueLight, Color(0xFF0077AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }
  
  static const gradientNeonStatic = LinearGradient(
    colors: [neonBlue, neonBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientDarkModeBlue = LinearGradient(
    colors: [darkModeBlue, darkModeBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientSilver = LinearGradient(
    colors: [silver, silverDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient gradientPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [darkModeBlue, darkModeBlueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [neonBlue, neonBlueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }
  
  static LinearGradient gradientAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [Color(0xFF6B6B6B), Color(0xFF3A3A3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : gradientSilver;
  }
  
  // Shadows
  static List<BoxShadow> cardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            BoxShadow(
              color: darkModeBlue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ];
  }

  static List<BoxShadow> buttonShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            BoxShadow(
              color: darkModeBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ]
        : [
            BoxShadow(
              color: neonBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ];
  }

  // Text Styles
  static TextStyle headingStyle(BuildContext context) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary(context),
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
        letterSpacing: -0.3,
      );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
        color: textSecondary(context),
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle captionStyle(BuildContext context) => TextStyle(
        color: textSecondary(context),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );
  
  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: neonBlue,
      secondary: silver,
      surface: lightCard,
      background: lightBackground,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkModeBlue,
      secondary: silverDark,
      surface: darkCard,
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}