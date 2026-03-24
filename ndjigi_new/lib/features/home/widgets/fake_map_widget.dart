// ============================================================
// FEATURES/HOME/WIDGETS/FAKE_MAP_WIDGET.DART
// Widget de carte simulée (style Google Maps personnalisé)
// Fond vert menthe + routes + marqueurs animés
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FakeMapWidget extends StatefulWidget {
  const FakeMapWidget({super.key});
  @override
  State<FakeMapWidget> createState() => _FakeMapWidgetState();
}

class _FakeMapWidgetState extends State<FakeMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _haloController;
  late Animation<double> _haloAnim;

  @override
  void initState() {
    super.initState();
    _haloController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _haloAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _haloController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _MapPainter(_haloAnim),
        child: AnimatedBuilder(
          animation: _haloAnim,
          builder: (_, __) => CustomPaint(painter: _MapPainter(_haloAnim)),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Animation<double> haloAnim;
  _MapPainter(this.haloAnim) : super(repaint: haloAnim);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ---- Fond vert menthe ----
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8F5ED));

    // ---- Blocs "zones" ----
    final blockPaint = Paint()..color = const Color(0xFFCCEBDA);
    for (final r in [
      Rect.fromLTWH(20, 80, 120, 80),
      Rect.fromLTWH(200, 60, 90, 60),
      Rect.fromLTWH(size.width - 140, 100, 120, 90),
      Rect.fromLTWH(30, size.height * 0.45, 100, 70),
      Rect.fromLTWH(size.width - 110, size.height * 0.5, 90, 80),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(4)), blockPaint);
    }

    // ---- Routes principales (blanc) ----
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Route horizontale principale
    canvas.drawLine(Offset(0, cy - 30), Offset(size.width, cy - 30), roadPaint);
    // Route verticale principale
    canvas.drawLine(
        Offset(cx + 40, 0), Offset(cx + 40, size.height), roadPaint);
    // Routes secondaires
    canvas.drawLine(
        Offset(0, cy + 60), Offset(size.width, cy + 60), thinRoadPaint);
    canvas.drawLine(
        Offset(cx - 80, 0), Offset(cx - 80, size.height), thinRoadPaint);
    canvas.drawLine(
        Offset(0, cy - 120), Offset(size.width * 0.6, cy - 120), thinRoadPaint);

    // ---- Marqueurs bleus (points d'intérêt) ----
    final blueMarkerPositions = [
      Offset(cx - 110, cy - 80),
      Offset(cx + 130, cy - 50),
      Offset(cx - 60, cy + 100),
      Offset(cx + 160, cy + 80),
      Offset(cx - 150, cy + 30),
    ];

    final bluePaint = Paint()..color = AppColors.markerBlue;
    for (final pos in blueMarkerPositions) {
      // Ombre
      canvas.drawCircle(
          pos + const Offset(1, 2),
          8,
          Paint()
            ..color = Colors.black.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      // Cercle blanc intérieur
      canvas.drawCircle(pos, 9, Paint()..color = Colors.white);
      // Point bleu
      canvas.drawCircle(pos, 6, bluePaint);
    }

    // ---- Marqueur vert central avec halo animé ----
    final centerPos = Offset(cx, cy - 30);
    final haloRadius = 20.0 + haloAnim.value * 18;
    final haloOpacity = (1.0 - haloAnim.value) * 0.35;

    // Halo externe animé
    canvas.drawCircle(centerPos, haloRadius,
        Paint()..color = AppColors.primary.withOpacity(haloOpacity));
    // Halo intermédiaire
    canvas.drawCircle(
        centerPos, 18, Paint()..color = AppColors.primary.withOpacity(0.2));
    // Contour blanc
    canvas.drawCircle(centerPos, 14, Paint()..color = Colors.white);
    // Point vert central
    canvas.drawCircle(centerPos, 10, Paint()..color = AppColors.primary);
    // Point blanc intérieur
    canvas.drawCircle(centerPos, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => true;
}
