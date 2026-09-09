import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/field_state.dart';

class BiomeSceneryLayer extends StatefulWidget {
  final SceneryBiome biome;
  final DayPhase dayPhase;

  const BiomeSceneryLayer({
    super.key,
    required this.biome,
    required this.dayPhase,
  });

  @override
  State<BiomeSceneryLayer> createState() => _BiomeSceneryLayerState();
}

class _BiomeSceneryLayerState extends State<BiomeSceneryLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 30 seconds for a full slow loop (clouds, waves, train)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant BiomeSceneryLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.biome != widget.biome) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    if (widget.biome == SceneryBiome.coast || widget.biome == SceneryBiome.valley) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      if (_controller.isAnimating) _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needsAnimation = widget.biome == SceneryBiome.coast || widget.biome == SceneryBiome.valley;

    if (!needsAnimation) {
      return CustomPaint(
        painter: _SceneryPainter(
          biome: widget.biome,
          dayPhase: widget.dayPhase,
          animationValue: 0.0,
        ),
        size: Size.infinite,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SceneryPainter(
            biome: widget.biome,
            dayPhase: widget.dayPhase,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SceneryPainter extends CustomPainter {
  final SceneryBiome biome;
  final DayPhase dayPhase;
  final double animationValue;

  _SceneryPainter({
    required this.biome,
    required this.dayPhase,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Shared styling based on time of day
    final bool isNight = dayPhase == DayPhase.night;
    final bool isEvening = dayPhase == DayPhase.evening;
    
    // Base silhouette color
    Color silhouetteColor = isNight 
        ? Colors.black87 
        : (isEvening ? const Color(0xFF2C1E16) : const Color(0xFF1B3B22));

    switch (biome) {
      case SceneryBiome.plains:
        _drawPlains(canvas, size, silhouetteColor, isNight);
        break;
      case SceneryBiome.terraces:
        _drawTerraces(canvas, size, silhouetteColor);
        break;
      case SceneryBiome.valley:
        _drawValley(canvas, size, silhouetteColor);
        break;
      case SceneryBiome.coast:
        _drawCoast(canvas, size, silhouetteColor, isNight);
        break;
    }
  }

  void _drawPlains(Canvas canvas, Size size, Color color, bool isNight) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    
    // Distant tree line / rolling hills
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    // Smooth out the jagged lines by sampling densely (every 2 pixels instead of 20)
    // and adjusting the sine waves for a more natural, gentle rolling hill effect.
    for (double x = 0; x <= size.width + 10; x += 2) {
      final y = size.height * 0.65 - (sin(x * 0.01) * 15) - (cos(x * 0.03) * 5);
      path.lineTo(x, y);
    }
    path.lineTo(size.width + 50, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Power lines (電線桿)
    final polePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final wirePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final poleX = size.width * 0.8;
    // Anchor the pole lower down in the foreground so it doesn't float in the mountains
    final poleBaseY = size.height * 0.85; 
    final poleTopY = size.height * 0.35;
    
    // Draw pole
    canvas.drawLine(Offset(poleX, poleBaseY), Offset(poleX, poleTopY), polePaint);
    // Draw crossbars
    canvas.drawLine(Offset(poleX - 18, poleTopY + 15), Offset(poleX + 18, poleTopY + 15), polePaint);
    canvas.drawLine(Offset(poleX - 25, poleTopY + 35), Offset(poleX + 25, poleTopY + 35), polePaint);

    // Draw wires swooping in from off-screen
    final wirePath1 = Path()
      ..moveTo(0, poleTopY + 10)
      ..quadraticBezierTo(poleX * 0.5, poleTopY + 45, poleX - 18, poleTopY + 15);
    final wirePath2 = Path()
      ..moveTo(0, poleTopY + 25)
      ..quadraticBezierTo(poleX * 0.5, poleTopY + 60, poleX - 25, poleTopY + 35);
    
    // Wires going off right
    final wirePath3 = Path()
      ..moveTo(poleX + 18, poleTopY + 15)
      ..quadraticBezierTo(size.width * 0.9, poleTopY + 25, size.width, poleTopY + 10);
    final wirePath4 = Path()
      ..moveTo(poleX + 25, poleTopY + 35)
      ..quadraticBezierTo(size.width * 0.9, poleTopY + 45, size.width, poleTopY + 25);
      
    canvas.drawPath(wirePath1, wirePaint);
    canvas.drawPath(wirePath2, wirePaint);
    canvas.drawPath(wirePath3, wirePaint);
    canvas.drawPath(wirePath4, wirePaint);
  }

  void _drawTerraces(Canvas canvas, Size size, Color color) {
    // Layered contoured hills stepping down
    for (int i = 0; i < 5; i++) {
      final layerColor = color.withValues(alpha: 0.4 + (i * 0.15).clamp(0.0, 0.6));
      final paint = Paint()..color = layerColor..style = PaintingStyle.fill;
      
      final baseY = size.height * 0.5 + (i * size.height * 0.08);
      
      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, baseY - sin(i * 1.5) * 30);
      
      for (double x = 0; x <= size.width + 40; x += 2) {
        final y = baseY - sin(x * 0.02 + i) * 40 - cos(x * 0.01 + i * 2) * 20;
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width + 50, size.height);
      path.close();
      canvas.drawPath(path, paint);
      
      // Draw subtle contour lines (water reflection or ridge)
      final ridgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, ridgePaint);
    }
  }

  void _drawValley(Canvas canvas, Size size, Color color) {
    // Distant high mountains (Central Mountain Range)
    final mountainPaint1 = Paint()..color = color.withValues(alpha: 0.3);
    final path1 = Path()..moveTo(0, size.height);
    // Draw rugged peaks for Central Mountain Range
    path1.lineTo(0, size.height * 0.35);
    path1.quadraticBezierTo(size.width * 0.08, size.height * 0.15, size.width * 0.15, size.height * 0.15); // Smooth High peak
    path1.quadraticBezierTo(size.width * 0.22, size.height * 0.15, size.width * 0.3, size.height * 0.25);
    path1.quadraticBezierTo(size.width * 0.38, size.height * 0.35, size.width * 0.45, size.height * 0.1);  // Smooth Yushan
    path1.quadraticBezierTo(size.width * 0.52, size.height * -0.15, size.width * 0.6, size.height * 0.3);
    path1.quadraticBezierTo(size.width * 0.7, size.height * 0.4, size.width * 0.8, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.9, size.height * 0.0, size.width, size.height * 0.4);
    path1.lineTo(size.width, size.height);
    canvas.drawPath(path1, mountainPaint1);

    // Closer mountains (Coastal Mountain Range)
    final mountainPaint2 = Paint()..color = color.withValues(alpha: 0.6);
    final path2 = Path()..moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.45, size.width * 0.5, size.height * 0.55);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.5);
    path2.lineTo(size.width, size.height);
    canvas.drawPath(path2, mountainPaint2);

    // Train passing by very slowly in the midground
    // Train loop: appears from left, goes to right, takes 30s
    final trainX = -400 + (animationValue * (size.width + 800));
    final trainY = size.height * 0.72;
    
    final trainPaint = Paint()..color = color.withValues(alpha: 0.9);
    final windowPaint = Paint()..color = dayPhase == DayPhase.night ? Colors.yellow.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.6);
    final stripePaint = Paint()..color = Colors.orangeAccent.withValues(alpha: 0.7); // Commuter train stripe

    // Train body (EMU Commuter or Chu-Kuang Express vibe) - 5 cars
    for (int i = 0; i < 5; i++) {
      final carRect = Rect.fromLTWH(trainX - (i * 85), trainY, 80, 20);
      canvas.drawRRect(RRect.fromRectAndRadius(carRect, const Radius.circular(3)), trainPaint);
      
      // Front cabin slope (if it's the first car)
      if (i == 0) {
        final frontPath = Path()
          ..moveTo(trainX + 80, trainY)
          ..lineTo(trainX + 95, trainY + 20)
          ..lineTo(trainX + 80, trainY + 20)
          ..close();
        canvas.drawPath(frontPath, trainPaint);
        // Driver window
        canvas.drawRect(Rect.fromLTWH(trainX + 82, trainY + 5, 8, 8), windowPaint);
      }
      
      // Passenger Windows
      for (int w = 0; w < 6; w++) {
        canvas.drawRect(Rect.fromLTWH(trainX - (i * 85) + 5 + (w * 12), trainY + 4, 8, 8), windowPaint);
      }
      
      // Orange stripe across the body (classic Taiwan commuter)
      canvas.drawRect(Rect.fromLTWH(trainX - (i * 85), trainY + 14, 80, 2), stripePaint);
    }
    
    // Brown Avenue road cutting through bottom center
    final roadPaint = Paint()..color = color.withValues(alpha: 0.4);
    final roadPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.55, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();
    canvas.drawPath(roadPath, roadPaint);
  }

  void _drawCoast(Canvas canvas, Size size, Color silhouetteColor, bool isNight) {
    // Ocean background
    final oceanBaseColor = isNight ? const Color(0xFF0F1A2A) : const Color(0xFF28567A);
    final oceanPaint = Paint()..color = oceanBaseColor;
    
    final oceanRect = Rect.fromLTRB(0, size.height * 0.55, size.width, size.height);
    canvas.drawRect(oceanRect, oceanPaint);

    // Animated Waves
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    // Shift waves based on animation (0 to 1) -> 0 to 2pi
    final shift = animationValue * 2 * pi;

    for (int w = 0; w < 4; w++) {
      final waveY = size.height * 0.6 + (w * 25);
      final wavePath = Path();
      wavePath.moveTo(0, waveY);
      
      for (double x = 0; x <= size.width + 15; x += 2) {
        // Complex wave function
        final y = waveY + sin(x * 0.03 + shift + w) * 5 + cos(x * 0.01 - shift * 2) * 3;
        wavePath.lineTo(x, y);
      }
      canvas.drawPath(wavePath, wavePaint);
    }
    
    // Distant island / cliff
    final cliffPaint = Paint()..color = silhouetteColor.withValues(alpha: 0.7);
    final cliffPath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.45, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.55)
      ..close();
    canvas.drawPath(cliffPath, cliffPaint);
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) {
    return biome != oldDelegate.biome || 
           dayPhase != oldDelegate.dayPhase || 
           animationValue != oldDelegate.animationValue;
  }
}
