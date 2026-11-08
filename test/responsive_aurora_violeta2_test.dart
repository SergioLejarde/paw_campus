import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'package:paw_campus/app/main_shell.dart';
import 'package:paw_campus/app/theme.dart';
import 'package:paw_campus/core/presentation/pawco_design_system.dart';
import 'package:paw_campus/features/adoptions/presentation/add_pet_page.dart';
import 'package:paw_campus/features/adoptions/presentation/adoptions_page.dart';
import 'package:paw_campus/features/auth/presentation/login_page.dart';
import 'package:paw_campus/features/auth/presentation/register_page.dart';
import 'package:paw_campus/features/donations/presentation/donations_page.dart';
import 'package:paw_campus/features/lost_pets/presentation/add_lost_pet_page.dart';
import 'package:paw_campus/features/lost_pets/presentation/lost_pets_page.dart';
import 'package:paw_campus/features/overview/presentation/overview_page.dart';
import 'package:paw_campus/features/profile/presentation/edit_profile_page.dart';
import 'package:paw_campus/features/profile/presentation/profile_page.dart';
import 'package:paw_campus/features/sos/presentation/create_sos_report_page.dart';
import 'package:paw_campus/features/sos/presentation/sos_page.dart';

Future<void> _pumpAtViewport(
  WidgetTester tester, {
  required Size size,
  required Widget child,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: lightTheme,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'Aurora Hibrida + Paleta Violeta 2 renders Orbit Hero, SVG and Lottie cleanly',
    (tester) async {
      await _pumpAtViewport(
        tester,
        size: const Size(1280, 900),
        child: const OverviewPage(),
      );

      expect(find.byType(PawColAuroraWaveHeader), findsOneWidget);
      expect(find.byType(PawColOrbitHeroStage), findsOneWidget);
      expect(find.byType(PawColGlassCard), findsWidgets);
      expect(find.byType(PawColGradientText), findsWidgets);
      expect(find.byType(SvgPicture), findsWidgets);
      expect(find.byType(Lottie), findsWidgets);
      expect(find.text('100% REAL'), findsWidgets);
    },
  );

  testWidgets(
    'MainShell navigates all 6 modules at 320px compact mobile without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: lightTheme,
            home: const MainShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      for (var tabIndex = 0; tabIndex < 6; tabIndex++) {
        container.read(mainNavIndexProvider.notifier).state = tabIndex;
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Tab $tabIndex overflowed at 320px compact mobile viewport',
        );
      }
    },
  );

  testWidgets(
    'MainShell navigates all 6 modules at 1440px desktop SaaS top bar without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: lightTheme,
            home: const MainShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      for (var tabIndex = 0; tabIndex < 6; tabIndex++) {
        container.read(mainNavIndexProvider.notifier).state = tabIndex;
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Tab $tabIndex overflowed at 1440px desktop viewport',
        );
      }
    },
  );

  for (final viewport in const [
    Size(320, 840),
    Size(390, 844),
    Size(1440, 960),
  ]) {
    testWidgets(
      'All standalone pages render without overflow at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        final pages = <Widget>[
          const OverviewPage(),
          const AdoptionsPage(),
          const DonationsPage(),
          const LostPetsPage(),
          const SosPage(),
          const CreateSosReportPage(),
          const LoginPage(),
          const RegisterPage(),
          const ProfilePage(),
          const EditProfilePage(),
          const AddPetPage(),
          const AddLostPetPage(),
        ];

        for (final page in pages) {
          await _pumpAtViewport(
            tester,
            size: viewport,
            child: page,
          );
        }
      },
    );
  }
}
