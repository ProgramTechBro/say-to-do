import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF6663F1); // was 0xFF9929EA
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;

  // Task priority colors
  static const Color lowPriority = Color(0xFFDBEFDC);
  static const Color mediumPriority = Color(0xFFFEF5D0);
  static const Color highPriority = Color(0xFFFFDADA);

  static const Color lowPriorityLabel = Color(0xFF4CAF50);
  static const Color mediumPrioriyLabel = Color(0xFFFACC15);
  static const Color highPriorityLabel = Color(0xFFFF4747);

  // Task status colors
  static const Color completed = Color(0xFF4CAF50);
  static const Color pending = Color(0xFF9E9E9E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        primary: AppColors.primaryColor,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.secondaryColor,
        secondaryContainer: AppColors.secondaryVariant,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.onBackground,
        onError: AppColors.onError,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.onSecondary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AppConstants {
  static const String appName = 'TaskMaster';
  static const String appVersion = '1.0.0';

  // Task priorities
  static const int lowPriority = 1;
  static const int mediumPriority = 2;
  static const int highPriority = 3;

  // Task priority labels
  static const Map<int, String> priorityLabels = {
    lowPriority: 'Low',
    mediumPriority: 'Medium',
    highPriority: 'High',
  };
  static const Map<int, Color> priorityLabelsColor = {
    lowPriority: AppColors.lowPriorityLabel,
    mediumPriority: AppColors.mediumPrioriyLabel,
    highPriority: AppColors.highPriorityLabel,
  };

  // Task priority colors
  static const Map<int, Color> priorityColors = {
    lowPriority: AppColors.lowPriority,
    mediumPriority: AppColors.mediumPriority,
    highPriority: AppColors.highPriority,
  };

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Gemini API settings
  // static const String apiKey = 'AIzaSyB6UQMdFsMez-4BiWOtepcwA6AiQGsI-Qw';
  static const String apiKey='AIzaSyA4R6FamZ29S0ZBEs85WIX9dATgmzCG650';
  static const String modelName = 'gemini-1.5-flash-latest';

  //Privacy Policy and Terms and Condition
  static const String privacyPolicyLink = 'https://www.freeprivacypolicy.com/live/0f27a593-2a00-45bb-a326-32bf0097db0d';
  static const String termsConditionsLink = 'https://www.termsfeed.com/live/dd360a91-a476-4890-8536-1c7c9430f002';
}
