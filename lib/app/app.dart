// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'env.dart';
import 'router.dart';
import 'theme.dart'; // ✅ Importamos el tema global

/// Provider que expone la configuración global (AppConfig)
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig no inicializado');
});

/// 🌎 Widget raíz de PawCampus
/// Configura el tema, las rutas y la integración global de Riverpod.
class PawCampusApp extends ConsumerWidget {
  const PawCampusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la configuración actual del entorno (AppConfig)
    // final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'PawCampus',
      debugShowCheckedModeBanner: false,
      routerConfig: router, // 🚀 Define las rutas en router.dart
      theme: lightTheme, // 🎨 Definido en theme.dart
      darkTheme: lightTheme, // mantenemos el mismo por ahora
      themeMode: ThemeMode.dark, // 🔒 Fuerza modo oscuro (corrige fondo blanco iOS)
    );
  }
}
