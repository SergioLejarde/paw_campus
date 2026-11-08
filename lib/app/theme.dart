import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 💜 Paleta de colores "Aurora Híbrida + Violeta 2" de PawCol
/// Combina cabeceras oscuras profesionales estilo SaaS (Violeta Profundo Aurora)
/// con superficies claras, tiernas y luminosas en Marfil-Lila Pastel y Rosa Malva.
abstract class PawCoColors {
  // --- Cabeceras y Hero Oscuro Pro (Violeta Profundo Aurora) ---
  static const Color auroraStart = Color(0xFF1B0B2E); // Noche Violeta Profundo
  static const Color auroraMid = Color(0xFF3B1763); // Amatista Real
  static const Color auroraEnd = Color(0xFF431E61); // Morado Mora Profundo
  static const Color auroraSurface = Color(0xFF271142); // Superficie oscura elevada

  // --- Degradados Luminosos y Nodos Orbitales ---
  static const Color lilacGlow = Color(0xFFD8B4FE); // Lila Neón Suave
  static const Color malva = Color(0xFFE6759D); // Rosa Malva Principal
  static const Color amberGlow = Color(0xFFFBBF24); // Ámbar Cálido Luminoso
  static const Color orchid = Color(0xFFA855F7); // Orquídea Vibrante

  // --- Cuerpo Claro Pastel Tierno (Paleta 2C-2) ---
  static const Color background = Color(0xFFFAF6F9); // Marfil-Lila Pastel
  static const Color surface = Color(0xFFFFFFFF); // Blanco Puro para tarjetas
  static const Color surfaceMuted = Color(0xFFF3ECF8); // Lavanda Seda Suave
  static const Color border = Color(0xFFE5DDF0); // Borde Sutil Lila (1px)
  static const Color borderLight = Color(0xFFEFE9F6);

  // --- Iconografía Circular y Acentos Primarios ---
  static const Color cottonLilac = Color(0xFFD2C2E5); // Lila Algodón
  static const Color softMalva = Color(0xFFF9D8E6); // Rosa Malva Pastel
  static const Color plum = Color(0xFF431E61); // Morado Mora (Botón primario)
  static const Color plumVibrant = Color(0xFF6B21A8); // Morado Real Vibrante

  // --- Tokens Semánticos Unificados (Compatibilidad total con módulos) ---
  static const Color forest = Color(0xFF431E61); // Primario: Morado Mora (#431E61)
  static const Color forestDark = Color(0xFF280E3E);
  static const Color sage = Color(0xFF8C6BB1); // Lavanda Media
  static const Color sageLight = Color(0xFFEAE0F5); // Lila Claro Suave
  static const Color sageMuted = Color(0xFFF5EFFB);

  static const Color terracotta = Color(0xFFE6759D); // Acento: Rosa Malva (#E6759D)
  static const Color terracottaDark = Color(0xFFAD3663); // Rosa Malva Profundo legible
  static const Color terracottaLight = Color(0xFFF9D8E6); // Rosa Malva Tierno (#F9D8E6)
  static const Color terracottaMuted = Color(0xFFFDF2F7);

  static const Color slateBlue = Color(0xFF6D28D9); // Violeta Iris (Voluntariado)
  static const Color slateBlueLight = Color(0xFFEDE9FE);
  static const Color slateBlueMuted = Color(0xFFF5F3FF);

  static const Color sand = Color(0xFFE5DDF0);
  static const Color sandLight = Color(0xFFF5EFFA);

  // Siluetas lineales y marcas de agua de perros, gatos y huellas en Lila Armónico
  static const Color silhouette = Color(0xFFE2D4F0);

  // --- Tipografía de Alto Contraste ---
  static const Color ink = Color(0xFF231138); // Tinta Violeta Espresso Profundo
  static const Color inkSecondary = Color(0xFF4A3663);
  static const Color muted = Color(0xFF735F8C);
  static const Color mutedLight = Color(0xFF9E8BB5);

  // --- Estados Semánticos ---
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFBE123C);
}

/// ✍️ Tipografía moderna SaaS de PawCol
class PawCoTypography {
  static TextTheme textTheme(BuildContext context) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: PawCoColors.ink,
        letterSpacing: -0.9,
        height: 1.14,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 29,
        fontWeight: FontWeight.w800,
        color: PawCoColors.ink,
        letterSpacing: -0.7,
        height: 1.18,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: PawCoColors.ink,
        letterSpacing: -0.4,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: PawCoColors.ink,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: PawCoColors.inkSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.normal,
        color: PawCoColors.muted,
        height: 1.42,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// 🎨 Tema global Material 3 de PawCol — Aurora Híbrida + Paleta Violeta 2
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

  colorScheme: ColorScheme.fromSeed(
    seedColor: PawCoColors.plum,
    primary: PawCoColors.plum,
    secondary: PawCoColors.malva,
    tertiary: PawCoColors.orchid,
    error: PawCoColors.error,
    surface: PawCoColors.surface,
    brightness: Brightness.light,
  ),

  scaffoldBackgroundColor: PawCoColors.background,

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: PawCoColors.auroraStart,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    indicatorColor: PawCoColors.cottonLilac.withValues(alpha: 0.55),
    height: 64,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: PawCoColors.plum, size: 22);
      }
      return const IconThemeData(color: PawCoColors.muted, size: 21);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          color: PawCoColors.plum,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        );
      }
      return GoogleFonts.plusJakartaSans(
        color: PawCoColors.muted,
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
      );
    }),
  ),

  cardTheme: CardThemeData(
    color: PawCoColors.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: PawCoColors.border, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: PawCoColors.plum,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: PawCoColors.plum,
      side: const BorderSide(color: PawCoColors.border, width: 1.3),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: PawCoColors.plum,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: PawCoColors.cottonLilac.withValues(alpha: 0.5),
    secondarySelectedColor: PawCoColors.cottonLilac.withValues(alpha: 0.5),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: PawCoColors.border),
    ),
    labelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.inkSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.plum,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.mutedLight,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: PawCoColors.malva, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: PawCoColors.plum,
    unselectedLabelColor: PawCoColors.muted,
    indicatorColor: PawCoColors.malva,
    labelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: PawCoColors.auroraStart,
    contentTextStyle: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    behavior: SnackBarBehavior.floating,
  ),

  iconTheme: const IconThemeData(color: PawCoColors.ink),
);
