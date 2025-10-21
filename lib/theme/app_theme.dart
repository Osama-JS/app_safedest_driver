import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(AppConfig.primaryColorValue);
  static const Color secondaryColor = Color(AppConfig.secondaryColorValue);
  static const Color errorColor = Color(AppConfig.errorColorValue);
  static const Color successColor = Color(AppConfig.successColorValue);
  static const Color warningColor = Color(AppConfig.warningColorValue);

  // Task Status Colors
  static const Color pendingColor = Color(AppConfig.pendingColorValue);
  static const Color acceptedColor = Color(AppConfig.acceptedColorValue);
  static const Color inProgressColor = Color(AppConfig.inProgressColorValue);
  static const Color completedColor = Color(AppConfig.completedColorValue);
  static const Color cancelledColor = Color(AppConfig.cancelledColorValue);

  // Additional Colors - Light Theme
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF212121);
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.white;

  // Additional Colors - Dark Theme
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkOnSurfaceColor = Color(0xFFE0E0E0);
  static const Color darkOnPrimaryColor = Colors.white;
  static const Color darkOnSecondaryColor = Colors.white;

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFFBDBDBD);

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);

  // Get light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: onPrimaryColor,
        onSecondary: onSecondaryColor,
        onSurface: onSurfaceColor,
        onBackground: textPrimaryColor,
      ),

      // Typography
      textTheme: _buildTextTheme(),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
        fontFamily: "Tajawal",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onPrimaryColor,
        ),
        iconTheme: const IconThemeData(
          color: onPrimaryColor,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 2,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: "Tajawal",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: "Tajawal",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontFamily: "Tajawal",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: "Tajawal",
          color: textHintColor,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: "Tajawal",
          color: textSecondaryColor,
          fontSize: 14,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        labelStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSecondaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        contentTextStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: TextStyle(
          fontFamily: "Tajawal",
          color: surfaceColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),
    );
  }

  // Get dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurfaceColor,
        onPrimary: darkOnPrimaryColor,
        onSecondary: darkOnSecondaryColor,
        onSurface: darkOnSurfaceColor,
      ),

      // Typography
      textTheme: _buildDarkTextTheme(),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkOnSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: "Tajawal",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurfaceColor,
        ),
        iconTheme: IconThemeData(
          color: darkOnSurfaceColor,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: "Tajawal",
          color: Colors.grey[400],
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: "Tajawal",
          color: Colors.grey[300],
          fontSize: 14,
        ),
      ),
    );
  }

  // Build text theme
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
      ),
    );
  }

  // Build dark text theme
  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: darkOnSurfaceColor,
      ),
      displayMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      displaySmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      titleLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      titleMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      titleSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkOnSurfaceColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkOnSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkOnSurfaceColor,
      ),
      bodySmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey[400],
      ),
      labelLarge: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkOnSurfaceColor,
      ),
      labelMedium: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey[400],
      ),
      labelSmall: TextStyle(
        fontFamily: "Tajawal",
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.grey[400],
      ),
    );
  }

  // Task status color helper
  static Color getTaskStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'accepted':
        return acceptedColor;
      case 'picked_up':
      case 'in_transit':
        return inProgressColor;
      case 'delivered':
      case 'completed':
        return completedColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return textSecondaryColor;
    }
  }

  // Get status color with opacity
  static Color getTaskStatusColorWithOpacity(String status, double opacity) {
    return getTaskStatusColor(status).withOpacity(opacity);
  }
}
