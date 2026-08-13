import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class WindGustLayer extends StatefulWidget {
  final WeatherCondition weather;
  const WindGustLayer({super.key, this.weather = WeatherCondition.clear});

  @override
  State<WindGustLayer> createState() => _WindGustLayerState();
}

class _WindGustLayerState extends State<WindGustLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _Gust? _currentGust;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _controller.addListener(_updateGusts);
  }

  void _updateGusts() {
    double probability = 0.01;
    if (widget.weather == WeatherCondition.stormy) {
      probability = 0.08;
    } else if (widget.weather == WeatherCondition.rainy) {
      probability = 0.03;
    }

    if (_currentGust == null && _rng.nextDouble() < probability) {
      _currentGust = _Gust(startTime: DateTime.now());
    }
    
    if (_currentGust != null) {
      final elapsed = DateTime.now().difference(_currentGust!.startTime).inMilliseconds;
      if (elapsed > 2000) { // gust lasts 2 seconds
        _currentGust = null;
      }
    }
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
          painter: _WindGustPainter(_currentGust),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Gust {
  final DateTime startTime;
  _Gust({required this.startTime});
}

class _WindGustPainter extends CustomPainter {
  final _Gust? gust;
  _WindGustPainter(this.gust);

  @override
  void paint(Canvas canvas, Size size) {
    if (gust == null) return;
    
    final elapsed = DateTime.now().difference(gust!.startTime).inMilliseconds / 2000.0;
    if (elapsed > 1.0) return;

    // Fade in and out
    double opacity = sin(elapsed * pi) * 0.4;
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Draw 3 swooping bezier curves moving across
    double progress = elapsed; // 0 to 1
    
    for (int i = 0; i < 3; i++) {
      double startX = size.width * 1.2 - (progress * size.width * 1.5) - (i * 50);
      double startY = size.height * (0.6 + i * 0.1);
      
      Path path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX - 200, startY + 50 * sin(elapsed * pi * 4 + i), 
        startX - 400, startY - 50,
      );
      canvas.drawPath(path, paint);

      // tiny dust particles
      final dustPaint = Paint()..color = Colors.white.withValues(alpha: opacity * 1.5);
      canvas.drawCircle(Offset(startX - 50, startY + 10), 1.5, dustPaint);
      canvas.drawCircle(Offset(startX - 150, startY - 20), 1.0, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

