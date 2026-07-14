import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium World-Class Theme with Gradients, Glassmorphism, and Modern Design
class PremiumTheme {
  // Premium Color Palette
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color deepRed = Color(0xFFB91C1C);
  static const Color darkBlack = Color(0xFF0B0B0B);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color mediumGrey = Color(0xFF9CA3AF);
  static const Color darkGrey = Color(0xFF374151);
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFFDC2626);
  static const Color gradientEnd = Color(0xFFEF4444);
  static const Color darkGradientStart = Color(0xFF1F2937);
  static const Color darkGradientEnd = Color(0xFF111827);
  
  // Glassmorphism Colors
  static Color glassWhite = Colors.white.withValues(alpha: 0.1);
  static Color glassBlack = Colors.black.withValues(alpha: 0.2);
  
  // Premium Gradients
  static const LinearGradient redGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkGradientStart, darkGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.2),
      Colors.white.withValues(alpha: 0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Premium Shadows
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primaryRed.withValues(alpha: 0.2),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: primaryRed.withValues(alpha: 0.3),
      blurRadius: 40,
      offset: const Offset(0, 15),
      spreadRadius: -5,
    ),
  ];
  
  // Premium Border Radius
  static BorderRadius get smallRadius => BorderRadius.circular(12);
  static BorderRadius get mediumRadius => BorderRadius.circular(16);
  static BorderRadius get largeRadius => BorderRadius.circular(24);
  static BorderRadius get xlRadius => BorderRadius.circular(32);
  
  static ThemeData? _cachedTheme;

  static ThemeData get theme {
    if (_cachedTheme != null) return _cachedTheme!;
    final baseTextTheme = GoogleFonts.robotoTextTheme(ThemeData.light().textTheme);
    final displayFont = GoogleFonts.spaceGrotesk;

    _cachedTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: darkBlack,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: darkBlack,
      ),
      scaffoldBackgroundColor: lightGrey,
      
      // Premium AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: darkBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkBlack,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      
      // Premium Typography
      textTheme: baseTextTheme.copyWith(
        displayLarge: displayFont(
          fontSize: 64,
          fontWeight: FontWeight.w900,
          color: darkBlack,
          height: 1.1,
          letterSpacing: -2,
        ),
        displayMedium: displayFont(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: darkBlack,
          height: 1.2,
          letterSpacing: -1.5,
        ),
        displaySmall: displayFont(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: darkBlack,
          height: 1.2,
          letterSpacing: -1,
        ),
        headlineLarge: displayFont(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkBlack,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkBlack,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkBlack,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkBlack,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: darkGrey,
          height: 1.6,
          letterSpacing: 0.2,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: mediumGrey,
          height: 1.6,
          letterSpacing: 0.1,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkBlack,
          letterSpacing: 0.5,
        ),
      ),
      
      // Premium Card Theme
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: mediumRadius,
        ),
      ),
      
      // Premium Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: pureWhite,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: primaryRed.withValues(alpha: 0.3),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) return 8;
              return 0;
            },
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkBlack,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          side: const BorderSide(color: darkBlack, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Premium Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGrey, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: mediumGrey,
          fontSize: 16,
        ),
      ),
      
      // Premium Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: pureWhite,
        selectedIconTheme: IconThemeData(
          color: primaryRed,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: mediumGrey,
          size: 28,
        ),
        selectedLabelTextStyle: TextStyle(
          color: primaryRed,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: mediumGrey,
          fontSize: 13,
        ),
      ),
      
      // Premium Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: primaryRed,
        unselectedItemColor: mediumGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
      ),
      
      // Premium Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: pureWhite,
        elevation: 20,
      ),
    );
    return _cachedTheme!;
  }
}
