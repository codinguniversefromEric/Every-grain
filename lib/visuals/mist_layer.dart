import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class MistLayer extends StatefulWidget {
  const MistLayer({super.key});

  @override
  State<MistLayer> createState() => _MistLayerState();
}

class _MistLayerState extends State<MistLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
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
          painter: _MistPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MistPainter extends CustomPainter {
  final double progress;
  _MistPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Draw several wide, soft blobs drifting right
    for (int i = 0; i < 3; i++) {
      double speed = 0.5 + i * 0.2;
      double xOffset = ((progress * speed + (i * 0.33)) % 1.0) * (size.width + 400) - 200;
      double yWobble = sin(progress * pi * 2 + i) * 20;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(xOffset, size.height * 0.75 + yWobble),
          width: size.width * 0.8,
          height: 150,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

