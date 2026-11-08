import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../app/theme.dart';

/// Detecta de forma 100% compatible con Web y Nativo si se está ejecutando en `flutter test`.
/// Evita que animaciones continuas (`.repeat()`) bloqueen `tester.pumpAndSettle()`.
bool get isRunningInFlutterTest {
  final bindingType = WidgetsBinding.instance.runtimeType.toString();
  return bindingType.contains('TestWidgetsFlutterBinding') ||
      bindingType.contains('AutomatedTestWidgetsFlutterBinding') ||
      bindingType.contains('LiveTestWidgetsFlutterBinding');
}

// ============================================================================
// 1. AURORA HÍBRIDA, HALOS DE LUZ, ONDA CURVA Y SILUETAS LINEALES CONTINUAS
// ============================================================================

/// Texto destacado con degradado SaaS (Lila `#D8B4FE` -> Rosa Malva `#E6759D` -> Ámbar `#FBBF24`)
class PawColGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final List<Color> colors;

  const PawColGradientText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.colors = const [
      PawCoColors.lilacGlow,
      PawCoColors.malva,
      PawCoColors.amberGlow,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Tarjeta Glassmorphism real con `BackdropFilter`, cristal esmerilado y borde luminoso
class PawColGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final Color? borderColor;

  const PawColGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurSigma = 16,
    this.tintColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tintColor ?? Colors.white).withValues(alpha: 0.14),
                (tintColor ?? PawCoColors.lilacGlow).withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Cabecera Hero / Módulo en Violeta Profundo Aurora (`#1B0B2E` -> `#3B1763` -> `#431E61`)
