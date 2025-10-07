// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Router global de PawCampus.
/// Define todas las rutas principales de la aplicación.
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const _LoginPage(),
    ),
    GoRoute(
      path: '/adoptions',
      name: 'adoptions',
      builder: (context, state) => const _AdoptionsPage(),
    ),
    GoRoute(
      path: '/donations',
      name: 'donations',
      builder: (context, state) => const _DonationsPage(),
    ),
  ],
);

/// --- Páginas de prueba ---
/// Las iremos reemplazando por las reales después.

class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegar a la página de adopciones
            context.go('/adoptions');
          },
          child: const Text('Ingresar (Demo)'),
        ),
      ),
    );
  }
}

class _AdoptionsPage extends StatelessWidget {
  const _AdoptionsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopciones')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/donations');
          },
          child: const Text('Ir a Donaciones'),
        ),
      ),
    );
  }
}

class _DonationsPage extends StatelessWidget {
  const _DonationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
}
