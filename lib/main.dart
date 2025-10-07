import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración del entorno
  final config = AppConfig.fromEnvironment();
  config.printConfig();

  // Inicializar Supabase solo si hay claves
  if (config.supabaseUrl.isNotEmpty && config.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
    debugPrint('✅ Supabase inicializado (${config.environment})');
  } else {
    debugPrint('⚠️ Ejecutando sin Supabase (${config.environment})');
  }

  // Inyectamos el AppConfig en Riverpod y lanzamos la app
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const PawCampusApp(),
    ),
  );
}
