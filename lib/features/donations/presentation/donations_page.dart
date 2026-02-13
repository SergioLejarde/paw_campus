import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  static const String wompiLink = 'https://checkout.wompi.co/l/IMjZp7';

  Future<void> _openWompi(BuildContext context) async {
    // Si quieres forzar login antes de donar:
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    final uri = Uri.parse(wompiLink);

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // abre navegador / app externa
      webOnlyWindowName: '_blank',          // en web abre nueva pestaña
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el link de pago.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = Supabase.instance.client.auth.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donaciones'),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Apoya PawCampus 💛',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isLogged
                      ? 'Escanea el QR o toca “Donar” para abrir Wompi.'
                      : 'Inicia sesión para donar (o quita esta restricción si quieres).',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // QR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: wompiLink,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                SelectableText(
                  wompiLink,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Donar con Wompi'),
                    onPressed: () => _openWompi(context),
                  ),
                ),

                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar link'),
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: wompiLink));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado ✅')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
