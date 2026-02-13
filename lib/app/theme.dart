import 'package:flutter/material.dart';

/// 🎨 Tema global de PawCampus (claro + cute)
/// - Fondo claro (tipo crema)
/// - Cards blancas con sombra suave
/// - Material 3 + seedColor teal
/// - Arreglado para Flutter donde se usa TabBarThemeData/CardThemeData
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ),

  // Fondo general claro (más friendly para app de animalitos)
  scaffoldBackgroundColor: const Color(0xFFFFF7ED), // crema suave
  // AppBar claro y consistente
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF7ED),
    foregroundColor: Colors.black87,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Tabs (para tu AdoptionsPage con TabBar)
  tabBarTheme: const TabBarThemeData(
    labelColor: Colors.teal,
    unselectedLabelColor: Color(0xFF64748B),
    indicatorSize: TabBarIndicatorSize.tab,
  ),

  // Cards más bonitas
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  // Botones
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),

  // Inputs
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
      borderSide: const BorderSide(color: Colors.teal, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),

  // Snackbars
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.orange,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // Iconos
  iconTheme: const IconThemeData(color: Colors.teal),

  // ListTiles (para que se vea más “limpio”)
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.teal,
    textColor: Colors.black87,
  ),
);
