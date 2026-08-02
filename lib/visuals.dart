import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================
// 1. LIVING SKY BACKGROUND — Gradient that breathes
// ============================================================
class LivingSkyBackground extends StatefulWidget {
  final Color topColor;
  final Color bottomColor;
  const LivingSkyBackground({super.key, required this.topColor, required this.bottomColor});

  @override
  State<LivingSkyBackground> createState() => _LivingSkyBackgroundState();
}

class _LivingSkyBackgroundState extends State<LivingSkyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        // The mid-stop breathes up and down
        final breathAmount = 0.3 + _breathController.value * 0.2;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.topColor,
                Color.lerp(widget.topColor, widget.bottomColor, breathAmount)!,
                widget.bottomColor,
              ],
              stops: [0.0, 0.5 + _breathController.value * 0.1, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// 2. DRIFTING CLOUDS — Lazy, floating shapes
// ============================================================
class CloudLayer extends StatefulWidget {
  final bool isNight;
  const CloudLayer({super.key, this.isNight = false});

  @override
  State<CloudLayer> createState() => _CloudLayerState();
}

class _CloudLayerState extends State<CloudLayer> with SingleTickerProviderStateMixin {
  late AnimationController _driftController;
  late List<_Cloud> _clouds;
  final Random _rng = Random(7);

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _clouds = List.generate(5, (i) => _Cloud(
      xStart: _rng.nextDouble() * 1.5 - 0.25,
      yPosition: 0.05 + _rng.nextDouble() * 0.25,
      speed: 0.15 + _rng.nextDouble() * 0.3,
      width: 80 + _rng.nextDouble() * 120,
      height: 25 + _rng.nextDouble() * 30,
      opacity: 0.15 + _rng.nextDouble() * 0.25,
    ));
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNight) return const SizedBox.shrink(); // No clouds at night

    return AnimatedBuilder(
      animation: _driftController,
      builder: (context, child) {
        return CustomPaint(
          painter: _CloudPainter(_clouds, _driftController.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Cloud {
  final double xStart;
  final double yPosition;
  final double speed;
  final double width;
  final double height;
  final double opacity;
  _Cloud({required this.xStart, required this.yPosition, required this.speed, required this.width, required this.height, required this.opacity});
}

class _CloudPainter extends CustomPainter {
  final List<_Cloud> clouds;
  final double time;
  _CloudPainter(this.clouds, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in clouds) {
      final xPos = ((c.xStart + time * c.speed) % 1.4) - 0.2; // Wraps around
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: c.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(xPos * size.width, c.yPosition * size.height),
          width: c.width,
          height: c.height,
        ),
        Radius.circular(c.height),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => true;
}


// ============================================================
// 4. FIREFLIES — Organic, pulsing, wandering
// ============================================================
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

