import re

with open("lib/visuals/scenery/biome_scenery_layer.dart", "r", encoding="utf-8") as f:
    content = f.read()

new_valley = """
  void _drawValley(Canvas canvas, Size size, Color color) {
    // Distant high mountains (Central Mountain Range)
    final mountainPaint1 = Paint()..color = color.withValues(alpha: 0.3);
    final path1 = Path()..moveTo(0, size.height);
    // Draw rugged peaks for Central Mountain Range
    path1.lineTo(0, size.height * 0.35);
    path1.lineTo(size.width * 0.15, size.height * 0.15); // High peak
    path1.lineTo(size.width * 0.3, size.height * 0.25);
    path1.lineTo(size.width * 0.45, size.height * 0.1);  // Yushan (Jade Mountain) peak
    path1.lineTo(size.width * 0.6, size.height * 0.3);
    path1.lineTo(size.width * 0.8, size.height * 0.2);
    path1.lineTo(size.width, size.height * 0.4);
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
"""

content = re.sub(r'void _drawValley.*?void _drawCoast', new_valley.strip() + '\n\n  void _drawCoast', content, flags=re.DOTALL)

with open("lib/visuals/scenery/biome_scenery_layer.dart", "w", encoding="utf-8") as f:
    f.write(content)
