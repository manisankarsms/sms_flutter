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
      surfaceVariant: Colors.black, // Replacement for background
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
      surfaceVariant: Colors.white, // Replacement for background
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
      surfaceVariant: Colors.white, // Replacement for background
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
  ];
}
