import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 💜 Paleta de colores "Dark Aurora SaaS" de PawCol (Inspiración Brace Developers)
/// Combina un canvas continuo en Noche Profunda Obsidian (#0B0716) con halos radiales
/// luminosos en Violeta Neón (#A855F7), Rosa Magenta (#EC4899), cristal esmerilado
/// (Glassmorphism real) y tipografía de alto contraste en Blanco Puro y Lavanda.
abstract class PawCoColors {
  // --- Canvas y Cabeceras Dark SaaS (Brace Developers) ---
  static const Color auroraStart = Color(0xFF0B0716); // Noche Profunda Obsidian Base
  static const Color auroraMid = Color(0xFF130C24); // Violeta Profundo
  static const Color auroraEnd = Color(0xFF1B1133); // Amatista Oscuro
  static const Color auroraSurface = Color(0xFF160D2A); // Superficie oscura elevada

  // --- Degradados Luminosos y Nodos Orbitales ---
  static const Color lilacGlow = Color(0xFFC084FC); // Lila Neón Suave
  static const Color malva = Color(0xFFEC4899); // Rosa Magenta Principal
  static const Color amberGlow = Color(0xFFFBBF24); // Ámbar Cálido Luminoso
  static const Color orchid = Color(0xFFA855F7); // Violeta / Orquídea Neón

  // --- Superficies de Cristal Esmerilado (Dark Glassmorphism) ---
  static const Color background = Color(0xFF0B0716); // Canvas continuo sin cortes
  static const Color surface = Color(0xFF140D26); // Superficie oscura de tarjeta
  static const Color surfaceMuted = Color(0xFF1A1132); // Superficie oscura elevada
  static const Color surfaceElevated = Color(0xFF1B1133); // Superficie elevada para diálogos
  static const Color border = Color(0x26FFFFFF); // Borde sutil cristal blanco (15%)
  static const Color borderLight = Color(0x14FFFFFF); // Borde extra sutil (8%)

  // --- Iconografía Circular y Acentos Primarios ---
  static const Color cottonLilac = Color(0xFF261542); // Contenedor oscuro lila
  static const Color softMalva = Color(0xFF381432); // Contenedor oscuro malva
  static const Color plum = Color(0xFF9333EA); // Violeta Eléctrico (Botón primario)
  static const Color plumVibrant = Color(0xFFA855F7); // Violeta Neón Brillante

  // --- Tokens Semánticos Unificados (Compatibilidad total con módulos) ---
  static const Color forest = Color(0xFFA855F7); // Primario unificado
  static const Color forestDark = Color(0xFF7E22CE);
  static const Color sage = Color(0xFF34D399); // Verde Esmeralda Verificado
  static const Color sageLight = Color(0xFF10B981);
  static const Color sageMuted = Color(0x2410B981);

  static const Color terracotta = Color(0xFFEC4899); // Acento Rosa Magenta
  static const Color terracottaDark = Color(0xFFF472B6); // Rosa Malva legible
  static const Color terracottaLight = Color(0xFF381432);
  static const Color terracottaMuted = Color(0x26EC4899);

  static const Color slateBlue = Color(0xFF8B5CF6); // Violeta Iris
  static const Color slateBlueLight = Color(0xFFC4B5FD);
  static const Color slateBlueMuted = Color(0x248B5CF6);

  static const Color sand = Color(0xFF24173D);
  static const Color sandLight = Color(0xFF1B1133);

  // Siluetas lineales y marcas de agua de mascotas
  static const Color silhouette = Color(0x14C084FC);

  // --- Tipografía de Alto Contraste para Canvas Oscuro ---
  static const Color ink = Color(0xFFFFFFFF); // Blanco Puro
  static const Color inkSecondary = Color(0xFFC4B5FD); // Lavanda Suave Luminoso
  static const Color muted = Color(0xFF8F82A8); // Lavanda Grisácea
  static const Color mutedLight = Color(0xFF6B5E85); // Placeholder / Hints

  // --- Estados Semánticos ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
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

/// 🎨 Tema global Material 3 de PawCol — Dark Aurora SaaS (Inspiración Brace Developers)
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

  colorScheme: ColorScheme.fromSeed(
    seedColor: PawCoColors.plum,
    primary: PawCoColors.plum,
    secondary: PawCoColors.malva,
    tertiary: PawCoColors.orchid,
    error: PawCoColors.error,
    surface: PawCoColors.surface,
    brightness: Brightness.dark,
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
    backgroundColor: PawCoColors.surface,
    elevation: 0,
    indicatorColor: PawCoColors.cottonLilac,
    height: 64,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: PawCoColors.lilacGlow, size: 22);
      }
      return const IconThemeData(color: PawCoColors.muted, size: 21);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          color: Colors.white,
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
      side: const BorderSide(color: PawCoColors.border, width: 1.1),
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
      foregroundColor: Colors.white,
      side: const BorderSide(color: PawCoColors.border, width: 1.2),
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
      foregroundColor: PawCoColors.lilacGlow,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: PawCoColors.surfaceMuted,
    selectedColor: PawCoColors.plum.withValues(alpha: 0.35),
    secondarySelectedColor: PawCoColors.plum.withValues(alpha: 0.35),
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
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: PawCoColors.surfaceMuted,
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
      borderSide: const BorderSide(color: PawCoColors.lilacGlow, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
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
    backgroundColor: PawCoColors.surfaceElevated,
    contentTextStyle: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: PawCoColors.border),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  iconTheme: const IconThemeData(color: PawCoColors.ink),
);
