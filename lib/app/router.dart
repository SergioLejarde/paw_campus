// lib/app/router.dart
//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_campus/features/auth/presentation/login_page.dart';
import 'package:paw_campus/features/auth/presentation/register_page.dart';
import 'package:paw_campus/features/adoptions/presentation/adoptions_page.dart';
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
      path: '/donations',
      name: 'donations',
      builder: (context, state) => const DonationsPage(),
    ),
  ],
);
