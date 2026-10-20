import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

// ============================================================================
// 1. SILUETAS DE PERROS, GATOS Y HUELLAS (CustomPainter & Backgrounds)
// ============================================================================

/// Dibuja con precisión vectorial siluetas artísticas de perros, gatos, huellas y aves.
/// Diseñado para dar la estética editorial cálida del refugio animalista.
class AnimalSilhouettesPainter extends CustomPainter {
  final Color silhouetteColor;
  final double opacity;

  const AnimalSilhouettesPainter({
    this.silhouetteColor = PawCoColors.silhouette,
    this.opacity = 0.42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = silhouetteColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // --- 1. Perro grande sentado de perfil (Golden / Retriever) en la esquina superior derecha ---
    final dog1Width = math.min(size.width * 0.38, 260.0);
    final dog1Height = dog1Width * 1.15;
    final dog1X = size.width - dog1Width * 0.92;
    final dog1Y = size.height * 0.04;
    _drawSeatedDog(canvas, paint, Offset(dog1X, dog1Y), dog1Width, dog1Height);

    // --- 2. Gato sentado con cola curva en la esquina inferior izquierda ---
    final cat1Width = math.min(size.width * 0.32, 210.0);
    final cat1Height = cat1Width * 1.25;
    final cat1X = -cat1Width * 0.15;
    final cat1Y = size.height * 0.72;
    _drawSeatedCat(canvas, paint, Offset(cat1X, cat1Y), cat1Width, cat1Height);

    // --- 3. Perro caminando / de pie en el lateral derecho inferior ---
    final dog2Width = math.min(size.width * 0.35, 240.0);
    final dog2Height = dog2Width * 0.78;
    final dog2X = size.width - dog2Width * 0.85;
    final dog2Y = size.height * 0.78;
    _drawStandingDog(canvas, paint, Offset(dog2X, dog2Y), dog2Width, dog2Height);

    // --- 4. Gato estirándose / jugando en el lateral izquierdo medio ---
    final cat2Width = math.min(size.width * 0.28, 180.0);
    final cat2Height = cat2Width * 0.75;
    final cat2X = -cat2Width * 0.08;
    final cat2Y = size.height * 0.38;
    _drawStretchingCat(canvas, paint, Offset(cat2X, cat2Y), cat2Width, cat2Height);

    // --- 5. Huellitas orgánicas dispersas con sutileza ---
    _drawPawPrint(canvas, paint, Offset(size.width * 0.12, size.height * 0.14), 32);
    _drawPawPrint(canvas, paint, Offset(size.width * 0.88, size.height * 0.32), 26, rotation: 0.3);
    _drawPawPrint(canvas, paint, Offset(size.width * 0.06, size.height * 0.62), 28, rotation: -0.4);
    _drawPawPrint(canvas, paint, Offset(size.width * 0.92, size.height * 0.64), 30, rotation: 0.2);
    _drawPawPrint(canvas, paint, Offset(size.width * 0.28, size.height * 0.92), 24, rotation: 0.5);

    // --- 6. Pequeñas aves en vuelo en lo alto ---
    _drawFlyingBird(canvas, paint, Offset(size.width * 0.74, size.height * 0.08), 26);
    _drawFlyingBird(canvas, paint, Offset(size.width * 0.86, size.height * 0.16), 20);
  }

  void _drawSeatedDog(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path();
    // Silueta de perro retriever sentado en perfil mirando a la izquierda
    path.moveTo(w * 0.40, h * 0.92);
    // Patas traseras y anca
    path.cubicTo(w * 0.25, h * 0.90, w * 0.20, h * 0.76, w * 0.22, h * 0.62);
    // Espalda curvada elegante
    path.cubicTo(w * 0.25, h * 0.45, w * 0.35, h * 0.32, w * 0.42, h * 0.24);
    // Nuca hacia la cabeza
    path.cubicTo(w * 0.45, h * 0.16, w * 0.50, h * 0.08, w * 0.58, h * 0.05);
    // Oreja caída de Golden
    path.cubicTo(w * 0.48, h * 0.09, w * 0.42, h * 0.20, w * 0.44, h * 0.32);
    path.cubicTo(w * 0.48, h * 0.36, w * 0.54, h * 0.30, w * 0.56, h * 0.20);
    // Frente y hocico
    path.cubicTo(w * 0.64, h * 0.06, w * 0.74, h * 0.10, w * 0.82, h * 0.15);
    // Trufa / Nariz
    path.cubicTo(w * 0.90, h * 0.17, w * 0.94, h * 0.22, w * 0.94, h * 0.26);
    // Mandíbula y labio
    path.cubicTo(w * 0.92, h * 0.30, w * 0.84, h * 0.32, w * 0.76, h * 0.32);
    // Garganta y pecho prominente
    path.cubicTo(w * 0.68, h * 0.36, w * 0.66, h * 0.46, w * 0.74, h * 0.56);
    path.cubicTo(w * 0.80, h * 0.65, w * 0.78, h * 0.76, w * 0.76, h * 0.85);
    // Pata delantera
    path.cubicTo(w * 0.74, h * 0.92, w * 0.70, h * 0.96, w * 0.64, h * 0.96);
    path.cubicTo(w * 0.58, h * 0.96, w * 0.56, h * 0.88, w * 0.56, h * 0.80);
    // Vientre hacia patas traseras
    path.cubicTo(w * 0.50, h * 0.82, w * 0.46, h * 0.88, w * 0.40, h * 0.92);
    path.close();

    // Cola alegre curvada hacia arriba
    final tail = Path();
    tail.moveTo(w * 0.24, h * 0.66);
    tail.cubicTo(w * 0.10, h * 0.62, w * 0.04, h * 0.46, w * 0.02, h * 0.36);
    tail.cubicTo(w * 0.06, h * 0.34, w * 0.12, h * 0.44, w * 0.22, h * 0.60);
    tail.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawSeatedCat(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path();
    // Gato estilizado sentado con orejas puntiagudas
    path.moveTo(w * 0.48, h * 0.94);
    // Anca trasera redondeada
    path.cubicTo(w * 0.34, h * 0.94, w * 0.26, h * 0.82, w * 0.26, h * 0.68);
    // Espalda delgada y curvada
    path.cubicTo(w * 0.26, h * 0.50, w * 0.34, h * 0.35, w * 0.38, h * 0.24);
    // Cuello
    path.cubicTo(w * 0.40, h * 0.18, w * 0.42, h * 0.14, w * 0.44, h * 0.10);
    // Oreja izquierda puntiaguda
    path.lineTo(w * 0.45, h * 0.02);
    path.lineTo(w * 0.54, h * 0.10);
    // Corona de la cabeza
    path.cubicTo(w * 0.56, h * 0.10, w * 0.60, h * 0.10, w * 0.62, h * 0.10);
    // Oreja derecha puntiaguda
    path.lineTo(w * 0.70, h * 0.03);
    path.lineTo(w * 0.72, h * 0.12);
    // Mejilla y hocico felino
    path.cubicTo(w * 0.78, h * 0.18, w * 0.76, h * 0.24, w * 0.72, h * 0.28);
    // Pecho estilizado
    path.cubicTo(w * 0.65, h * 0.36, w * 0.64, h * 0.48, w * 0.64, h * 0.62);
    // Patas delanteras juntas
    path.cubicTo(w * 0.64, h * 0.78, w * 0.66, h * 0.90, w * 0.62, h * 0.94);
    path.cubicTo(w * 0.56, h * 0.96, w * 0.50, h * 0.96, w * 0.48, h * 0.94);
    path.close();

    // Cola larga y elegante rodeando el cuerpo
    final tail = Path();
    tail.moveTo(w * 0.28, h * 0.72);
    tail.cubicTo(w * 0.12, h * 0.76, w * 0.08, h * 0.64, w * 0.08, h * 0.54);
    tail.cubicTo(w * 0.14, h * 0.52, w * 0.16, h * 0.64, w * 0.26, h * 0.68);
    tail.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawStandingDog(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path();
    // Silueta de perro caminando/de pie
    path.moveTo(w * 0.18, h * 0.88); // Pata trasera
    path.lineTo(w * 0.24, h * 0.88);
    path.cubicTo(w * 0.26, h * 0.65, w * 0.32, h * 0.55, w * 0.42, h * 0.55); // Vientre
    path.cubicTo(w * 0.55, h * 0.55, w * 0.65, h * 0.62, w * 0.68, h * 0.88); // Pata delantera
    path.lineTo(w * 0.74, h * 0.88);
    path.cubicTo(w * 0.76, h * 0.58, w * 0.82, h * 0.50, w * 0.86, h * 0.42); // Pecho
    path.cubicTo(w * 0.90, h * 0.30, w * 0.96, h * 0.22, w * 0.98, h * 0.18); // Cabeza / hocico
    path.cubicTo(w * 0.95, h * 0.12, w * 0.88, h * 0.12, w * 0.80, h * 0.18);
    // Oreja
    path.cubicTo(w * 0.74, h * 0.14, w * 0.68, h * 0.16, w * 0.68, h * 0.26);
    // Espalda recta
    path.cubicTo(w * 0.58, h * 0.30, w * 0.38, h * 0.30, w * 0.24, h * 0.36);
    // Cola hacia arriba
    path.cubicTo(w * 0.16, h * 0.28, w * 0.08, h * 0.14, w * 0.06, h * 0.12);
    path.cubicTo(w * 0.04, h * 0.14, w * 0.10, h * 0.28, w * 0.14, h * 0.42);
    // Anca trasera
    path.cubicTo(w * 0.14, h * 0.55, w * 0.12, h * 0.72, w * 0.18, h * 0.88);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawStretchingCat(Canvas canvas, Paint paint, Offset offset, double w, double h) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final path = Path();
    // Gato estirando las patas delanteras hacia abajo
    path.moveTo(w * 0.86, h * 0.84); // Patas delanteras estiradas
    path.cubicTo(w * 0.78, h * 0.84, w * 0.68, h * 0.72, w * 0.62, h * 0.65); // Cabeza baja
    // Orejas
    path.lineTo(w * 0.66, h * 0.52);
    path.lineTo(w * 0.60, h * 0.56);
    // Lomo arqueado en bajada
    path.cubicTo(w * 0.50, h * 0.62, w * 0.38, h * 0.44, w * 0.28, h * 0.36); // Cadera levantada
    // Cola en S
    path.cubicTo(w * 0.20, h * 0.25, w * 0.12, h * 0.12, w * 0.06, h * 0.16);
    path.cubicTo(w * 0.10, h * 0.24, w * 0.18, h * 0.34, w * 0.24, h * 0.42);
    // Patas traseras
    path.cubicTo(w * 0.20, h * 0.55, w * 0.22, h * 0.76, w * 0.26, h * 0.84);
    path.lineTo(w * 0.32, h * 0.84);
    path.cubicTo(w * 0.36, h * 0.68, w * 0.52, h * 0.72, w * 0.86, h * 0.84);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawPawPrint(Canvas canvas, Paint paint, Offset center, double size, {double rotation = 0.0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0) canvas.rotate(rotation);

    final r = size / 2;

    // Almohadilla principal (forma de corazón invertido / redondeada)
    final mainPad = Path();
    mainPad.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, r * 0.25), width: r * 1.25, height: r * 0.95),
      Radius.circular(r * 0.42),
    ));
    canvas.drawPath(mainPad, paint);

    // 4 Dedos / almohadillas de garras (elipses)
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

  void _drawFlyingBird(Canvas canvas, Paint paint, Offset pos, double size) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final path = Path();
    // Ala izquierda y ala derecha con cuerpo central sutil
    path.moveTo(-size * 0.5, size * 0.2);
    path.quadraticBezierTo(-size * 0.25, -size * 0.3, 0, 0);
    path.quadraticBezierTo(size * 0.25, -size * 0.3, size * 0.5, size * 0.2);
    path.quadraticBezierTo(size * 0.2, -size * 0.1, 0, size * 0.1);
    path.quadraticBezierTo(-size * 0.2, -size * 0.1, -size * 0.5, size * 0.2);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimalSilhouettesPainter oldDelegate) {
    return oldDelegate.silhouetteColor != silhouetteColor || oldDelegate.opacity != opacity;
  }
}

