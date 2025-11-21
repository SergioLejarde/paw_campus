import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/adoptions/presentation/adoptions_page.dart';
import '../features/adoptions/presentation/my_pets_page.dart';
import '../features/adoptions/presentation/admin_page.dart';
import '../features/adoptions/presentation/pet_detail_page.dart';
import '../features/donations/presentation/donations_page.dart';

final supabase = Supabase.instance.client;

/// 🔄 Necesario para que GoRouter reaccione a cambios de sesión
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  debugLogDiagnostics: true,

  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  /// 🚀 REDIRECT GLOBAL BASADO EN ROL
  redirect: (context, state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    final isLoggingIn = state.matchedLocation == '/login';

    // 🧪 Si no hay usuario → enviarlo a login
    if (user == null) {
      return isLoggingIn ? null : '/login';
    }

    // 🧪 Obtener perfil (is_admin)
    final profile = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .maybeSingle();

    final bool isAdmin = profile?['is_admin'] == true;

    // 🔐 Si entra a login estando logueado → redirigir según rol
    if (isLoggingIn) {
      return isAdmin ? '/admin' : '/adoptions';
    }

    return null; // No hacer nada
  },

  /// 📌 RUTAS
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/adoptions', builder: (_, __) => const AdoptionsPage()),
    GoRoute(path: '/my-pets', builder: (_, __) => const MyPetsPage()),
    GoRoute(path: '/donations', builder: (_, __) => const DonationsPage()),

    /// 👑 PANEL ADMIN
    GoRoute(path: '/admin', builder: (_, __) => const AdminPage()),

    /// 🔍 DETALLE DE MASCOTA
    GoRoute(
      path: '/pet/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PetDetailPage(petId: id);
      },
    ),
  ],
);
