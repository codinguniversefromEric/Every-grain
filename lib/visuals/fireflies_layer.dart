import 'dart:math';
import 'package:flutter/material.dart';

class FirefliesLayer extends StatefulWidget {
  const FirefliesLayer({super.key});
  @override
  State<FirefliesLayer> createState() => _FirefliesLayerState();
}

class _FirefliesLayerState extends State<FirefliesLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int count = 25;
  final Random _random = Random();
  late List<_Firefly> _fireflies;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _fireflies = List.generate(count, (_) => _Firefly(
      x: _random.nextDouble(),
      y: 0.3 + _random.nextDouble() * 0.6,
      phase: _random.nextDouble() * pi * 2,
      wanderSpeed: 0.3 + _random.nextDouble() * 0.7,
      wanderRadius: 15 + _random.nextDouble() * 30,
      pulseSpeed: 1.0 + _random.nextDouble() * 2.0,
      size: 1.5 + _random.nextDouble() * 2.0,
      glowRadius: 4 + _random.nextDouble() * 6,
    ));
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
          painter: _FireflyPainter(_fireflies, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Firefly {
  final double x;
  final double y;
  final double phase;
  final double wanderSpeed;
  final double wanderRadius;
  final double pulseSpeed;
  final double size;
  final double glowRadius;
  _Firefly({
    required this.x, required this.y, required this.phase,
    required this.wanderSpeed, required this.wanderRadius,
    required this.pulseSpeed, required this.size, required this.glowRadius,
  });
}

class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double animationValue;

  _FireflyPainter(this.fireflies, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var f in fireflies) {
      final time = animationValue * pi * 2;
      
      // Each firefly wanders in a lazy Lissajous path
      final wanderX = sin(time * f.wanderSpeed + f.phase) * f.wanderRadius;
      final wanderY = cos(time * f.wanderSpeed * 0.7 + f.phase * 1.3) * f.wanderRadius * 0.6;
      
      // Pulsing glow — not a simple sine, but more organic
      final pulse = (sin(time * f.pulseSpeed + f.phase) + 1) / 2;
      final brightness = pulse * pulse; // Quadratic for sharper on/off feel
      
      if (brightness < 0.1) continue; // Skip when nearly invisible
      
      final center = Offset(
        f.x * size.width + wanderX,
        f.y * size.height + wanderY,
      );

      // Outer glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: brightness * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, f.glowRadius);
      canvas.drawCircle(center, f.glowRadius, glowPaint);

      // Core dot
      final corePaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFEB3B),
          Colors.white,
          brightness * 0.5,
        )!.withValues(alpha: brightness * 0.9);
      canvas.drawCircle(center, f.size, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

