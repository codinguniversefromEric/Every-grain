import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShootingStarLayer extends StatefulWidget {
  const ShootingStarLayer({super.key});

  @override
  State<ShootingStarLayer> createState() => _ShootingStarLayerState();
}

class _ShootingStarLayerState extends State<ShootingStarLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _Star? _currentStar;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_updateStars);
  }

  void _updateStars() {
    if (_currentStar == null && _rng.nextDouble() < 0.005) {
      // very rare
      _currentStar = _Star(
        startX: 0.2 + _rng.nextDouble() * 0.8,
        startY: 0.05 + _rng.nextDouble() * 0.2,
        length: 100 + _rng.nextDouble() * 100,
        angle: pi + pi / 4 + (_rng.nextDouble() * pi / 8), // down and left
        startTime: DateTime.now(),
      );
    }

    if (_currentStar != null) {
      final elapsed = DateTime.now()
          .difference(_currentStar!.startTime)
          .inMilliseconds;
      if (elapsed > 800) {
        // fades fast
        _currentStar = null;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShootingStarPainter(_currentStar),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  final double startX;
  final double startY;
  final double length;
  final double angle;
  final DateTime startTime;
  _Star({
    required this.startX,
    required this.startY,
    required this.length,
    required this.angle,
    required this.startTime,
  });
}

class _ShootingStarPainter extends CustomPainter {
  final _Star? star;
  _ShootingStarPainter(this.star);

  @override
  void paint(Canvas canvas, Size size) {
    if (star == null) return;

    final elapsed =
        DateTime.now().difference(star!.startTime).inMilliseconds / 800.0;
    if (elapsed > 1.0) return;

    // Head of the star moves fast
    double progress = Curves.easeOut.transform(elapsed);
    double headX =
        star!.startX * size.width + cos(star!.angle) * (progress * 500);
    double headY =
        star!.startY * size.height + sin(star!.angle) * (progress * 500);

    // Tail follows and fades
    double tailProgress = (elapsed - 0.2).clamp(0.0, 1.0);
    double tailX =
        star!.startX * size.width + cos(star!.angle) * (tailProgress * 500);
    double tailY =
        star!.startY * size.height + sin(star!.angle) * (tailProgress * 500);

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(headX, headY),
        Offset(tailX, tailY),
        [
          Colors.white.withValues(alpha: (1.0 - elapsed) * 0.8), // bright head
          Colors.white.withValues(alpha: 0.0), // faded tail
        ],
      )
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(headX, headY), Offset(tailX, tailY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