/// Widget que envuelve cualquier vista con el fondo editorial avena y las siluetas reconocibles de animales.
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
    this.opacity = 0.42,
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

/// Marca de agua con siluetas de perro y gato para poner dentro de cards o banners
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

// ============================================================================
// 2. ILUSTRACIÓN HERO DE RESCATISTA CON PERRO Y GATO (Vectorial / Mockup 1)
// ============================================================================

/// Ilustración vectorial limpia y estilizada para el banner Hero:
/// Muestra un rescatista de pie junto a su perrito sentado felizmente.
class DogCatHeroIllustration extends StatelessWidget {
  final double width;
  final double height;

  const DogCatHeroIllustration({
    super.key,
    this.width = 140,
    this.height = 115,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _RescuerWithPetPainter(),
      ),
    );
  }
}

class _RescuerWithPetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF2C3E2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final skinPaint = Paint()
      ..color = const Color(0xFFF9DEC9)
      ..style = PaintingStyle.fill;

    final shirtPaint = Paint()
      ..color = const Color(0xFFE2EFE0)
      ..style = PaintingStyle.fill;

    final hairPaint = Paint()
      ..color = const Color(0xFF7A6B5D)
      ..style = PaintingStyle.fill;

    final dogPaint = Paint()
      ..color = const Color(0xFFF7ECD5)
      ..style = PaintingStyle.fill;

    final dogCollarPaint = Paint()
      ..color = const Color(0xFFD87A61)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // --- Suelo base sutil ---
    canvas.drawLine(Offset(w * 0.05, h * 0.94), Offset(w * 0.95, h * 0.94), strokePaint);

    // --- Perro sentado a la izquierda del rescatista ---
    final dogPath = Path();
    dogPath.moveTo(w * 0.16, h * 0.94);
    dogPath.cubicTo(w * 0.08, h * 0.92, w * 0.06, h * 0.75, w * 0.10, h * 0.65); // Cola y anca
    dogPath.cubicTo(w * 0.12, h * 0.52, w * 0.16, h * 0.44, w * 0.22, h * 0.40); // Lomo
    dogPath.cubicTo(w * 0.24, h * 0.32, w * 0.30, h * 0.28, w * 0.38, h * 0.28); // Cabeza
    dogPath.cubicTo(w * 0.45, h * 0.30, w * 0.50, h * 0.34, w * 0.50, h * 0.38); // Hocico
    dogPath.cubicTo(w * 0.46, h * 0.44, w * 0.38, h * 0.46, w * 0.36, h * 0.50); // Cuello
    dogPath.cubicTo(w * 0.40, h * 0.64, w * 0.40, h * 0.78, w * 0.38, h * 0.94); // Pecho y pata
    dogPath.close();

    canvas.drawPath(dogPath, dogPaint);
    canvas.drawPath(dogPath, strokePaint);

    // Oreja del perro (caída)
    final dogEar = Path();
    dogEar.moveTo(w * 0.24, h * 0.34);
    dogEar.cubicTo(w * 0.20, h * 0.42, w * 0.22, h * 0.54, w * 0.28, h * 0.50);
    dogEar.close();
    canvas.drawPath(dogEar, dogPaint);
    canvas.drawPath(dogEar, strokePaint);

    // Collar del perro
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.48, w * 0.08, h * 0.04), dogCollarPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.48, w * 0.08, h * 0.04), strokePaint);

    // Ojo y nariz del perro
    canvas.drawCircle(Offset(w * 0.38, h * 0.34), 1.5, strokePaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.36), 2.2, strokePaint);

    // --- Rescatista de pie a la derecha ---
    final rescuerCenterX = w * 0.74;

    // Cuerpo / Camisa
    final shirtPath = Path();
    shirtPath.moveTo(rescuerCenterX - w * 0.16, h * 0.94);
    shirtPath.lineTo(rescuerCenterX - w * 0.14, h * 0.48); // Hombro izq
    shirtPath.lineTo(rescuerCenterX - w * 0.06, h * 0.44); // Cuello izq
    shirtPath.lineTo(rescuerCenterX + w * 0.06, h * 0.44); // Cuello der
    shirtPath.lineTo(rescuerCenterX + w * 0.14, h * 0.48); // Hombro der
    shirtPath.lineTo(rescuerCenterX + w * 0.16, h * 0.94); // Base
    shirtPath.close();

    canvas.drawPath(shirtPath, shirtPaint);
    canvas.drawPath(shirtPath, strokePaint);

    // Cuello de la persona
    canvas.drawRect(Rect.fromLTWH(rescuerCenterX - w * 0.04, h * 0.36, w * 0.08, h * 0.09), skinPaint);
    canvas.drawRect(Rect.fromLTWH(rescuerCenterX - w * 0.04, h * 0.36, w * 0.08, h * 0.09), strokePaint);

    // Cabeza
    canvas.drawOval(
      Rect.fromCenter(center: Offset(rescuerCenterX, h * 0.26), width: w * 0.18, height: h * 0.24),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(rescuerCenterX, h * 0.26), width: w * 0.18, height: h * 0.24),
      strokePaint,
    );

    // Cabello estilizado
    final hairPath = Path();
    hairPath.moveTo(rescuerCenterX - w * 0.10, h * 0.26);
    hairPath.cubicTo(rescuerCenterX - w * 0.10, h * 0.14, rescuerCenterX + w * 0.10, h * 0.14, rescuerCenterX + w * 0.10, h * 0.26);
    hairPath.cubicTo(rescuerCenterX + w * 0.06, h * 0.20, rescuerCenterX - w * 0.06, h * 0.20, rescuerCenterX - w * 0.10, h * 0.26);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);
    canvas.drawPath(hairPath, strokePaint);

    // Credencial / Lanyard de voluntario
    canvas.drawLine(Offset(rescuerCenterX - w * 0.03, h * 0.44), Offset(rescuerCenterX, h * 0.60), strokePaint);
    canvas.drawLine(Offset(rescuerCenterX + w * 0.03, h * 0.44), Offset(rescuerCenterX, h * 0.60), strokePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rescuerCenterX - w * 0.03, h * 0.60, w * 0.06, h * 0.09), const Radius.circular(2)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rescuerCenterX - w * 0.03, h * 0.60, w * 0.06, h * 0.09), const Radius.circular(2)),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. ANIMACIONES Y COMPONENTES REUTILIZABLES (100% Test-Safe)
