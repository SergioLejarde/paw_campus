// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'env.dart';
import 'router.dart';
import 'theme.dart';

/// Provider que expone la configuración global (AppConfig)
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig no inicializado');
});

class PawCampusApp extends ConsumerWidget {
  const PawCampusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si luego lo necesitas:
    // final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'PawCampus',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // ✅ Tema claro (cute)
      theme: lightTheme,

      // ✅ Por ahora, si el sistema pide dark, usamos el mismo tema para que no cambie feo
      darkTheme: lightTheme,

      // ✅ No forzamos oscuro: usamos claro (lo que quieres para el video)
      themeMode: ThemeMode.light,
    );
  }
}
