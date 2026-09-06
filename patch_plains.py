import re

with open("lib/visuals/scenery/biome_scenery_layer.dart", "r", encoding="utf-8") as f:
    content = f.read()

new_plains = """
  void _drawPlains(Canvas canvas, Size size, Color color, bool isNight) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    
    // Distant tree line / rolling hills
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    // Smooth out the jagged lines by sampling densely (every 2 pixels instead of 20)
    // and adjusting the sine waves for a more natural, gentle rolling hill effect.
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.65 - (sin(x * 0.01) * 15) - (cos(x * 0.03) * 5);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
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
"""

content = re.sub(r'void _drawPlains.*?void _drawTerraces', new_plains.strip() + '\n\n  void _drawTerraces', content, flags=re.DOTALL)

with open("lib/visuals/scenery/biome_scenery_layer.dart", "w", encoding="utf-8") as f:
    f.write(content)