// ============================================================================

/// Animación suave de entrada (Fade + Slide vertical)
/// Implementada con [TweenAnimationBuilder] para evitar timers pendientes en tests
class PawCoFadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double verticalOffset;
  final Curve curve;

  const PawCoFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.verticalOffset = 18.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, animChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, verticalOffset * (1.0 - value)),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }
}

/// Tarjeta interactiva: en Web/Desktop reacciona al cursor con elevación y borde suave;
/// en Móvil proporciona feedback táctil limpio y bordes redondeados.
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
    final activeBorder = _isHovered ? PawCoColors.sage : widget.borderColor;
    final translateY = _isHovered ? -3.0 : 0.0;
    final shadowElevation = _isHovered ? 8.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        transform: Matrix4.translationValues(0, translateY, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: activeBorder, width: _isHovered ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.02),
              blurRadius: shadowElevation * 2,
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
            splashColor: PawCoColors.sageLight.withValues(alpha: 0.5),
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

/// Barra de progreso animada para metas de donación, campañas e impacto
class PawCoAnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final Color progressColor;
  final Color backgroundColor;
  final double height;
  final Duration duration;

  const PawCoAnimatedProgressBar({
    super.key,
    required this.value,
    this.progressColor = PawCoColors.forest,
    this.backgroundColor = PawCoColors.sageLight,
    this.height = 8.0,
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

/// Contenedor con borde punteado suave (Igual a "Photo or Video Upload" en Mockup 5)
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
    this.borderRadius = 16.0,
    this.strokeWidth = 1.4,
    this.dashLength = 6.0,
    this.dashGap = 4.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, nextDistance);
        canvas.drawPath(extract, paint);
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

/// Grid inteligente adaptable a cualquier ancho (1, 2, 3 o 4 columnas automáticamente)
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

            final itemWidth = (width - (spacing * (columns - 1))) / columns;

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

/// Badge o píldora de estado editorial
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
    this.textColor = PawCoColors.forest,
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
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
