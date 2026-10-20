import 'package:flutter/material.dart';

/// 🎨 Tema global de PawCo (Material 3 Light — Cálido, limpio y animalista)
/// - Fondo crema suave (#FFF7ED)
/// - Color primario Teal (#0D9488)
/// - Cards blancas con bordes redondeados (16px) y sombra suave
/// - NavigationBarThemeData con fondo blanco, indicador teal suave y contraste claro
/// - ChipThemeData con diseño amigable
/// - Sin uso de Colors.white70 sobre fondos claros
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D9488),
    primary: const Color(0xFF0D9488),
    secondary: const Color(0xFFF59E0B),
    error: const Color(0xFFE11D48),
    surface: Colors.white,
    brightness: Brightness.light,
  ),

  // Fondo general claro (cálido y animalista)
  scaffoldBackgroundColor: const Color(0xFFFFF7ED),

  // AppBar claro y consistente
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF7ED),
    foregroundColor: Color(0xFF1E293B),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Color(0xFF1E293B),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Color(0xFF0D9488)),
  ),

  // NavigationBar (Barra inferior de 5 pestañas de MainShell)
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 4,
    shadowColor: Colors.black12,
    indicatorColor: const Color(0xFFCCFBF1), // Teal suave
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: Color(0xFF0F766E), size: 26);
      }
      return const IconThemeData(color: Color(0xFF64748B), size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: Color(0xFF0F766E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        );
      }
      return const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
    }),
  ),

  // Tabs
  tabBarTheme: const TabBarThemeData(
    labelColor: Color(0xFF0D9488),
    unselectedLabelColor: Color(0xFF64748B),
    indicatorColor: Color(0xFF0D9488),
    indicatorSize: TabBarIndicatorSize.tab,
  ),

  // Chips
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: const Color(0xFFCCFBF1),
    secondarySelectedColor: const Color(0xFFCCFBF1),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF1E293B),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: Color(0xFF0F766E),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Cards más bonitas con bordes redondeados (16px)
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
      backgroundColor: const Color(0xFF0D9488),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF0D9488),
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
      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),

  // Snackbars
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFFF59E0B),
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // Iconos
  iconTheme: const IconThemeData(color: Color(0xFF0D9488)),

  // ListTiles
  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF0D9488),
    textColor: Color(0xFF1E293B),
  ),
);
