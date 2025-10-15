import 'package:flutter/material.dart';

/// 🎨 Tema global de PawCampus
/// Asegura consistencia visual en web, Android e iOS.
final lightTheme = ThemeData(
  brightness: Brightness.dark, // modo oscuro global
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black, // fondo consistente
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.redAccent,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    behavior: SnackBarBehavior.floating,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  useMaterial3: true,
);
