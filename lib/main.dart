import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Leemos variables por --dart-define para no quemar secretos en código.
/// Ejemplo de ejecución:
/// flutter run \
///   --dart-define=APP_ENV=dev \
///   --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase si pasaste las llaves; si no, ejecuta en modo "mock".
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    debugPrint('✅ Supabase inicializado (${appEnv.toUpperCase()})');
  } else {
    debugPrint('⚠️  SUPABASE_URL/ANON_KEY no definidos. Ejecutando sin backend (${appEnv.toUpperCase()}).');
  }

  runApp(const PawCampusApp());
}

/// App mínima para arrancar. Luego moveremos esto a lib/app/app.dart y usaremos router.
class PawCampusApp extends StatelessWidget {
  const PawCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawCampus',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0E7C7B),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF0E7C7B),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const _BootstrapPage(),
    );
  }
}

/// Pantalla inicial temporal para verificar que todo corre.
/// La reemplazaremos cuando creemos router y páginas reales.
class _BootstrapPage extends StatelessWidget {
  const _BootstrapPage();

  @override
  Widget build(BuildContext context) {
    final hasSupabase = supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('PawCampus')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PawCampus arrancó 🚀', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Entorno: $appEnv'),
            const SizedBox(height: 8),
            Text(hasSupabase ? 'Backend: Supabase ✅' : 'Backend: (mock) ⚠️ sin llaves'),
          ],
        ),
      ),
    );
  }
}
