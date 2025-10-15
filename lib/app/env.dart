// lib/app/env.dart
import 'package:flutter/foundation.dart';

/// AppConfig centraliza la configuración de la aplicación.
/// Lee las variables definidas por `--dart-define`, o usa valores por defecto.
/// Permite ejecutar `flutter run` sin necesidad de definir claves manualmente.
class AppConfig {
  final String environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  /// Lee variables de entorno o aplica valores por defecto (modo dev)
  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://hvnerazfhkjqzqmueyso.supabase.co',
    );
    const key = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2bmVyYXpmaGtqcXpxbXVleXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3OTA3MzgsImV4cCI6MjA3NTM2NjczOH0.Cdz--By3NtuUgsQnBr6ovbyLpO8N_kjs0BvRbRc5g5c',
    );

    return AppConfig(
      environment: env,
      supabaseUrl: url,
      supabaseAnonKey: key,
    );
  }

  /// Muestra la configuración actual (solo en modo debug)
  void printConfig() {
    debugPrint('🌍 Configuración App:');
    debugPrint('  Entorno: $environment');
    debugPrint('  Supabase URL: $supabaseUrl');
    debugPrint(
        '  Supabase Key: ${supabaseAnonKey.isNotEmpty ? "••••••••" : "⚠️ Vacía"}');
  }
}
