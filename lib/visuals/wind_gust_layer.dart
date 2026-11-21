import 'dart:math';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class WindGustLayer extends StatefulWidget {
  final WeatherCondition weather;
  const WindGustLayer({super.key, this.weather = WeatherCondition.clear});

  @override
  State<WindGustLayer> createState() => _WindGustLayerState();
}

class _WindGustLayerState extends State<WindGustLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration? _gustStart;
  final _gustProgress = ValueNotifier<double?>(null);
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_updateGusts);
  }

  void _updateGusts() {
    double probability = 0.01;
    if (widget.weather == WeatherCondition.stormy) {
      probability = 0.08;
    } else if (widget.weather == WeatherCondition.rainy) {
      probability = 0.03;
    }

    final now = _controller.lastElapsedDuration ?? Duration.zero;
    if (_gustStart == null && _rng.nextDouble() < probability) {
      _gustStart = now;
    }
    final start = _gustStart;
    if (start != null) {
      final elapsed = (now - start).inMilliseconds / 2000;
      if (elapsed >= 1) {
        _gustStart = null;
        _gustProgress.value = null;
      } else {
        _gustProgress.value = elapsed;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _gustProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WindGustPainter(_gustProgress),
      size: Size.infinite,
    );
  }
}

class _WindGustPainter extends CustomPainter {
  final ValueListenable<double?> progress;
  _WindGustPainter(this.progress) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = progress.value;
    if (elapsed == null) return;

    // Fade in and out
    final opacity = sin(elapsed * pi) * 0.4;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final dustPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 1.5);

    // Draw 3 swooping bezier curves moving across
    for (int i = 0; i < 3; i++) {
      double startX =
          size.width * 1.2 - (elapsed * size.width * 1.5) - (i * 50);
      double startY = size.height * (0.6 + i * 0.1);

      Path path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX - 200,
        startY + 50 * sin(elapsed * pi * 4 + i),
        startX - 400,
        startY - 50,
      );
      canvas.drawPath(path, paint);

      // tiny dust particles
      canvas.drawCircle(Offset(startX - 50, startY + 10), 1.5, dustPaint);
      canvas.drawCircle(Offset(startX - 150, startY - 20), 1.0, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindGustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
