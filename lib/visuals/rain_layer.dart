import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class RainLayer extends StatefulWidget {
  final WeatherCondition weather;
  const RainLayer({super.key, required this.weather});

  @override
  State<RainLayer> createState() => _RainLayerState();
}

class _RainLayerState extends State<RainLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();
  late List<_RainDrop> _drops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _generateDrops();
  }

  @override
  void didUpdateWidget(RainLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather != widget.weather) {
      _generateDrops();
    }
  }

  void _generateDrops() {
    int count = 0;
    if (widget.weather == WeatherCondition.rainy) count = 100;
    if (widget.weather == WeatherCondition.stormy) count = 250;

    _drops = List.generate(count, (i) => _RainDrop(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      speed: 0.8 + _rng.nextDouble() * 0.4,
      length: 15 + _rng.nextDouble() * 15,
      thickness: 0.5 + _rng.nextDouble() * 1.5,
      opacity: 0.2 + _rng.nextDouble() * 0.3,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weather != WeatherCondition.rainy && widget.weather != WeatherCondition.stormy) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainPainter(_drops, _controller.value, widget.weather == WeatherCondition.stormy),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainDrop {
  final double x;
  final double y;
  final double speed;
  final double length;
  final double thickness;
  final double opacity;
  _RainDrop({required this.x, required this.y, required this.speed, required this.length, required this.thickness, required this.opacity});
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double time;
  final bool isStormy;
  
  _RainPainter(this.drops, this.time, this.isStormy);

  @override
  void paint(Canvas canvas, Size size) {
    final dx = isStormy ? 0.3 : 0.05; // Wind angle
    
    for (var drop in drops) {
      // Loop over screen
      final yProgress = (drop.y + time * drop.speed * 5.0) % 1.0;
      final xProgress = (drop.x + time * drop.speed * dx * 5.0) % 1.0;
      
      final xPos = xProgress * size.width;
      final yPos = yProgress * size.height;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.thickness
        ..strokeCap = StrokeCap.round;
        
      canvas.drawLine(
        Offset(xPos, yPos), 
        Offset(xPos + drop.length * dx, yPos + drop.length), 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}
