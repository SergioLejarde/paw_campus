import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:paw_campus/features/adoptions/presentation/adoptions_page.dart';
import 'package:paw_campus/features/donations/presentation/donations_page.dart';
import 'package:paw_campus/features/overview/presentation/overview_page.dart';
import 'package:paw_campus/features/sos/presentation/create_sos_report_page.dart';
import 'package:paw_campus/features/sos/presentation/sos_page.dart';

void main() {
  testWidgets('AnimalSilhouettesPainter paints without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomPaint(
            size: const Size(400, 800),
            painter: const AnimalSilhouettesPainter(),
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('PawCo design system components render properly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: Column(
            children: [
              const PawCoBadge(label: 'Bucaramanga & AMB'),
              const DogCatHeroIllustration(width: 100, height: 80),
              PawCoHoverCard(
                child: const Text('Tarjeta interactiva'),
              ),
              const PawCoAnimatedProgressBar(value: 0.5),
              const PawCoDashedBox(
                child: Text('Dashed box'),
              ),
              PawCoResponsiveGrid(
                children: const [Text('Item 1'), Text('Item 2')],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bucaramanga & AMB'), findsOneWidget);
    expect(find.text('Tarjeta interactiva'), findsOneWidget);
    expect(find.text('Dashed box'), findsOneWidget);
  });

  testWidgets('OverviewPage renders editorial hero, actions and transparency', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: lightTheme,
          home: const OverviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PawCo Santander'), findsOneWidget);
    expect(find.text('Juntos por los animales'), findsOneWidget);
    expect(find.text('Conviértete en un Héroe para los Animales'), findsOneWidget);
    expect(find.text('Transparencia Total'), findsOneWidget);
    expect(find.text('Sergio Lejarde'), findsOneWidget);
    expect(find.text('Ingeniero de Sistemas e Informática (24 años)'), findsOneWidget);
    expect(find.text('Voluntariado en Fundaciones del AMB'), findsOneWidget);
  });

  testWidgets('AnimalSilhouetteBackground wraps content cleanly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimalSilhouetteBackground(
          child: Center(
            child: Text('Contenido con siluetas'),
          ),
        ),
      ),
    );
    expect(find.text('Contenido con siluetas'), findsOneWidget);
    expect(find.byType(AnimalSilhouetteBackground), findsOneWidget);
  });

  testWidgets('DonationsPage renders verified causes, direct donation and directory', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: lightTheme,
          home: const DonationsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PawCo Donaciones'), findsOneWidget);
    expect(find.text('Apoya Nuestras Causas y Alianzas'), findsOneWidget);
    expect(find.text('Apoya Nuestras Causas Verificadas'), findsOneWidget);
    expect(find.text('Donación Directa con Propósito'), findsOneWidget);
    expect(find.text('Fundaciones Aliadas y Directorio 24/7'), findsOneWidget);
    expect(find.text('Donar Ahora con Wompi'), findsOneWidget);
  });

  testWidgets('AdoptionsPage renders editorial header, pill filters and companion cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: lightTheme,
          home: const AdoptionsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PawCo Adopciones'), findsOneWidget);
    expect(find.text('Encuentra un compañero'), findsOneWidget);
    expect(find.text('🐕 Perros'), findsOneWidget);
    expect(find.text('🐈 Gatos'), findsOneWidget);
    expect(find.text('🐾 Cachorros (<1 año)'), findsOneWidget);
    expect(find.text('Dar en adopción'), findsOneWidget);
  });

  testWidgets('SosPage renders legal framework, emergency channels and report CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: lightTheme,
          home: const SosPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOS y Denuncias'), findsOneWidget);
    expect(find.text('Marco Legal de Protección Animal en Colombia'), findsOneWidget);
    expect(find.text('Policía Nacional — Línea 123'), findsOneWidget);
    expect(find.text('Fiscalía General — Grupo GELMA'), findsOneWidget);
    expect(find.text('Radicar Reporte SOS Ahora'), findsOneWidget);
  });

  testWidgets('CreateSosReportPage renders form with dashed evidence box and anonymous switch', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: lightTheme,
          home: const CreateSosReportPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reportar Caso SOS'), findsOneWidget);
    expect(find.text('Nivel de Urgencia *'), findsOneWidget);
    expect(find.text('Tipo de Maltrato o Situación *'), findsOneWidget);
    expect(find.text('Foto o Video de Evidencia'), findsOneWidget);
    expect(find.text('Toca aquí para subir foto o video'), findsOneWidget);
    expect(find.text('Enviar denuncia de forma anónima'), findsOneWidget);
    expect(find.text('Radicar Reporte SOS'), findsOneWidget);
  });
}
