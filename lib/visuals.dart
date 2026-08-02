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
// 3. FLOATING MEMORIES — Organic, drifting wisps
// ============================================================
class FloatingMemoriesLayer extends StatefulWidget {
  final List<String> reflections;
  const FloatingMemoriesLayer({super.key, required this.reflections});

  @override
  State<FloatingMemoriesLayer> createState() => _FloatingMemoriesLayerState();
}

class _FloatingMemoriesLayerState extends State<FloatingMemoriesLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<_FloatingMemory> _memories;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _generateMemories();
  }

  @override
  void didUpdateWidget(FloatingMemoriesLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reflections.length != widget.reflections.length) {
      _generateMemories();
    }
  }

  void _generateMemories() {
    _memories = widget.reflections.map((text) {
      return _FloatingMemory(
        text: text,
        xPos: 0.05 + _random.nextDouble() * 0.9,
        speed: 0.15 + _random.nextDouble() * 0.25,
        startPhase: _random.nextDouble(),
        wobblePhase: _random.nextDouble() * pi * 2,
        wobbleAmount: 10 + _random.nextDouble() * 20,
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_memories.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _memories.map((m) {
            double progress = (_controller.value * m.speed + m.startPhase) % 1.0;
            double yPos = 1.1 - (progress * 1.4);
            // Horizontal wobble — drifting like smoke
            double xWobble = sin(_controller.value * pi * 2 + m.wobblePhase) * m.wobbleAmount;
            
            // Opacity follows a bell curve: fade in, hold, fade out
            double opacity;
            if (progress < 0.15) {
              opacity = progress / 0.15;
            } else if (progress > 0.85) {
              opacity = (1.0 - progress) / 0.15;
            } else {
              opacity = 1.0;
            }
            opacity *= 0.7; // Never fully opaque

            return Positioned(
              left: m.xPos * MediaQuery.of(context).size.width + xWobble - 60,
              top: yPos * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _FloatingMemory {
  final String text;
  final double xPos;
  final double speed;
  final double startPhase;
  final double wobblePhase;
  final double wobbleAmount;

  _FloatingMemory({
    required this.text,
    required this.xPos,
    required this.speed,
    required this.startPhase,
    required this.wobblePhase,
    required this.wobbleAmount,
  });
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
// 5. SINKING SEED ANIMATION — Organic falling seed
// ============================================================
class SinkingSeedAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  const SinkingSeedAnimation({super.key, required this.onComplete});

  @override
  State<SinkingSeedAnimation> createState() => _SinkingSeedAnimationState();
}

class _SinkingSeedAnimationState extends State<SinkingSeedAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
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
        final t = _controller.value;
        
        // The seed accelerates downward (ease-in curve)
        final fallProgress = Curves.easeIn.transform(t);
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Starts from bottom-third, falls to bottom
        final startY = screenHeight * 0.65;
        final endY = screenHeight * 0.95;
        final currentY = startY + (endY - startY) * fallProgress;
        
        // Wobble side to side as it falls
        final wobble = sin(t * pi * 4) * (1.0 - t) * 15;
        
        // Gentle spin
        final rotation = t * pi * 1.5;
        
        // Fade and shrink in last 30%
        final opacity = t > 0.7 ? (1.0 - t) / 0.3 : 1.0;
        final scale = t > 0.7 ? 1.0 - (t - 0.7) * 2.0 : 1.0;

        // Little mud splash particles at the end
        List<Widget> particles = [];
        if (t > 0.75) {
          final splashProgress = (t - 0.75) / 0.25;
          for (int i = 0; i < 5; i++) {
            final angle = (i / 5) * pi + pi; // Spread upward
            final dist = splashProgress * 20;
            final pOpacity = (1.0 - splashProgress).clamp(0.0, 1.0);
            particles.add(Positioned(
              left: MediaQuery.of(context).size.width / 2 + cos(angle) * dist + wobble - 3,
              top: endY + sin(angle) * dist - 3,
              child: Opacity(
                opacity: pOpacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ));
          }
        }
        
        return Stack(
          children: [
            ...particles,
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + wobble - 16,
              top: currentY - 16,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale.clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: rotation,
                    child: const Icon(
                      Icons.spa,
                      color: Color(0xFFD4AF37),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
