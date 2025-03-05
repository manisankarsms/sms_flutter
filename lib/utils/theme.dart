import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3b5998), // #3b5998
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF3b5998), // #3b5998
      secondary: const Color(0xFF8b9dc3), // #8b9dc3
      background: const Color(0xFFf7f7f7), // #f7f7f7
      surface: const Color(0xFFdfe3ee), // #dfe3ee
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black87,
      error: Colors.red,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.tealAccent,
      background: Colors.black,
      surface: Colors.grey[800]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white70,
      error: Colors.redAccent,
    ),
  );

  static final ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    colorScheme: ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.lime,
      background: Colors.white,
      surface: Colors.green[100]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black87,
      error: Colors.red,
    ),
  );

  static final ThemeData purpleTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple,
      secondary: Colors.purpleAccent,
      background: Colors.white,
      surface: Colors.purple[100]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black87,
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
