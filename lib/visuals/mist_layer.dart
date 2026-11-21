import 'dart:math';
import 'package:flutter/material.dart';

class MistLayer extends StatefulWidget {
  const MistLayer({super.key});

  @override
  State<MistLayer> createState() => _MistLayerState();
}

class _MistLayerState extends State<MistLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MistPainter(_controller), size: Size.infinite);
  }
}

class _MistPainter extends CustomPainter {
  final Animation<double> animation;
  _MistPainter(this.animation) : super(repaint: animation);

  static const _gradient = RadialGradient(
    colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint()
      ..shader = _gradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: 1),
      );

    // Draw several wide, soft blobs drifting right
    for (int i = 0; i < 3; i++) {
      double speed = 0.5 + i * 0.2;
      double xOffset =
          ((progress * speed + (i * 0.33)) % 1.0) * (size.width + 400) - 200;
      double yWobble = sin(progress * pi * 2 + i) * 20;

      canvas.save();
      canvas.translate(xOffset, size.height * 0.75 + yWobble);
      canvas.scale(size.width * 0.4, 85);
      canvas.drawCircle(Offset.zero, 1, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MistPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
