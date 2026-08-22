import 'dart:math';
import 'package:flutter/material.dart';

class WaterRippleLayer extends StatefulWidget {
  const WaterRippleLayer({super.key});

  @override
  State<WaterRippleLayer> createState() => _WaterRippleLayerState();
}

class _WaterRippleLayerState extends State<WaterRippleLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Ripple> _ripples = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _controller.addListener(_updateRipples);
  }

  void _updateRipples() {
    // occasionally spawn a ripple
    if (_rng.nextDouble() < 0.015 && _ripples.length < 4) {
      _ripples.add(
        _Ripple(
          x: 0.1 + _rng.nextDouble() * 0.8,
          y: 0.7 + _rng.nextDouble() * 0.25,
          startTime: DateTime.now(),
        ),
      );
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
      final elapsed =
          now.difference(r.startTime).inMilliseconds / 1000.0; // 0 to 3 seconds
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
