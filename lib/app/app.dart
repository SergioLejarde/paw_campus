// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'env.dart';
import 'router.dart';

/// Este provider expone la configuración global (AppConfig)
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig no inicializado');
});

/// PawCampusApp es el widget raíz de toda la aplicación.
/// Configura el tema, las rutas y el acceso a la configuración global.
class PawCampusApp extends ConsumerWidget {
  const PawCampusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la configuración actual del entorno (AppConfig)
    //final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'PawCampus',
      routerConfig: router, // Definido en router.dart
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Tema claro ---
final _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7C7B),
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
);

// --- Tema oscuro ---
final _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7C7B),
    brightness: Brightness.dark,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
);
