import 'dart:math';
import 'package:flutter/material.dart';

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

