// lib/app/env.dart
import 'package:flutter/foundation.dart';

/// AppConfig centraliza toda la configuración de la aplicación.
/// Usa variables pasadas por --dart-define al ejecutar `flutter run`.
/// Ejemplo de ejecución:
/// flutter run \
///   --dart-define=APP_ENV=dev \
///   --dart-define=SUPABASE_URL=https://tuproyecto.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=clave_anonima

class AppConfig {
  /// URL base del proyecto Supabase
  final String supabaseUrl;

  /// Llave anónima pública de Supabase (para acceso desde cliente)
  final String supabaseAnonKey;

  /// Nombre del entorno actual (dev, stg, prod)
  final String environment;

  /// Constructor inmutable
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.environment,
  });

  /// Crea la configuración leyendo variables de entorno con valores por defecto.
  static AppConfig fromEnvironment() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isEmpty || key.isEmpty) {
      debugPrint('⚠️ Advertencia: variables de Supabase no definidas.');
    }

    return AppConfig(
      supabaseUrl: url,
      supabaseAnonKey: key,
      environment: env,
    );
  }

  /// Método auxiliar para mostrar el estado actual del entorno (útil para depuración)
  void printConfig() {
    debugPrint('''
🌍 Configuración App:
  Entorno: $environment
  Supabase URL: $supabaseUrl
  Supabase Key: ${supabaseAnonKey.isNotEmpty ? "••••••••" : "(vacía)"}
''');
  }
}
