import 'dart:math';
import 'package:flutter/material.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
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
        xPos: 0.1 + _random.nextDouble() * 0.8,
        speed: 0.2 + _random.nextDouble() * 0.3,
        startPhase: _random.nextDouble(),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _memories.map((m) {
            double progress = (_controller.value + m.startPhase) % 1.0;
            double yPos = 1.2 - (progress * 1.5); 
            
            return Align(
              alignment: FractionalOffset(m.xPos, yPos),
              child: Opacity(
                opacity: sin(progress * pi), // Fade in and out curve
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    m.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
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

  _FloatingMemory({required this.text, required this.xPos, required this.speed, required this.startPhase});
}

// Ambient effects (Fireflies)
class FirefliesLayer extends StatefulWidget {
  const FirefliesLayer({super.key});
  @override
  State<FirefliesLayer> createState() => _FirefliesLayerState();
}

class _FirefliesLayerState extends State<FirefliesLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int count = 30;
  final Random _random = Random();
  late List<_Firefly> _fireflies;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _fireflies = List.generate(count, (_) => _Firefly(
      x: _random.nextDouble(),
      y: 0.5 + _random.nextDouble() * 0.5, 
      phase: _random.nextDouble() * pi * 2,
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
  _Firefly({required this.x, required this.y, required this.phase});
}

class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double animationValue;

  _FireflyPainter(this.fireflies, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (var f in fireflies) {
      double opacity = (sin(f.phase + animationValue * pi * 2) + 1) / 2;
      paint.color = Colors.yellowAccent.withValues(alpha: opacity * 0.9);
      canvas.drawCircle(
        Offset(f.x * size.width, f.y * size.height + sin(animationValue * pi * 2 + f.phase) * 15),
        2 + opacity * 2.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
