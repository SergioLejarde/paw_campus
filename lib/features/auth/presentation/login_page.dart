import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppFeedback.showError(context, Exception('Ingresa correo y contraseña'));
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException("Usuario o contraseña inválidos");
      }

      // Consultar is_admin
      final profile = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();

      final bool isAdmin = (profile?['is_admin'] == true) ||
          (user.email?.endsWith('@admin.com') ?? false);

      if (!mounted) return;

      AppFeedback.showSuccess(context, '¡Bienvenido de vuelta a PawCol!');
      context.go(isAdmin ? '/admin' : '/');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawCoColors.background,
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: PawCoColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: PawCoColors.border),
                boxShadow: [
                  BoxShadow(
                    color: PawCoColors.ink.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo PawCol
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PawCoColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PawCoColors.border),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 32,
                        color: PawCoColors.forest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PawCol',
                      style: GoogleFonts.fraunces(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Comunidad animalista de Bucaramanga y Colombia',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: PawCoColors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _loading ? null : _login(),
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Iniciar sesión",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Registro
                    TextButton(
                      onPressed: _loading ? null : () => context.push('/register'),
                      child: const Text('¿No tienes cuenta? Crear cuenta'),
                    ),

                    const Divider(height: 32, color: PawCoColors.border),

                    // Volver al modo invitado
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PawCoColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text(
                        'Continuar como invitado',
                        style: TextStyle(color: PawCoColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
