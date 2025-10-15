import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../adoptions/data/pets_repository.dart';

final supabase = Supabase.instance.client;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: 'usuario@prueba.com');
  final _passwordController = TextEditingController(text: '12345678');
  bool _loading = false;
  String _message = '';

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user == null) throw Exception('Error al iniciar sesión');
      setState(() => _message = '✅ Sesión iniciada correctamente');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _insertPet() async {
    try {
      await PetsRepository().addPet(
        name: 'Luna',
        species: 'Perro',
        age: 2,
        description: 'Juguetona y noble',
        photoUrl: 'https://placekitten.com/400/400',
      );
      setState(() => _message = '🐾 Mascota subida correctamente');
    } catch (e) {
      setState(() => _message = '⚠️ Error insertando mascota: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Entrar con Supabase'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _insertPet,
              child: const Text('Insertar mascota de prueba 🐶'),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
