import 'package:go_router/go_router.dart';
import 'package:paw_campus/features/auth/presentation/login_page.dart';
import 'package:paw_campus/features/auth/presentation/register_page.dart';
import 'package:paw_campus/features/adoptions/presentation/adoptions_page.dart';
import 'package:paw_campus/features/adoptions/presentation/my_pets_page.dart';
import 'package:paw_campus/features/adoptions/presentation/admin_page.dart'; // 👈 IMPORTANTE
import 'package:paw_campus/features/donations/presentation/donations_page.dart';

/// Router global de PawCampus.
/// Define todas las rutas principales de la aplicación.
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/adoptions',
      name: 'adoptions',
      builder: (context, state) => const AdoptionsPage(),
    ),
    GoRoute(
      path: '/my-pets',
      name: 'my_pets',
      builder: (context, state) => const MyPetsPage(),
    ),
    GoRoute(
      path: '/donations',
      name: 'donations',
      builder: (context, state) => const DonationsPage(),
    ),

    // 🧩 NUEVA RUTA PARA EL PANEL ADMIN
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
  ],
);
