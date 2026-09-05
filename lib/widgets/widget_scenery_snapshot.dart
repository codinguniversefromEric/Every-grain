import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/field_state.dart';

class WidgetScenerySnapshot extends StatelessWidget {
  final FieldState state;
  final bool hasUnreadJournal;

  const WidgetScenerySnapshot({
    super.key, 
    required this.state, 
    this.hasUnreadJournal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      color: _getSkyColor(state.weatherCondition),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Basic Ground/Dirt
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              color: const Color(0xFF3E2723), // Dark dirt color
            ),
          ),
          
          // Basic Rice Plant (Static representation)
          if (state.growthStage != GrowthStage.fallow)
            Positioned(
              bottom: 20,
              left: 100,
              right: 100,
              height: _getPlantHeight(state.growthStage),
              child: CustomPaint(
                painter: StaticRicePlantPainter(stage: state.growthStage),
              ),
            ),
            
          // Taiwanese Begonia Patterned Glass (Frosted Glass Effect)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
            
          // Taiwan Wrought Iron Grill Overlay
          CustomPaint(
            painter: IronGrillPainter(),
          ),
          
          // Notification indicator
          if (hasUnreadJournal)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Text(
                  '● 阿公有信',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSkyColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.cloudy: return const Color(0xFF90A4AE);
      case WeatherCondition.rainy: return const Color(0xFF607D8B);
      case WeatherCondition.stormy: return const Color(0xFF37474F);
      case WeatherCondition.clear:
      default: return const Color(0xFF81D4FA);
    }
  }

  double _getPlantHeight(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seedling: return 80;
      case GrowthStage.tillering: return 150;
      case GrowthStage.heading: return 200;
      case GrowthStage.ripening: return 220;
      case GrowthStage.harvested: return 40;
      case GrowthStage.fallow: return 0;
      case GrowthStage.dead: return 40;
    }
  }
}

class StaticRicePlantPainter extends CustomPainter {
  final GrowthStage stage;
  StaticRicePlantPainter({required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    if (stage == GrowthStage.fallow || stage == GrowthStage.harvested) return;
    
    final paint = Paint()
      ..color = stage == GrowthStage.ripening ? const Color(0xFFFFD54F) : const Color(0xFF66BB6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.quadraticBezierTo(
      size.width / 2 + 20, size.height / 2, 
      size.width / 2 - 10, 0
    );
    
    path.moveTo(size.width / 2, size.height);
    path.quadraticBezierTo(
      size.width / 2 - 30, size.height / 2, 
      size.width / 2 + 20, 20
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IronGrillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C1C1C).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    // Draw outer frame
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw horizontal and vertical bars
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    
    paint.strokeWidth = 3.0;
    
    void drawScroll(Offset center, bool flipX, bool flipY) {
      final path = Path();
      double dx = flipX ? -1 : 1;
      double dy = flipY ? -1 : 1;
      
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 40 * dx, center.dy + 10 * dy, 
        center.dx + 50 * dx, center.dy + 40 * dy
      );
      path.quadraticBezierTo(
        center.dx + 60 * dx, center.dy + 70 * dy, 
        center.dx + 20 * dx, center.dy + 80 * dy
      );
      path.quadraticBezierTo(
        center.dx - 10 * dx, center.dy + 80 * dy, 
        center.dx, center.dy + 50 * dy
      );
      canvas.drawPath(path, paint);
    }
    
    drawScroll(Offset(size.width / 2, size.height / 2), false, false);
    drawScroll(Offset(size.width / 2, size.height / 2), true, false);
    drawScroll(Offset(size.width / 2, size.height / 2), false, true);
    drawScroll(Offset(size.width / 2, size.height / 2), true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
