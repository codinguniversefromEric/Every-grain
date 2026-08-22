import 'dart:math';
import 'package:flutter/material.dart';

class EgretFlockLayer extends StatefulWidget {
  const EgretFlockLayer({super.key});

  @override
  State<EgretFlockLayer> createState() => _EgretFlockLayerState();
}

class _EgretFlockLayerState extends State<EgretFlockLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
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