/// con halos radiales difuminados (Ambient Glow Orbs) y divisor inferior en onda curva
/// acompañado de siluetas lineales continuas de perros, gatos y huellas hacia `#FAF6F9`.
class PawColAuroraWaveHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final double waveHeight;
  final Color bottomColor;
  final bool showLineArtPets;

  const PawColAuroraWaveHeader({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 28, 20, 24),
    this.waveHeight = 62,
    this.bottomColor = PawCoColors.background,
    this.showLineArtPets = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PawCoColors.auroraStart,
            PawCoColors.auroraMid,
            PawCoColors.auroraEnd,
          ],
          stops: [0.0, 0.58, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // --- Ambient Glow Orbs (Halos radiales difuminados) ---
          Positioned(
            top: -80,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PawCoColors.malva.withValues(alpha: 0.28),
                      PawCoColors.orchid.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -70,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PawCoColors.lilacGlow.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Contenido + Divisor en Onda Curva con Siluetas Lineales ---
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: contentPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: child,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: waveHeight,
                child: CustomPaint(
                  painter: PawColWaveLineArtPainter(
                    fillColor: bottomColor,
                    lineColor: PawCoColors.lilacGlow,
                    accentLineColor: PawCoColors.malva,
                    showPets: showLineArtPets,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dibuja el divisor en onda orgánica suave hacia `#FAF6F9` acompañado de un trazo
/// continuo luminoso con siluetas minimalistas de perrito, gatito y huellas.
class PawColWaveLineArtPainter extends CustomPainter {
  final Color fillColor;
  final Color lineColor;
  final Color accentLineColor;
  final bool showPets;

  const PawColWaveLineArtPainter({
    this.fillColor = PawCoColors.background,
    this.lineColor = PawCoColors.lilacGlow,
    this.accentLineColor = PawCoColors.malva,
    this.showPets = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;

    // 1. Relleno inferior Marfil-Lila Pastel (#FAF6F9)
    final wavePath = Path()
      ..moveTo(0, h * 0.58)
      ..cubicTo(
        w * 0.24,
        h * 0.96,
        w * 0.52,
        h * 0.14,
        w * 0.78,
        h * 0.54,
      )
      ..quadraticBezierTo(w * 0.91, h * 0.74, w, h * 0.44)
      ..lineTo(w, h + 1)
      ..lineTo(0, h + 1)
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(wavePath, fillPaint);

    // 2. Línea luminosa continua en degradado siguiendo la cresta de la onda
    final crestPath = Path()
      ..moveTo(0, h * 0.58)
      ..cubicTo(
        w * 0.24,
        h * 0.96,
        w * 0.52,
        h * 0.14,
        w * 0.78,
        h * 0.54,
      )
      ..quadraticBezierTo(w * 0.91, h * 0.74, w, h * 0.44);

    final strokePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.45),
          accentLineColor.withValues(alpha: 0.75),
          PawCoColors.amberGlow.withValues(alpha: 0.55),
          lineColor.withValues(alpha: 0.40),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(crestPath, strokePaint);

    if (!showPets || w < 260) return;

    // 3. Siluetas lineales minimalistas posadas sobre la onda (gato + perro + huellas)
    final petLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Gatito lineal sentado cerca del pico central-derecho (x ~ 0.60w)
    final catX = w * 0.60;
    final catY = h * 0.35;
    final catLine = Path()
      ..moveTo(catX - 12, catY + 2)
      ..cubicTo(catX - 16, catY - 8, catX - 10, catY - 16, catX - 6, catY - 18)
      ..lineTo(catX - 5, catY - 25) // Oreja izq
      ..lineTo(catX - 1, catY - 20)
      ..lineTo(catX + 3, catY - 20)
      ..lineTo(catX + 6, catY - 25) // Oreja der
      ..lineTo(catX + 7, catY - 17)
      ..cubicTo(catX + 11, catY - 12, catX + 9, catY - 4, catX + 8, catY + 3)
      ..moveTo(catX - 12, catY + 2)
      ..quadraticBezierTo(catX - 20, catY - 4, catX - 17, catY - 12); // Cola
    canvas.drawPath(catLine, petLinePaint);

    // Perrito lineal alegre a la izquierda (x ~ 0.16w)
    if (w >= 420) {
      final dogX = w * 0.16;
      final dogY = h * 0.72;
      final dogLine = Path()
        ..moveTo(dogX - 14, dogY)
        ..quadraticBezierTo(dogX - 20, dogY - 8, dogX - 16, dogY - 14) // Cola
        ..moveTo(dogX - 13, dogY)
        ..cubicTo(dogX - 12, dogY - 12, dogX - 4, dogY - 16, dogX + 2, dogY - 20)
        ..cubicTo(dogX + 6, dogY - 24, dogX + 12, dogY - 22, dogX + 15, dogY - 18) // Hocico
        ..cubicTo(dogX + 12, dogY - 14, dogX + 8, dogY - 14, dogX + 7, dogY - 8)
        ..lineTo(dogX + 7, dogY + 2);
      canvas.drawPath(dogLine, petLinePaint);
    }

    // Huellitas luminosas sobre la onda
    _drawMiniPaw(canvas, Offset(w * 0.44, h * 0.28), 5.5, accentLineColor.withValues(alpha: 0.7));
    _drawMiniPaw(canvas, Offset(w * 0.74, h * 0.42), 5.0, PawCoColors.amberGlow.withValues(alpha: 0.65));
  }

  void _drawMiniPaw(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.2), width: r * 1.3, height: r), p);
    canvas.drawCircle(Offset(c.dx - r * 0.6, c.dy - r * 0.35), r * 0.26, p);
    canvas.drawCircle(Offset(c.dx - r * 0.2, c.dy - r * 0.6), r * 0.26, p);
    canvas.drawCircle(Offset(c.dx + r * 0.2, c.dy - r * 0.6), r * 0.26, p);
    canvas.drawCircle(Offset(c.dx + r * 0.6, c.dy - r * 0.35), r * 0.26, p);
  }

  @override
  bool shouldRepaint(covariant PawColWaveLineArtPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.showPets != showPets;
}

// ============================================================================
// 2. ESCENARIO ORBITAL ANIMADO DEL HERO (Órbitas + Glassmorphism + SVG + Lottie)
// ============================================================================

/// Escenario derecho/inferior del Hero inspirado en sitios SaaS modernos:
/// - Dos anillos orbitales giratorios con nodos luminosos (`CustomPainter`)
/// - Tarjeta flotante Glassmorphism (`BackdropFilter`) con progreso en vivo
/// - Ilustración vectorial local (`flutter_svg`) de rescatista, perro y gato
/// - Pulso vectorial animado local (`lottie`)
class PawColOrbitHeroStage extends StatefulWidget {
  final VoidCallback? onExploreTap;
  final VoidCallback? onDonateTap;

  const PawColOrbitHeroStage({
    super.key,
    this.onExploreTap,
    this.onDonateTap,
  });

  @override
  State<PawColOrbitHeroStage> createState() => _PawColOrbitHeroStageState();
}

class _PawColOrbitHeroStageState extends State<PawColOrbitHeroStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    if (!isRunningInFlutterTest) {
      _orbitController.repeat();
    } else {
      _orbitController.value = 0.28;
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 440.0;
        final isCompact = maxW < 360;
        final stageHeight = isCompact ? 340.0 : 395.0;

        Widget glassDashboard = PawColGlassCard(
          padding: EdgeInsets.all(isCompact ? 14 : 18),
          borderRadius: 22,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'IMPACTO AUDITADO EN VIVO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: PawCoColors.lilacGlow,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOrbitMetricRow(
                icon: Icons.pets_rounded,
                iconBg: PawCoColors.cottonLilac,
                iconColor: PawCoColors.plum,
                title: 'Adopción Verificada',
                badge: '86%',
                progress: 0.86,
                barColor: PawCoColors.lilacGlow,
                isCompact: isCompact,
              ),
              const SizedBox(height: 10),
              _buildOrbitMetricRow(
                icon: Icons.inventory_2_rounded,
                iconBg: PawCoColors.softMalva,
                iconColor: PawCoColors.terracottaDark,
                title: '40 Bultos Concentrado',
                badge: '78%',
                progress: 0.78,
                barColor: PawCoColors.malva,
                isCompact: isCompact,
              ),
              const SizedBox(height: 10),
              _buildOrbitMetricRow(
                icon: Icons.verified_user_rounded,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFB45309),
                title: 'Trazabilidad Clínica',
                badge: '100%',
                progress: 1.0,
                barColor: PawCoColors.amberGlow,
                isCompact: isCompact,
              ),
            ],
          ),
        );

        if (!isRunningInFlutterTest) {
          glassDashboard = glassDashboard
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -4,
                end: 5,
                duration: 3200.ms,
                curve: Curves.easeInOutSine,
              );
        }

        return SizedBox(
          width: maxW,
          height: stageHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Anillos orbitales giratorios con nodos luminosos
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _OrbitalRingsPainter(
                        progress: _orbitController.value,
                      ),
                    );
                  },
                ),
              ),

              // 2. Tarjeta flotante Glassmorphism (Izquierda/Centro)
              Positioned(
                top: isCompact ? 18 : 22,
                left: 0,
                right: isCompact ? 28 : 88,
                child: glassDashboard,
              ),

              // 3. Pulso Lottie local en la esquina superior derecha
              Positioned(
                top: 2,
                right: isCompact ? 0 : 12,
                child: IgnorePointer(
                  child: SizedBox(
                    width: isCompact ? 56 : 72,
                    height: isCompact ? 56 : 72,
                    child: Lottie.asset(
                      'assets/animations/pawcol_heart_pulse.json',
                      animate: !isRunningInFlutterTest,
                      repeat: !isRunningInFlutterTest,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 4. Ilustración vectorial SVG local (Rescatista + Perro + Gato)
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: SvgPicture.asset(
                    'assets/vectors/pawcol_rescuer_pets.svg',
                    width: isCompact ? 178 : 235,
                    height: isCompact ? 148 : 195,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitMetricRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badge,
    required double progress,
    required Color barColor,
    required bool isCompact,
  }) {
    return Row(
      children: [
        Container(
          width: isCompact ? 32 : 36,
          height: isCompact ? 32 : 36,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isCompact ? 16 : 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isCompact ? 11.5 : 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: barColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrbitalRingsPainter extends CustomPainter {
  final double progress;

  const _OrbitalRingsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.48);
    final outerR = math.min(size.width, size.height) * 0.46;
    final innerR = outerR * 0.72;

    // Halo radial central
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          PawCoColors.orchid.withValues(alpha: 0.26),
          PawCoColors.malva.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerR * 1.1));
    canvas.drawCircle(center, outerR * 1.1, glowPaint);

    final outerRingPaint = Paint()
      ..color = PawCoColors.lilacGlow.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final innerRingPaint = Paint()
      ..color = PawCoColors.malva.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    canvas.drawCircle(center, outerR, outerRingPaint);
    canvas.drawCircle(center, innerR, innerRingPaint);

    // Nodos orbitales luminosos
    final angle1 = progress * 2 * math.pi;
    final angle2 = angle1 + (2.1 * math.pi / 3);
    final angle3 = -progress * 2 * math.pi + 1.1;

    _drawGlowingNode(
      canvas,
      Offset(
        center.dx + outerR * math.cos(angle1),
        center.dy + outerR * math.sin(angle1),
      ),
      PawCoColors.lilacGlow,
      5.0,
    );
    _drawGlowingNode(
      canvas,
      Offset(
        center.dx + outerR * math.cos(angle2),
        center.dy + outerR * math.sin(angle2),
      ),
      PawCoColors.amberGlow,
      4.2,
    );
    _drawGlowingNode(
      canvas,
      Offset(
        center.dx + innerR * math.cos(angle3),
        center.dy + innerR * math.sin(angle3),
      ),
      PawCoColors.malva,
      5.2,
    );
  }

  void _drawGlowingNode(Canvas canvas, Offset pos, Color color, double r) {
    canvas.drawCircle(
      pos,
      r * 2.4,
      Paint()..color = color.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      pos,
      r,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ============================================================================
// 3. BOTONES ESTILO SAAS Y CATEGORÍAS CIRCULARES TIERNAS (PALETA VIOLETA 2)
// ============================================================================

/// Botón primario estilo SaaS con degradado Morado Mora -> Violeta -> Rosa Malva
class PawColPrimarySaaSButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showArrow;

  const PawColPrimarySaaSButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PawCoColors.plum,
            PawCoColors.plumVibrant,
            PawCoColors.malva,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: PawCoColors.malva.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 17, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario tipo píldora estilo SaaS con borde luminoso, efecto `.shimmer()`
/// y badge interno en degradado `100% REAL`.
class PawColRealBadgeButton extends StatelessWidget {
  final String label;
  final String badgeText;
  final VoidCallback onTap;

  const PawColRealBadgeButton({
    super.key,
    required this.label,
    this.badgeText = '100% REAL',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget innerBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PawCoColors.orchid, PawCoColors.malva],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        badgeText,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );

    if (!isRunningInFlutterTest) {
      innerBadge = innerBadge
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2400.ms,
            color: Colors.white.withValues(alpha: 0.48),
          );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: PawCoColors.malva.withValues(alpha: 0.65),
          width: 1.3,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 16, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                innerBadge,
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: PawCoColors.lilacGlow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular interactivo de categoría en Lila Algodón (`#D2C2E5`),
/// Rosa Malva (`#F9D8E6`) o Morado Mora activo (`#431E61`).
class PawColCircularCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool useMalvaTint;
  final VoidCallback onTap;

  const PawColCircularCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.useMalvaTint = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleBg = isSelected
        ? PawCoColors.plum
        : (useMalvaTint ? PawCoColors.softMalva : PawCoColors.cottonLilac);
    final iconColor = isSelected
        ? Colors.white
        : (useMalvaTint ? PawCoColors.terracottaDark : PawCoColors.plum);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? PawCoColors.malva
                      : Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? PawCoColors.plum : PawCoColors.sage)
                        .withValues(alpha: isSelected ? 0.26 : 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? PawCoColors.plum : PawCoColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. SILUETAS DE PERROS, GATOS Y HUELLAS (Fondos Marfil-Lila Pastel)
// ============================================================================

/// Dibuja siluetas orgánicas suaves de perros, gatos, huellas y aves en tono Lila Pastel.
class AnimalSilhouettesPainter extends CustomPainter {
  final Color silhouetteColor;
  final double opacity;

  const AnimalSilhouettesPainter({
    this.silhouetteColor = PawCoColors.silhouette,
    this.opacity = 0.26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = silhouetteColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final dog1Width = math.min(size.width * 0.36, 250.0);
    final dog1Height = dog1Width * 1.15;
    _drawSeatedDog(
      canvas,
      paint,
      Offset(size.width - dog1Width * 0.92, size.height * 0.08),
      dog1Width,
      dog1Height,
    );

    final cat1Width = math.min(size.width * 0.30, 200.0);
    final cat1Height = cat1Width * 1.25;
    _drawSeatedCat(
      canvas,
      paint,
      Offset(-cat1Width * 0.14, size.height * 0.72),
      cat1Width,
      cat1Height,
    );

    final dog2Width = math.min(size.width * 0.34, 230.0);
    final dog2Height = dog2Width * 0.78;
    _drawStandingDog(
      canvas,
      paint,
      Offset(size.width - dog2Width * 0.85, size.height * 0.78),
      dog2Width,
      dog2Height,
    );

    _drawPawPrint(canvas, paint, Offset(size.width * 0.12, size.height * 0.18), 30);
    _drawPawPrint(
      canvas,
      paint,
      Offset(size.width * 0.88, size.height * 0.36),
      26,
      rotation: 0.3,
    );
    _drawPawPrint(
      canvas,
      paint,
      Offset(size.width * 0.06, size.height * 0.60),
      26,
      rotation: -0.4,
    );
    _drawPawPrint(
      canvas,
      paint,
      Offset(size.width * 0.92, size.height * 0.64),
      28,
      rotation: 0.2,
    );
  }

  void _drawSeatedDog(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path()
      ..moveTo(w * 0.40, h * 0.92)
      ..cubicTo(w * 0.25, h * 0.90, w * 0.20, h * 0.76, w * 0.22, h * 0.62)
      ..cubicTo(w * 0.25, h * 0.45, w * 0.35, h * 0.32, w * 0.42, h * 0.24)
      ..cubicTo(w * 0.45, h * 0.16, w * 0.50, h * 0.08, w * 0.58, h * 0.05)
      ..cubicTo(w * 0.48, h * 0.09, w * 0.42, h * 0.20, w * 0.44, h * 0.32)
      ..cubicTo(w * 0.48, h * 0.36, w * 0.54, h * 0.30, w * 0.56, h * 0.20)
      ..cubicTo(w * 0.64, h * 0.06, w * 0.74, h * 0.10, w * 0.82, h * 0.15)
      ..cubicTo(w * 0.90, h * 0.17, w * 0.94, h * 0.22, w * 0.94, h * 0.26)
      ..cubicTo(w * 0.92, h * 0.30, w * 0.84, h * 0.32, w * 0.76, h * 0.32)
      ..cubicTo(w * 0.68, h * 0.36, w * 0.66, h * 0.46, w * 0.74, h * 0.56)
      ..cubicTo(w * 0.80, h * 0.65, w * 0.78, h * 0.76, w * 0.76, h * 0.85)
      ..cubicTo(w * 0.74, h * 0.92, w * 0.70, h * 0.96, w * 0.64, h * 0.96)
      ..cubicTo(w * 0.58, h * 0.96, w * 0.56, h * 0.88, w * 0.56, h * 0.80)
      ..cubicTo(w * 0.50, h * 0.82, w * 0.46, h * 0.88, w * 0.40, h * 0.92)
      ..close();

    final tail = Path()
      ..moveTo(w * 0.24, h * 0.66)
      ..cubicTo(w * 0.10, h * 0.62, w * 0.04, h * 0.46, w * 0.02, h * 0.36)
      ..cubicTo(w * 0.06, h * 0.34, w * 0.12, h * 0.44, w * 0.22, h * 0.60)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawSeatedCat(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path()
      ..moveTo(w * 0.48, h * 0.94)
      ..cubicTo(w * 0.34, h * 0.94, w * 0.26, h * 0.82, w * 0.26, h * 0.68)
      ..cubicTo(w * 0.26, h * 0.50, w * 0.34, h * 0.35, w * 0.38, h * 0.24)
      ..cubicTo(w * 0.40, h * 0.18, w * 0.42, h * 0.14, w * 0.44, h * 0.10)
      ..lineTo(w * 0.45, h * 0.02)
      ..lineTo(w * 0.54, h * 0.10)
      ..cubicTo(w * 0.56, h * 0.10, w * 0.60, h * 0.10, w * 0.62, h * 0.10)
      ..lineTo(w * 0.70, h * 0.03)
      ..lineTo(w * 0.72, h * 0.12)
      ..cubicTo(w * 0.78, h * 0.18, w * 0.76, h * 0.24, w * 0.72, h * 0.28)
      ..cubicTo(w * 0.65, h * 0.36, w * 0.64, h * 0.48, w * 0.64, h * 0.62)
      ..cubicTo(w * 0.64, h * 0.78, w * 0.66, h * 0.90, w * 0.62, h * 0.94)
      ..cubicTo(w * 0.56, h * 0.96, w * 0.50, h * 0.96, w * 0.48, h * 0.94)
      ..close();

    final tail = Path()
      ..moveTo(w * 0.28, h * 0.72)
      ..cubicTo(w * 0.12, h * 0.76, w * 0.08, h * 0.64, w * 0.08, h * 0.54)
      ..cubicTo(w * 0.14, h * 0.52, w * 0.16, h * 0.64, w * 0.26, h * 0.68)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawStandingDog(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path()
      ..moveTo(w * 0.18, h * 0.88)
      ..lineTo(w * 0.24, h * 0.88)
      ..cubicTo(w * 0.26, h * 0.65, w * 0.32, h * 0.55, w * 0.42, h * 0.55)
      ..cubicTo(w * 0.55, h * 0.55, w * 0.65, h * 0.62, w * 0.68, h * 0.88)
      ..lineTo(w * 0.74, h * 0.88)
      ..cubicTo(w * 0.76, h * 0.58, w * 0.82, h * 0.50, w * 0.86, h * 0.42)
      ..cubicTo(w * 0.90, h * 0.30, w * 0.96, h * 0.22, w * 0.98, h * 0.18)
      ..cubicTo(w * 0.95, h * 0.12, w * 0.88, h * 0.12, w * 0.80, h * 0.18)
      ..cubicTo(w * 0.74, h * 0.14, w * 0.68, h * 0.16, w * 0.68, h * 0.26)
      ..cubicTo(w * 0.58, h * 0.30, w * 0.38, h * 0.30, w * 0.24, h * 0.36)
      ..cubicTo(w * 0.16, h * 0.28, w * 0.08, h * 0.14, w * 0.06, h * 0.12)
      ..cubicTo(w * 0.04, h * 0.14, w * 0.10, h * 0.28, w * 0.14, h * 0.42)
      ..cubicTo(w * 0.14, h * 0.55, w * 0.12, h * 0.72, w * 0.18, h * 0.88)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawPawPrint(Canvas canvas, Paint paint, Offset center, double size,
      {double rotation = 0.0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0) canvas.rotate(rotation);

    final r = size / 2;
    final mainPad = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, r * 0.25), width: r * 1.25, height: r * 0.95),
          Radius.circular(r * 0.42),
        ),
      );
    canvas.drawPath(mainPad, paint);

    final toeRadiusX = r * 0.24;
    final toeRadiusY = r * 0.32;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r * 0.55, -r * 0.18), width: toeRadiusX * 2, height: toeRadiusY * 2),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r * 0.20, -r * 0.45), width: toeRadiusX * 2, height: toeRadiusY * 2),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r * 0.20, -r * 0.45), width: toeRadiusX * 2, height: toeRadiusY * 2),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r * 0.55, -r * 0.18), width: toeRadiusX * 2, height: toeRadiusY * 2),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimalSilhouettesPainter oldDelegate) {
    return oldDelegate.silhouetteColor != silhouetteColor || oldDelegate.opacity != opacity;
  }
}

