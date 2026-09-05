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
    )..repeat();
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
    
    // Distant tree line
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.7 - sin(x * 0.05) * 10 - sin(x * 0.1) * 5;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Power lines (電線桿)
    final polePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final wirePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final poleX = size.width * 0.8;
    final poleBaseY = size.height * 0.75;
    final poleTopY = size.height * 0.4;
    
    // Draw pole
    canvas.drawLine(Offset(poleX, poleBaseY), Offset(poleX, poleTopY), polePaint);
    // Draw crossbars
    canvas.drawLine(Offset(poleX - 15, poleTopY + 10), Offset(poleX + 15, poleTopY + 10), polePaint);
    canvas.drawLine(Offset(poleX - 20, poleTopY + 25), Offset(poleX + 20, poleTopY + 25), polePaint);

    // Draw wires swooping in from off-screen
    final wirePath1 = Path()
      ..moveTo(0, poleTopY + 5)
      ..quadraticBezierTo(poleX * 0.5, poleTopY + 30, poleX - 15, poleTopY + 10);
    final wirePath2 = Path()
      ..moveTo(0, poleTopY + 15)
      ..quadraticBezierTo(poleX * 0.5, poleTopY + 40, poleX - 20, poleTopY + 25);
    
    // Wires going off right
    final wirePath3 = Path()
      ..moveTo(poleX + 15, poleTopY + 10)
      ..quadraticBezierTo(size.width * 0.9, poleTopY + 15, size.width, poleTopY + 5);
      
    canvas.drawPath(wirePath1, wirePaint);
    canvas.drawPath(wirePath2, wirePaint);
    canvas.drawPath(wirePath3, wirePaint);
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
      
      for (double x = 0; x <= size.width; x += 40) {
        final y = baseY - sin(x * 0.02 + i) * 40 - cos(x * 0.01 + i * 2) * 20;
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
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
    path1.lineTo(0, size.height * 0.4);
    path1.lineTo(size.width * 0.3, size.height * 0.2);
    path1.lineTo(size.width * 0.6, size.height * 0.45);
    path1.lineTo(size.width, size.height * 0.25);
    path1.lineTo(size.width, size.height);
    canvas.drawPath(path1, mountainPaint1);

    // Closer mountains (Coastal Mountain Range)
    final mountainPaint2 = Paint()..color = color.withValues(alpha: 0.6);
    final path2 = Path()..moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.lineTo(size.width * 0.4, size.height * 0.5);
    path2.lineTo(size.width * 0.8, size.height * 0.65);
    path2.lineTo(size.width, size.height * 0.55);
    path2.lineTo(size.width, size.height);
    canvas.drawPath(path2, mountainPaint2);

    // Train passing by very slowly in the midground
    // Train loop: appears from left, goes to right, takes 30s
    final trainX = -200 + (animationValue * (size.width + 400));
    final trainY = size.height * 0.7;
    
    final trainPaint = Paint()..color = color.withValues(alpha: 0.8);
    final windowPaint = Paint()..color = dayPhase == DayPhase.night ? Colors.yellow.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.4);

    // Train body (3 cars)
    for (int i = 0; i < 3; i++) {
      final carRect = Rect.fromLTWH(trainX - (i * 65), trainY, 60, 15);
      canvas.drawRRect(RRect.fromRectAndRadius(carRect, const Radius.circular(2)), trainPaint);
      
      // Windows
      for (int w = 0; w < 4; w++) {
        canvas.drawRect(Rect.fromLTWH(trainX - (i * 65) + 5 + (w * 13), trainY + 3, 10, 6), windowPaint);
      }
    }
    
    // Brown Avenue road cutting through bottom center
    final roadPaint = Paint()..color = color.withValues(alpha: 0.4);
    final roadPath = Path()
      ..moveTo(size.width * 0.48, size.height * 0.75)
      ..lineTo(size.width * 0.52, size.height * 0.75)
      ..lineTo(size.width * 0.7, size.height)
      ..lineTo(size.width * 0.3, size.height)
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
      
      for (double x = 0; x <= size.width; x += 10) {
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
