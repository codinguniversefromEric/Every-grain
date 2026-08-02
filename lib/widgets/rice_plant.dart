import 'dart:math';
import 'package:flutter/material.dart';
import '../models/field_state.dart';

class RicePlantLayer extends StatefulWidget {
  final GrowthStage growthStage;

  const RicePlantLayer({super.key, required this.growthStage});

  @override
  State<RicePlantLayer> createState() => _RicePlantLayerState();
}

class _RicePlantLayerState extends State<RicePlantLayer> with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.growthStage == GrowthStage.harvested) {
      return const SizedBox.shrink(); // Hide plant when harvested
    }

    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        return CustomPaint(
          painter: _RicePlantPainter(
            growthStage: widget.growthStage,
            swayAmount: _swayController.value,
          ),
          size: const Size(double.infinity, 300),
        );
      },
    );
  }
}

class _RicePlantPainter extends CustomPainter {
  final GrowthStage growthStage;
  final double swayAmount;

  _RicePlantPainter({required this.growthStage, required this.swayAmount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getPlantColor()
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    if (growthStage == GrowthStage.harvested) {
      return; // Handled outside, but fallback
    }

    if (growthStage == GrowthStage.fallow) {
      _drawFloodedField(canvas, size, swayAmount);
      return;
    }

    // Base position
    final double baseX = width / 2;
    final double baseY = height;

    // Sway effect based on sine wave
    final double swayOffset = sin(swayAmount * pi * 2) * 15.0;

    // Draw main stem based on stage
    double stemHeight = 0;
    switch (growthStage) {
      case GrowthStage.seedling:
        stemHeight = height * 0.3;
        break;
      case GrowthStage.tillering:
        stemHeight = height * 0.6;
        break;
      case GrowthStage.heading:
      case GrowthStage.ripening:
        stemHeight = height * 0.8;
        break;
      case GrowthStage.harvested:
      case GrowthStage.fallow:
        stemHeight = 0; // Handled outside, but fallback
        break;
    }

    final topX = baseX + swayOffset;
    final topY = baseY - stemHeight;

    // Draw main stem
    final path = Path();
    path.moveTo(baseX, baseY);
    path.quadraticBezierTo(
      baseX + (swayOffset / 2),
      baseY - (stemHeight / 2),
      topX,
      topY,
    );

    canvas.drawPath(path, paint);

    // Draw leaves based on stage
    if (growthStage != GrowthStage.seedling) {
      _drawLeaf(canvas, paint, path, baseX, baseY, topX, topY, stemHeight * 0.4, true, swayOffset);
      _drawLeaf(canvas, paint, path, baseX, baseY, topX, topY, stemHeight * 0.7, false, swayOffset);
    }

    // Draw grains for heading/ripening
    if (growthStage == GrowthStage.heading || growthStage == GrowthStage.ripening) {
      final grainPaint = Paint()
        ..color = growthStage == GrowthStage.ripening ? Colors.amber : Colors.lightGreenAccent
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(topX + 5, topY + 10), 6, grainPaint);
      canvas.drawCircle(Offset(topX - 5, topY + 20), 6, grainPaint);
      canvas.drawCircle(Offset(topX + 8, topY + 30), 6, grainPaint);
      canvas.drawCircle(Offset(topX - 8, topY + 40), 6, grainPaint);
      canvas.drawCircle(Offset(topX + 5, topY + 50), 6, grainPaint);
    }
  }

  void _drawLeaf(Canvas canvas, Paint paint, Path stemPath, double baseX, double baseY, double topX, double topY, double offset, bool isLeft, double sway) {
    // Simple straight line for leaf
    final startY = baseY - offset;
    final startX = baseX + (sway / 2) * (offset / (baseY - topY)); // approximate point on stem
    
    final endX = isLeft ? startX - 40 : startX + 40;
    final endY = startY - 30;

    final leafPath = Path();
    leafPath.moveTo(startX, startY);
    leafPath.quadraticBezierTo(
      startX + (isLeft ? -20 : 20),
      startY,
      endX,
      endY,
    );

    final leafPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawFloodedField(Canvas canvas, Size size, double sway) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    // Draw a few simple horizontal rippling lines representing water
    for (int i = 0; i < 5; i++) {
      final y = height - (i * 20) - 10;
      final path = Path();
      
      // Add subtle ripple based on sway
      double ripple = sin((sway + i * 0.2) * pi * 2) * 10;
      
      path.moveTo(width * 0.2, y);
      path.quadraticBezierTo(width * 0.5, y + ripple, width * 0.8, y - ripple);
      
      canvas.drawPath(path, paint);
    }
  }

  Color _getPlantColor() {
    switch (growthStage) {
      case GrowthStage.fallow:
      case GrowthStage.seedling:
      case GrowthStage.tillering:
      case GrowthStage.heading:
        return Colors.green;
      case GrowthStage.ripening:
        return Colors.yellow.shade700;
      case GrowthStage.harvested:
        return Colors.green; // Fallback
    }
  }

  @override
  bool shouldRepaint(covariant _RicePlantPainter oldDelegate) {
    return oldDelegate.growthStage != growthStage || oldDelegate.swayAmount != swayAmount;
  }
}
