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

// ============================================================
// 5. EGRET FLOCK — Slow moving birds in the distance
// ============================================================
class EgretFlockLayer extends StatefulWidget {
  const EgretFlockLayer({super.key});

  @override
  State<EgretFlockLayer> createState() => _EgretFlockLayerState();
}

class _EgretFlockLayerState extends State<EgretFlockLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
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
          painter: _EgretPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _EgretPainter extends CustomPainter {
  final double progress;
  _EgretPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Move from right to left
    double xBase = size.width + 100 - (progress * (size.width + 200));
    double yBase = size.height * 0.25 + sin(progress * pi * 4) * 20;

    // Draw a small flock (V formation)
    final offsets = [
      const Offset(0, 0),
      const Offset(20, -10),
      const Offset(15, 15),
      const Offset(40, -5),
      const Offset(35, 25),
    ];

    for (var i = 0; i < offsets.length; i++) {
      var offset = offsets[i];
      double x = xBase + offset.dx;
      double y = yBase + offset.dy;
      
      // Flap wings: sin wave based on progress + offset to desync them slightly
      double flap = sin(progress * pi * 80 + i); 
      
      Path path = Path();
      // left wing
      path.moveTo(x - 8, y - flap * 5);
      path.quadraticBezierTo(x - 4, y - flap * 2, x, y);
      // right wing
      path.quadraticBezierTo(x + 4, y - flap * 2, x + 8, y - flap * 5);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================
// 6. DRAGONFLIES — Fast darting insects
// ============================================================
class DragonflyLayer extends StatefulWidget {
  const DragonflyLayer({super.key});

  @override
  State<DragonflyLayer> createState() => _DragonflyLayerState();
}

class _DragonflyLayerState extends State<DragonflyLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
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
          painter: _DragonflyPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _DragonflyPainter extends CustomPainter {
  final double progress;
  _DragonflyPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.8)..strokeWidth = 2..style = PaintingStyle.stroke;
    final wingPaint = Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.fill;

    // 3 dragonflies
    for (int i = 0; i < 3; i++) {
      // Darting motion: sharp curves
      double t = (progress + i * 0.33) % 1.0;
      double smoothT = Curves.easeInOutCubic.transform(t);
      
      double x = size.width * (0.2 + 0.6 * sin(smoothT * pi * 4 + i));
      double y = size.height * (0.55 + 0.25 * cos(smoothT * pi * 6 + i));
      
      // fast wing blur
      double flap = sin(progress * pi * 200);

      canvas.save();
      canvas.translate(x, y);
      // angle based on movement direction roughly
      canvas.rotate(sin(smoothT * pi * 4) * 0.5);

      // Body (thin line)
      canvas.drawLine(const Offset(-4, 0), const Offset(4, 0), bodyPaint);
      
      // Wings (blurred ovals)
      canvas.drawOval(Rect.fromCenter(center: Offset(0, -2 - flap), width: 8, height: 3), wingPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, 2 + flap), width: 8, height: 3), wingPaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================
// 7. WATER RIPPLES — Occasional splashes in the flooded paddy
// ============================================================
class WaterRippleLayer extends StatefulWidget {
  const WaterRippleLayer({super.key});

  @override
  State<WaterRippleLayer> createState() => _WaterRippleLayerState();
}

class _WaterRippleLayerState extends State<WaterRippleLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Ripple> _ripples = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _controller.addListener(_updateRipples);
  }

  void _updateRipples() {
    // occasionally spawn a ripple
    if (_rng.nextDouble() < 0.015 && _ripples.length < 4) {
      _ripples.add(_Ripple(
        x: 0.1 + _rng.nextDouble() * 0.8,
        y: 0.7 + _rng.nextDouble() * 0.25,
        startTime: DateTime.now(),
      ));
    }
    
    // remove old ripples
    final now = DateTime.now();
    _ripples.removeWhere((r) => now.difference(r.startTime).inSeconds > 3);
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
          painter: _RipplePainter(_ripples),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Ripple {
  final double x;
  final double y;
  final DateTime startTime;
  _Ripple({required this.x, required this.y, required this.startTime});
}

class _RipplePainter extends CustomPainter {
  final List<_Ripple> ripples;
  _RipplePainter(this.ripples);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    
    for (var r in ripples) {
      final elapsed = now.difference(r.startTime).inMilliseconds / 1000.0; // 0 to 3 seconds
      if (elapsed > 3.0) continue;
      
      final progress = elapsed / 3.0; // 0.0 to 1.0
      
      final radius = progress * 40;
      final opacity = (1.0 - progress) * 0.4;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      canvas.save();
      // scale Y to make ripples oval (perspective)
      canvas.translate(r.x * size.width, r.y * size.height);
      canvas.scale(1.0, 0.3);
      canvas.drawCircle(Offset.zero, radius, paint);
      // inner ripple
      if (progress > 0.2) {
        canvas.drawCircle(Offset.zero, (progress - 0.2) * 40, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
