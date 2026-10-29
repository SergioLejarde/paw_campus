import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/app_feedback.dart';
import '../data/auth_repository.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppFeedback.showError(context, Exception('Ingresa correo y contraseña'));
      return;
    }

    if (password.length < 6) {
      AppFeedback.showError(
        context,
        Exception('La contraseña debe tener al menos 6 caracteres'),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.signUp(email, password);

      if (!mounted) return;

      AppFeedback.showSuccess(
        context,
        '¡Cuenta creada exitosamente en PawCol! Ahora inicia sesión.',
      );

      context.go('/login');
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
        title: const Text('Crear cuenta'),
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PawCoColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PawCoColors.border),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 32,
                        color: PawCoColors.forest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Únete a PawCol',
                      style: GoogleFonts.fraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: PawCoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crea tu cuenta para publicar mascotas y participar en la comunidad.',
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
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _loading ? null : _register(),
                      decoration: const InputDecoration(
                        labelText: 'Contraseña (mínimo 6 caracteres)',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
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
                                'Registrarme en PawCol',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loading ? null : () => context.go('/login'),
                      child: const Text('¿Ya tienes cuenta? Iniciar sesión'),
                    ),

                    const Divider(height: 32, color: PawCoColors.border),

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