/// Fondo Marfil-Lila Pastel (`#FAF6F9`) con siluetas orgánicas de animales.
class AnimalSilhouetteBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color silhouetteColor;
  final double opacity;

  const AnimalSilhouetteBackground({
    super.key,
    required this.child,
    this.backgroundColor = PawCoColors.background,
    this.silhouetteColor = PawCoColors.silhouette,
    this.opacity = 0.26,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: AnimalSilhouettesPainter(
                  silhouetteColor: silhouetteColor,
                  opacity: opacity,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Marca de agua con siluetas de perro y gato para tarjetas.
class AnimalSilhouetteCardWatermark extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double opacity;

  const AnimalSilhouetteCardWatermark({
    super.key,
    this.width = 160,
    this.height = 110,
    this.color = PawCoColors.silhouette,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: AnimalSilhouettesPainter(
          silhouetteColor: color,
          opacity: opacity,
        ),
      ),
    );
  }
}

/// Ilustración vectorial de rescatista con perro y gato renderizada con `flutter_svg`.
class DogCatHeroIllustration extends StatelessWidget {
  final double width;
  final double height;

  const DogCatHeroIllustration({
    super.key,
    this.width = 165,
    this.height = 135,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        'assets/vectors/pawcol_rescuer_pets.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ============================================================================
// 5. ANIMACIONES DECLARATIVAS Y COMPONENTES REUTILIZABLES (100% Test-Safe)
// ============================================================================

/// Animación declarativa a 60fps usando `flutter_animate` (fadeIn + slideY).
class PawCoFadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double verticalOffset;
  final Curve curve;

  const PawCoFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.delay = Duration.zero,
    this.verticalOffset = 12.0,
    this.curve = Curves.easeOutQuart,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .moveY(begin: verticalOffset, end: 0, duration: duration, curve: curve);
  }
}

/// Tarjeta interactiva en Blanco Puro (`#FFFFFF`) con borde Lila (`#E5DDF0`) y elevación suave.
class PawCoHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const PawCoHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = PawCoColors.surface,
    this.borderColor = PawCoColors.border,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(18.0),
    this.margin = const EdgeInsets.symmetric(vertical: 6.0),
  });

  @override
  State<PawCoHoverCard> createState() => _PawCoHoverCardState();
}

