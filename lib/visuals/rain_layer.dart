import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class RainLayer extends StatefulWidget {
  final WeatherCondition weather;
  const RainLayer({super.key, required this.weather});

  @override
  State<RainLayer> createState() => _RainLayerState();
}

class _RainLayerState extends State<RainLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();
  late List<_RainBatch> _batches;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
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

    const styles = 4;
    _batches = List.generate(styles, (style) {
      final drops = List.generate((count + styles - 1 - style) ~/ styles, (_) {
        return _RainDrop(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          speed: 0.8 + _rng.nextDouble() * 0.4,
          length: 15 + _rng.nextDouble() * 15,
        );
      });
      return _RainBatch(drops, style);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weather != WeatherCondition.rainy &&
        widget.weather != WeatherCondition.stormy) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _RainPainter(
        _batches,
        _controller,
        widget.weather == WeatherCondition.stormy,
      ),
      size: Size.infinite,
    );
  }
}

class _RainDrop {
  final double x;
  final double y;
  final double speed;
  final double length;
  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class _RainBatch {
  final List<_RainDrop> drops;
  final Float32List points;
  final Paint paint;

  _RainBatch(this.drops, int style)
    : points = Float32List(drops.length * 4),
      paint = (Paint()
        ..color = Colors.white.withValues(alpha: 0.24 + style * 0.075)
        ..strokeWidth = 0.65 + style * 0.4
        ..strokeCap = StrokeCap.round);
}

class _RainPainter extends CustomPainter {
  final List<_RainBatch> batches;
  final AnimationController animation;
  final bool isStormy;

  _RainPainter(this.batches, this.animation, this.isStormy)
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final dx = isStormy ? 0.3 : 0.05;
    final seconds = (animation.lastElapsedDuration?.inMicroseconds ?? 0) / 1e6;
    for (final batch in batches) {
      for (var i = 0; i < batch.drops.length; i++) {
        final drop = batch.drops[i];
        final distance = seconds * drop.speed * 5;
        final x = ((drop.x + distance * dx) % 1) * size.width;
        final y = ((drop.y + distance) % 1) * size.height;
        final index = i * 4;
        batch.points[index] = x;
        batch.points[index + 1] = y;
        batch.points[index + 2] = x + drop.length * dx;
        batch.points[index + 3] = y + drop.length;
      }
      canvas.drawRawPoints(PointMode.lines, batch.points, batch.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) =>
      oldDelegate.batches != batches ||
      oldDelegate.animation != animation ||
      oldDelegate.isStormy != isStormy;
}
