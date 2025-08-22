import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PawCampusApp());
}

class PawCampusApp extends StatelessWidget {
  const PawCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawCampus',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0E7C7B),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PawCampus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // 👉 Función para abrir una URL en el navegador (iOS/Android/Web)
  Future<void> _openFlutterSite() async {
    final uri = Uri.parse('https://flutter.dev');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Si por alguna razón falla, muestra un mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la URL')),
        );
      }
    }
  }

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Has presionado el botón esta cantidad:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            // 👇 Este es el botón que te dije:
            ElevatedButton(
              onPressed: _openFlutterSite,
              child: const Text('Abrir Flutter.dev'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
