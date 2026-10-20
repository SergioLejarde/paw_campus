import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Paleta de colores editorial orgánica de PawCo
/// Inspirada en la estética natural, cálida y de rescate animalista (Bucaramanga y AMB)
abstract class PawCoColors {
  // Fondos y superficies
  static const Color background = Color(0xFFF6F3EC); // Avena / Marfil cálido
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro para tarjetas
  static const Color surfaceMuted = Color(0xFFEEE9DF); // Crema neutro
  static const Color border = Color(0xFFE0D9CC); // Borde sutil orgánico
  static const Color borderLight = Color(0xFFECE7DD);

  // Verdes bosque y salvia (Naturaleza, esperanza, vida)
  static const Color forest = Color(0xFF3E5641); // Verde bosque profundo (Primario)
  static const Color forestDark = Color(0xFF283B2B);
  static const Color sage = Color(0xFF7A947B); // Verde salvia suave
  static const Color sageLight = Color(0xFFDCE5DC); // Píldoras activas y fondos
  static const Color sageMuted = Color(0xFFEBF0EA);

  // Terracota y coral cálido (Alertas, SOS, pasión, donaciones urgentes)
  static const Color terracotta = Color(0xFFD87A61); // Terracota cálido
  static const Color terracottaDark = Color(0xFFB85840);
  static const Color terracottaLight = Color(0xFFF7E4DE); // Fondos suaves de SOS/Alertas
  static const Color terracottaMuted = Color(0xFFFDF2EF);

  // Azul pizarra (Voluntariado, comunidad y transparencia)
  static const Color slateBlue = Color(0xFF708B99);
  static const Color slateBlueLight = Color(0xFFDCE6EC);
  static const Color slateBlueMuted = Color(0xFFEFF4F8);

  // Arena y trigo
  static const Color sand = Color(0xFFE9DFCE);
  static const Color sandLight = Color(0xFFF4EEE2);

  // Siluetas y marcas de agua
  static const Color silhouette = Color(0xFFE2D8C3); // Cálido visible y reconocible

  // Texto y contrastes
  static const Color ink = Color(0xFF1E2621); // Carbón vegetal profundo
  static const Color inkSecondary = Color(0xFF3A443E);
  static const Color muted = Color(0xFF5C6660); // Gris verde oliva legible
  static const Color mutedLight = Color(0xFF8A948E);

  // Éxito y estados
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
}

/// ✍️ Tipografía editorial de PawCo (Fraunces para titulares, Plus Jakarta Sans para cuerpo)
class PawCoTypography {
  static TextTheme textTheme(BuildContext context) {
    return TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: PawCoColors.ink,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: PawCoColors.ink,
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
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: PawCoColors.ink,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: PawCoColors.muted,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// 🎨 Tema global de PawCo (Material 3 — Editorial, cálido, limpio y animalista)
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

  // Fondo marfil / avena cálido
  scaffoldBackgroundColor: PawCoColors.background,

  // AppBar editorial
  appBarTheme: AppBarTheme(
    backgroundColor: PawCoColors.background,
    foregroundColor: PawCoColors.ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.fraunces(
      color: PawCoColors.ink,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: const IconThemeData(color: PawCoColors.forest),
  ),

  // NavigationBar inferior móvil estilizada
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 6,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    indicatorColor: PawCoColors.sageLight,
    height: 68,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: PawCoColors.forest, size: 25);
      }
      return const IconThemeData(color: PawCoColors.muted, size: 23);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          color: PawCoColors.forest,
          fontSize: 11.5,
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

  // Tarjetas editoriales con bordes sutiles y esquinas suaves
  cardTheme: CardThemeData(
    color: PawCoColors.surface,
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: 0.04),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: PawCoColors.border, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  ),

  // Botones principales con verde bosque y esquinas redondeadas
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: PawCoColors.forest,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: PawCoColors.forest,
      side: const BorderSide(color: PawCoColors.border, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  // Chips
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: PawCoColors.sageLight,
    secondarySelectedColor: PawCoColors.sageLight,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: PawCoColors.border),
    ),
    labelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.ink,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.forest,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  ),

  // Inputs con fondo blanco y borde suave
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: GoogleFonts.plusJakartaSans(
      color: PawCoColors.mutedLight,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: PawCoColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: PawCoColors.forest, width: 1.8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  // TabBar
  tabBarTheme: TabBarThemeData(
    labelColor: PawCoColors.forest,
    unselectedLabelColor: PawCoColors.muted,
    indicatorColor: PawCoColors.forest,
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

  // Snackbars
  snackBarTheme: SnackBarThemeData(
    backgroundColor: PawCoColors.forest,
    contentTextStyle: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  // Iconos
  iconTheme: const IconThemeData(color: PawCoColors.forest),
);