class _PawCoHoverCardState extends State<PawCoHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBorder = _isHovered
        ? PawCoColors.malva.withValues(alpha: 0.45)
        : widget.borderColor;
    final translateY = _isHovered ? -2.5 : 0.0;
    final shadowElevation = _isHovered ? 7.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutQuart,
        margin: widget.margin,
        transform: Matrix4.translationValues(0, translateY, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: activeBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: PawCoColors.plum.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: shadowElevation * 3.0,
              offset: Offset(0, shadowElevation),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: PawCoColors.cottonLilac.withValues(alpha: 0.35),
            highlightColor: PawCoColors.sageMuted,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso animada en Rosa Malva / Morado Mora
class PawCoAnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color progressColor;
  final Color backgroundColor;
  final double height;
  final Duration duration;

  const PawCoAnimatedProgressBar({
    super.key,
    required this.value,
    this.progressColor = PawCoColors.malva,
    this.backgroundColor = PawCoColors.sageLight,
    this.height = 8.5,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: clampedValue),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: animValue,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              backgroundColor: backgroundColor,
            ),
          ),
        );
      },
    );
  }
}

/// Contenedor con borde punteado suave en Lila/Malva para subida de evidencia
class PawCoDashedBox extends StatelessWidget {
  final Widget child;
  final Color strokeColor;
  final Color backgroundColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final VoidCallback? onTap;

