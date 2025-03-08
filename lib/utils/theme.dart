import 'package:flutter/material.dart';
import 'AppTextStyles.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3b5998),
    textTheme: AppTextStyles.textTheme, // Apply TextTheme
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF3b5998),
      secondary: const Color(0xFF8b9dc3),
      surface: const Color(0xFFdfe3ee),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.tealAccent,
      surface: Colors.grey[800]!,
      surfaceContainerHighest: Colors.black, // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white70, // Replacement for onBackground
      error: Colors.redAccent,
    ),
  );

  static final ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.lime,
      surface: Colors.green[100]!,
      surfaceContainerHighest: Colors.white, // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final ThemeData purpleTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple,
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple,
      secondary: Colors.purpleAccent,
      surface: Colors.purple[100]!,
      surfaceContainerHighest: Colors.white, // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final ThemeData blueGreenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF205781),
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF205781),
      secondary: const Color(0xFF4F959D),
      surface: const Color(0xFF98D2C0),
      surfaceContainerHighest: const Color(0xFFF6F8D5), // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final ThemeData pastelTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFB7B1F2),
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFB7B1F2),
      secondary: const Color(0xFFFDB7EA),
      surface: const Color(0xFFFFDCCC),
      surfaceContainerHighest: const Color(0xFFFBF3B9), // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final ThemeData deepBlueTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF000957),
    textTheme: AppTextStyles.textTheme,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF000957),
      secondary: const Color(0xFF344CB7),
      surface: const Color(0xFF577BC1),
      surfaceContainerHighest: const Color(0xFFFFEB00), // Replacement for background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87, // Replacement for onBackground
      error: Colors.red,
    ),
  );

  static final List<Map<String, dynamic>> themes = [
    {'name': "Light Theme", 'theme': lightTheme},
    {'name': "Dark Theme", 'theme': darkTheme},
    {'name': "Green Theme", 'theme': greenTheme},
    {'name': "Purple Theme", 'theme': purpleTheme},
    {'name': "Blue-Green Theme", 'theme': blueGreenTheme},
    {'name': "Pastel Theme", 'theme': pastelTheme},
    {'name': "Deep Blue Theme", 'theme': deepBlueTheme},
  ];
}