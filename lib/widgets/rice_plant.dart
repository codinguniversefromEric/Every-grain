import 'dart:math';
import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../models/rice_variety.dart';

/// A living, breathing paddy field — not a single lonely stem,
/// but a sea of rice stalks, each swaying to its own rhythm.
/// Now differentiates visually by rice variety.
class RicePlantLayer extends StatefulWidget {
  final GrowthStage growthStage;
  final RiceVariety? variety;

  const RicePlantLayer({super.key, required this.growthStage, this.variety});

  @override
  State<RicePlantLayer> createState() => _RicePlantLayerState();
}

class _RicePlantLayerState extends State<RicePlantLayer> with SingleTickerProviderStateMixin {
  late AnimationController _windController;
  late List<_RiceStalk> _stalks;
  final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _generateField();
  }

  @override
  void didUpdateWidget(RicePlantLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.growthStage != widget.growthStage || oldWidget.variety != widget.variety) {
      _generateField();
    }
  }

  VarietyVisualTraits get _traits =>
      widget.variety?.visualTraits ?? RiceVariety.tainan11.visualTraits;

  void _generateField() {
    if (widget.growthStage == GrowthStage.harvested || widget.growthStage == GrowthStage.fallow) {
      _stalks = [];
      return;
    }

    final traits = _traits;

    // Base counts adjusted by variety density
    int count;
    switch (widget.growthStage) {
      case GrowthStage.seedling:
        count = (12 * traits.maxStalksMultiplier).round();
        break;
      case GrowthStage.tillering:
        count = (20 * traits.maxStalksMultiplier).round();
        break;
      case GrowthStage.heading:
      case GrowthStage.ripening:
        count = (25 * traits.maxStalksMultiplier).round();
        break;
      default:
        count = 0;
    }

    _stalks = List.generate(count, (i) {
      double xNorm = (i / count) + (_rng.nextDouble() - 0.5) * 0.08;
      xNorm = xNorm.clamp(0.05, 0.95);

      // Height variation influenced by variety
      final baseHeight = 0.5 + _rng.nextDouble() * traits.stalkHeightRange;

      return _RiceStalk(
        xPosition: xNorm,
        height: baseHeight.clamp(0.3, 1.0),
        phaseOffset: _rng.nextDouble() * pi * 2,
        thickness: 2.0 + _rng.nextDouble() * 2.0,
        leafCount: widget.growthStage == GrowthStage.seedling ? 0 : 1 + _rng.nextInt(3),
        grainCount: (widget.growthStage == GrowthStage.heading || widget.growthStage == GrowthStage.ripening)
            ? 3 + _rng.nextInt(5)
            : 0,
        grainDroop: widget.growthStage == GrowthStage.ripening ? 0.3 + _rng.nextDouble() * 0.4 : 0.0,
        randomSeed: _rng.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.growthStage == GrowthStage.harvested) {
      return CustomPaint(
        painter: _StubblePainter(),
        size: const Size(double.infinity, 300),
      );
    }

    if (widget.growthStage == GrowthStage.fallow) {
      return AnimatedBuilder(
        animation: _windController,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaterPainter(_windController.value),
            size: const Size(double.infinity, 300),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        return CustomPaint(
          painter: _PaddyFieldPainter(
            stalks: _stalks,
            windTime: _windController.value,
            growthStage: widget.growthStage,
            traits: _traits,
          ),
          size: const Size(double.infinity, 300),
        );
      },
    );
  }
}

class _RiceStalk {
  final double xPosition;
  final double height;
  final double phaseOffset;
  final double thickness;
  final int leafCount;
  final int grainCount;
  final double grainDroop;
  final double randomSeed;

  _RiceStalk({
    required this.xPosition,
    required this.height,
    required this.phaseOffset,
    required this.thickness,
    required this.leafCount,
    required this.grainCount,
    required this.grainDroop,
    required this.randomSeed,
  });
}

class _PaddyFieldPainter extends CustomPainter {
  final List<_RiceStalk> stalks;
  final double windTime;
  final GrowthStage growthStage;
  final VarietyVisualTraits traits;

  _PaddyFieldPainter({
    required this.stalks,
    required this.windTime,
    required this.growthStage,
    required this.traits,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    for (final stalk in stalks) {
      _drawStalk(canvas, size, stalk);
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.brown.withValues(alpha: 0.0),
          Colors.brown.withValues(alpha: 0.2),
          const Color(0xFF3E2723).withValues(alpha: 0.5),
        ],
        stops: const [0.6, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), groundPaint);
  }

  void _drawStalk(Canvas canvas, Size size, _RiceStalk stalk) {
    final baseX = stalk.xPosition * size.width;
    final baseY = size.height;
    final maxHeight = size.height * 0.85;
    final stalkHeight = maxHeight * stalk.height;

    final globalWind = sin(windTime * pi * 2 + stalk.phaseOffset) * 18.0;
    final localFlutter = sin(windTime * pi * 4 + stalk.phaseOffset * 1.7) * 5.0;
    final totalSway = globalWind + localFlutter;

    final droopX = totalSway + stalk.grainDroop * 30.0;
    final droopY = stalk.grainDroop * 20.0;

    final tipX = baseX + droopX;
    final tipY = baseY - stalkHeight + droopY;

    // Use variety-specific stem color, adjusted by growth stage
    final stemColor = _getStemColor();
    final stemPaint = Paint()
      ..color = stemColor
      ..strokeWidth = stalk.thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(baseX, baseY);
    final controlY1 = baseY - stalkHeight * 0.4;
    final controlY2 = baseY - stalkHeight * 0.7;
    stemPath.cubicTo(
      baseX + totalSway * 0.3, controlY1,
      baseX + totalSway * 0.7, controlY2,
      tipX, tipY,
    );
    canvas.drawPath(stemPath, stemPaint);

    // Draw leaves
    for (int i = 0; i < stalk.leafCount; i++) {
      final t = 0.3 + (i * 0.25);
      final leafBaseX = baseX + totalSway * t * 0.5;
      final leafBaseY = baseY - stalkHeight * t;
      final isLeft = i % 2 == 0;
      final leafSway = sin(windTime * pi * 4 + stalk.phaseOffset + i) * 8.0;
      _drawLeaf(canvas, leafBaseX, leafBaseY, isLeft, leafSway, stemColor);
    }

    // Draw grain panicle with variety-specific traits
    if (stalk.grainCount > 0) {
      _drawGrainPanicle(canvas, tipX, tipY, stalk, totalSway);
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, bool isLeft, double sway, Color color) {
    final leafPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dir = isLeft ? -1.0 : 1.0;
    final leafPath = Path();
    leafPath.moveTo(x, y);
    leafPath.quadraticBezierTo(
      x + dir * (25 + sway), y - 8,
      x + dir * (40 + sway * 1.5), y + 5,
    );
    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawGrainPanicle(Canvas canvas, double tipX, double tipY, _RiceStalk stalk, double sway) {
    final isRipening = growthStage == GrowthStage.ripening;

    // Use variety-specific grain color
    final grainColor = isRipening ? traits.ripeGrainColor : const Color(0xFF8BC34A);
    final grainPaint = Paint()
      ..color = grainColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < stalk.grainCount; i++) {
      final t = i / stalk.grainCount;
      // Add random spread using the stalk's randomSeed to make them look distinct
      final spread = (stalk.randomSeed * 2.0 - 1.0) * 3.0; 
      final grainX = tipX + sin(t * pi + sway * 0.05 + spread) * (8 + t * 6) + (i%2==0? spread:-spread);
      final grainY = tipY + t * 35 + sin(sway * 0.1 + i) * 2 + (stalk.randomSeed * 5.0);

      // Use variety-specific grain size and roundness, plus minor random variation
      final baseRadius = 3.0 + t * 1.5 + (stalk.randomSeed * 0.5);
      final radius = baseRadius * traits.grainSize;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(grainX, grainY),
          width: radius * traits.grainRoundness,
          height: radius,
        ),
        grainPaint,
      );
    }
  }

  Color _getStemColor() {
    switch (growthStage) {
      case GrowthStage.seedling:
        return Color.lerp(const Color(0xFF66BB6A), traits.stemColor, 0.3)!;
      case GrowthStage.tillering:
        return Color.lerp(const Color(0xFF43A047), traits.stemColor, 0.5)!;
      case GrowthStage.heading:
        return traits.stemColor;
      case GrowthStage.ripening:
        return Color.lerp(traits.stemColor, const Color(0xFF9E9D24), 0.6)!;
      default:
        return Colors.green;
    }
  }

  @override
  bool shouldRepaint(covariant _PaddyFieldPainter oldDelegate) {
    return oldDelegate.windTime != windTime || oldDelegate.growthStage != growthStage;
  }
}

/// After harvest: short broken stubs in the mud
class _StubblePainter extends CustomPainter {
  final Random _rng = Random(99);

  @override
  void paint(Canvas canvas, Size size) {
    final stubPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 30; i++) {
      final x = (i / 30) * size.width + (_rng.nextDouble() - 0.5) * 20;
      final stubHeight = 10 + _rng.nextDouble() * 25;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + (_rng.nextDouble() - 0.5) * 3, size.height - stubHeight),
        stubPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallow season: flooded paddy with animated ripples
class _WaterPainter extends CustomPainter {
  final double time;
  _WaterPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlueAccent.withValues(alpha: 0.05),
          Colors.lightBlueAccent.withValues(alpha: 0.2),
          Colors.blueAccent.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), waterPaint);

    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final y = size.height * 0.2 + (i * i * 1.5);
      final ripple = sin((time * pi * 2) + i * 0.8) * 12;
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 30) {
        final localRipple = sin((time * pi * 2) + x * 0.01 + i * 0.5) * 6 + ripple;
        path.lineTo(x, y + localRipple);
      }
      canvas.drawPath(path, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => true;
}
