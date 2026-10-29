import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Paleta de colores neutra contemporánea de PawCol
/// Diseñada con estética arquitectónica limpia, tonos piedra/lino cálidos y acentos orgánicos sobrios.
abstract class PawCoColors {
  // Fondos y superficies neutras (Piedra / Lino / Alabastro)
  static const Color background = Color(0xFFF8F7F4); // Alabastro cálido neutro
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro limpio
  static const Color surfaceMuted = Color(0xFFF1EFEA); // Piedra suave
  static const Color border = Color(0xFFE5E2DC); // Línea fina arquitectónica (1px)
  static const Color borderLight = Color(0xFFEEECE7);

  // Acentos primarios neutros-orgánicos (Oliva carbón / Salvia piedra)
  static const Color forest = Color(0xFF2C3A2F); // Verde carbón profundo y sobrio
  static const Color forestDark = Color(0xFF1E2820);
  static const Color sage = Color(0xFF6E7F71); // Salvia grisácea neutra
  static const Color sageLight = Color(0xFFE7ECE7); // Superficie activa sutil
  static const Color sageMuted = Color(0xFFF2F4F2);

  // Acento cálido terroso (Arcilla / Terracota suave sin saturación excesiva)
  static const Color terracotta = Color(0xFFC26D53); // Arcilla sobria
  static const Color terracottaDark = Color(0xFF9E523B);
  static const Color terracottaLight = Color(0xFFF6EBE7);
  static const Color terracottaMuted = Color(0xFFFBF6F4);

  // Gris pizarra cálido (Voluntariado y elementos secundarios)
  static const Color slateBlue = Color(0xFF5E6F78);
  static const Color slateBlueLight = Color(0xFFE6ECEF);
  static const Color slateBlueMuted = Color(0xFFF3F6F8);

  // Arena y lino
  static const Color sand = Color(0xFFE8E2D5);
  static const Color sandLight = Color(0xFFF4F1EA);

  // Siluetas de perros y gatos en tono lino/piedra armónico
  static const Color silhouette = Color(0xFFE4DFD3);

  // Tipografía y contrastes neutros (Espresso / Taupe)
  static const Color ink = Color(0xFF1C1B19); // Carbón espresso casi negro
  static const Color inkSecondary = Color(0xFF3D3B37);
  static const Color muted = Color(0xFF6E6A63); // Taupe neutro de alta legibilidad
  static const Color mutedLight = Color(0xFF969188);

  // Estados semánticos sobrios
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);
}

/// ✍️ Tipografía moderna y editorial de PawCol
class PawCoTypography {
  static TextTheme textTheme(BuildContext context) {
    return TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
        letterSpacing: -0.4,
        height: 1.18,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w600,
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
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// 🎨 Tema global de PawCol (Material 3 — Neutro, moderno, limpio y humano)
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

  colorScheme: ColorScheme.fromSeed(
    seedColor: PawCoColors.forest,
    primary: PawCoColors.forest,
    secondary: PawCoColors.terracotta,
    tertiary: PawCoColors.sage,
    error: PawCoColors.terracotta,
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
    backgroundColor: PawCoColors.background,
    foregroundColor: PawCoColors.ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.fraunces(
      color: PawCoColors.ink,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    iconTheme: const IconThemeData(color: PawCoColors.ink),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    indicatorColor: PawCoColors.surfaceMuted,
    height: 64,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: PawCoColors.forest, size: 23);
      }
      return const IconThemeData(color: PawCoColors.muted, size: 22);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          color: PawCoColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        );
      }
      return GoogleFonts.plusJakartaSans(
        color: PawCoColors.muted,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );
    }),
  ),

  cardTheme: CardThemeData(
    color: PawCoColors.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: PawCoColors.border, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: PawCoColors.forest,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: PawCoColors.ink,
      side: const BorderSide(color: PawCoColors.border, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: PawCoColors.forest,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: PawCoColors.surfaceMuted,
    secondarySelectedColor: PawCoColors.surfaceMuted,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: PawCoColors.border),
    ),
    labelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.inkSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.ink,
      fontSize: 13,
      fontWeight: FontWeight.w600,
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
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: PawCoColors.forest, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: PawCoColors.ink,
    unselectedLabelColor: PawCoColors.muted,
    indicatorColor: PawCoColors.forest,
    labelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: PawCoColors.ink,
    contentTextStyle: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    behavior: SnackBarBehavior.floating,
  ),

  iconTheme: const IconThemeData(color: PawCoColors.ink),
);
