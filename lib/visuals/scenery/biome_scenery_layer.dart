import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/field_state.dart';

/// 細分的台灣景觀變體。
///
/// 取代原本的 7 種變體，改為 12 種涵蓋北中南東不同地形的實景風格，
/// 大幅減少幾何圖形感，增加遠山、丘陵、水圳、電線桿、竹林等台灣鄉土元素。
enum _LandscapeVariant {
  // Plains (對應中南部平原)
  centralPlains,
  southPlains,
  southWetlands,
  // Terraces (對應北部、丘陵梯田)
  northHills,
  northTerraces,
  centralHills,
  // Valley (對應花東縱谷、山谷)
  centralValley,
  eastRiftValley,
  eastFoothills,
  // Coast (對應海岸、河口)
  northEstuary,
  southCoast,
  eastCoast,
}

/// 用於快取靜態路徑繪製，避免每幀重建 Path
class SceneryCache {
  ui.Picture? picture;
  String key = '';

  void dispose() {
    picture?.dispose();
    picture = null;
  }
}

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
  late final AnimationController _controller;

  late _LandscapeVariant _variant;
  late int _seed;
  final SceneryCache _cache = SceneryCache();

  // 每個 Session 隨機分配各 Biome 的 Seed，確保同一開啟期間地貌穩定，但每次開啟有驚喜
  static final Map<SceneryBiome, int> _sessionSeeds = {
    SceneryBiome.plains: 1729 + Random().nextInt(10000),
    SceneryBiome.terraces: 2819 + Random().nextInt(10000),
    SceneryBiome.valley: 3947 + Random().nextInt(10000),
    SceneryBiome.coast: 5173 + Random().nextInt(10000),
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // 放慢動畫節奏
    );

    _updateScene(force: true);
  }

  @override
  void didUpdateWidget(covariant BiomeSceneryLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.biome != widget.biome) {
      _updateScene(force: true);
    }
  }

  void _updateScene({bool force = false}) {
    final variants = _variantsFor(widget.biome);

    if (force || !variants.contains(_variant)) {
      final index = _sessionSeeds[widget.biome]! % variants.length;
      _variant = variants[index];
    }

    _seed = _sessionSeeds[widget.biome]!;

    final needsAnimation = _variant == _LandscapeVariant.centralValley ||
        _variant == _LandscapeVariant.eastCoast ||
        _variant == _LandscapeVariant.southCoast ||
        _variant == _LandscapeVariant.northEstuary;

    if (needsAnimation) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  List<_LandscapeVariant> _variantsFor(SceneryBiome biome) {
    switch (biome) {
      case SceneryBiome.plains:
        return const [
          _LandscapeVariant.centralPlains,
          _LandscapeVariant.southPlains,
          _LandscapeVariant.southWetlands,
        ];
      case SceneryBiome.terraces:
        return const [
          _LandscapeVariant.northHills,
          _LandscapeVariant.northTerraces,
          _LandscapeVariant.centralHills,
        ];
      case SceneryBiome.valley:
        return const [
          _LandscapeVariant.centralValley,
          _LandscapeVariant.eastRiftValley,
          _LandscapeVariant.eastFoothills,
        ];
      case SceneryBiome.coast:
        return const [
          _LandscapeVariant.northEstuary,
          _LandscapeVariant.southCoast,
          _LandscapeVariant.eastCoast,
        ];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SceneryPainter(
              biome: widget.biome,
              dayPhase: widget.dayPhase,
              variant: _variant,
              animationValue: _controller.value,
              seed: _seed,
              cache: _cache,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SceneryPainter extends CustomPainter {
  final SceneryBiome biome;
  final DayPhase dayPhase;
  final _LandscapeVariant variant;
  final double animationValue;
  final int seed;
  final SceneryCache cache;

  _SceneryPainter({
    required this.biome,
    required this.dayPhase,
    required this.variant,
    required this.animationValue,
    required this.seed,
    required this.cache,
  });

  bool get isNight => dayPhase == DayPhase.night;
  bool get isEvening => dayPhase == DayPhase.evening;
  bool get isMorning => dayPhase == DayPhase.morning;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _palette();
    
    // 將大部分不會變動的背景、中景、前景繪製快取起來
    final currentKey = '${variant.name}_${size.width}x${size.height}_${dayPhase.name}_$seed';

    if (cache.key != currentKey || cache.picture == null) {
      final recorder = ui.PictureRecorder();
      final recordCanvas = Canvas(recorder);
      _drawStaticScene(recordCanvas, size, p);
      
      cache.picture?.dispose();
      cache.picture = recorder.endRecording();
      cache.key = currentKey;
    }

    if (cache.picture != null) {
      canvas.drawPicture(cache.picture!);
    }

    // 繪製動態特效 (海浪、火車、水波紋)
    _drawDynamicScene(canvas, size, p);
  }

  void _drawStaticScene(Canvas canvas, Size size, _SceneryPalette p) {
    final rng = Random(seed);

    _drawAtmosphere(canvas, size, p);

    // 1. Background (Mountains, Hills, Ocean)
    switch (variant) {
      case _LandscapeVariant.eastRiftValley:
      case _LandscapeVariant.centralValley:
        // High mountains on left and right
        _drawMountain(canvas, size, Paint()..color = p.farMountain.withValues(alpha: 0.5), size.height * 0.3, size.height * 0.7, 50, 6, 1.5, rng);
        _drawMountain(canvas, size, Paint()..color = p.nearMountain.withValues(alpha: 0.6), size.height * 0.8, size.height * 0.4, 40, 6, 1.3, rng);
        break;
      case _LandscapeVariant.eastFoothills:
      case _LandscapeVariant.northTerraces:
        // Massive mountain on one side
        _drawMountain(canvas, size, Paint()..color = p.nearMountain.withValues(alpha: 0.6), size.height * 0.2, size.height * 0.8, 60, 6, 1.4, rng);
        break;
      case _LandscapeVariant.northHills:
      case _LandscapeVariant.centralHills:
        // Rolling hills
        _drawRollingHills(canvas, size, Paint()..color = p.farMountain.withValues(alpha: 0.4), size.height * 0.55, 60, rng);
        _drawRollingHills(canvas, size, Paint()..color = p.nearMountain.withValues(alpha: 0.6), size.height * 0.65, 40, rng);
        break;
      case _LandscapeVariant.centralPlains:
        // Distant mountains
        _drawMountain(canvas, size, Paint()..color = p.farMountain.withValues(alpha: 0.4), size.height * 0.6, size.height * 0.6, 30, 6, 1.0, rng);
        break;
      case _LandscapeVariant.southCoast:
      case _LandscapeVariant.eastCoast:
        // Ocean horizon
        canvas.drawRect(Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42), Paint()..color = p.water.withValues(alpha: 0.8));
        if (variant == _LandscapeVariant.eastCoast) {
          // Cliff on left
          _drawMountain(canvas, size, Paint()..color = p.nearMountain.withValues(alpha: 0.7), size.height * 0.3, size.height * 0.7, 50, 5, 1.2, rng);
        }
        break;
      case _LandscapeVariant.northEstuary:
        // Distant hills and water
        _drawRollingHills(canvas, size, Paint()..color = p.farMountain.withValues(alpha: 0.4), size.height * 0.6, 30, rng);
        break;
      case _LandscapeVariant.southPlains:
      case _LandscapeVariant.southWetlands:
        // Very flat, maybe faint distant hills
        _drawRollingHills(canvas, size, Paint()..color = p.farMountain.withValues(alpha: 0.2), size.height * 0.65, 15, rng);
        break;
    }

    // 2. Midground (Fields, Water)
    switch (variant) {
      case _LandscapeVariant.centralPlains:
      case _LandscapeVariant.southPlains:
      case _LandscapeVariant.eastRiftValley:
        _drawPlainsFields(canvas, size, p, rng);
        break;
      case _LandscapeVariant.northHills:
      case _LandscapeVariant.northTerraces:
      case _LandscapeVariant.centralHills:
      case _LandscapeVariant.eastFoothills:
        _drawTerracedFields(canvas, size, p, rng);
        break;
      case _LandscapeVariant.southWetlands:
        _drawPlainsFields(canvas, size, p, rng);
        _drawWetlandWater(canvas, size, p, rng);
        break;
      case _LandscapeVariant.centralValley:
        _drawRiver(canvas, size, p, rng);
        _drawPlainsFields(canvas, size, p, rng, startY: 0.75);
        break;
      case _LandscapeVariant.northEstuary:
        _drawEstuary(canvas, size, p, rng);
        break;
      case _LandscapeVariant.southCoast:
      case _LandscapeVariant.eastCoast:
        _drawCoastBeach(canvas, size, p, rng);
        break;
    }

    // 3. Infrastructure & Decor
    switch (variant) {
      case _LandscapeVariant.centralPlains:
      case _LandscapeVariant.southPlains:
      case _LandscapeVariant.eastRiftValley:
        _drawRoadAndPoles(canvas, size, p, rng);
        _drawHouseCluster(canvas, size, p, rng, size.width * 0.2, size.height * 0.65);
        break;
      case _LandscapeVariant.northHills:
      case _LandscapeVariant.centralHills:
        _drawBamboo(canvas, size, p, rng, Offset(size.width * 0.8, size.height * 0.68), 0.8);
        _drawHouseCluster(canvas, size, p, rng, size.width * 0.7, size.height * 0.68);
        break;
      case _LandscapeVariant.northTerraces:
      case _LandscapeVariant.eastFoothills:
        _drawTrees(canvas, size, p, rng, count: 5, y: size.height * 0.7, spread: size.width);
        break;
      case _LandscapeVariant.centralValley:
      case _LandscapeVariant.eastCoast:
        _drawRailwayTrack(canvas, size, p, rng);
        break;
      case _LandscapeVariant.southCoast:
      case _LandscapeVariant.northEstuary:
        _drawTrees(canvas, size, p, rng, count: 3, y: size.height * 0.65, spread: size.width * 0.3);
        break;
      case _LandscapeVariant.southWetlands:
        _drawTrees(canvas, size, p, rng, count: 6, y: size.height * 0.65, spread: size.width * 0.8);
        break;
    }
  }

  void _drawDynamicScene(Canvas canvas, Size size, _SceneryPalette p) {
    if (animationValue == 0) return;

    if (variant == _LandscapeVariant.centralValley || variant == _LandscapeVariant.eastCoast) {
      _drawTrain(canvas, size, p, animationValue);
    }

    if (variant == _LandscapeVariant.southCoast || variant == _LandscapeVariant.eastCoast || variant == _LandscapeVariant.northEstuary) {
      _drawWaves(canvas, size, p, animationValue);
    }

    if (variant == _LandscapeVariant.centralValley || variant == _LandscapeVariant.northEstuary || variant == _LandscapeVariant.southWetlands) {
      _drawWaterShimmer(canvas, size, p, animationValue);
    }
  }

  // ---------------------------------------------------------------------------
  // Generators (Static)
  // ---------------------------------------------------------------------------

  List<double> _generateFractal(int iterations, double roughness, Random rng) {
    List<double> points = [0.0, 0.0];
    for (int i = 0; i < iterations; i++) {
      List<double> newPoints = [];
      for (int j = 0; j < points.length - 1; j++) {
        newPoints.add(points[j]);
        double mid = (points[j] + points[j + 1]) / 2.0;
        mid += (rng.nextDouble() - 0.5) * roughness;
        newPoints.add(mid);
      }
      newPoints.add(points.last);
      points = newPoints;
      roughness *= 0.5;
    }
    return points;
  }

  void _drawMountain(Canvas canvas, Size size, Paint paint, double yStart, double yEnd, double heightRange, int iterations, double roughness, Random rng) {
    final path = Path()..moveTo(0, size.height)..lineTo(0, yStart);
    final points = _generateFractal(iterations, roughness, rng);
    
    for (int i = 0; i < points.length; i++) {
      double t = i / (points.length - 1);
      double x = t * size.width;
      double base = yStart + (yEnd - yStart) * t;
      double y = base + points[i] * heightRange;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRollingHills(Canvas canvas, Size size, Paint paint, double baseHeight, double amplitude, Random rng) {
    final path = Path()..moveTo(0, size.height)..lineTo(0, baseHeight);
    int segments = 4 + rng.nextInt(3);
    double step = size.width / segments;
    double currentX = 0;
    double currentY = baseHeight + (rng.nextDouble() - 0.5) * amplitude;

    for (int i = 0; i < segments; i++) {
      double nextX = currentX + step;
      double nextY = baseHeight + (rng.nextDouble() - 0.5) * amplitude;
      double controlX = currentX + step / 2;
      double controlY = currentY + (rng.nextDouble() - 0.5) * amplitude * 1.5;
      
      path.quadraticBezierTo(controlX, controlY, nextX, nextY);
      currentX = nextX;
      currentY = nextY;
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPlainsFields(Canvas canvas, Size size, _SceneryPalette p, Random rng, {double startY = 0.68}) {
    final landPaint = Paint()..color = p.land.withValues(alpha: 0.8);
    final darkPaint = Paint()..color = p.darkLand.withValues(alpha: 0.5);
    final ridgePaint = Paint()..color = p.accent.withValues(alpha: 0.3)..strokeWidth = 1.5;

    canvas.drawRect(Rect.fromLTWH(0, size.height * startY, size.width, size.height * (1 - startY)), landPaint);

    final path = Path();
    for (int i = 0; i < 4; i++) {
      double y1 = size.height * (startY + rng.nextDouble() * 0.1);
      double y2 = size.height * (startY + 0.1 + rng.nextDouble() * 0.2);
      double x1 = size.width * rng.nextDouble();
      double x2 = x1 + size.width * (0.2 + rng.nextDouble() * 0.3);
      
      path.moveTo(x1, y1);
      path.lineTo(x2, y1);
      path.lineTo(x2 - 40, y2);
      path.lineTo(x1 - 60, y2);
      path.close();
    }
    canvas.drawPath(path, darkPaint);

    for (int i = 0; i < 6; i++) {
      double y = size.height * (startY + pow(i / 5, 1.5) * (1 - startY));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ridgePaint);
    }
  }

  void _drawTerracedFields(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final landPaint = Paint()..color = p.land.withValues(alpha: 0.8);
    final ridgePaint = Paint()..color = p.accent.withValues(alpha: 0.4)..strokeWidth = 2.0..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, landPaint);

    for (int i = 0; i < 7; i++) {
      double y = size.height * (0.65 + i * 0.05);
      double ctrlY = y + 20 + rng.nextDouble() * 20;
      
      final ridge = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.4, ctrlY, size.width, y - 10 - rng.nextDouble()*10);
      canvas.drawPath(ridge, ridgePaint);
    }
  }

  void _drawRoadAndPoles(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final roadPaint = Paint()..color = p.darkLand.withValues(alpha: 0.6);
    
    final roadPath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.65)
      ..lineTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    final polePaint = Paint()..color = p.infrastructure.withValues(alpha: 0.8)..strokeWidth = 1.5;
    final wirePaint = Paint()..color = p.infrastructure.withValues(alpha: 0.4)..strokeWidth = 0.8..style = PaintingStyle.stroke;
    
    List<Offset> poleTops = [];
    int poleCount = 6;
    for (int i = 0; i < poleCount; i++) {
      double t = i / (poleCount - 1);
      double per = pow(t, 1.5).toDouble();
      
      double x = size.width * 0.62 + (size.width * 0.25 - size.width * 0.62) * per;
      double y = size.height * 0.65 + (size.height * 0.95 - size.height * 0.65) * per;
      double h = 10 + 40 * per;
      
      canvas.drawLine(Offset(x, y), Offset(x, y - h), polePaint);
      canvas.drawLine(Offset(x - h*0.2, y - h + h*0.1), Offset(x + h*0.2, y - h + h*0.1), polePaint);
      poleTops.add(Offset(x, y - h + h*0.1));
    }

    if (poleTops.length > 1) {
      for (int w = -1; w <= 1; w += 2) {
        final wire = Path()..moveTo(poleTops[0].dx + w*2, poleTops[0].dy);
        for (int i = 1; i < poleTops.length; i++) {
          double pPrev = pow((i-1)/(poleCount-1), 1.5).toDouble();
          double pCurr = pow(i/(poleCount-1), 1.5).toDouble();
          
          double startX = poleTops[i-1].dx + w * (2 + 4 * pPrev);
          double endX = poleTops[i].dx + w * (2 + 4 * pCurr);
          double midX = (startX + endX) / 2;
          double midY = (poleTops[i-1].dy + poleTops[i].dy) / 2 + 8 * pCurr; 
          
          wire.quadraticBezierTo(midX, midY, endX, poleTops[i].dy);
        }
        canvas.drawPath(wire, wirePaint);
      }
    }
  }

  void _drawHouseCluster(Canvas canvas, Size size, _SceneryPalette p, Random rng, double baseX, double baseY) {
    final wallPaint = Paint()..color = p.village.withValues(alpha: 0.85);
    final roofPaint = Paint()..color = p.roof.withValues(alpha: 0.95);
    final winPaint = Paint()..color = isNight ? p.light.withValues(alpha: 0.8) : p.water.withValues(alpha: 0.5);

    int count = 2 + rng.nextInt(3);
    for (int i = 0; i < count; i++) {
      double scale = 0.6 + rng.nextDouble() * 0.6;
      double x = baseX + (rng.nextDouble() - 0.5) * 60;
      double y = baseY + (rng.nextDouble() - 0.5) * 15;
      
      double w = 25 * scale;
      double h = 16 * scale;
      
      canvas.drawRect(Rect.fromLTWH(x, y - h, w, h), wallPaint);
      
      final roof = Path()
        ..moveTo(x - 3, y - h)
        ..lineTo(x + w / 2, y - h - 10 * scale)
        ..lineTo(x + w + 3, y - h)
        ..close();
      canvas.drawPath(roof, roofPaint);
      
      canvas.drawRect(Rect.fromLTWH(x + w * 0.2, y - h * 0.6, 6 * scale, 7 * scale), winPaint);
    }
  }

  void _drawBamboo(Canvas canvas, Size size, _SceneryPalette p, Random rng, Offset pos, double scale) {
    final stemPaint = Paint()..color = p.tree.withValues(alpha: 0.7)..strokeWidth = 1.5 * scale..style = PaintingStyle.stroke;
    final leafPaint = Paint()..color = p.tree.withValues(alpha: 0.85);

    int stems = 12 + rng.nextInt(8);
    for (int i = 0; i < stems; i++) {
      double h = (30 + rng.nextDouble() * 40) * scale;
      double ox = (rng.nextDouble() - 0.5) * 40 * scale;
      
      final stem = Path()
        ..moveTo(pos.dx + ox, pos.dy)
        ..quadraticBezierTo(
          pos.dx + ox + (rng.nextDouble() - 0.5) * 20 * scale, pos.dy - h * 0.5,
          pos.dx + ox + (rng.nextDouble() - 0.5) * 30 * scale, pos.dy - h
        );
      canvas.drawPath(stem, stemPaint);
      
      canvas.drawCircle(Offset(pos.dx + ox + (rng.nextDouble() - 0.5) * 30 * scale, pos.dy - h), 6 * scale, leafPaint);
    }
  }

  void _drawTrees(Canvas canvas, Size size, _SceneryPalette p, Random rng, {required int count, required double y, required double spread}) {
    final trunkPaint = Paint()..color = p.village.withValues(alpha: 0.7)..strokeWidth = 2;
    final crownPaint = Paint()..color = p.tree.withValues(alpha: 0.85);

    for (int i = 0; i < count; i++) {
      double x = spread * (0.1 + rng.nextDouble() * 0.8);
      double h = 15 + rng.nextDouble() * 20;
      double r = 8 + rng.nextDouble() * 8;
      
      canvas.drawLine(Offset(x, y), Offset(x, y - h), trunkPaint);
      canvas.drawCircle(Offset(x, y - h), r, crownPaint);
      canvas.drawCircle(Offset(x - r*0.6, y - h + 4), r*0.8, crownPaint);
      canvas.drawCircle(Offset(x + r*0.6, y - h + 4), r*0.8, crownPaint);
    }
  }

  void _drawRiver(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final waterPaint = Paint()..color = p.water.withValues(alpha: 0.75);
    final path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(0, size.height * 0.85, 0, size.height * 0.9)
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.65, size.width * 0.45, size.height * 0.6)
      ..close();
    canvas.drawPath(path, waterPaint);
  }

  void _drawWetlandWater(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final waterPaint = Paint()..color = p.water.withValues(alpha: 0.6);
    for (int i = 0; i < 4; i++) {
      double cx = size.width * (0.2 + rng.nextDouble() * 0.6);
      double cy = size.height * (0.7 + rng.nextDouble() * 0.2);
      double w = size.width * (0.2 + rng.nextDouble() * 0.3);
      double h = size.height * 0.05;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: w, height: h), waterPaint);
    }
  }

  void _drawEstuary(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final waterPaint = Paint()..color = p.water.withValues(alpha: 0.75);
    final path = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.68, size.width * 0.6, size.height * 0.62)
      ..lineTo(size.width, size.height * 0.62)
      ..lineTo(size.width, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, 0, size.height * 0.75)
      ..close();
    canvas.drawPath(path, waterPaint);
  }

  void _drawCoastBeach(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final beachPaint = Paint()..color = p.land.withValues(alpha: 0.75);
    final beach = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.53, size.width * 0.55, size.height * 0.59)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.64, size.width, size.height * 0.53)
      ..lineTo(size.width, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width * 0.52, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.59, 0, size.height * 0.65)
      ..close();
    canvas.drawPath(beach, beachPaint);
  }

  void _drawRailwayTrack(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final railPaint = Paint()..color = p.village.withValues(alpha: 0.5)..strokeWidth = 2.0;
    final sleeperPaint = Paint()..color = p.roof.withValues(alpha: 0.7)..strokeWidth = 3.0;

    double y = size.height * 0.70;
    canvas.drawLine(Offset(0, y), Offset(size.width, y + 10), railPaint);
    canvas.drawLine(Offset(0, y + 8), Offset(size.width, y + 18), railPaint);

    for (int i = 0; i < 25; i++) {
      double x = i * size.width / 24;
      double yOffset = (x / size.width) * 10;
      canvas.drawLine(Offset(x, y + yOffset - 2), Offset(x + 2, y + yOffset + 18), sleeperPaint);
    }
  }

  void _drawAtmosphere(Canvas canvas, Size size, _SceneryPalette p) {
    final haze = Paint()
      ..color = p.accent.withValues(alpha: isNight ? 0.02 : (isMorning ? 0.08 : 0.035));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.75), haze);
  }

  // ---------------------------------------------------------------------------
  // Generators (Dynamic)
  // ---------------------------------------------------------------------------

  void _drawTrain(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    double trainX = -150 + anim * (size.width + 300);
    double yOffset = (trainX / size.width) * 10;
    double y = size.height * 0.70 + yOffset;
    
    final bodyPaint = Paint()..color = p.village.withValues(alpha: 0.9);
    final winPaint = Paint()..color = isNight ? p.light.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.45);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(trainX, y - 22, 125, 18), const Radius.circular(3)), bodyPaint);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(trainX + 8 + i * 22, y - 18, 12, 7), winPaint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.08 : 0.16)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double shift = anim * 2 * pi;
    for (int r = 0; r < 5; r++) {
      double waveY = size.height * (0.68 + r * 0.065);
      final path = Path()..moveTo(0, waveY);
      for (int i = 0; i <= 10; i++) {
        double x = i * size.width / 10;
        double w = sin(x * 0.018 + shift + r) * 4;
        path.lineTo(x, waveY + w);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawWaterShimmer(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final shimmer = Paint()..color = Colors.white.withValues(alpha: 0.15)..strokeWidth = 1.0;
    double shift = anim * pi * 2;
    for (int i = 0; i < 6; i++) {
      double y = size.height * (0.65 + i * 0.04);
      double x = size.width * 0.3 + sin(shift + i) * 20 + i * 15;
      canvas.drawLine(Offset(x, y), Offset(x + 15 + sin(shift*2 + i)*10, y), shimmer);
    }
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) {
    return oldDelegate.biome != biome ||
        oldDelegate.dayPhase != dayPhase ||
        oldDelegate.variant != variant ||
        oldDelegate.animationValue != animationValue;
  }

  _SceneryPalette _palette() {
    if (isNight) {
      return const _SceneryPalette(
        farMountain: Color(0xFF17251F),
        nearMountain: Color(0xFF122019),
        land: Color(0xFF263D27),
        darkLand: Color(0xFF18271C),
        water: Color(0xFF173347),
        village: Color(0xFF201D19),
        roof: Color(0xFF34231C),
        tree: Color(0xFF142119),
        infrastructure: Color(0xFF101612),
        accent: Color(0xFF687A5A),
        light: Color(0xFFE8C978),
      );
    }

    if (isEvening) {
      return const _SceneryPalette(
        farMountain: Color(0xFF5C5144),
        nearMountain: Color(0xFF3A362F),
        land: Color(0xFF4B542F),
        darkLand: Color(0xFF303A25),
        water: Color(0xFF34546A),
        village: Color(0xFF393128),
        roof: Color(0xFF6A4030),
        tree: Color(0xFF263B27),
        infrastructure: Color(0xFF2D2620),
        accent: Color(0xFFB58B54),
        light: Color(0xFFFFD47A),
      );
    }

    if (isMorning) {
      return const _SceneryPalette(
        farMountain: Color(0xFF718778),
        nearMountain: Color(0xFF405746),
        land: Color(0xFF617342),
        darkLand: Color(0xFF3D5333),
        water: Color(0xFF6A9BA6),
        village: Color(0xFF655A4C),
        roof: Color(0xFF765140),
        tree: Color(0xFF355239),
        infrastructure: Color(0xFF4A443A),
        accent: Color(0xFF9BAA78),
        light: Color(0xFFFFE5A3),
      );
    }

    return const _SceneryPalette(
      farMountain: Color(0xFF70836E),
      nearMountain: Color(0xFF435D43),
      land: Color(0xFF607544),
      darkLand: Color(0xFF3A5135),
      water: Color(0xFF518A92),
      village: Color(0xFF655C4C),
      roof: Color(0xFF714B39),
      tree: Color(0xFF2F5135),
      infrastructure: Color(0xFF484236),
      accent: Color(0xFF8DA266),
      light: Color(0xFFFFE8B0),
    );
  }
}

class _SceneryPalette {
  final Color farMountain;
  final Color nearMountain;
  final Color land;
  final Color darkLand;
  final Color water;
  final Color village;
  final Color roof;
  final Color tree;
  final Color infrastructure;
  final Color accent;
  final Color light;

  const _SceneryPalette({
    required this.farMountain,
    required this.nearMountain,
    required this.land,
    required this.darkLand,
    required this.water,
    required this.village,
    required this.roof,
    required this.tree,
    required this.infrastructure,
    required this.accent,
    required this.light,
  });
}
