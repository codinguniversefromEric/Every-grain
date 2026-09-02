import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../visuals/living_sky.dart';
import 'rice_plant.dart';

class WidgetScenerySnapshot extends StatelessWidget {
  final FieldState state;
  final bool hasUnreadJournal;

  const WidgetScenerySnapshot({super.key, required this.state, this.hasUnreadJournal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Sky
          LivingSkyBackground(
            sunElevation: _getSunElevation(TimeOfDay.now()),
            weatherMetrics: WeatherMetrics(
              precipitation: state.weatherCondition == WeatherCondition.rainy ? 2.0 : 
                            (state.weatherCondition == WeatherCondition.stormy ? 10.0 : 0.0),
              windSpeed: 2.0,
              weatherCode: state.weatherCondition == WeatherCondition.cloudy ? 3 : 
                          (state.weatherCondition == WeatherCondition.rainy ? 61 : 
                          (state.weatherCondition == WeatherCondition.stormy ? 95 : 0)),
            ),
          ),
          
          // 2. Rice Plant Layer
          if (state.growthStage != GrowthStage.fallow)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 250,
              child: RicePlantLayer(
                growthStage: state.growthStage,
                variety: state.currentVariety,
              ),
            ),
            
          // 3. Taiwan Wrought Iron Grill Overlay
          CustomPaint(
            painter: IronGrillPainter(),
          ),
          
          // 4. Notification indicator
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
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _getSunElevation(TimeOfDay time) {
    if (time.hour >= 6 && time.hour <= 18) {
      return 1.0;
    }
    return -1.0;
  }
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
    
    // Draw classic Taiwanese geometric curves (Heart / Mount shape)
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
    
    // Center intersection ornaments
    drawScroll(Offset(size.width / 2, size.height / 2), false, false);
    drawScroll(Offset(size.width / 2, size.height / 2), true, false);
    drawScroll(Offset(size.width / 2, size.height / 2), false, true);
    drawScroll(Offset(size.width / 2, size.height / 2), true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
