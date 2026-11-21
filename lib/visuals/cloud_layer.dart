import 'dart:math';
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class CloudLayer extends StatefulWidget {
  final bool isNight;
  final WeatherCondition weather;
  const CloudLayer({
    super.key,
    this.isNight = false,
    this.weather = WeatherCondition.clear,
  });

  @override
  State<CloudLayer> createState() => _CloudLayerState();
}

class _CloudLayerState extends State<CloudLayer>
    with SingleTickerProviderStateMixin {
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
    int cloudCount = 5;
    double opacityMultiplier = 1.0;
    double speedMultiplier = 1.0;

    if (widget.weather == WeatherCondition.cloudy) {
      cloudCount = 10;
      opacityMultiplier = 2.5;
    } else if (widget.weather == WeatherCondition.rainy) {
      cloudCount = 15;
      opacityMultiplier = 3.5;
      speedMultiplier = 1.5;
    } else if (widget.weather == WeatherCondition.stormy) {
      cloudCount = 20;
      opacityMultiplier = 4.5;
      speedMultiplier = 3.0;
    }

    _clouds = List.generate(
      cloudCount,
      (i) => _Cloud(
        xStart: _rng.nextDouble() * 1.5 - 0.25,
        yPosition: 0.05 + _rng.nextDouble() * 0.25,
        speed: (0.15 + _rng.nextDouble() * 0.3) * speedMultiplier,
        width: 80 + _rng.nextDouble() * 120,
        height: 25 + _rng.nextDouble() * 30,
        opacity: (0.15 + _rng.nextDouble() * 0.25) * opacityMultiplier,
      ),
    );
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNight) return const SizedBox.shrink(); // No clouds at night

    return CustomPaint(
      painter: _CloudPainter(_clouds, _driftController),
      size: Size.infinite,
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
  _Cloud({
    required this.xStart,
    required this.yPosition,
    required this.speed,
    required this.width,
    required this.height,
    required this.opacity,
  });
}

class _CloudPainter extends CustomPainter {
  final List<_Cloud> clouds;
  final Animation<double> animation;
  _CloudPainter(this.clouds, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;
    final paint = Paint();
    for (final c in clouds) {
      final xPos = ((c.xStart + time * c.speed) % 1.4) - 0.2; // Wraps around
      const cloudColor = Color(0xFF90A4AE);
      paint.shader = RadialGradient(
        colors: [
          cloudColor.withValues(alpha: c.opacity),
          cloudColor.withValues(alpha: 0),
        ],
        stops: const [0.35, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));
      canvas.save();
      canvas.translate(xPos * size.width, c.yPosition * size.height);
      canvas.scale(c.width / 2 + 10, c.height / 2 + 10);
      canvas.drawCircle(Offset.zero, 1, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) =>
      oldDelegate.clouds != clouds || oldDelegate.animation != animation;
}