  const PawCoDashedBox({
    super.key,
    required this.child,
    this.strokeColor = PawCoColors.sage,
    this.backgroundColor = PawCoColors.sageMuted,
    this.borderRadius = 18.0,
    this.strokeWidth = 1.4,
    this.dashLength = 6.0,
    this.dashGap = 4.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            strokeColor: strokeColor,
            borderRadius: borderRadius,
            strokeWidth: strokeWidth,
            dashLength: dashLength,
            dashGap: dashGap,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color strokeColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DashedBorderPainter({
    required this.strokeColor,
    required this.borderRadius,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Grid inteligente adaptable a cualquier ancho (`320px` a `1920px+`)
class PawCoResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double maxWidth;

  const PawCoResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.maxWidth = 1220.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int columns = 1;
            if (width >= 1150) {
              columns = 4;
            } else if (width >= 860) {
              columns = 3;
            } else if (width >= 540) {
              columns = 2;
            }

            final itemWidth = math.max(0.0, (width - (spacing * (columns - 1))) / columns);

            return Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: children.map((child) {
                return SizedBox(
                  width: itemWidth,
                  child: child,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// Píldora o badge semántico adaptable sin overflow en pantallas pequeñas (`320px`)
class PawCoBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const PawCoBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = PawCoColors.sageLight,
    this.textColor = PawCoColors.plum,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
