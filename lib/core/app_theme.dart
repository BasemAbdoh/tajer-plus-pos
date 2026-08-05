import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightPrimary = Color.fromARGB(255, 42, 150, 177);
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Colors.white;

  static const Color darkPrimary = Color(0xFF2A96B1);
  static const Color darkBackground = Color(0xFF1E1E2C);
  static const Color darkSurface = Color(0xFF2D2D42);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: lightPrimary,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: Colors.teal,
        surface: lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      fontFamily: 'Arial',
      dialogBackgroundColor: darkSurface,
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: Colors.tealAccent,
        surface: darkSurface,
      ),
    );
  }
}
