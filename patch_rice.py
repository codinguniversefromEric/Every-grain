import re

with open("lib/widgets/rice_plant.dart", "r", encoding="utf-8") as f:
    content = f.read()

# We completely replace RicePlantLayer and its painters
new_content = """import 'dart:math';
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

class _RicePlantLayerState extends State<RicePlantLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _windController;

  @override
  void initState() {
    super.initState();
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _windController.dispose();
    super.dispose();
  }

  VarietyVisualTraits get _traits =>
      widget.variety?.visualTraits ?? RiceVariety.tainan11.visualTraits;

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
          painter: _SeaOfRicePainter(
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

class _SeaOfRicePainter extends CustomPainter {
  final double windTime;
  final GrowthStage growthStage;
  final VarietyVisualTraits traits;
  final Random _rng = Random(42);

  _SeaOfRicePainter({
    required this.windTime,
    required this.growthStage,
    required this.traits,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    
    // Draw 3 layers of procedural waves to create the "Sea of Rice" (稻浪)
    _drawRiceWaveLayer(canvas, size, 0, 0.4, 1.0);
    _drawRiceWaveLayer(canvas, size, 1, 0.7, 0.85);
    _drawRiceWaveLayer(canvas, size, 2, 1.0, 0.7);

    // Foreground detailed stalks (if close enough to see)
    _drawForegroundStalks(canvas, size);
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

  Color _getBaseColor(double darkness) {
    Color base;
    switch (growthStage) {
      case GrowthStage.seedling:
        base = Color.lerp(const Color(0xFF66BB6A), traits.stemColor, 0.3)!;
        break;
      case GrowthStage.tillering:
        base = Color.lerp(const Color(0xFF43A047), traits.stemColor, 0.5)!;
        break;
      case GrowthStage.heading:
        base = traits.stemColor;
        break;
      case GrowthStage.ripening:
        base = Color.lerp(traits.stemColor, const Color(0xFF9E9D24), 0.6)!;
        break;
      default:
        base = Colors.green;
    }
    // Darken back layers
    return Color.lerp(base, Colors.black, 1.0 - darkness)!;
  }

  void _drawRiceWaveLayer(Canvas canvas, Size size, int layerIndex, double scale, double darkness) {
    final color = _getBaseColor(darkness);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Height based on growth stage
    double heightRatio = 0.3;
    if (growthStage == GrowthStage.tillering) heightRatio = 0.6;
    if (growthStage == GrowthStage.heading) heightRatio = 0.85;
    if (growthStage == GrowthStage.ripening) heightRatio = 0.8;
    
    // Scale down back layers
    final waveBaseY = size.height - (size.height * heightRatio * scale);
    
    final path = Path();
    path.moveTo(0, size.height);
    
    // Procedural wind wave (稻浪)
    final shift = windTime * pi * 4;
    for (double x = 0; x <= size.width; x += 15) {
      // Complex sine waves for organic swaying
      final wave1 = sin(x * 0.02 + shift + layerIndex) * 15;
      final wave2 = cos(x * 0.05 - shift * 0.5 + layerIndex * 2) * 5;
      // Tips of the rice stalks blowing in the wind
      final tipSway = sin(x * 0.1 + shift * 2) * 8 * (windTime % 1.0 > 0.5 ? 1 : 0.8);
      
      final y = waveBaseY + wave1 + wave2 + tipSway;
      path.lineTo(x, y);
      
      // Draw grains on the wave crests if heading/ripening
      if ((growthStage == GrowthStage.heading || growthStage == GrowthStage.ripening) && x % 45 == 0) {
        _drawWaveGrains(canvas, x, y, layerIndex, color);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
    
    // Highlight edge (sunlight on the waves)
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, edgePaint);
  }

  void _drawWaveGrains(Canvas canvas, double x, double y, int layer, Color baseColor) {
    final isRipening = growthStage == GrowthStage.ripening;
    final grainColor = isRipening ? traits.ripeGrainColor : Color.lerp(baseColor, Colors.lightGreen, 0.5)!;
    final grainPaint = Paint()..color = grainColor..style = PaintingStyle.fill;
    
    // Droop based on ripening
    final droop = isRipening ? 15.0 : 0.0;
    
    for(int i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + i*3 + droop*0.2, y + i*4 + droop),
          width: 4 * traits.grainRoundness,
          height: 4,
        ),
        grainPaint,
      );
    }
  }

  void _drawForegroundStalks(Canvas canvas, Size size) {
    // Just a few detailed stalks in the very front so it doesn't look like purely abstract blobs
    final int count = (6 * traits.maxStalksMultiplier).round();
    final stemColor = _getBaseColor(1.0);
    final paint = Paint()
      ..color = stemColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double heightRatio = 0.3;
    if (growthStage == GrowthStage.tillering) heightRatio = 0.65;
    if (growthStage == GrowthStage.heading || growthStage == GrowthStage.ripening) heightRatio = 0.9;

    for (int i = 0; i < count; i++) {
      final x = (i + 0.5) * (size.width / count) + (_rng.nextDouble() - 0.5) * 20;
      final baseY = size.height;
      final stalkHeight = size.height * heightRatio * (0.8 + _rng.nextDouble() * 0.4);
      
      final shift = windTime * pi * 4;
      final sway = sin(x * 0.02 + shift) * 25 + sin(windTime * pi * 8 + i) * 5;
      
      final path = Path();
      path.moveTo(x, baseY);
      path.quadraticBezierTo(x + sway * 0.5, baseY - stalkHeight * 0.5, x + sway, baseY - stalkHeight);
      canvas.drawPath(path, paint);
      
      // Leaves
      if (growthStage != GrowthStage.seedling) {
        final leafPaint = Paint()..color = stemColor.withValues(alpha: 0.9)..strokeWidth = 2.0..style = PaintingStyle.stroke;
        final leafPath = Path();
        leafPath.moveTo(x + sway*0.3, baseY - stalkHeight * 0.4);
        leafPath.quadraticBezierTo(x + sway*0.8 + 20, baseY - stalkHeight * 0.5, x + sway*1.2 + 30, baseY - stalkHeight * 0.3);
        canvas.drawPath(leafPath, leafPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SeaOfRicePainter oldDelegate) {
    return oldDelegate.windTime != windTime ||
        oldDelegate.growthStage != growthStage;
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
        final localRipple =
            sin((time * pi * 2) + x * 0.01 + i * 0.5) * 6 + ripple;
        path.lineTo(x, y + localRipple);
      }
      canvas.drawPath(path, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => true;
}
"""

with open("lib/widgets/rice_plant.dart", "w", encoding="utf-8") as f:
    f.write(new_content)
