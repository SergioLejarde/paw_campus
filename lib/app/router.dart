import 'package:go_router/go_router.dart';
import 'package:paw_campus/app/main_shell.dart';
import 'package:paw_campus/features/auth/presentation/login_page.dart';
import 'package:paw_campus/features/auth/presentation/register_page.dart';
import 'package:paw_campus/features/adoptions/presentation/adoptions_page.dart';
import 'package:paw_campus/features/adoptions/presentation/my_pets_page.dart';
import 'package:paw_campus/features/adoptions/presentation/admin_page.dart';
import 'package:paw_campus/features/adoptions/presentation/add_pet_page.dart';
import 'package:paw_campus/features/donations/presentation/donations_page.dart';
import 'package:paw_campus/features/adoptions/presentation/pet_detail_page.dart';
import 'package:paw_campus/features/profile/presentation/profile_page.dart';
import 'package:paw_campus/features/profile/presentation/edit_profile_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainShell(),
    ),
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
      path: '/pets/new',
      name: 'add_pet',
      builder: (context, state) => const AddPetPage(),
    ),
    GoRoute(
      path: '/donations',
      name: 'donations',
      builder: (context, state) => const DonationsPage(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
    GoRoute(
      path: '/pet/:id',
      name: 'pet_detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PetDetailPage(petId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'profile_edit',
      builder: (context, state) => const EditProfilePage(),
    ),
  ],
);
