import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'usuario@prueba.com');
  final _passwordController = TextEditingController(text: '12345678');
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw AuthException('Usuario o contraseña incorrectos');

      // 🔍 Consultar perfil COMPLETO para debug
      final profile = await supabase
          .from('profiles')
          .select('id, email, full_name, phone, photo_url, is_admin')
          .eq('id', user.id)
          .maybeSingle();

      // ignore: avoid_print
      print('DEBUG PERFIL → $profile'); // 👈 AQUI SABREMOS SI ESTA LLEGANDO is_admin

      final bool isAdmin = (profile?['is_admin'] ?? false) as bool;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdmin
              ? '👑 Bienvenido Administrador'
              : '✅ Sesión iniciada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // 🚀 Redirigir según rol
      if (isAdmin) {
        context.go('/admin');
      } else {
        context.go('/adoptions');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error de autenticación: ${e.message}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Error inesperado: $e'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
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
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Entrar con Supabase'),
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
