import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/auth_repository.dart';
import 'register_page.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de correo
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),

            // Campo de contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            // Botón principal de login
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      // Guardamos el contexto antes del await 👇
                      final ctx = context;
                      setState(() => _loading = true);

                      try {
                        await authRepo.signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        // Verificamos que el widget sigue montado
                        if (!mounted) return;

                        // Si todo sale bien, navegamos al módulo de adopciones
                        // ignore: use_build_context_synchronously
                        ctx.go('/adoptions');
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          // ignore: use_build_context_synchronously
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Entrar'),
            ),

            // Enlace a registro
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
