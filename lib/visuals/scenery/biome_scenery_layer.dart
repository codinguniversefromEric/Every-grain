import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/field_state.dart';

part 'local_scenery_foregrounds.dart';

/// 細分的台灣景觀變體。
///
/// 11 種涵蓋北中南東不同地形的實景風格。
///
/// 地景：分層山脈（背光面、溪谷紋、稜線受光、樹冠起伏、山腳霧化）、
/// 透視棋盤水田（秧苗、金黃稻穗、映天光的水田）、沿等高線的水梯田與茶園、
/// 辮狀礫石河床、河口紅樹林與灘地、海面波光。
///
/// 台灣意象：高鐵高架、台北 101 天際線、貓空纜車、阿里山森林鐵路、
/// 紅色拱橋、鹿野熱氣球、白色燈塔、漁電共生光電板、風力發電、
/// 現代住宅（太陽能屋頂、陽台植栽）、日式老屋與彩繪牆、三合院、
/// 廟宇（剪黏、紅燈籠、香爐）、夜市、自行車騎士、茶園、鳳梨田、
/// 金針花、芒草、白鷺鷥、天燈（夜晚）。
///
/// 聚落點綴依 session seed 從各變體的槽位池隨機抽選，
/// 同一 session 內穩定，每次開啟組合不同。
enum LandscapeVariant {
  // Plains (對應中南部平原)
  centralPlains,
  southPlains,
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

// =============================================================================
// 聚落點綴的版面配置（純函式：只由 variant + seed 決定，靜態與動態層共用）
// =============================================================================

enum _Decor {
  sanheyuan, // 三合院
  temple, // 廟宇（含廟埕、香爐）
  shrine, // 土地公廟
  modernHouse, // 現代住宅（太陽能屋頂）
  artHouse, // 日式老屋 + 彩繪牆
  nightMarket, // 夜市
  houseCluster, // 一般農舍
}

class _Placement {
  final _Decor decor;
  final double fx;
  final double fy;
  final double scale;

  const _Placement(this.decor, this.fx, this.fy, this.scale);

  Offset at(Size s) => Offset(s.width * fx, s.height * fy);
}

class _Slot {
  final double fx;
  final double fy;
  final double scale;
  final List<_Decor> pool; // 重複項目 = 加權

  const _Slot(this.fx, this.fy, this.scale, this.pool);
}

/// 山丘：用比例座標描述，梯田與茶園沿它的等高線展開
class _Mound {
  final double cx; // 山頂 x（寬度比例）
  final double peak; // 山頂 y（高度比例）
  final double halfW; // 半寬（寬度比例）
  final double base; // 山腳 y（高度比例）
  const _Mound(this.cx, this.peak, this.halfW, this.base);
}

enum _HillStyle { paddy, tea }

class _SceneLayout {
  final List<_Placement> placements;
  final bool road; // 有道路 → 自行車騎士

  const _SceneLayout({
    required this.placements,
    this.road = false,
  });

  bool get hasDynamic =>
      road ||
      placements.any(
          (p) => p.decor == _Decor.temple || p.decor == _Decor.shrine);

  static const _repeatable = {_Decor.modernHouse, _Decor.houseCluster};

  static _SceneLayout compute(LandscapeVariant v, int seed) {
    final rng = Random(seed * 31 + v.index * 7919);
    var slots = const <_Slot>[];
    var road = false;

    switch (v) {
      case LandscapeVariant.centralPlains:
        break;
      case LandscapeVariant.southPlains:
        break;
      case LandscapeVariant.eastRiftValley:
        road = true;
        slots = const [
          _Slot(0.84, 0.68, 0.75, [
            _Decor.sanheyuan,
            _Decor.modernHouse,
            _Decor.artHouse,
            _Decor.temple,
          ]),
          _Slot(0.14, 0.665, 0.8, [_Decor.artHouse, _Decor.modernHouse]),
        ];
      case LandscapeVariant.northHills:
        break;
      case LandscapeVariant.centralHills:
        break;
      case LandscapeVariant.northTerraces:
        slots = const [
          _Slot(0.5, 0.69, 0.6, [_Decor.shrine, _Decor.artHouse]),
        ];
      case LandscapeVariant.eastFoothills:
        slots = const [
          _Slot(0.62, 0.7, 0.6, [
            _Decor.modernHouse,
            _Decor.shrine,
            _Decor.houseCluster,
          ]),
        ];
      case LandscapeVariant.centralValley:
        slots = const [
          _Slot(0.8, 0.84, 0.75, [
            _Decor.modernHouse,
            _Decor.sanheyuan,
            _Decor.shrine,
            _Decor.artHouse,
          ]),
        ];
      case LandscapeVariant.eastCoast:
        break; // 斷崖海岸保持自然
      case LandscapeVariant.southCoast:
        slots = const [
          _Slot(0.2, 0.62, 0.75, [
            _Decor.temple,
            _Decor.temple,
            _Decor.modernHouse,
          ]),
          _Slot(0.3, 0.74, 1.05, [_Decor.nightMarket, _Decor.artHouse]),
        ];
      case LandscapeVariant.northEstuary:
        slots = const [
          _Slot(0.42, 0.84, 0.95, [
            _Decor.nightMarket,
            _Decor.artHouse,
            _Decor.temple,
          ]),
          _Slot(0.78, 0.86, 0.9, [
            _Decor.modernHouse,
            _Decor.houseCluster,
            _Decor.sanheyuan,
            _Decor.temple,
          ]),
        ];
    }

    final used = <_Decor>{};
    final placements = <_Placement>[];
    for (final slot in slots) {
      var cands = slot.pool
          .where((d) => !used.contains(d) || _repeatable.contains(d))
          .toList();
      if (cands.isEmpty) cands = slot.pool;
      final d = cands[rng.nextInt(cands.length)];
      used.add(d);
      placements.add(_Placement(
        d,
        slot.fx + (rng.nextDouble() - 0.5) * 0.04,
        slot.fy,
        slot.scale * (0.92 + rng.nextDouble() * 0.16),
      ));
    }

    return _SceneLayout(
      placements: placements,
      road: road,
    );
  }
}

// =============================================================================
// Widget
// =============================================================================

class BiomeSceneryLayer extends StatefulWidget {
  final SceneryBiome biome;
  final DayPhase dayPhase;
  final LandscapeVariant? variantOverride;
  final bool interactive;

  const BiomeSceneryLayer({
    super.key,
    required this.biome,
    required this.dayPhase,
    this.variantOverride,
    this.interactive = false,
  });

  @override
  State<BiomeSceneryLayer> createState() => _BiomeSceneryLayerState();
}

class _BiomeSceneryLayerState extends State<BiomeSceneryLayer>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _touchController;
  late final Listenable _repaint;
  Offset? _touch;

  late LandscapeVariant _variant;
  late int _seed;
  late _SceneLayout _layout;
  final SceneryCache _cache = SceneryCache();

  // 每個 Session 隨機分配各 Biome 的 Seed，確保同一開啟期間地貌穩定，但每次開啟有驚喜
  static final Map<SceneryBiome, int> _sessionSeeds = {
    SceneryBiome.plains: 1729 + Random().nextInt(10000),
    SceneryBiome.terraces: 2819 + Random().nextInt(10000),
    SceneryBiome.valley: 3947 + Random().nextInt(10000),
    SceneryBiome.coast: 5173 + Random().nextInt(10000),
  };

  // 白天完全靜態的變體（其餘都有高鐵、纜車、熱氣球、海浪等動態元素）
  static const _staticByDay = {
    LandscapeVariant.northTerraces,
    LandscapeVariant.eastFoothills,
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    );

    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      value: 1,
    );
    _repaint = Listenable.merge([_controller, _touchController]);
    _updateScene(force: true);
  }

  @override
  void didUpdateWidget(covariant BiomeSceneryLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.biome != widget.biome ||
        oldWidget.variantOverride != widget.variantOverride) {
      _touch = null;
      _touchController.value = 1;
      _updateScene(force: true);
    } else if (oldWidget.dayPhase != widget.dayPhase) {
      _updateScene(force: false);
    }
  }

  void _updateScene({bool force = false}) {
    if (widget.variantOverride != null) {
      _variant = widget.variantOverride!;
    } else {
      final variants = _variantsFor(widget.biome);

      if (force || !variants.contains(_variant)) {
        final index = _sessionSeeds[widget.biome]! % variants.length;
        _variant = variants[index];
      }
    }

    _seed = _sessionSeeds[widget.biome]!;
    _layout = _SceneLayout.compute(_variant, _seed);

    final needsAnimation = !_staticByDay.contains(_variant) ||
        _layout.hasDynamic ||
        widget.dayPhase == DayPhase.night;

    if (needsAnimation) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  List<LandscapeVariant> _variantsFor(SceneryBiome biome) {
    switch (biome) {
      case SceneryBiome.plains:
        return const [
          LandscapeVariant.centralPlains,
          LandscapeVariant.southPlains,
        ];
      case SceneryBiome.terraces:
        return const [
          LandscapeVariant.northHills,
          LandscapeVariant.northTerraces,
          LandscapeVariant.centralHills,
        ];
      case SceneryBiome.valley:
        return const [
          LandscapeVariant.centralValley,
          LandscapeVariant.eastRiftValley,
          LandscapeVariant.eastFoothills,
        ];
      case SceneryBiome.coast:
        return const [
          LandscapeVariant.northEstuary,
          LandscapeVariant.southCoast,
          LandscapeVariant.eastCoast,
        ];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _touchController.dispose();
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _repaint,
        builder: (context, child) {
          return CustomPaint(
            painter: _SceneryPainter(
              biome: widget.biome,
              dayPhase: widget.dayPhase,
              variant: _variant,
              animationValue: _controller.value,
              seed: _seed,
              layout: _layout,
              cache: _cache,
              touch: _touch,
              touchProgress: _touchController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
    if (!widget.interactive) return scene;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        _touch = details.localPosition;
        _touchController.forward(from: 0);
      },
      child: scene,
    );
  }
}

// =============================================================================
// Painter
// =============================================================================

class _Cyclist {
  final Offset pos;
  final double scale;
  final bool approach;
  final Color helmet;
  final Color jersey;
  final double pedal;
  final double opacity;

  const _Cyclist({
    required this.pos,
    required this.scale,
    required this.approach,
    required this.helmet,
    required this.jersey,
    required this.pedal,
    this.opacity = 1,
  });
}

class _SceneryPainter extends CustomPainter {
  final SceneryBiome biome;
  final DayPhase dayPhase;
  final LandscapeVariant variant;
  final double animationValue;
  final int seed;
  final _SceneLayout layout;
  final SceneryCache cache;
  final Offset? touch;
  final double touchProgress;

  _SceneryPainter({
    required this.biome,
    required this.dayPhase,
    required this.variant,
    required this.animationValue,
    required this.seed,
    required this.layout,
    required this.cache,
    required this.touch,
    required this.touchProgress,
  });

  bool get isNight => dayPhase == DayPhase.night;
  bool get isEvening => dayPhase == DayPhase.evening;
  bool get isMorning => dayPhase == DayPhase.morning;

  /// 把固定色依時段調暗／調暖
  Color _tone(Color c) {
    if (isNight) return Color.lerp(c, const Color(0xFF0D1419), 0.7)!;
    if (isEvening) return Color.lerp(c, const Color(0xFF4A2E22), 0.3)!;
    if (isMorning) return Color.lerp(c, const Color(0xFFFFF4E0), 0.06)!;
    return c;
  }

  // ---------------------------------------------------------------------------
  // 幾何工具
  // ---------------------------------------------------------------------------

  Offset _cubic(Offset a, Offset b, Offset c, Offset d, double t) {
    final mt = 1 - t;
    return a * (mt * mt * mt) +
        b * (3 * mt * mt * t) +
        c * (3 * mt * t * t) +
        d * (t * t * t);
  }

  Offset _cubicTangent(Offset a, Offset b, Offset c, Offset d, double t) {
    final mt = 1 - t;
    return (b - a) * (3 * mt * mt) + (c - b) * (6 * mt * t) + (d - c) * (3 * t * t);
  }

  Offset _quad(Offset a, Offset c, Offset b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);

  // 河道（中部溪谷）：從地平線往下流出，再往左下展開
  static const _riverCtrl = [
    Offset(0.56, 0.69),
    Offset(0.57, 0.77),
    Offset(0.20, 0.82),
    Offset(0.04, 1.08),
  ];

  (Offset, Offset, double) _riverFrame(Size size, double t) {
    Offset sc(Offset o) => Offset(o.dx * size.width, o.dy * size.height);
    final a = sc(_riverCtrl[0]),
        b = sc(_riverCtrl[1]),
        c = sc(_riverCtrl[2]),
        d = sc(_riverCtrl[3]);
    final pt = _cubic(a, b, c, d, t);
    final tan = _cubicTangent(a, b, c, d, t);
    final normal = Offset(-tan.dy, tan.dx) / tan.distance;
    return (pt, normal, _riverHalfWidth(size, t));
  }

  double _riverHalfWidth(Size size, double t) =>
      (0.008 + 0.092 * t) * size.width;

  Offset _channelCenter(Size size, double t, int ch) {
    final (pt, nrm, half) = _riverFrame(size, t);
    final bend = 0.14 * sin(t * 2 * pi);
    final braid = (0.43 + 0.19 * sin(t * 3 * pi)) * min(1.0, t * 6);
    final shift = switch (ch) {
      1 => bend - braid,
      2 => bend + braid,
      _ => bend,
    };
    return pt + nrm * (half * shift);
  }

  double _channelHalf(Size size, double t, int ch) =>
      _riverHalfWidth(size, t) *
      (ch == 0 ? 0.30 : 0.085 + 0.045 * sin(t * pi));

  // 貓空纜車
  Offset _gondA(Size s) => Offset(-0.05 * s.width, 0.47 * s.height);
  Offset _gondB(Size s) => Offset(0.62 * s.width, 0.652 * s.height);
  Offset _gondC(Size s) => (_gondA(s) + _gondB(s)) / 2 + const Offset(0, 14);

  // 騎士在農路上的起點
  static const double _cyclistT0 = 0.09;

  // 平原透視（棋盤田、水塘、光電板、蚵架、金針花、道路共用）
  static const double _plainsTop = 0.64;

  Offset _plainsVp(Size s, [double startY = _plainsTop]) =>
      Offset(s.width * 0.5, s.height * startY - s.height * 0.06);

  /// 把「地面基準座標 xb」（以畫面底邊為基準）投影到螢幕 y 高度上的 x
  double _plainsX(Size s, double xb, double y, [double startY = _plainsTop]) {
    final vp = _plainsVp(s, startY);
    return vp.dx + (xb - vp.dx) * (y - vp.dy) / (s.height - vp.dy);
  }

  // 鄉間道路：由中間偏右的地平線往右下延伸，避開畫面中央的稻株
  double _roadCx(double t) => 0.64 + 0.22 * t + 0.045 * sin(pi * t);
  double _roadHalf(double t) => 0.006 + 0.104 * t;
  double _roadY(double t) => _plainsTop + (1 - _plainsTop) * t;

  // 燈塔
  static const double _lhScale = 1.1;
  Offset _lhBase(Size s) => Offset(s.width * 0.06, s.height * 0.545);
  Offset _lhLamp(Size s) => _lhBase(s).translate(0, -24.5 * _lhScale);

  // 風機（河口左側）：高度以寬度為基準，直立螢幕才不會過高
  double _turbineBaseY(Size size, int i) => size.height * (0.62 + i * 0.008);
  double _turbineHeight(Size size, int i) => size.width * (0.2 - i * 0.03);
  double _turbineRadius(Size size, int i) => size.width * (0.045 - i * 0.007);

  List<Offset> _turbineHubs(Size size) => [
        for (int i = 0; i < 3; i++)
          Offset(size.width * (0.08 + i * 0.12),
              _turbineBaseY(size, i) - _turbineHeight(size, i)),
      ];

  // ---------------------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;

    final p = _palette();
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRect(bounds);

    final currentKey =
        '${variant.name}_${size.width}x${size.height}_${dayPhase.name}_$seed';

    if (cache.key != currentKey || cache.picture == null) {
      final recorder = ui.PictureRecorder();
      final recordCanvas = Canvas(recorder, bounds);
      recordCanvas.save();
      _frameLandscape(recordCanvas, size);
      _drawStaticScene(recordCanvas, size, p);
      recordCanvas.restore();
      _drawLocalForeground(recordCanvas, size, p);

      cache.picture?.dispose();
      cache.picture = recorder.endRecording();
      cache.key = currentKey;
    }

    if (cache.picture != null) {
      canvas.drawPicture(cache.picture!);
    }

    canvas.save();
    _frameLandscape(canvas, size);
    _drawDynamicScene(canvas, size, p);
    canvas.restore();
    if (touch case final point? when touchProgress < 1) {
      _drawSceneryTouch(canvas, size, p, point, touchProgress);
    }
    canvas.restore();
  }

  // ===========================================================================
  // 靜態場景
  // ===========================================================================

  void _drawStaticScene(Canvas canvas, Size size, _SceneryPalette p) {
    final rng = Random(seed);
    final h = size.height;
    final w = size.width;

    _drawAtmosphere(canvas, size, p);

    // 1. 背景
    switch (variant) {
      case LandscapeVariant.eastRiftValley:
      case LandscapeVariant.centralValley:
        // 遠方山稜：填補兩側稜線交會處的缺口
        _drawMountain(canvas, size, p, p.farMountain, 0.28, h * 0.5, h * 0.52,
            30, 6, 1.0, rng);
        _drawMountain(canvas, size, p, p.farMountain, 0.5, h * 0.3, h * 0.7,
            50, 6, 1.5, rng);
        _drawMistBand(canvas, size, h * 0.52, 46, p, 0.16);
        _drawMountain(canvas, size, p, p.nearMountain, 0.65, h * 0.8, h * 0.4,
            40, 6, 1.3, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.62, 30, p, 0.10);
      case LandscapeVariant.eastFoothills:
      case LandscapeVariant.northTerraces:
        _drawMountain(canvas, size, p, p.farMountain, 0.4, h * 0.35, h * 0.65,
            45, 6, 1.2, rng);
        _drawMistBand(canvas, size, h * 0.5, 50, p, 0.18);
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.55, h * 0.56, 50, rng,
            forested: true);
        _drawMountain(canvas, size, p, p.nearMountain, 0.65, h * 0.2, h * 0.8,
            60, 6, 1.4, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.64, 34, p, 0.12);
      case LandscapeVariant.northHills:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.54, h * 0.43, h * 0.12, rng);
        _drawMistBand(canvas, size, h * 0.6, 36, p, 0.14);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.65, h * 0.59, h * 0.09, rng,
            forested: true);
      case LandscapeVariant.centralHills:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.45, h * 0.55, 60, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.6, 36, p, 0.12);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.65, h * 0.65, 40, rng,
            forested: true);
      case LandscapeVariant.centralPlains:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.50, h * 0.49, h * 0.072, rng);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.42, h * 0.57, h * 0.042, rng);
        _drawMistBand(canvas, size, h * 0.59, 36, p, 0.16);
      case LandscapeVariant.southCoast:
      case LandscapeVariant.eastCoast:
        _drawOcean(canvas, size, p, h * 0.58);
        if (variant == LandscapeVariant.eastCoast) {
          _drawDistantIsland(canvas, size, p, h * 0.58);
          // 清水斷崖意象：只佔左半，直落海面
          _drawMountain(canvas, size, p, p.nearMountain, 0.78, h * 0.34,
              h * 0.575, 30, 5, 1.2, rng,
              forested: true, xEndFrac: 0.55, bottomY: h * 0.582);
          _drawMistBand(canvas, size, h * 0.47, 30, p, 0.14);
        }
      case LandscapeVariant.northEstuary:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.45, h * 0.6, 30, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.62, 24, p, 0.10);
      case LandscapeVariant.southPlains:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.54, h * 0.47, h * 0.10, rng);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.50, h * 0.59, h * 0.085, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.57, 26, p, 0.10);

    }

    // 2. 中景
    switch (variant) {
      case LandscapeVariant.centralPlains:
      case LandscapeVariant.eastRiftValley:
        _drawPlainsFields(canvas, size, p);
      case LandscapeVariant.southPlains:
        break;
      case LandscapeVariant.northHills:
        break;
      case LandscapeVariant.centralHills:
        _drawHillMounds(canvas, size, p, rng, _HillStyle.tea);
      case LandscapeVariant.northTerraces:
      case LandscapeVariant.eastFoothills:
        _drawHillMounds(canvas, size, p, rng, _HillStyle.paddy);
      case LandscapeVariant.centralValley:
        _drawPlainsFields(canvas, size, p, startY: 0.69);
        _drawRiver(canvas, size, p, rng);
      case LandscapeVariant.northEstuary:
        _drawEstuary(canvas, size, p, rng);
      case LandscapeVariant.southCoast:
      case LandscapeVariant.eastCoast:
        _drawCoastBeach(canvas, size, p);
    }

    // 3 + 4. 直立物件（固定元素 + 聚落）：收集後依接地 y 由遠到近畫。
    // 平面的東西（路面、軌道、花田）直接畫，墊在最底下。
    final standing = <({double y, void Function() draw})>[];
    void stand(double y, void Function() draw) =>
        standing.add((y: y, draw: draw));

    switch (variant) {
      case LandscapeVariant.centralPlains:
        stand(h * 0.69,
            () => _drawTrees(canvas, size, p, rng,
                count: 2, y: h * 0.69, spread: w * 0.15, x0: w * 0.08,
                scale: _decorScale(0.69)));
      case LandscapeVariant.southPlains:
        break;
      case LandscapeVariant.eastRiftValley:
        _drawRoadSurface(canvas, size, p);
      case LandscapeVariant.northHills:
        stand(h * 0.652, () => _drawGondolaLine(canvas, size, p));
        stand(h * 0.68,
            () => _drawBamboo(canvas, p, rng, Offset(w * 0.85, h * 0.68), 0.8));
      case LandscapeVariant.centralHills:
        stand(h * 0.68,
            () => _drawBamboo(canvas, p, rng, Offset(w * 0.12, h * 0.68), 0.8));
      case LandscapeVariant.northTerraces:
        stand(h * 0.7,
            () => _drawTrees(canvas, size, p, rng, count: 4, y: h * 0.7, spread: w));
        stand(
            h * 0.78,
            () => _drawSilvergrassCluster(
                canvas, p, rng, Offset(w * 0.8, h * 0.78), 1.0));
      case LandscapeVariant.eastFoothills:
        stand(h * 0.7,
            () => _drawTrees(canvas, size, p, rng, count: 5, y: h * 0.7, spread: w));
        stand(
            h * 0.8,
            () => _drawSilvergrassCluster(
                canvas, p, rng, Offset(w * 0.2, h * 0.8), 1.1));
      case LandscapeVariant.centralValley:
        _drawRailwayTrack(canvas, size, p);
        stand(
            h * 0.76,
            () => _drawTrees(canvas, size, p, rng,
                count: 3, y: h * 0.76, spread: w * 0.4, x0: w * 0.58));
      case LandscapeVariant.eastCoast:
        stand(
            h * 0.72,
            () => _drawPalmTrees(canvas, p, rng,
                count: 2, y: h * 0.72, spread: w * 0.3));
      case LandscapeVariant.southCoast:
        stand(h * 0.545, () => _drawLighthouse(canvas, size, p));
        stand(
            h * 0.62,
            () => _drawPalmTrees(canvas, p, rng,
                count: 3, y: h * 0.62, spread: w * 0.45));
      case LandscapeVariant.northEstuary:
        stand(h * 0.62, () => _drawWindTurbinePylons(canvas, size, p));
        stand(
            h * 0.82,
            () => _drawSilvergrassCluster(
                canvas, p, rng, Offset(w * 0.15, h * 0.82), 1.0));
    }

    for (final pl in layout.placements) {
      stand(h * pl.fy, () => _drawDecor(canvas, size, p, rng, pl));
    }

    // 同一 y 時保留加入順序，確保同一 seed 每次畫出來一樣
    final order = List<int>.generate(standing.length, (i) => i)
      ..sort((a, b) {
        final c = standing[a].y.compareTo(standing[b].y);
        return c != 0 ? c : a.compareTo(b);
      });
    for (final i in order) {
      standing[i].draw();
    }
  }

  void _drawDecor(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      _Placement pl) {
    final pos = pl.at(size);
    final s = pl.scale * _decorScale(pl.fy);
    switch (pl.decor) {
      case _Decor.sanheyuan:
        _drawSanheyuan(canvas, p, pos, s);
      case _Decor.temple:
        _drawTemple(canvas, p, pos, s, plaza: true);
      case _Decor.shrine:
        _drawTemple(canvas, p, pos, s, plaza: false);
      case _Decor.modernHouse:
        _drawModernHouses(canvas, p, pos, s, rng);
      case _Decor.artHouse:
        _drawArtHouse(canvas, p, pos, s, rng);
      case _Decor.nightMarket:
        _drawNightMarket(canvas, p, pos, s, rng);
      case _Decor.houseCluster:
        _drawHouseCluster(canvas, p, rng, pos.dx - 12, pos.dy);
    }
  }

  /// 建築依距離縮放：地平線附近小、近景大
  double _decorScale(double fy) {
    final depth = ((fy - 0.6) / 0.4).clamp(0.0, 1.0);
    return 0.55 + 0.75 * depth;
  }

  // ===========================================================================
  // 動態場景
  // ===========================================================================

  void _drawDynamicScene(Canvas canvas, Size size, _SceneryPalette p) {
    if (animationValue == 0) return;
    final anim = animationValue;

    if (variant == LandscapeVariant.eastRiftValley) {
      _drawBalloons(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralValley) {
      _drawTrain(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.southCoast ||
        variant == LandscapeVariant.eastCoast) {
      _drawWaves(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.southCoast ||
        variant == LandscapeVariant.eastCoast ||
        variant == LandscapeVariant.northEstuary) {
      _drawFishingBoat(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralValley ||
        variant == LandscapeVariant.northEstuary) {
      _drawWaterShimmer(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralPlains ||
        variant == LandscapeVariant.southPlains ||
        variant == LandscapeVariant.eastRiftValley) {
      _drawEgretsFlying(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.northEstuary) {
      _drawWindTurbineBlades(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.northHills) {
      _drawGondolaCabins(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.southCoast) {
      _drawLighthouseBeam(canvas, size, p, anim);
    }

    for (int i = 0; i < layout.placements.length; i++) {
      final pl = layout.placements[i];
      final pos = pl.at(size);
      final s = pl.scale * _decorScale(pl.fy);
      switch (pl.decor) {
        case _Decor.temple:
          _drawIncenseSmoke(
              canvas, _burnerPos(pos, s, true) - Offset(0, 2 * s), s, anim, i);
        case _Decor.shrine:
          _drawIncenseSmoke(canvas,
              _burnerPos(pos, s, false) - Offset(0, 1.6 * s), s, anim, i);
        case _Decor.nightMarket:
          _drawNightMarketLights(canvas, p, pos, s, anim);
        default:
          break;
      }
    }

    if (layout.road) {
      _drawCyclists(canvas, size, p, anim);
    }

    if (isNight &&
        (variant == LandscapeVariant.northHills ||
            variant == LandscapeVariant.northTerraces ||
            variant == LandscapeVariant.centralHills ||
            variant == LandscapeVariant.eastFoothills)) {
      _drawSkyLanterns(canvas, size, p, anim);
    }
  }

  // ===========================================================================
  // 地形：山、丘陵、霧、海
  // ===========================================================================

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

  /// 山脈：漸層山體（山腳霧化）、背光面、溪谷紋、稜線受光、樹冠起伏
  void _drawMountain(
      Canvas canvas,
      Size size,
      _SceneryPalette p,
      Color color,
      double alpha,
      double yStart,
      double yEnd,
      double heightRange,
      int iterations,
      double roughness,
      Random rng,
      {bool forested = false, double xEndFrac = 1.0, double? bottomY}) {
    final pts = _generateFractal(iterations, roughness, rng);
    final xEnd = size.width * xEndFrac;
    final bottom = bottomY ?? size.height;
    final ridge = <Offset>[
      for (int i = 0; i < pts.length; i++)
        Offset(
            i / (pts.length - 1) * xEnd,
            yStart +
                (yEnd - yStart) * (i / (pts.length - 1)) +
                pts[i] * heightRange),
    ];

    var body = Path()..moveTo(0, bottom);
    for (final o in ridge) {
      body.lineTo(o.dx, o.dy);
    }
    body
      ..lineTo(xEnd, bottom)
      ..close();

    if (forested) {
      final bumps = Path();
      for (final o in ridge) {
        bumps.addOval(Rect.fromCircle(
            center: o.translate(0, 1.4), radius: 1.5 + rng.nextDouble() * 2.2));
      }
      body = ui.Path.combine(ui.PathOperation.union, body, bumps);
    }

    final top = ridge.map((o) => o.dy).reduce(min);
    final foot = min(size.height, max(yStart, yEnd) + heightRange + 60);
    canvas.drawPath(
        body,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, foot), [
            color.withValues(alpha: alpha),
            Color.lerp(color, p.haze, 0.3)!.withValues(alpha: alpha),
          ]));

    // 背光面與溪谷（遠山太淡時不畫，否則像刮痕）
    final shadeColor = Color.lerp(color, Colors.black, 0.4)!;
    final gully = Paint()
      ..color = shadeColor.withValues(alpha: alpha * 0.28)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 3; alpha >= 0.45 && i < ridge.length - 3; i++) {
      final y = ridge[i].dy;
      var isPeak = true;
      for (int k = -3; k <= 3; k++) {
        if (k != 0 && ridge[i + k].dy < y) {
          isPeak = false;
          break;
        }
      }
      if (!isPeak) continue;

      var j = i;
      while (j < ridge.length - 1 && ridge[j + 1].dy >= ridge[j].dy) {
        j++;
      }
      if (j - i < 2) continue;

      final depth = (ridge[j].dy - y) * 1.6 + 26;
      final facet = Path()..moveTo(ridge[i].dx, ridge[i].dy);
      for (int k = i + 1; k <= j; k++) {
        facet.lineTo(ridge[k].dx, ridge[k].dy);
      }
      facet
        ..lineTo(ridge[j].dx, ridge[j].dy + depth * 0.5)
        ..lineTo(ridge[i].dx + (ridge[j].dx - ridge[i].dx) * 0.2,
            ridge[i].dy + depth)
        ..close();
      canvas.drawPath(
          facet,
          Paint()
            ..shader = ui.Gradient.linear(
                ridge[i], Offset(ridge[i].dx, ridge[i].dy + depth), [
              shadeColor.withValues(alpha: alpha * 0.42),
              shadeColor.withValues(alpha: 0),
            ]));

      for (int g = 0; g < 2; g++) {
        var gx = ridge[i].dx + (rng.nextDouble() - 0.3) * 8;
        var gy = y + 2;
        final gp = Path()..moveTo(gx, gy);
        for (int sgm = 0; sgm < 5; sgm++) {
          gx += (rng.nextDouble() - 0.3) * 6;
          gy += 4 + rng.nextDouble() * 5;
          gp.lineTo(gx, gy);
        }
        canvas.drawPath(gp, gully);
      }
    }

    // 稜線受光
    final rim = Path()..moveTo(ridge.first.dx, ridge.first.dy);
    for (final o in ridge.skip(1)) {
      rim.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
        rim,
        Paint()
          ..color = Color.lerp(color, p.light, 0.55)!
              .withValues(alpha: isNight ? 0.06 : 0.25 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  /// 丘陵：柔和稜線、漸層、樹冠與坡面樹叢
  void _drawRollingHills(Canvas canvas, Size size, _SceneryPalette p,
      Color color, double alpha, double baseHeight, double amplitude, Random rng,
      {bool forested = false}) {
    final crest = <Offset>[];
    final segments = 4 + rng.nextInt(3);
    final step = size.width / segments;
    double currentX = 0;
    double currentY = baseHeight + (rng.nextDouble() - 0.5) * amplitude;
    crest.add(Offset(0, currentY));

    for (int i = 0; i < segments; i++) {
      final nextX = currentX + step;
      final nextY = baseHeight + (rng.nextDouble() - 0.5) * amplitude;
      final cx = currentX + step / 2;
      final cy = currentY + (rng.nextDouble() - 0.5) * amplitude * 1.5;
      for (int k = 1; k <= 10; k++) {
        crest.add(_quad(
            Offset(currentX, currentY), Offset(cx, cy), Offset(nextX, nextY), k / 10));
      }
      currentX = nextX;
      currentY = nextY;
    }

    var body = Path()..moveTo(0, size.height);
    for (final o in crest) {
      body.lineTo(o.dx, o.dy);
    }
    body
      ..lineTo(size.width, size.height)
      ..close();

    if (forested) {
      final bumps = Path();
      for (final o in crest) {
        bumps.addOval(Rect.fromCircle(
            center: o.translate((rng.nextDouble() - 0.5) * 3, 1.2),
            radius: 1.6 + rng.nextDouble() * 2.4));
      }
      body = ui.Path.combine(ui.PathOperation.union, body, bumps);
    }

    final top = crest.map((o) => o.dy).reduce(min) - 4;
    canvas.drawPath(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
              Offset(0, top),
              Offset(0, min(size.height, top + amplitude * 2 + 80)), [
            color.withValues(alpha: alpha),
            Color.lerp(color, p.haze, 0.3)!.withValues(alpha: alpha),
          ]));

    final rim = Path()..moveTo(crest.first.dx, crest.first.dy);
    for (final o in crest.skip(1)) {
      rim.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
        rim,
        Paint()
          ..color = Color.lerp(color, p.light, 0.55)!
              .withValues(alpha: isNight ? 0.06 : 0.3 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    if (forested) {
      final clumps = Path();
      for (int i = 0; i < 40; i++) {
        final o = crest[rng.nextInt(crest.length)];
        clumps.addOval(Rect.fromCircle(
            center: o.translate(
                (rng.nextDouble() - 0.5) * 8, 4 + rng.nextDouble() * 22),
            radius: 1.2 + rng.nextDouble() * 2));
      }
      canvas.drawPath(
          clumps,
          Paint()
            ..color = Color.lerp(color, Colors.black, 0.25)!
                .withValues(alpha: alpha * 0.45));
    }
  }

  void _drawMistBand(Canvas canvas, Size size, double y, double thickness,
      _SceneryPalette p, double alpha) {
    // 柔化：厚度加倍、不透明度減半，避免變成明顯的灰色橫條
    thickness *= 2.2;
    final a = (isNight ? alpha * 0.4 : alpha) * 0.45;
    final mistColor = isNight ? const Color(0xFFBFD4E0) : Colors.white;
    final rect = Rect.fromLTWH(0, y - thickness / 2, size.width, thickness);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            [
              mistColor.withValues(alpha: 0),
              mistColor.withValues(alpha: a),
              mistColor.withValues(alpha: 0),
            ],
            [0.0, 0.5, 1.0],
          ));
  }

  void _drawAtmosphere(Canvas canvas, Size size, _SceneryPalette p) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.75);
    final glow = isMorning || isEvening ? 0.12 : (isNight ? 0.02 : 0.05);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
            p.accent.withValues(alpha: glow * 0.3),
            p.light.withValues(alpha: glow),
          ]));
  }

  /// 海面：漸層、海平線微光、波光帶
  void _drawOcean(Canvas canvas, Size size, _SceneryPalette p, double top) {
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
            Color.lerp(p.water, p.haze, 0.3)!.withValues(alpha: 0.85),
            Color.lerp(p.water, Colors.black, 0.25)!.withValues(alpha: 0.92),
          ]));
    canvas.drawRect(Rect.fromLTWH(0, top, size.width, 2),
        Paint()..color = p.light.withValues(alpha: isNight ? 0.06 : 0.22));

    final gx = size.width * 0.72;
    final rng2 = Random(seed + 3);
    final glitter = Paint()..strokeWidth = 1.2;
    for (int r = 0; r < 16; r++) {
      final y = top + 3 + r * (size.height - top) / 20;
      final spread = 8 + r * 4.0;
      for (int k = 0; k < 2; k++) {
        final x = gx + (rng2.nextDouble() - 0.5) * spread * 2;
        final len = 3 + rng2.nextDouble() * (4 + r);
        glitter.color =
            p.light.withValues(alpha: (isNight ? 0.18 : 0.35) * (1 - r / 18));
        canvas.drawLine(Offset(x, y), Offset(x + len, y), glitter);
      }
    }
  }

  /// 遠方島嶼剪影（龜山島意象）
  void _drawDistantIsland(
      Canvas canvas, Size size, _SceneryPalette p, double horizonY) {
    final x = size.width * 0.72;
    final w = size.width * 0.16;
    canvas.drawPath(
        Path()
          ..moveTo(x, horizonY)
          ..quadraticBezierTo(
              x + w * 0.3, horizonY - 16, x + w * 0.55, horizonY - 6)
          ..quadraticBezierTo(x + w * 0.75, horizonY - 11, x + w, horizonY)
          ..close(),
        Paint()..color = Color.lerp(p.farMountain, p.haze, 0.3)!.withValues(alpha: 0.6));
  }

  // ===========================================================================
  // 丘陵：沿等高線展開的山丘（水梯田、茶園）
  // ===========================================================================

  static const double _capF = 0.05; // 山頂樹林帶的厚度

  /// 每個變體兩座山丘：先畫的在後面
  List<_Mound> _moundsFor(LandscapeVariant v) {
    switch (v) {
      case LandscapeVariant.northTerraces:
        return const [
          _Mound(0.22, 0.615, 0.8, 0.76),
          _Mound(0.8, 0.655, 0.75, 0.84),
        ];
      case LandscapeVariant.eastFoothills:
        return const [
          _Mound(0.75, 0.62, 0.8, 0.76),
          _Mound(0.2, 0.66, 0.7, 0.84),
        ];
      case LandscapeVariant.northHills:
        return const [
          _Mound(0.3, 0.64, 0.75, 0.76),
          _Mound(0.85, 0.67, 0.7, 0.86),
        ];
      case LandscapeVariant.centralHills:
        return const [
          _Mound(0.7, 0.635, 0.8, 0.76),
          _Mound(0.15, 0.665, 0.7, 0.86),
        ];
      default:
        return const [];
    }
  }

  /// 稜線：圓頂山形，半寬以外接回山腳高度
  double _ridgeY(_Mound m, Size s, double x) {
    final u = (x / s.width - m.cx) / m.halfW;
    final bell =
        u.abs() >= 1 ? 0.0 : pow(0.5 * (1 + cos(pi * u)), 0.7).toDouble();
    return s.height * (m.base - (m.base - m.peak) * bell);
  }

  /// 等高線：f = 0 是稜線、f = 1 是畫面底；越往下越平、間距越大
  double _contourY(_Mound m, Size s, double x, double f) {
    final r = _ridgeY(m, s, x);
    return r + (s.height * 1.02 - r) * f;
  }

  List<double> _moundXs(Size s, [int n = 96]) =>
      [for (int i = 0; i <= n; i++) -0.04 * s.width + i * 1.08 * s.width / n];

  /// 兩條等高線之間的帶狀區域
  Path _contourBand(_Mound m, Size s, List<double> xs, double f0, double f1) {
    final path = Path()..moveTo(xs.first, _contourY(m, s, xs.first, f0));
    for (final x in xs.skip(1)) {
      path.lineTo(x, _contourY(m, s, x, f0));
    }
    for (final x in xs.reversed) {
      path.lineTo(x, _contourY(m, s, x, f1));
    }
    return path..close();
  }

  Path _contourLine(_Mound m, Size s, List<double> xs, double f) {
    final path = Path()..moveTo(xs.first, _contourY(m, s, xs.first, f));
    for (final x in xs.skip(1)) {
      path.lineTo(x, _contourY(m, s, x, f));
    }
    return path;
  }

  void _drawHillMounds(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      _HillStyle style) {
    final mounds = _moundsFor(variant);
    for (int i = 0; i < mounds.length; i++) {
      final m = mounds[i];
      final haze = i < mounds.length - 1 ? 0.22 : 0.0; // 後面的山丘偏淡
      if (i > 0) {
        _drawMistBand(canvas, size, size.height * (m.peak + 0.015), 22, p, 0.12);
      }
      switch (style) {
        case _HillStyle.tea:
          _drawTeaMound(canvas, size, p, rng, m, haze);
        case _HillStyle.paddy:
          _drawPaddyMound(canvas, size, p, rng, m, haze, flooded: true);
      }
    }
  }
  /// 山體與山頂樹林
  void _drawMoundBase(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      _Mound m, double haze, Color ground) {
    final h = size.height;
    final xs = _moundXs(size);
    Color hz(Color c) => Color.lerp(c, p.haze, haze)!;

    canvas.drawPath(
        _contourBand(m, size, xs, 0, 1),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, h * m.peak), Offset(0, h), [
            hz(Color.lerp(ground, p.haze, 0.15)!),
            hz(Color.lerp(ground, p.darkLand, 0.4)!),
          ]));

    final crown = Paint()..color = hz(Color.lerp(p.tree, p.land, 0.1)!);
    final crownLight = Paint()
      ..color = hz(Color.lerp(p.tree, p.light, 0.2)!)
          .withValues(alpha: isNight ? 0.15 : 0.4);
    // 山頂樹林：只畫在真正隆起的山體上，山腳平地不畫
    final capXs = xs
        .where((x) => ((x / size.width - m.cx) / m.halfW).abs() < 0.8)
        .toList();
    if (capXs.length >= 2) {
      canvas.drawPath(_contourBand(m, size, capXs, 0, _capF), crown);
      for (final x in capXs) {
        final c = Offset(x + (rng.nextDouble() - 0.5) * 6,
            _contourY(m, size, x, _capF * 0.3) - 1);
        final r = 2.5 + rng.nextDouble() * 3.5;
        canvas.drawCircle(c, r, crown);
        canvas.drawCircle(c.translate(-r * 0.3, -r * 0.35), r * 0.45, crownLight);
      }
    }
  }

  bool _cellHasDecor(
      _Mound m, Size size, double xa, double xb, double f0, double f1) {
    for (final pl in layout.placements) {
      final x = pl.fx * size.width;
      if (x < xa || x > xb) continue;
      final y = pl.fy * size.height;
      if (y >= _contourY(m, size, x, f0) - 2 &&
          y <= _contourY(m, size, x, f1) + 2) {
        return true;
      }
    }
    return false;
  }

  /// 水梯田：彎月形田塊、倒影拼布、土埂立面、秧苗
  void _drawPaddyMound(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      _Mound m, double haze,
      {required bool flooded}) {
    final w = size.width;
    Color hz(Color c) => Color.lerp(c, p.haze, haze)!;
    _drawMoundBase(canvas, size, p, rng, m, haze, p.land);

    final skyTint = isNight
        ? const Color(0xFF2A4258)
        : (isEvening ? const Color(0xFFD9A06B) : const Color(0xFFBCD8DD));
    final bund = hz(Color.lerp(p.accent, p.light, 0.3)!);
    final riserColor = hz(Color.lerp(p.darkLand, Colors.black, 0.2)!);
    final allXs = _moundXs(size);
    final step = w / 96;
    const bands = 9;

    for (int k = 0; k < bands; k++) {
      final f0 = _capF + (1 - _capF) * pow(k / bands, 1.35).toDouble();
      final f1 = _capF + (1 - _capF) * pow((k + 1) / bands, 1.35).toDouble();
      final depth = (f0 + f1) / 2;

      // 田埂分格
      final cellN = 2 + rng.nextInt(3) + (depth > 0.4 ? 1 : 0);
      final cuts = <double>[-0.04 * w];
      for (int c = 1; c < cellN; c++) {
        cuts.add(-0.04 * w +
            1.08 * w * (c + (rng.nextDouble() - 0.5) * 0.6) / cellN);
      }
      cuts.add(1.04 * w);

      for (int c = 0; c < cuts.length - 1; c++) {
        final xa = cuts[c], xb = cuts[c + 1];
        final n = max(2, ((xb - xa) / step).ceil());
        final xs = [for (int i = 0; i <= n; i++) xa + (xb - xa) * i / n];
        final cell = _contourBand(m, size, xs, f0, f1);
        final midX = (xa + xb) / 2;
        final y0 = _contourY(m, size, midX, f0);
        final y1 = _contourY(m, size, midX, f1);
        final roll = rng.nextDouble();
        final wet =
            flooded && roll < 0.8 && !_cellHasDecor(m, size, xa, xb, f0, f1);

        if (wet) {
          // 每塊田倒映的天光深淺不同 → 拼布感
          final mirror = Color.lerp(skyTint, p.water, 0.15 + roll * 0.4)!;
          canvas.drawPath(
              cell,
              Paint()
                ..shader = ui.Gradient.linear(Offset(0, y0), Offset(0, y1), [
                  hz(mirror).withValues(alpha: isNight ? 0.6 : 0.95),
                  hz(Color.lerp(p.water, p.land, 0.35)!)
                      .withValues(alpha: 0.95),
                ]));
          if (depth > 0.2) {
            final dots = Path();
            final gap = 3 + 6 * depth;
            final r = 0.4 + 1.1 * depth;
            for (final g in [0.3, 0.55, 0.8]) {
              final ff = f0 + (f1 - f0) * g;
              for (double x = xa + gap / 2; x < xb; x += gap) {
                dots.addOval(Rect.fromCircle(
                    center: Offset(x, _contourY(m, size, x, ff)), radius: r));
              }
            }
            canvas.drawPath(
                dots,
                Paint()
                  ..color = hz(Color.lerp(p.land, p.accent, 0.4)!)
                      .withValues(alpha: isNight ? 0.3 : 0.7));
          }
        } else {
          final green = Color.lerp(p.land, p.accent, 0.2 + roll * 0.4)!;
          canvas.drawPath(
              cell,
              Paint()
                ..shader = ui.Gradient.linear(Offset(0, y0), Offset(0, y1), [
                  hz(green),
                  hz(Color.lerp(green, p.darkLand, 0.3)!),
                ]));
        }
      }

      // 上一階的土埂立面
      canvas.drawPath(_contourBand(m, size, allXs, f0, f0 + (f1 - f0) * 0.18),
          Paint()..color = riserColor.withValues(alpha: 0.55));
      // 田埂頂（長草的受光邊）
      canvas.drawPath(
          _contourLine(m, size, allXs, f0),
          Paint()
            ..color = bund.withValues(alpha: isNight ? 0.15 : 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6 + 2.0 * depth);
      // 分格田埂
      final div = Paint()
        ..color = bund.withValues(alpha: isNight ? 0.12 : 0.5)
        ..strokeWidth = 0.5 + 1.4 * depth
        ..strokeCap = StrokeCap.round;
      for (int c = 1; c < cuts.length - 1; c++) {
        final x = cuts[c];
        canvas.drawLine(Offset(x, _contourY(m, size, x, f0)),
            Offset(x, _contourY(m, size, x, f1)), div);
      }
    }
  }

  /// 茶園：沿等高線的圓頂樹籬、嫩芽受光、行間土徑
  void _drawTeaMound(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      _Mound m, double haze) {
    Color hz(Color c) => Color.lerp(c, p.haze, haze)!;
    final soil = Color.lerp(p.darkLand, _tone(const Color(0xFF6B5A3E)), 0.35)!;
    _drawMoundBase(canvas, size, p, rng, m, haze, soil);

    final xs = _moundXs(size, 192);
    final body = Paint()..color = hz(Color.lerp(p.tree, p.land, 0.35)!);
    final shade = Paint()
      ..color =
          hz(Color.lerp(p.tree, Colors.black, 0.25)!).withValues(alpha: 0.6);
    final sprout = Paint()
      ..color = hz(Color.lerp(
              p.accent, const Color(0xFFD8E27A), isNight ? 0.1 : 0.45)!)
          .withValues(alpha: isNight ? 0.2 : 0.55);
    const rows = 22;
    final phase = rng.nextDouble() * pi;

    for (int k = 0; k < rows; k++) {
      final f0 = _capF + 0.01 + (1 - _capF) * pow(k / rows, 1.45).toDouble();
      final f1 =
          _capF + 0.01 + (1 - _capF) * pow((k + 1) / rows, 1.45).toDouble();
      final df = f1 - f0;

      // 樹籬：上緣在近處加圓弧起伏，像一叢叢修剪過的茶樹
      Path hedge(double fTop, double fBot, {bool bumpy = false}) {
        final path = Path();
        for (int i = 0; i < xs.length; i++) {
          final x = xs[i];
          final yTop = _contourY(m, size, x, fTop);
          var y = yTop;
          if (bumpy) {
            final rowW = _contourY(m, size, x, fBot) - yTop;
            if (rowW > 3) {
              y -= sin(x / (rowW * 1.2) + phase + k).abs() * rowW * 0.2;
            }
          }
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        for (final x in xs.reversed) {
          path.lineTo(x, _contourY(m, size, x, fBot));
        }
        return path..close();
      }

      canvas.drawPath(hedge(f0 + df * 0.62, f0 + df * 0.78), shade);
      canvas.drawPath(hedge(f0, f0 + df * 0.66, bumpy: true), body);
      canvas.drawPath(hedge(f0, f0 + df * 0.22, bumpy: true), sprout);
    }
  }

  // ===========================================================================
  // 地形：田、河、河口、海岸
  // ===========================================================================

  /// 透視棋盤水田：嫩綠秧苗、金黃稻穗、映天光的水田、深綠田
  void _drawPlainsFields(
      Canvas canvas, Size size, _SceneryPalette p,
      {double startY = _plainsTop}) {
    final w = size.width, h = size.height;
    final top = h * startY;
    final landRect = Rect.fromLTWH(0, top, w, h - top);
    canvas.drawRect(
        landRect,
        Paint()
          ..shader =
              ui.Gradient.linear(landRect.topCenter, landRect.bottomCenter, [
            Color.lerp(p.land, p.haze, 0.25)!,
            p.darkLand,
          ]));

    Offset point(double groundX, double depthY) {
      final x = _plainsX(size, groundX, depthY, startY);
      final across = x / w;
      final depth = (depthY - top) / (h - top);
      final bow = 4 * across * (1 - across) * h * 0.025 * depth;
      return Offset(x, depthY + bow);
    }

    // 每排田埂略帶弧度，近處田區較寬，分界交錯。
    const rows = 6;
    final rowY = [
      for (int k = 0; k <= rows; k++)
        top + (h - top) * pow(k / rows, 1.65).toDouble(),
    ];
    const cuts = [-0.90, -0.53, -0.16, 0.11, 0.41, 0.80, 1.14, 1.58, 1.90];
    final plots = Random(seed + 19 + 31 * variant.index);
    final colors = [
      Color.lerp(p.land, p.accent, 0.35)!,
      Color.lerp(p.land, _tone(const Color(0xFFB4A169)), 0.42)!,
      Color.lerp(p.water, p.haze, 0.24)!,
      Color.lerp(p.land, p.darkLand, 0.32)!,
    ];
    final bund = Paint()
      ..color = p.darkLand.withValues(alpha: isNight ? 0.38 : 0.62)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final shoots = Path();
    final soil = Paint();

    void rowEdge(Path path, double from, double to, double y, Offset end) {
      final mid = point((from + to) / 2, y);
      final controlY = 2 * mid.dy - (point(from, y).dy + end.dy) / 2;
      path.quadraticBezierTo(mid.dx, controlY, end.dx, end.dy);
    }

    for (int row = 0; row < rows; row++) {
      final front = rowY[row + 1];
      final back = rowY[row];
      final shift = (row.isEven ? -0.045 : 0.045) * w;
      bund.strokeWidth = 0.55 + 1.6 * row / (rows - 1);
      for (int j = 0; j < cuts.length - 1; j++) {
        final left = w * cuts[j] + shift;
        final right = w * cuts[j + 1] + shift;
        final a = point(left, back);
        final b = point(right, back);
        final c = point(right, front);
        final d = point(left, front);
        if (max(b.dx, c.dx) < 0 || min(a.dx, d.dx) > w) continue;

        final tile = Path()..moveTo(a.dx, a.dy);
        rowEdge(tile, left, right, back, b);
        tile.lineTo(c.dx, c.dy);
        rowEdge(tile, right, left, front, d);
        tile.close();

        final type = plots.nextInt(colors.length);
        canvas.drawPath(tile, soil..color = colors[type]);
        canvas.drawPath(tile, bund);

        if (row >= 2 && (type == 0 || type == 2)) {
          final blade = 0.55 + (front - top) / (h - top) * 1.9;
          final across = ((c.dx - d.dx) / (4 + blade)).clamp(3, 32).toInt();
          for (int r = 1; r <= 3; r++) {
            final y = back + (front - back) * r / 4;
            for (int i = 0; i < across; i++) {
              final x = left + (right - left) * (i + (r.isEven ? 0.7 : 0.35)) / across;
              final stem = point(x, y);
              shoots
                ..moveTo(stem.dx - blade * 0.5, stem.dy - blade * 0.7)
                ..lineTo(stem.dx, stem.dy)
                ..lineTo(stem.dx + blade * 0.4, stem.dy - blade);
            }
          }
        }
      }
    }
    canvas.drawPath(
      shoots,
      Paint()
        ..color = p.tree.withValues(alpha: isNight ? 0.34 : 0.58)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..strokeCap = StrokeCap.round,
    );
  }

  /// 河床外框（河道本體、鐵橋位置共用）
  ({Path bed, List<Offset> left, List<Offset> right}) _riverOutline(Size size) {
    const n = 40;
    final left = <Offset>[], right = <Offset>[];
    for (int i = 0; i <= n; i++) {
      final (pt, nrm, half) = _riverFrame(size, i / n);
      left.add(pt + nrm * half);
      right.add(pt - nrm * half);
    }
    final bed = Path()..moveTo(left.first.dx, left.first.dy);
    for (final o in left.skip(1)) {
      bed.lineTo(o.dx, o.dy);
    }
    for (final o in right.reversed) {
      bed.lineTo(o.dx, o.dy);
    }
    return (bed: bed..close(), left: left, right: right);
  }

  /// 辮狀礫石河床：寬闊灰白卵石灘、數條交織水道、河岸植被
  void _drawRiver(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    const n = 40;
    final h = size.height;
    final outline = _riverOutline(size);
    final bed = outline.bed, left = outline.left, right = outline.right;

    // 河只畫在地平線以下
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, h * 0.69, size.width, h));

    final gravel = Color.lerp(_tone(const Color(0xFFBDB6A4)), p.land, 0.24)!;
    canvas.drawPath(
        bed,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, h * 0.6), Offset(0, h * 0.9), [
            Color.lerp(gravel, p.haze, 0.45)!,
            gravel,
          ]));

    // 卵石
    final pebLight = Path(), pebDark = Path();
    for (int i = 0; i < 140; i++) {
      final t = sqrt(rng.nextDouble());
      final (pt, nrm, half) = _riverFrame(size, t);
      final o = pt + nrm * (half * (rng.nextDouble() * 2 - 1) * 0.92);
      final r = 0.4 + 1.3 * t * rng.nextDouble();
      (i.isEven ? pebLight : pebDark)
          .addOval(Rect.fromCircle(center: o, radius: r));
    }
    canvas.drawPath(pebLight,
        Paint()..color = Color.lerp(gravel, Colors.white, 0.35)!.withValues(alpha: 0.6));
    canvas.drawPath(pebDark,
        Paint()..color = Color.lerp(gravel, Colors.black, 0.3)!.withValues(alpha: 0.45));

    // 水道
    final waterPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(0, h * 0.6), Offset(0, h * 0.9), [
        Color.lerp(p.water, p.haze, 0.35)!.withValues(alpha: 0.88),
        p.water.withValues(alpha: 0.95),
      ]);
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.06 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int ch = 0; ch < 3; ch++) {
      final l = <Offset>[], r = <Offset>[];
      final hl = Path();
      for (int i = 0; i <= n; i++) {
        final t = i / n;
        final (_, nrm, _) = _riverFrame(size, t);
        final c = _channelCenter(size, t, ch);
        final hw = _channelHalf(size, t, ch);
        l.add(c + nrm * hw);
        r.add(c - nrm * hw);
        final hp = c - nrm * (hw * 0.4);
        if (i == (n * 0.3).round()) {
          hl.moveTo(hp.dx, hp.dy);
        } else if (i > n * 0.3) {
          hl.lineTo(hp.dx, hp.dy);
        }
      }
      final chPath = Path()..moveTo(l.first.dx, l.first.dy);
      for (final o in l.skip(1)) {
        chPath.lineTo(o.dx, o.dy);
      }
      for (final o in r.reversed) {
        chPath.lineTo(o.dx, o.dy);
      }
      chPath.close();
      canvas.drawPath(chPath, waterPaint);
      canvas.drawPath(hl, highlight);
    }

    // 河岸植被
    final bank = Paint()
      ..color = p.tree.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    for (final side in [left, right]) {
      final bp = Path()..moveTo(side.first.dx, side.first.dy);
      for (final o in side.skip(1)) {
        bp.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(bp, bank);
    }

    canvas.restore();
  }

  Path _estuaryWater(Size size) => Path()
    ..moveTo(0, size.height * 0.65)
    ..quadraticBezierTo(size.width * 0.3, size.height * 0.68, size.width * 0.6,
        size.height * 0.62)
    ..lineTo(size.width, size.height * 0.62)
    ..lineTo(size.width, size.height * 0.75)
    ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.7, 0, size.height * 0.75)
    ..close();

  /// 河口：灘地、紅樹林、漸層水面、紅色拱橋
  void _drawEstuary(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width, h = size.height;

    // 前景河岸草地（有漸層與草紋，不再是一整塊暗色）
    final bankRect = Rect.fromLTWH(0, h * 0.73, w, h * 0.27);
    canvas.drawRect(
        bankRect,
        Paint()
          ..shader = ui.Gradient.linear(bankRect.topCenter, bankRect.bottomCenter, [
            Color.lerp(p.land, p.accent, 0.25)!,
            p.darkLand,
          ]));
    final grass = Paint()
      ..color = Color.lerp(p.land, p.accent, 0.5)!.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    for (int row = 0; row < 5; row++) {
      final y = h * (0.82 + row * 0.04);
      final n = 24 + row * 6;
      for (int i = 0; i < n; i++) {
        final x = (i + (row.isEven ? 0.0 : 0.5)) * w / n;
        canvas.drawLine(Offset(x, y), Offset(x + 1, y - 3 - row * 1.2), grass);
      }
    }

    // 灘地
    canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.75)
          ..quadraticBezierTo(w * 0.5, h * 0.7, w, h * 0.75)
          ..lineTo(w, h * 0.775)
          ..quadraticBezierTo(w * 0.5, h * 0.735, 0, h * 0.785)
          ..close(),
        Paint()..color = _tone(const Color(0xFF8A7F6C)));

    final water = _estuaryWater(size);
    canvas.drawPath(
        water,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, h * 0.62), Offset(0, h * 0.75), [
            Color.lerp(p.water, p.haze, 0.4)!.withValues(alpha: 0.9),
            p.water.withValues(alpha: 0.92),
          ]));
    canvas.drawLine(
        Offset(w * 0.6, h * 0.622),
        Offset(w, h * 0.622),
        Paint()
          ..color = p.light.withValues(alpha: isNight ? 0.05 : 0.25)
          ..strokeWidth = 1);

    // 紅樹林
    final mangrove = Path();
    for (int i = 0; i < 26; i++) {
      final x = w * (0.02 + i * 0.018 + rng.nextDouble() * 0.01);
      final t = x / w;
      final y = h * (0.75 - 0.1 * (1 - t) * t);
      mangrove.addOval(Rect.fromCircle(
          center: Offset(x, y + 1), radius: 3 + rng.nextDouble() * 4));
    }
    canvas.drawPath(mangrove,
        Paint()..color = Color.lerp(p.tree, p.land, 0.15)!.withValues(alpha: 0.92));

    _drawArchBridge(canvas, size, p, water);
  }

  void _drawArchBridge(
      Canvas canvas, Size size, _SceneryPalette p, Path water) {
    final w = size.width, h = size.height;
    final deckY = h * 0.655;
    final x0 = w * 0.47, x1 = w * 1.03;
    final peakY = h * 0.56;
    final ctrlY = 2 * peakY - deckY;
    final ax0 = x0 + (x1 - x0) * 0.05, ax1 = x1 - (x1 - x0) * 0.05;
    final mid = (ax0 + ax1) / 2;
    Offset arch(double t) => Offset(ax0 + (ax1 - ax0) * t,
        (1 - t) * (1 - t) * deckY + 2 * (1 - t) * t * ctrlY + t * t * deckY);

    final red = _tone(const Color(0xFFC8372D));
    final archPath = Path()
      ..moveTo(ax0, deckY)
      ..quadraticBezierTo(mid, ctrlY, ax1, deckY);

    // 倒影
    canvas.save();
    canvas.clipPath(water);
    canvas.save();
    canvas.translate(0, 2 * (deckY + 3));
    canvas.scale(1, -1);
    canvas.drawPath(
        archPath,
        Paint()
          ..color = red.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.restore();
    canvas.restore();

    final pier = Paint()..color = _tone(const Color(0xFFB7B1A6));
    canvas.drawRect(Rect.fromLTRB(ax0 - 3, deckY, ax0 + 3, deckY + 9), pier);
    canvas.drawRect(Rect.fromLTRB(ax1 - 3, deckY, ax1 + 3, deckY + 9), pier);

    final hanger = Paint()
      ..color = red.withValues(alpha: 0.85)
      ..strokeWidth = 0.7;
    for (int k = 1; k < 14; k++) {
      final a = arch(k / 14);
      canvas.drawLine(a, Offset(a.dx, deckY), hanger);
    }

    canvas.drawRect(Rect.fromLTRB(x0, deckY - 1.5, x1, deckY + 2),
        Paint()..color = _tone(const Color(0xFFD4CEC3)));
    canvas.drawLine(Offset(x0, deckY - 1.5), Offset(x1, deckY - 1.5),
        Paint()
          ..color = red
          ..strokeWidth = 1);

    canvas.drawPath(
        archPath,
        Paint()
          ..color = red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        archPath.shift(const Offset(0, 2.5)),
        Paint()
          ..color = Color.lerp(red, Colors.black, 0.25)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    if (isNight) {
      final bulb = Paint()..color = p.light.withValues(alpha: 0.9);
      for (int k = 0; k <= 20; k++) {
        canvas.drawCircle(arch(k / 20), 1.1, bulb);
      }
      for (double x = x0; x < x1; x += 10) {
        canvas.drawCircle(Offset(x, deckY - 2), 0.9, bulb);
      }
    }
  }

  Path _beachPath(Size size) => Path()
    ..moveTo(0, size.height * 0.52)
    ..quadraticBezierTo(
        size.width * 0.4, size.height * 0.65, size.width * 0.95, size.height)
    ..lineTo(0, size.height)
    ..close();

  void _drawCoastBeach(Canvas canvas, Size size, _SceneryPalette p) {
    final beach = _beachPath(size);
    final beachRect =
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5);
    final sand = _tone(const Color(0xFFC7BBA0));
    canvas.drawPath(
        beach,
        Paint()
          ..shader =
              ui.Gradient.linear(beachRect.topCenter, beachRect.bottomCenter, [
            Color.lerp(sand, p.haze, 0.25)!,
            Color.lerp(sand, const Color(0xFF9A8460), 0.35)!,
          ]));
    canvas.save();
    canvas.clipPath(beach);
    final grass = Path();
    final shoreRandom = Random(seed + 67);
    for (int i = 0; i < 95; i++) {
      final depth = 0.6 + 0.4 * shoreRandom.nextDouble();
      final x = size.width * ((depth - 0.6) * 1.25) * shoreRandom.nextDouble();
      final y = size.height * depth;
      if (!beach.contains(Offset(x, y))) continue;
      final blade = 2 + 8 * (depth - 0.6) * shoreRandom.nextDouble();
      grass
        ..moveTo(x - blade * 0.55, y - blade * 0.6)
        ..quadraticBezierTo(x, y - 2, x, y)
        ..lineTo(x + blade * 0.4, y - blade);
    }
    canvas.drawPath(grass, Paint()
      ..color = p.land.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round);
    canvas.restore();
    final edge = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.65, size.width * 0.95, size.height);
    // 濕沙帶
    canvas.drawPath(
        edge.shift(const Offset(-3, 3)),
        Paint()
          ..color = p.darkLand.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    // 浪花線
    canvas.drawPath(
        edge,
        Paint()
          ..color = Colors.white.withValues(alpha: isNight ? 0.08 : 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  // ===========================================================================
  // 交通與基礎設施
  // ===========================================================================

  /// 鄉間道路：沿路肩收邊，遠處縮窄。
  void _drawRoadSurface(Canvas canvas, Size size, _SceneryPalette p) {
    final w = size.width, h = size.height;
    const segments = 20;
    final left = Path();
    final right = Path();
    final road = Path();
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final y = h * _roadY(t);
      final xLeft = w * (_roadCx(t) - _roadHalf(t));
      final xRight = w * (_roadCx(t) + _roadHalf(t));
      if (i == 0) {
        left.moveTo(xLeft, y);
        right.moveTo(xRight, y);
        road.moveTo(xLeft, y);
      } else {
        left.lineTo(xLeft, y);
        right.lineTo(xRight, y);
        road.lineTo(xLeft, y);
      }
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      road.lineTo(w * (_roadCx(t) + _roadHalf(t)), h * _roadY(t));
    }
    road.close();

    final asphalt = _tone(const Color(0xFF6D7372));
    canvas.drawPath(road, Paint()
      ..shader = ui.Gradient.linear(Offset(0, h * _roadY(0)), Offset(0, h), [
        Color.lerp(asphalt, p.haze, 0.26)!,
        asphalt,
      ]));
    final shoulder = Paint()
      ..color = p.darkLand.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(left, shoulder);
    canvas.drawPath(right, shoulder);
  }

  double _valleyRailwayTop(Size size) => size.height * 0.70 + 5;

  /// 鐵路側面：河床兩側是路基，過河段由橋墩支撐。
  void _drawRailwayTrack(Canvas canvas, Size size, _SceneryPalette p) {
    final y = _valleyRailwayTop(size);
    final bed = _riverOutline(size).bed;

    // 橋的範圍：鐵軌和河床重疊的那段
    double? bx0, bx1;
    for (double x = 0; x <= size.width; x += 2) {
      if (bed.contains(Offset(x, y + 3))) {
        bx0 ??= x;
        bx1 = x;
      }
    }

    final roadbed = Paint()
      ..shader = ui.Gradient.linear(Offset(0, y), Offset(0, y + 7), [
        _tone(const Color(0xFF807B70)),
        _tone(const Color(0xFF5E6254)),
      ]);
    if (bx0 case final left?) {
      final a = max(0.0, left - 6);
      final b = min(size.width, bx1! + 6);
      canvas.drawRect(Rect.fromLTRB(0, y, a, y + 7), roadbed);
      canvas.drawRect(Rect.fromLTRB(b, y, size.width, y + 7), roadbed);

      final concrete = _tone(const Color(0xFFB9B4AA));
      final pier = Paint()..color = Color.lerp(concrete, Colors.black, 0.25)!;
      final spans = max(2, ((b - a) / 17).ceil());
      for (int i = 0; i <= spans; i++) {
        final x = a + (b - a) * i / spans;
        canvas.drawRect(
            Rect.fromLTRB(x - 1.5, y + 6, x + 1.5, y + 15), pier);
      }
      canvas.drawRect(Rect.fromLTRB(a, y, b, y + 7), Paint()..color = concrete);
      canvas.drawRect(
          Rect.fromLTRB(a, y + 5, b, y + 7),
          Paint()
            ..color = Color.lerp(concrete, Colors.black, 0.28)!);
    } else {
      canvas.drawRect(Rect.fromLTRB(0, y, size.width, y + 7), roadbed);
    }
  }

  /// 貓空纜車：纜線、塔架、站房
  void _drawGondolaLine(Canvas canvas, Size size, _SceneryPalette p) {
    final a = _gondA(size), b = _gondB(size), c = _gondC(size);
    final steel = _tone(const Color(0xFF6C7277));
    final top = _quad(a, c, b, 0.478);
    final groundY = size.height * 0.69;
    final pyl = Paint()
      ..color = steel
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(top.dx - 3, groundY), Offset(top.dx - 0.8, top.dy + 2), pyl);
    canvas.drawLine(Offset(top.dx + 3, groundY), Offset(top.dx + 0.8, top.dy + 2), pyl);
    pyl.strokeWidth = 0.6;
    for (double yy = top.dy + 6; yy < groundY; yy += 6) {
      final f = (yy - top.dy) / (groundY - top.dy);
      final half = 0.8 + 2.2 * f;
      canvas.drawLine(Offset(top.dx - half, yy), Offset(top.dx + half, yy), pyl);
    }
    pyl.strokeWidth = 1.0;
    canvas.drawLine(Offset(top.dx - 3, top.dy + 2), Offset(top.dx + 3, top.dy + 2), pyl);

    canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        Paint()
          ..color = steel
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);

    canvas.drawRect(Rect.fromLTRB(b.dx - 3, b.dy - 1, b.dx + 12, b.dy + 8),
        Paint()..color = _tone(const Color(0xFFE6E2DA)));
    canvas.drawRect(Rect.fromLTRB(b.dx - 4, b.dy - 3, b.dx + 13, b.dy - 1),
        Paint()..color = _tone(const Color(0xFF4A5560)));
    canvas.drawRect(
        Rect.fromLTRB(b.dx + 1, b.dy + 2, b.dx + 8, b.dy + 5),
        Paint()
          ..color = isNight
              ? p.light.withValues(alpha: 0.85)
              : _tone(const Color(0xFF7D93A3)));
  }

  /// 白色燈塔（南端岬角意象）
  void _drawLighthouse(Canvas canvas, Size size, _SceneryPalette p) {
    final b = _lhBase(size);
    const s = _lhScale;
    final white = _tone(const Color(0xFFF4F2EC));
    final dark = _tone(const Color(0xFF3B3F44));

    canvas.drawRect(Rect.fromLTWH(b.dx - 2 * s, b.dy - 5 * s, 13 * s, 5 * s),
        Paint()..color = white);
    canvas.drawRect(Rect.fromLTWH(b.dx - 2.5 * s, b.dy - 6 * s, 14 * s, 1.2 * s),
        Paint()..color = dark);

    final towerTop = b.dy - 22 * s;
    final tower = Path()
      ..moveTo(b.dx - 3.6 * s, b.dy)
      ..lineTo(b.dx + 3.6 * s, b.dy)
      ..lineTo(b.dx + 2.4 * s, towerTop)
      ..lineTo(b.dx - 2.4 * s, towerTop)
      ..close();
    canvas.drawPath(tower, Paint()..color = white);
    canvas.drawPath(
        tower,
        Paint()
          ..shader = ui.Gradient.linear(
              Offset(b.dx - 3.6 * s, 0), Offset(b.dx + 3.6 * s, 0), [
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.15),
          ]));
    canvas.drawRect(
        Rect.fromLTRB(b.dx - 3.4 * s, towerTop - 0.6 * s, b.dx + 3.4 * s,
            towerTop + 0.6 * s),
        Paint()..color = dark);
    canvas.drawRect(
        Rect.fromLTRB(b.dx - 2 * s, towerTop - 4.5 * s, b.dx + 2 * s,
            towerTop - 0.6 * s),
        Paint()
          ..color = (isNight || isEvening)
              ? p.light
              : _tone(const Color(0xFF9FB4BF)));
    canvas.drawPath(
        Path()
          ..moveTo(b.dx - 2.4 * s, towerTop - 4.5 * s)
          ..quadraticBezierTo(
              b.dx, towerTop - 8 * s, b.dx + 2.4 * s, towerTop - 4.5 * s)
          ..close(),
        Paint()..color = dark);
  }

  void _drawWindTurbinePylons(Canvas canvas, Size size, _SceneryPalette p) {
    final pylon = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.2 : 0.75)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final hubs = _turbineHubs(size);
    for (int i = 0; i < hubs.length; i++) {
      final hub = hubs[i];
      pylon.strokeWidth = 1.2 + size.width * 0.004;
      canvas.drawLine(Offset(hub.dx, _turbineBaseY(size, i)), hub, pylon);
      canvas.drawCircle(hub, 1 + size.width * 0.004,
          Paint()..color = Colors.white.withValues(alpha: isNight ? 0.25 : 0.85));
    }
  }

  // ===========================================================================
  // 建築
  // ===========================================================================

  /// 紅磚三合院
  void _drawSanheyuan(
      Canvas canvas, _SceneryPalette p, Offset base, double scale) {
    final brick = Paint()..color = p.brick.withValues(alpha: 0.95);
    final brickDark = Paint()
      ..color = Color.lerp(p.brick, Colors.black, 0.25)!.withValues(alpha: 0.95);
    final roofPaint = Paint()..color = p.roof.withValues(alpha: 0.95);
    final winPaint = Paint()
      ..color = isNight
          ? p.light.withValues(alpha: 0.9)
          : p.darkLand.withValues(alpha: 0.6);

    final w = 46 * scale;
    final h = 15 * scale;
    final wingW = 11 * scale;
    final wingH = 11 * scale;

    for (final side in [-1.0, 1.0]) {
      final x = base.dx + side * (w / 2 + wingW / 2) - wingW / 2;
      final y = base.dy + 4 * scale;
      canvas.drawRect(Rect.fromLTWH(x, y - wingH, wingW, wingH), brickDark);
      canvas.drawPath(
          Path()
            ..moveTo(x - 2 * scale, y - wingH)
            ..quadraticBezierTo(x + wingW / 2, y - wingH - 6 * scale,
                x + wingW + 2 * scale, y - wingH)
            ..close(),
          roofPaint);
    }

    canvas.drawRect(Rect.fromLTWH(base.dx - w / 2, base.dy - h, w, h), brick);
    canvas.drawPath(
        Path()
          ..moveTo(base.dx - w / 2 - 3 * scale, base.dy - h)
          ..quadraticBezierTo(base.dx, base.dy - h - 10 * scale,
              base.dx + w / 2 + 3 * scale, base.dy - h)
          ..close(),
        roofPaint);

    canvas.drawRect(
        Rect.fromLTWH(base.dx - 3.5 * scale, base.dy - 9 * scale, 7 * scale,
            9 * scale),
        Paint()..color = p.templeRed.withValues(alpha: 0.9));
    for (final dx in [-w * 0.3, w * 0.3]) {
      canvas.drawRect(
          Rect.fromLTWH(base.dx + dx - 3 * scale, base.dy - 10 * scale,
              6 * scale, 6 * scale),
          winPaint);
    }
  }

  /// 廟宇：紅牆、燕尾脊、剪黏、寶珠、紅燈籠、香爐；plaza = 有廟埕
  void _drawTemple(Canvas canvas, _SceneryPalette p, Offset base, double scale,
      {bool plaza = false}) {
    final s = scale;
    final w = 36 * s;
    final h = 17 * s;

    if (plaza) {
      canvas.drawPath(
          Path()
            ..moveTo(base.dx - w / 2 - 4 * s, base.dy)
            ..lineTo(base.dx + w / 2 + 4 * s, base.dy)
            ..lineTo(base.dx + w / 2 + 12 * s, base.dy + 9 * s)
            ..lineTo(base.dx - w / 2 - 12 * s, base.dy + 9 * s)
            ..close(),
          Paint()..color = _tone(const Color(0xFFC9BCA4)));
      canvas.drawLine(
          Offset(base.dx - w / 2 - 8 * s, base.dy + 4.5 * s),
          Offset(base.dx + w / 2 + 8 * s, base.dy + 4.5 * s),
          Paint()
            ..color = _tone(const Color(0xFFA89C86))
            ..strokeWidth = 0.5 * s);
    }

    canvas.drawRect(Rect.fromLTWH(base.dx - w / 2, base.dy - h, w, h),
        Paint()..color = p.templeRed.withValues(alpha: 0.95));

    canvas.drawPath(
        Path()
          ..moveTo(base.dx - w / 2 - 7 * s, base.dy - h - 9 * s)
          ..quadraticBezierTo(base.dx - w / 2, base.dy - h - 2 * s, base.dx,
              base.dy - h - 4.5 * s)
          ..quadraticBezierTo(base.dx + w / 2, base.dy - h - 2 * s,
              base.dx + w / 2 + 7 * s, base.dy - h - 9 * s)
          ..lineTo(base.dx + w / 2 + 2 * s, base.dy - h + 1)
          ..lineTo(base.dx - w / 2 - 2 * s, base.dy - h + 1)
          ..close(),
        Paint()
          ..color = Color.lerp(p.roof, Colors.black, 0.2)!.withValues(alpha: 0.95));

    // 剪黏
    const jianNian = [
      Color(0xFF4FA36B),
      Color(0xFFF2C14E),
      Color(0xFF3E8CD1),
      Color(0xFFE8524A),
    ];
    for (int k = 0; k <= 8; k++) {
      final t = k / 8;
      final xx = base.dx + (t * 2 - 1) * (w / 2 + 5 * s);
      final yy = base.dy - h - 4.5 * s - pow(2 * t - 1, 2) * 4 * s - 1.2 * s;
      canvas.drawCircle(
          Offset(xx, yy), 0.9 * s, Paint()..color = _tone(jianNian[k % 4]));
    }
    canvas.drawCircle(Offset(base.dx, base.dy - h - 6.8 * s), 1.6 * s,
        Paint()..color = _tone(const Color(0xFFD8A63A)));

    canvas.drawRect(
        Rect.fromLTWH(base.dx - 4 * s, base.dy - 10 * s, 8 * s, 10 * s),
        Paint()..color = p.light.withValues(alpha: isNight ? 0.85 : 0.5));

    final lantern = Paint()
      ..color = p.lantern.withValues(alpha: isNight ? 0.95 : 0.85);
    for (final dx in [-w * 0.32, w * 0.32]) {
      final c = Offset(base.dx + dx, base.dy - h * 0.68);
      if (isNight) {
        canvas.drawCircle(c, 7 * s, Paint()..color = p.lantern.withValues(alpha: 0.22));
      }
      canvas.drawLine(
          Offset(c.dx, c.dy - 6 * s),
          Offset(c.dx, c.dy - 3.2 * s),
          Paint()
            ..color = p.infrastructure.withValues(alpha: 0.8)
            ..strokeWidth = 1);
      canvas.drawOval(
          Rect.fromCenter(center: c, width: 5.5 * s, height: 6.5 * s), lantern);
      canvas.drawLine(
          Offset(c.dx, c.dy + 3.2 * s),
          Offset(c.dx, c.dy + 5.5 * s),
          Paint()
            ..color = p.light.withValues(alpha: 0.8)
            ..strokeWidth = 1);
    }

    _drawBurner(canvas, p, _burnerPos(base, s, plaza), plaza ? s : s * 0.8);
  }

  Offset _burnerPos(Offset base, double s, bool plaza) =>
      Offset(base.dx, base.dy + (plaza ? 5.5 : 2.0) * s);

  void _drawBurner(Canvas canvas, _SceneryPalette p, Offset c, double s) {
    final gold = _tone(const Color(0xFFB0893A));
    canvas.drawRect(
        Rect.fromCenter(
            center: c.translate(0, 1.6 * s), width: 4.4 * s, height: 1.0 * s),
        Paint()..color = _tone(const Color(0xFF6E5424)));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: 6 * s, height: 3.4 * s),
            Radius.circular(1.2 * s)),
        Paint()..color = gold);
    canvas.drawLine(
        c.translate(-3.6 * s, -1.7 * s),
        c.translate(3.6 * s, -1.7 * s),
        Paint()
          ..color = gold
          ..strokeWidth = 0.9 * s);
    if (isNight) {
      canvas.drawCircle(c.translate(0, -1.9 * s), 1.6 * s,
          Paint()..color = p.light.withValues(alpha: 0.35));
    }
  }

  /// 現代住宅：淺色立面、木格柵、大片落地窗、陽台植栽、屋頂太陽能板
  void _drawModernHouses(Canvas canvas, _SceneryPalette p, Offset base,
      double s, Random rng) {
    const facades = [
      Color(0xFFF1EEE8),
      Color(0xFFDCD7CE),
      Color(0xFFE8DECD),
      Color(0xFFCBD5C6),
    ];
    final count = 1 + rng.nextInt(2);
    final w = 20 * s;
    double x = base.dx - count * w / 2;
    canvas.drawOval(
        Rect.fromLTWH(x - 2 * s, base.dy - 2 * s, count * w + 5 * s, 5 * s),
        Paint()..color = p.darkLand.withValues(alpha: 0.55));
    final glass = _tone(const Color(0xFF3E5566));
    final wood = _tone(const Color(0xFF9C6B45));
    final plant = Paint()..color = _tone(const Color(0xFF5E9A5A));
    final panel = Paint()..color = _tone(const Color(0xFF26456E));
    final panelGrid = Paint()
      ..color = _tone(const Color(0xFF7FA6CF)).withValues(alpha: 0.6)
      ..strokeWidth = 0.35 * s;

    for (int i = 0; i < count; i++) {
      final floors = 2 + rng.nextInt(2);
      final h = (9 + floors * 8) * s;
      final top = base.dy - h;
      final facade = _tone(facades[rng.nextInt(facades.length)]);
      final facadeDark = Color.lerp(facade, Colors.black, 0.2)!;

      canvas.drawRect(Rect.fromLTWH(x, top, w, h), Paint()..color = facade);
      canvas.drawRect(Rect.fromLTWH(x + w * 0.85, top, w * 0.15, h),
          Paint()..color = Color.lerp(facade, Colors.black, 0.12)!);

      if (rng.nextBool()) {
        final gx = x + w * 0.66;
        canvas.drawRect(Rect.fromLTWH(gx, top + 2 * s, w * 0.16, h - 11 * s),
            Paint()..color = wood);
        final slat = Paint()
          ..color = Color.lerp(wood, Colors.black, 0.25)!
          ..strokeWidth = 0.4 * s;
        for (double yy = top + 3.5 * s; yy < base.dy - 9 * s; yy += 1.5 * s) {
          canvas.drawLine(Offset(gx, yy), Offset(gx + w * 0.16, yy), slat);
        }
      }

      final shop = Rect.fromLTWH(x + 2 * s, base.dy - 7.5 * s, w * 0.58, 7.5 * s);
      canvas.drawRect(shop,
          Paint()..color = isNight ? p.light.withValues(alpha: 0.85) : glass);
      final mullion = Paint()
        ..color = facade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * s;
      canvas.drawRect(shop, mullion);
      canvas.drawLine(Offset(shop.center.dx, shop.top),
          Offset(shop.center.dx, shop.bottom), mullion);

      for (int f = 0; f < floors; f++) {
        final fy = base.dy - 9 * s - (f + 1) * 8 * s;
        final win = Rect.fromLTWH(x + 2 * s, fy + 1.5 * s, w * 0.58, 5 * s);
        final lit = isNight && rng.nextDouble() < 0.6;
        canvas.drawRect(win,
            Paint()..color = lit ? p.light.withValues(alpha: 0.85) : glass);
        if (!isNight) {
          canvas.drawPath(
              Path()
                ..moveTo(win.left + win.width * 0.15, win.bottom)
                ..lineTo(win.left + win.width * 0.35, win.top)
                ..lineTo(win.left + win.width * 0.45, win.top)
                ..lineTo(win.left + win.width * 0.25, win.bottom)
                ..close(),
              Paint()..color = Colors.white.withValues(alpha: 0.18));
        }
        canvas.drawRect(Rect.fromLTWH(x + 1 * s, fy + 6.5 * s, w * 0.66, 1 * s),
            Paint()..color = facadeDark);
        for (int k = 0; k < 3; k++) {
          canvas.drawCircle(Offset(x + (3 + k * 4.5) * s, fy + 6 * s), 1.3 * s, plant);
        }
      }

      canvas.drawLine(Offset(x, top), Offset(x + w, top),
          Paint()
            ..color = facadeDark
            ..strokeWidth = 0.8 * s);
      for (int k = 0; k < 2; k++) {
        final px = x + 2 * s + k * 8 * s;
        canvas.drawPath(
            Path()
              ..moveTo(px, top - 0.5 * s)
              ..lineTo(px + 7 * s, top - 0.5 * s)
              ..lineTo(px + 5.5 * s, top - 3.5 * s)
              ..lineTo(px - 1.5 * s, top - 3.5 * s)
              ..close(),
            panel);
        canvas.drawLine(Offset(px - 0.75 * s, top - 2 * s),
            Offset(px + 6.25 * s, top - 2 * s), panelGrid);
        canvas.drawLine(Offset(px + 3.5 * s, top - 0.5 * s),
            Offset(px + 2 * s, top - 3.5 * s), panelGrid);
      }

      x += w + 1.5 * s;
    }
  }

  /// 日式老屋文創：黑瓦、木牆、木窗、彩繪牆、夜晚串燈
  void _drawArtHouse(Canvas canvas, _SceneryPalette p, Offset base, double s,
      Random rng) {
    const muralColors = [
      Color(0xFFE8524A),
      Color(0xFFF2B33D),
      Color(0xFF4FA36B),
      Color(0xFF3E8CD1),
      Color(0xFF9B5EC1),
    ];
    final w = 28 * s;
    final h = 10 * s;
    final left = base.dx - w / 2 - 6 * s;
    final wallTop = base.dy - 2 * s - h;

    canvas.drawRect(Rect.fromLTWH(left - 1 * s, base.dy - 2 * s, w + 2 * s, 2 * s),
        Paint()..color = _tone(const Color(0xFF8F8A80)));

    final wood = _tone(const Color(0xFF7A5236));
    canvas.drawRect(Rect.fromLTWH(left, wallTop, w, h), Paint()..color = wood);
    final plank = Paint()
      ..color = Color.lerp(wood, Colors.black, 0.25)!
      ..strokeWidth = 0.4 * s;
    for (double xx = left + 2.5 * s; xx < left + w; xx += 2.5 * s) {
      canvas.drawLine(Offset(xx, wallTop), Offset(xx, base.dy - 2 * s), plank);
    }

    final frame = Paint()
      ..color = Color.lerp(wood, Colors.black, 0.35)!
      ..strokeWidth = 0.6 * s;
    for (final fx in [0.2, 0.62]) {
      final win = Rect.fromLTWH(left + w * fx, wallTop + 2.5 * s, 6 * s, 4.5 * s);
      canvas.drawRect(
          win,
          Paint()
            ..color = isNight
                ? p.light.withValues(alpha: 0.9)
                : _tone(const Color(0xFFE9DFC6)));
      canvas.drawLine(Offset(win.center.dx, win.top), Offset(win.center.dx, win.bottom), frame);
      canvas.drawLine(Offset(win.left, win.center.dy), Offset(win.right, win.center.dy), frame);
    }

    final roofTop = wallTop - 8 * s;
    final roofBase = wallTop + 0.5 * s;
    final tile = _tone(const Color(0xFF3F4246));
    canvas.drawPath(
        Path()
          ..moveTo(left - 3 * s, roofBase)
          ..lineTo(left + w + 3 * s, roofBase)
          ..lineTo(left + w - 4 * s, roofTop)
          ..lineTo(left + 4 * s, roofTop)
          ..close(),
        Paint()..color = tile);
    final tileLine = Paint()
      ..color = Color.lerp(tile, Colors.white, 0.18)!
      ..strokeWidth = 0.4 * s;
    for (double yy = roofTop + 1.6 * s; yy < roofBase; yy += 1.6 * s) {
      final f = (yy - roofTop) / (roofBase - roofTop);
      canvas.drawLine(Offset(left + 4 * s - 7 * s * f, yy),
          Offset(left + w - 4 * s + 7 * s * f, yy), tileLine);
    }
    canvas.drawLine(Offset(left + 4 * s, roofTop), Offset(left + w - 4 * s, roofTop),
        Paint()
          ..color = Color.lerp(tile, Colors.black, 0.3)!
          ..strokeWidth = 1.2 * s);

    // 彩繪牆
    final mural = Rect.fromLTWH(left + w + 1 * s, base.dy - 9 * s, 12 * s, 9 * s);
    canvas.drawRect(mural, Paint()..color = _tone(const Color(0xFFF3EEE3)));
    canvas.save();
    canvas.clipRect(mural);
    for (int k = 0; k < 5; k++) {
      canvas.drawRect(
          Rect.fromLTWH(mural.left, mural.bottom - (k + 1) * 1.3 * s,
              mural.width, 1.3 * s),
          Paint()..color = _tone(muralColors[k]).withValues(alpha: 0.85));
    }
    for (int k = 0; k < 5; k++) {
      canvas.drawCircle(
          Offset(mural.left + (1.5 + rng.nextDouble() * 9) * s,
              mural.top + (1 + rng.nextDouble() * 2.5) * s),
          (0.8 + rng.nextDouble() * 1.2) * s,
          Paint()..color = _tone(muralColors[rng.nextInt(muralColors.length)]));
    }
    canvas.restore();

    if (isNight) {
      final bulb = Paint()..color = p.light;
      for (double xx = left - 2 * s; xx <= left + w + 2 * s; xx += 3 * s) {
        canvas.drawCircle(Offset(xx, roofBase + 0.8 * s), 0.8 * s, bulb);
      }
    }
  }

  /// 夜市
  static const _nmStalls = 4;

  List<Offset> _nightMarketBulbs(Offset base, double s) {
    final sw = 18 * s;
    final left = base.dx - _nmStalls * sw / 2;
    final y0 = base.dy - 14.5 * s;
    final pts = <Offset>[];
    for (double x = left + 2 * s; x <= left + _nmStalls * sw - 2 * s; x += 4.5 * s) {
      final local = ((x - left) % sw) / sw;
      pts.add(Offset(x, y0 + sin(local * pi) * 1.5 * s));
    }
    return pts;
  }

  void _drawNightMarket(Canvas canvas, _SceneryPalette p, Offset base,
      double s, Random rng) {
    const canopyColors = [
      Color(0xFFC8372D),
      Color(0xFFE9B33A),
      Color(0xFF2F6DB0),
      Color(0xFFE8E4DA),
      Color(0xFF3D8C5A),
    ];
    const goods = [
      Color(0xFFE07B39),
      Color(0xFFC0392B),
      Color(0xFFF3E3B5),
      Color(0xFF8C5A3C),
    ];
    const shirts = [
      Color(0xFF3E6FB0),
      Color(0xFFE0E0E0),
      Color(0xFF9C4B3A),
      Color(0xFF5B7F4A),
      Color(0xFF7B5EA7),
      Color(0xFFE3A23B),
    ];

    final sw = 18 * s;
    final left = base.dx - _nmStalls * sw / 2;
    final pole = Paint()
      ..color = _tone(const Color(0xFF6B6259))
      ..strokeWidth = 0.8 * s;

    for (int i = 0; i < _nmStalls; i++) {
      final x = left + i * sw;
      final canopy = canopyColors[rng.nextInt(canopyColors.length)];
      final striped = rng.nextDouble() < 0.35;

      if (isNight) {
        canvas.drawRect(Rect.fromLTWH(x + 0.5 * s, base.dy - 15 * s, sw - s, 8 * s),
            Paint()..color = p.light.withValues(alpha: 0.28));
      }
      canvas.drawLine(Offset(x + 1.5 * s, base.dy), Offset(x + 1.5 * s, base.dy - 16 * s), pole);
      canvas.drawLine(Offset(x + sw - 1.5 * s, base.dy),
          Offset(x + sw - 1.5 * s, base.dy - 16 * s), pole);

      canvas.drawRect(Rect.fromLTWH(x + 1 * s, base.dy - 7 * s, sw - 2 * s, 7 * s),
          Paint()..color = _tone(const Color(0xFF8A7B66)));
      canvas.drawRect(Rect.fromLTWH(x + 1 * s, base.dy - 7 * s, sw - 2 * s, 1.2 * s),
          Paint()..color = _tone(const Color(0xFFD9D2C3)));
      for (int k = 0; k < 3; k++) {
        canvas.drawCircle(Offset(x + (4 + k * 5) * s, base.dy - 8 * s), 1.3 * s,
            Paint()..color = _tone(goods[rng.nextInt(goods.length)]));
      }

      canvas.drawPath(
          Path()
            ..moveTo(x, base.dy - 19 * s)
            ..lineTo(x + sw, base.dy - 19 * s)
            ..lineTo(x + sw + 1 * s, base.dy - 15 * s)
            ..lineTo(x - 1 * s, base.dy - 15 * s)
            ..close(),
          Paint()..color = _tone(canopy));
      if (striped) {
        final stripe = Paint()..color = _tone(const Color(0xFFF4F0E6));
        for (int k = 1; k < 6; k += 2) {
          final f0 = k / 6, f1 = (k + 1) / 6;
          canvas.drawPath(
              Path()
                ..moveTo(x + sw * f0, base.dy - 19 * s)
                ..lineTo(x + sw * f1, base.dy - 19 * s)
                ..lineTo(x - s + (sw + 2 * s) * f1, base.dy - 15 * s)
                ..lineTo(x - s + (sw + 2 * s) * f0, base.dy - 15 * s)
                ..close(),
              stripe);
        }
      }

      canvas.drawRect(
          Rect.fromLTWH(x + 2.5 * s, base.dy - 23 * s, sw - 5 * s, 3.5 * s),
          Paint()
            ..color = _tone(
                i.isEven ? const Color(0xFFD23A2C) : const Color(0xFFF0C53C)));
    }

    final bulbs = _nightMarketBulbs(base, s);
    if (bulbs.isNotEmpty) {
      final wire = Path()..moveTo(bulbs.first.dx, bulbs.first.dy);
      for (final b in bulbs.skip(1)) {
        wire.lineTo(b.dx, b.dy);
      }
      canvas.drawPath(
          wire,
          Paint()
            ..color = _tone(const Color(0xFF3A3530))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5 * s);
      for (final b in bulbs) {
        if (isNight) {
          canvas.drawCircle(b, 2.2 * s, Paint()..color = p.light.withValues(alpha: 0.3));
        }
        canvas.drawCircle(b, 0.9 * s,
            Paint()..color = isNight ? p.light : _tone(const Color(0xFFF2EAD0)));
      }
    }

    final people = isNight ? 8 : 3;
    for (int k = 0; k < people; k++) {
      final px = left + rng.nextDouble() * _nmStalls * sw;
      final py = base.dy + 2 * s + rng.nextDouble() * 3 * s;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(px - 1.6 * s, py - 6 * s, 3.2 * s, 6 * s),
              Radius.circular(1.2 * s)),
          Paint()..color = _tone(shirts[rng.nextInt(shirts.length)]));
      canvas.drawCircle(Offset(px, py - 7.4 * s), 1.4 * s,
          Paint()..color = _tone(const Color(0xFF2E2620)));
    }
  }

  void _drawHouseCluster(Canvas canvas, _SceneryPalette p, Random rng,
      double baseX, double baseY) {
    final wallPaint = Paint()..color = p.brick.withValues(alpha: 0.85);
    final roofPaint = Paint()..color = p.roof.withValues(alpha: 0.95);
    final winPaint = Paint()
      ..color = isNight
          ? p.light.withValues(alpha: 0.8)
          : p.water.withValues(alpha: 0.5);

    final count = 2 + rng.nextInt(3);
    for (int i = 0; i < count; i++) {
      final scale = 0.6 + rng.nextDouble() * 0.6;
      final x = baseX + (rng.nextDouble() - 0.5) * 60;
      final y = baseY + (rng.nextDouble() - 0.5) * 15;
      final w = 25 * scale;
      final h = 16 * scale;

      final eaveY = y - h;
      final ridge = Offset(x + w / 2, eaveY - 10 * scale);
      final eave = Offset(x + w + 2 * scale, eaveY);
      final depth = Offset(7 * scale, -3 * scale);
      canvas.drawOval(Rect.fromLTWH(x - 3 * scale, y - 3 * scale,
          w + 13 * scale, 6 * scale),
          Paint()..color = p.darkLand.withValues(alpha: 0.6));
      canvas.drawRect(Rect.fromLTWH(x, eaveY, w, h), wallPaint);
      canvas.drawPath(
          Path()..addPolygon([
            Offset(x + w, eaveY), Offset(x + w, eaveY) + depth,
            Offset(x + w, y) + depth, Offset(x + w, y),
          ], true),
          Paint()..color = Color.lerp(p.brick, p.darkLand, 0.38)!);
      canvas.drawPath(
          Path()..addPolygon([ridge, ridge + depth, eave + depth, eave], true),
          Paint()..color = Color.lerp(p.roof, p.haze, 0.18)!);
      canvas.drawPath(
          Path()..addPolygon([Offset(x - 2 * scale, eaveY), ridge, eave], true),
          roofPaint);
      canvas.drawRect(
          Rect.fromLTWH(x + w * 0.2, y - h * 0.6, 6 * scale, 7 * scale), winPaint);
    }
  }

  // ===========================================================================
  // 植物與動物
  // ===========================================================================

  void _drawPalm(Canvas canvas, _SceneryPalette p, Random rng, Offset base,
      double scale) {
    final trunk = Paint()
      ..color = p.village.withValues(alpha: 0.8)
      ..strokeWidth = 1.8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final frond = Paint()
      ..color = p.tree.withValues(alpha: 0.85)
      ..strokeWidth = 1.6 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final h = (40 + rng.nextDouble() * 14) * scale;
    final sway = (rng.nextDouble() - 0.5) * 10 * scale;
    final top = Offset(base.dx + sway, base.dy - h);

    canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
              base.dx + sway * 0.4, base.dy - h * 0.6, top.dx, top.dy),
        trunk);
    for (int i = 0; i < 7; i++) {
      final dir = -1.0 + 2.0 * (i / 6);
      final len = (10 + rng.nextDouble() * 3) * scale;
      final end =
          Offset(top.dx + dir * len, top.dy + dir.abs() * 6 * scale - 2 * scale);
      final ctrl = Offset(top.dx + dir * len * 0.5, top.dy - 7 * scale);
      canvas.drawPath(
          Path()
            ..moveTo(top.dx, top.dy)
            ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy),
          frond);
    }
  }

  void _drawPalmTrees(Canvas canvas, _SceneryPalette p, Random rng,
      {required int count, required double y, required double spread}) {
    for (int i = 0; i < count; i++) {
      final x = spread * (0.1 + rng.nextDouble() * 0.9);
      _drawPalm(canvas, p, rng, Offset(x, y + rng.nextDouble() * 10),
          1.2 + rng.nextDouble() * 0.5);
    }
  }

  void _drawBamboo(Canvas canvas, _SceneryPalette p, Random rng, Offset pos,
      double scale) {
    final stemPaint = Paint()
      ..color = p.tree.withValues(alpha: 0.7)
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;
    final leafPaint = Paint()..color = p.tree.withValues(alpha: 0.85);

    final stems = 12 + rng.nextInt(8);
    for (int i = 0; i < stems; i++) {
      final h = (30 + rng.nextDouble() * 40) * scale;
      final ox = (rng.nextDouble() - 0.5) * 40 * scale;
      canvas.drawPath(
          Path()
            ..moveTo(pos.dx + ox, pos.dy)
            ..quadraticBezierTo(
                pos.dx + ox + (rng.nextDouble() - 0.5) * 20 * scale,
                pos.dy - h * 0.5,
                pos.dx + ox + (rng.nextDouble() - 0.5) * 30 * scale,
                pos.dy - h),
          stemPaint);
      canvas.drawCircle(
          Offset(pos.dx + ox + (rng.nextDouble() - 0.5) * 30 * scale, pos.dy - h),
          6 * scale,
          leafPaint);
    }
  }

  void _drawTrees(Canvas canvas, Size size, _SceneryPalette p, Random rng,
      {required int count,
      required double y,
      required double spread,
      double x0 = 0,
      double scale = 1}) {
    final trunkPaint = Paint()
      ..color = p.village.withValues(alpha: 0.7)
      ..strokeWidth = 2 * scale;
    final crownPaint = Paint()..color = p.tree.withValues(alpha: 0.85);
    final crownLight = Paint()
      ..color = Color.lerp(p.tree, p.light, 0.2)!
          .withValues(alpha: isNight ? 0.2 : 0.5);

    for (int i = 0; i < count; i++) {
      final x = x0 + spread * (0.1 + rng.nextDouble() * 0.8);
      final h = (15 + rng.nextDouble() * 20) * scale;
      final r = (8 + rng.nextDouble() * 8) * scale;
      canvas.drawLine(Offset(x, y), Offset(x, y - h), trunkPaint);
      canvas.drawCircle(Offset(x, y - h), r, crownPaint);
      canvas.drawCircle(Offset(x - r * 0.6, y - h + 4 * scale), r * 0.8, crownPaint);
      canvas.drawCircle(Offset(x + r * 0.6, y - h + 4 * scale), r * 0.8, crownPaint);
      canvas.drawCircle(
          Offset(x - r * 0.3, y - h - r * 0.3), r * 0.45, crownLight);
    }
  }

  void _drawSilvergrassCluster(Canvas canvas, _SceneryPalette p, Random rng,
      Offset pos, double scale) {
    final stem = Paint()
      ..color = p.accent.withValues(alpha: 0.7)
      ..strokeWidth = 1.0 * scale
      ..style = PaintingStyle.stroke;
    final plume = Paint()
      ..color = isNight
          ? Colors.white.withValues(alpha: 0.18)
          : const Color(0xFFEADFC4).withValues(alpha: 0.85);

    for (int i = 0; i < 10; i++) {
      final ox = (rng.nextDouble() - 0.5) * 36 * scale;
      final h = (16 + rng.nextDouble() * 14) * scale;
      final lean = (rng.nextDouble() - 0.5) * 10 * scale;
      final top = Offset(pos.dx + ox + lean, pos.dy - h);
      canvas.drawPath(
          Path()
            ..moveTo(pos.dx + ox, pos.dy)
            ..quadraticBezierTo(
                pos.dx + ox + lean * 0.3, pos.dy - h * 0.6, top.dx, top.dy),
          stem);
      canvas.save();
      canvas.translate(top.dx, top.dy);
      canvas.rotate(lean / (20 * scale));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(0, -3 * scale), width: 3.5 * scale, height: 9 * scale),
          plume);
      canvas.restore();
    }
  }

  // ===========================================================================
  // 動態元素
  // ===========================================================================

  /// 台鐵區間車：縮到遠景比例，全寬行駛（含過橋）
  void _drawTrain(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    const s = 0.6;
    const len = 125 * s;
    final trainX = -len + ((anim * 3) % 1.0) * (size.width + len * 2);
    final y = _valleyRailwayTop(size);
    _drawTrainBody(canvas, p, trainX, y, s);
  }

  void _drawTrainBody(
      Canvas canvas, _SceneryPalette p, double trainX, double y, double s) {
    final wheels = Paint()..color = _tone(const Color(0xFF424747));
    for (final axle in [14, 22, 103, 111]) {
      canvas.drawCircle(Offset(trainX + axle * s, y - 2.5 * s), 2.5 * s,
          wheels);
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(trainX, y - 22 * s, 125 * s, 18 * s),
            Radius.circular(3 * s)),
        Paint()
          ..color = (isNight ? const Color(0xFF9AA4AC) : const Color(0xFFE8ECEF))
              .withValues(alpha: isNight ? 0.55 : 0.92));
    canvas.drawRect(
        Rect.fromLTWH(trainX, y - 9 * s, 125 * s, 3.5 * s),
        Paint()
          ..color =
              const Color(0xFF2E5FA3).withValues(alpha: isNight ? 0.5 : 0.9));
    final winPaint = Paint()
      ..color = isNight
          ? p.light.withValues(alpha: 0.85)
          : const Color(0xFF3A4E5C).withValues(alpha: 0.6);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
          Rect.fromLTWH(trainX + (8 + i * 22) * s, y - 18 * s, 12 * s, 7 * s),
          winPaint);
    }
  }

  void _drawWaves(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.08 : 0.16)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final sea = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addPath(_beachPath(size), Offset.zero);
    canvas.save();
    canvas.clipPath(sea);

    final shift = anim * 2 * pi;
    for (int r = 0; r < 5; r++) {
      final waveY = size.height * (0.66 + r * 0.065);
      final path = Path()..moveTo(0, waveY);
      for (int i = 0; i <= 10; i++) {
        final x = i * size.width / 10;
        path.lineTo(x, waveY + sin(x * 0.018 + shift + r) * 4);
      }
      canvas.drawPath(path, wavePaint);
    }
    canvas.restore();
  }

  void _drawWaterShimmer(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final shimmer = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    if (variant == LandscapeVariant.centralValley) {
      for (int i = 0; i < 9; i++) {
        final f = (anim * 1.2 + i / 9) % 1.0;
        final t = 0.15 + f * 0.8;
        final c = _channelCenter(size, t, i % 3);
        final len = 2 + 8 * t;
        shimmer.color = Colors.white
            .withValues(alpha: (isNight ? 0.08 : 0.28) * sin(f * pi));
        canvas.drawLine(c.translate(-len / 2, 0), c.translate(len / 2, 0), shimmer);
      }
      return;
    }

    final estuary = variant == LandscapeVariant.northEstuary;
    final y0 = estuary ? 0.645 : 0.72;
    final dy = estuary ? 0.018 : 0.03;
    final shift = anim * pi * 2;
    shimmer.color = Colors.white.withValues(alpha: isNight ? 0.08 : 0.2);
    for (int i = 0; i < 6; i++) {
      final y = size.height * (y0 + i * dy);
      final x = size.width * (estuary ? 0.1 : 0.3) + sin(shift + i) * 20 + i * 15;
      canvas.drawLine(
          Offset(x, y), Offset(x + 15 + sin(shift * 2 + i) * 10, y), shimmer);
    }
  }

  void _drawEgretsFlying(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final rng = Random(seed + 31);
    final wing = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.25 : 0.9)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final speed = 1.6 + rng.nextDouble() * 0.9;
      final yBase = size.height * (0.28 + rng.nextDouble() * 0.16);
      final s = 1.0 + rng.nextDouble() * 0.5;
      final offset = rng.nextDouble();

      final phase = (anim * speed + offset) % 1.25;
      final x = -40 + phase * (size.width + 80);
      final y = yBase + sin(anim * 2 * pi * 2 + i * 1.7) * 4;
      final flap = sin(anim * 2 * pi * 60 + i * 2.1) * 4.5 * s;

      canvas.drawPath(
          Path()
            ..moveTo(x - 7 * s, y - flap)
            ..quadraticBezierTo(x - 2 * s, y + 1.5, x, y)
            ..quadraticBezierTo(x + 2 * s, y + 1.5, x + 7 * s, y - flap),
          wing);
    }
  }

  void _drawWindTurbineBlades(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final blade = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.22 : 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final hubs = _turbineHubs(size);
    for (int i = 0; i < hubs.length; i++) {
      final r = _turbineRadius(size, i);
      canvas.save();
      canvas.translate(hubs[i].dx, hubs[i].dy);
      canvas.rotate(anim * 2 * pi * 6 + i * 0.9);
      for (int b = 0; b < 3; b++) {
        canvas.rotate(2 * pi / 3);
        canvas.drawLine(Offset.zero, Offset(0, -r), blade);
      }
      canvas.restore();
    }
  }

  void _drawFishingBoat(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final estuary = variant == LandscapeVariant.northEstuary;
    final x = size.width * (estuary ? 0.22 : 0.62);
    final y = size.height * (estuary ? 0.695 : 0.64) + sin(anim * 2 * pi * 8) * 1.8;

    canvas.drawPath(
        Path()
          ..moveTo(x - 16, y)
          ..lineTo(x + 18, y)
          ..lineTo(x + 13, y + 7)
          ..lineTo(x - 12, y + 7)
          ..close(),
        Paint()
          ..color =
              const Color(0xFF2A4E7A).withValues(alpha: isNight ? 0.5 : 0.9));
    canvas.drawRect(
        Rect.fromLTWH(x - 15, y + 1, 32, 2),
        Paint()
          ..color =
              const Color(0xFFB83A2E).withValues(alpha: isNight ? 0.45 : 0.9));
    canvas.drawRect(Rect.fromLTWH(x - 4, y - 7, 10, 7),
        Paint()..color = Colors.white.withValues(alpha: isNight ? 0.3 : 0.85));
    if (isNight) {
      canvas.drawCircle(Offset(x + 1, y - 3.5), 3,
          Paint()..color = p.light.withValues(alpha: 0.3));
    }
  }

  /// 鹿野熱氣球
  void _drawBalloons(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final rng = Random(seed + 911);
    const schemes = [
      [Color(0xFFE2463A), Color(0xFFF4C542), Color(0xFFF08A2C)],
      [Color(0xFF2F7DD1), Color(0xFFF4F1EA), Color(0xFF35B3A6)],
      [Color(0xFF4FA35B), Color(0xFFF4D35E), Color(0xFFF4F1EA)],
      [Color(0xFF8E5BC4), Color(0xFFF07FAE), Color(0xFFF4F1EA)],
    ];
    for (int i = 0; i < 3; i++) {
      final r = 9 + rng.nextDouble() * 8;
      final x0 = size.width * (0.2 + rng.nextDouble() * 0.65);
      final off = rng.nextDouble();
      final scheme = schemes[rng.nextInt(schemes.length)];
      final ph = (anim + off) % 1.0;
      final fade = ph < 0.12 ? ph / 0.12 : (ph > 0.85 ? (1 - ph) / 0.15 : 1.0);
      final x = x0 + ph * 30 + sin(anim * 2 * pi * 3 + i) * 3;
      final y = size.height * (0.54 - 0.32 * ph) + sin(anim * 2 * pi * 4 + i * 1.3) * 2;
      _drawBalloon(canvas, p, Offset(x, y), r, scheme, fade, anim, i);
    }
  }

  void _drawBalloon(Canvas canvas, _SceneryPalette p, Offset c, double r,
      List<Color> scheme, double a, double anim, int i) {
    final x = c.dx, y = c.dy;
    final env = Path()
      ..moveTo(x - r * 0.98, y + r * 0.2)
      ..cubicTo(x - r * 1.0, y - r * 1.3, x + r * 1.0, y - r * 1.3, x + r * 0.98,
          y + r * 0.2)
      ..cubicTo(x + r * 0.9, y + r * 0.75, x + r * 0.35, y + r * 1.2,
          x + r * 0.28, y + r * 1.45)
      ..lineTo(x - r * 0.28, y + r * 1.45)
      ..cubicTo(x - r * 0.35, y + r * 1.2, x - r * 0.9, y + r * 0.75,
          x - r * 0.98, y + r * 0.2)
      ..close();
    final bounds = Rect.fromLTRB(x - r, y - r * 1.3, x + r, y + r * 1.5);

    canvas.save();
    canvas.clipPath(env);
    canvas.drawRect(bounds, Paint()..color = _tone(scheme[0]).withValues(alpha: a));
    final gore = Paint()..color = _tone(scheme[1]).withValues(alpha: a);
    for (int g = -3; g <= 3; g += 2) {
      canvas.drawRect(
          Rect.fromLTWH(x + g * r * 0.3 - r * 0.14, y - r * 1.3, r * 0.28, r * 2.8),
          gore);
    }
    canvas.drawRect(Rect.fromLTWH(x - r, y + r * 0.35, 2 * r, r * 0.2),
        Paint()..color = _tone(scheme[2]).withValues(alpha: a));
    canvas.drawRect(
        bounds,
        Paint()
          ..shader = ui.Gradient.radial(
              Offset(x - r * 0.35, y - r * 0.5), r * 1.6, [
            Colors.white.withValues(alpha: 0.28 * a),
            Colors.black.withValues(alpha: 0.22 * a),
          ]));
    if (isNight) {
      final flicker = 0.6 + 0.4 * sin(anim * 2 * pi * 30 + i);
      canvas.drawCircle(Offset(x, y + r * 0.4), r * 1.2,
          Paint()..color = p.light.withValues(alpha: 0.45 * flicker * a));
    }
    canvas.restore();

    final rope = Paint()
      ..color = _tone(const Color(0xFF5A4A3A)).withValues(alpha: a)
      ..strokeWidth = 0.6;
    canvas.drawLine(Offset(x - r * 0.28, y + r * 1.45),
        Offset(x - r * 0.18, y + r * 1.8), rope);
    canvas.drawLine(Offset(x + r * 0.28, y + r * 1.45),
        Offset(x + r * 0.18, y + r * 1.8), rope);
    canvas.drawRect(Rect.fromLTWH(x - r * 0.2, y + r * 1.8, r * 0.4, r * 0.3),
        Paint()..color = _tone(const Color(0xFF8A5A34)).withValues(alpha: a));
    if (isNight || isMorning) {
      canvas.drawCircle(
          Offset(x, y + r * 1.6),
          r * 0.12,
          Paint()
            ..color = const Color(0xFFFFC24A)
                .withValues(alpha: a * (0.5 + 0.5 * sin(anim * 2 * pi * 40 + i))));
    }
  }

  /// 纜車車廂
  void _drawGondolaCabins(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final a = _gondA(size), b = _gondB(size), c = _gondC(size);
    const colors = [
      Color(0xFF39A9C9),
      Color(0xFFE2574C),
      Color(0xFFF2C14E),
      Color(0xFF6DBE7A),
    ];
    final hang = Paint()
      ..color = _tone(const Color(0xFF4A4F54))
      ..strokeWidth = 0.6;
    for (int i = 0; i < 5; i++) {
      final t = (anim * 3 + i / 5) % 1.0;
      final pt = _quad(a, c, b, t);
      canvas.drawLine(pt, pt.translate(0, 3), hang);
      final cabin = Rect.fromCenter(center: pt.translate(0, 6), width: 4.5, height: 5);
      canvas.drawRRect(RRect.fromRectAndRadius(cabin, const Radius.circular(1.2)),
          Paint()..color = _tone(colors[i % colors.length]));
      canvas.drawRect(
          Rect.fromLTWH(cabin.left + 0.6, cabin.top + 1, cabin.width - 1.2, 1.6),
          Paint()
            ..color = isNight
                ? p.light.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.6));
    }
  }

  void _drawLighthouseBeam(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    if (!(isNight || isEvening)) return;
    final lamp = _lhLamp(size);
    final ang = 0.05 + sin(anim * 2 * pi * 5) * 0.35;
    final len = size.width * 0.7;
    const spread = 0.06;
    final tip = lamp + Offset(cos(ang), sin(ang)) * len;
    canvas.drawPath(
        Path()
          ..moveTo(lamp.dx, lamp.dy)
          ..lineTo(lamp.dx + cos(ang - spread) * len, lamp.dy + sin(ang - spread) * len)
          ..lineTo(lamp.dx + cos(ang + spread) * len, lamp.dy + sin(ang + spread) * len)
          ..close(),
        Paint()
          ..shader = ui.Gradient.linear(lamp, tip, [
            p.light.withValues(alpha: 0.3),
            p.light.withValues(alpha: 0),
          ]));
    canvas.drawCircle(lamp, 6, Paint()..color = p.light.withValues(alpha: 0.35));
  }

  void _drawSkyLanterns(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final rng = Random(seed + 77);
    for (int i = 0; i < 5; i++) {
      final startX = size.width * (0.12 + rng.nextDouble() * 0.76);
      final offset = rng.nextDouble();
      final drift = rng.nextDouble() * 2 + 1;

      final phase = (anim * 2 + offset) % 1.0;
      final x = startX + sin(phase * drift * 2 * pi) * 10 + phase * 16;
      final y = size.height * (0.78 - phase * 0.7);
      final a = phase < 0.1
          ? phase / 0.1
          : (phase > 0.75 ? (1 - phase) / 0.25 : 1.0);
      final s = 6.0 - phase * 2.5;

      canvas.drawCircle(Offset(x, y), s * 2.4,
          Paint()..color = p.light.withValues(alpha: a * 0.16));
      canvas.drawPath(
          Path()
            ..moveTo(x - s * 0.72, y - s * 0.2)
            ..quadraticBezierTo(x, y - s * 1.6, x + s * 0.72, y - s * 0.2)
            ..lineTo(x + s * 0.5, y + s * 0.7)
            ..lineTo(x - s * 0.5, y + s * 0.7)
            ..close(),
          Paint()..color = p.lantern.withValues(alpha: a * 0.9));
      canvas.drawRect(Rect.fromLTWH(x - s * 0.28, y + s * 0.5, s * 0.56, s * 0.3),
          Paint()..color = p.light.withValues(alpha: a * 0.95));
    }
  }

  void _drawIncenseSmoke(
      Canvas canvas, Offset src, double s, double anim, int salt) {
    for (int i = 0; i < 5; i++) {
      final phase = (anim * 9 + i / 5 + salt * 0.13) % 1.0;
      final y = src.dy - phase * 26 * s;
      final x = src.dx +
          sin(phase * 5 + i + anim * 2 * pi * 3) * 3 * s * phase +
          phase * 6 * s;
      canvas.drawCircle(
          Offset(x, y),
          (1.5 + phase * 5) * s,
          Paint()
            ..color = const Color(0xFFE9E6E0)
                .withValues(alpha: (1 - phase) * (isNight ? 0.12 : 0.22)));
    }
  }

  void _drawNightMarketLights(
      Canvas canvas, _SceneryPalette p, Offset base, double s, double anim) {
    if (!isNight) return;
    final bulbs = _nightMarketBulbs(base, s);
    for (int i = 0; i < bulbs.length; i++) {
      final tw = 0.5 + 0.5 * sin(anim * 2 * pi * 25 + i * 1.9);
      canvas.drawCircle(bulbs[i], 2.8 * s,
          Paint()..color = p.light.withValues(alpha: 0.18 * tw));
    }
  }

  /// 自行車騎士：靠右通行，左車道迎面、右車道遠離
  void _drawCyclists(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final rng = Random(seed + 501);
    const helmets = [
      Color(0xFFF2C230),
      Color(0xFFD8392B),
      Color(0xFFF4F1EA),
      Color(0xFF3C78C8),
      Color(0xFF2B2B2B),
    ];
    const jerseys = [
      Color(0xFF2F7DD1),
      Color(0xFFE2574C),
      Color(0xFF35B3A6),
      Color(0xFFF2C14E),
      Color(0xFF7B5EA7),
      Color(0xFFF4F1EA),
    ];

    final list = <_Cyclist>[];
    for (int i = 0; i < 4; i++) {
      final approach = i.isEven;
      final speed = 2.0 + rng.nextInt(3);
      final off = rng.nextDouble();
      final helmet = helmets[rng.nextInt(helmets.length)];
      final jersey = jerseys[rng.nextInt(jerseys.length)];

      final phase = (anim * speed + off) % 1.0;
      final u = pow(approach ? phase : 1 - phase, 1.6).toDouble();
      // 從高架落地線之前才出現，避免畫在橋墩前面
      final t = _cyclistT0 + u * (1.04 - _cyclistT0);
      final y = size.height * _roadY(t);
      final cx = size.width * _roadCx(t);
      final half = size.width * _roadHalf(t);
      final x = cx + (approach ? -0.45 : 0.45) * half;

      list.add(_Cyclist(
        pos: Offset(x, y),
        scale: 0.25 + 1.45 * u,
        approach: approach,
        helmet: helmet,
        jersey: jersey,
        pedal: anim * 2 * pi * 40 + i,
        opacity: (u / 0.06).clamp(0.0, 1.0),
      ));
    }

    list.sort((a, b) => a.pos.dy.compareTo(b.pos.dy));
    for (final c in list) {
      _drawCyclist(canvas, p, c);
    }
  }

  void _drawCyclist(Canvas canvas, _SceneryPalette p, _Cyclist c) {
    if (c.opacity <= 0) return;
    final pos = c.pos;
    final s = c.scale;

    final fading = c.opacity < 1;
    if (fading) {
      canvas.saveLayer(
          Rect.fromLTRB(pos.dx - 8 * s, pos.dy - 22 * s, pos.dx + 8 * s,
              pos.dy + 10 * s),
          Paint()..color = Colors.white.withValues(alpha: c.opacity));
    }

    if (isNight && c.approach) {
      canvas.drawPath(
          Path()
            ..moveTo(pos.dx - 1 * s, pos.dy)
            ..lineTo(pos.dx + 1 * s, pos.dy)
            ..lineTo(pos.dx + 5 * s, pos.dy + 9 * s)
            ..lineTo(pos.dx - 5 * s, pos.dy + 9 * s)
            ..close(),
          Paint()..color = p.light.withValues(alpha: 0.1));
    }

    canvas.drawOval(
        Rect.fromCenter(
            center: pos.translate(0, 0.5 * s), width: 7 * s, height: 1.6 * s),
        Paint()..color = Colors.black.withValues(alpha: 0.16));
    canvas.drawLine(
        pos.translate(0, -0.3 * s),
        pos.translate(0, -6.5 * s),
        Paint()
          ..color = const Color(0xFF1E1E1E)
          ..strokeWidth = 1.1 * s
          ..strokeCap = StrokeCap.round);

    final legPaint = Paint()
      ..color = _tone(const Color(0xFF2B2B33))
      ..strokeWidth = 1.3 * s
      ..strokeCap = StrokeCap.round;
    final hip = pos.translate(0, -11 * s);
    final lift = sin(c.pedal) * 1.8 * s;
    canvas.drawLine(hip.translate(-1.2 * s, 0),
        pos.translate(-1.6 * s, -4 * s - lift), legPaint);
    canvas.drawLine(hip.translate(1.2 * s, 0),
        pos.translate(1.6 * s, -4 * s + lift), legPaint);

    final jersey = _tone(c.jersey);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(pos.dx - 2.6 * s, pos.dy - 17 * s, pos.dx + 2.6 * s,
                pos.dy - 10.5 * s),
            Radius.circular(1.8 * s)),
        Paint()..color = jersey);
    canvas.drawLine(
        Offset(pos.dx - 4 * s, pos.dy - 12 * s),
        Offset(pos.dx + 4 * s, pos.dy - 12 * s),
        Paint()
          ..color = const Color(0xFF3A3A3A)
          ..strokeWidth = 0.8 * s);
    final arm = Paint()
      ..color = jersey
      ..strokeWidth = 1.1 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(pos.dx - 2.3 * s, pos.dy - 16 * s),
        Offset(pos.dx - 3.8 * s, pos.dy - 12 * s), arm);
    canvas.drawLine(Offset(pos.dx + 2.3 * s, pos.dy - 16 * s),
        Offset(pos.dx + 3.8 * s, pos.dy - 12 * s), arm);

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(pos.dx, pos.dy - 18.6 * s),
            width: 4.6 * s,
            height: 3.2 * s),
        Paint()..color = _tone(c.helmet));

    if (c.approach) {
      final lamp = Offset(pos.dx, pos.dy - 11.2 * s);
      if (isNight || isEvening) {
        canvas.drawCircle(lamp, 3.5 * s,
            Paint()..color = const Color(0xFFFFF6D8).withValues(alpha: 0.35));
      }
      canvas.drawCircle(lamp, 0.9 * s, Paint()..color = const Color(0xFFFFF6D8));
    } else {
      final tail = Offset(pos.dx, pos.dy - 8 * s);
      final blinkOn = sin(c.pedal * 0.25) > 0;
      if ((isNight || isEvening) && blinkOn) {
        canvas.drawCircle(tail, 3 * s,
            Paint()..color = const Color(0xFFE0302A).withValues(alpha: 0.45));
      }
      canvas.drawCircle(tail, 0.8 * s, Paint()..color = const Color(0xFFE0302A));
    }

    if (fading) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) {
    return oldDelegate.biome != biome ||
        oldDelegate.dayPhase != dayPhase ||
        oldDelegate.variant != variant ||
        oldDelegate.seed != seed ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.touch != touch ||
        oldDelegate.touchProgress != touchProgress;
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
        brick: Color(0xFF3C2822),
        templeRed: Color(0xFF4E2420),
        lantern: Color(0xFFC84A38),
        haze: Color(0xFF223040),
      );
    }

    if (isEvening) {
      return const _SceneryPalette(
        farMountain: Color(0xFF686369),
        nearMountain: Color(0xFF4A524C),
        land: Color(0xFF4B542F),
        darkLand: Color(0xFF303A25),
        water: Color(0xFF34546A),
        village: Color(0xFF393128),
        roof: Color(0xFF6A4030),
        tree: Color(0xFF263B27),
        infrastructure: Color(0xFF2D2620),
        accent: Color(0xFFB58B54),
        light: Color(0xFFFFD47A),
        brick: Color(0xFF7E4634),
        templeRed: Color(0xFF93352A),
        lantern: Color(0xFFE0523C),
        haze: Color(0xFFC1ADA1),
      );
    }

    if (isMorning) {
      return const _SceneryPalette(
        farMountain: Color(0xFF819395),
        nearMountain: Color(0xFF61796B),
        land: Color(0xFF617342),
        darkLand: Color(0xFF3D5333),
        water: Color(0xFF6A9BA6),
        village: Color(0xFF655A4C),
        roof: Color(0xFF765140),
        tree: Color(0xFF355239),
        infrastructure: Color(0xFF4A443A),
        accent: Color(0xFF9BAA78),
        light: Color(0xFFFFE5A3),
        brick: Color(0xFFA66A52),
        templeRed: Color(0xFFB54A3C),
        lantern: Color(0xFFDE5B45),
        haze: Color(0xFFD5DED6),
      );
    }

    return const _SceneryPalette(
      farMountain: Color(0xFF82949C),
      nearMountain: Color(0xFF64796A),
      land: Color(0xFF78895B),
      darkLand: Color(0xFF505F47),
      water: Color(0xFF67888A),
      village: Color(0xFF898978),
      roof: Color(0xFF646E61),
      tree: Color(0xFF526C47),
      infrastructure: Color(0xFF535954),
      accent: Color(0xFF92A26F),
      light: Color(0xFFE0E4CC),
      brick: Color(0xFF9B6F56),
      templeRed: Color(0xFFA0503B),
      lantern: Color(0xFFD84B3A),
      haze: Color(0xFFCCD8D7),
    );
  }
}

class _PineapplePlants {
  final Path _shadows = Path();
  final Path _leaves = Path();
  final Path _litLeaves = Path();
  final Path _fruitShadows = Path();
  final Path _fruit = Path();
  final Path _eyes = Path();
  final Path _crowns = Path();

  void add(double x, double y, double scale, Random rng,
      {bool canFruit = true, double fruitChance = 0.26}) {
    Offset at(double dx, double dy) => Offset(x + dx * scale, y + dy * scale);

    _shadows.addOval(Rect.fromCenter(
        center: at(0.8, 0.2), width: 12 * scale, height: 2.6 * scale));
    for (int i = 0; i < 5; i++) {
      final spread = (i - 2) * 3.2 + (rng.nextDouble() - 0.5) * 1.4;
      final rise = 6.8 - (i - 2).abs() * 1.9 + rng.nextDouble() * 1.2;
      _blade(i < 2 ? _litLeaves : _leaves, at(0, 0), at(spread, -rise),
          1.9 * scale);
    }

    if (!canFruit || rng.nextDouble() >= fruitChance) return;

    _fruitShadows.addOval(Rect.fromCenter(
        center: at(0, -4.3), width: 5.4 * scale, height: 7 * scale));
    _fruit.addOval(Rect.fromCenter(
        center: at(-0.4, -4.7), width: 4.2 * scale, height: 5.7 * scale));

    for (final (dx, dy) in [(-1.2, -5.4), (0.7, -5.4), (-0.25, -3.6)]) {
      final top = at(dx, dy - 0.65);
      final right = at(dx + 0.55, dy);
      final bottom = at(dx, dy + 0.65);
      final left = at(dx - 0.55, dy);
      _eyes.addPolygon([top, right, bottom, left], true);
    }

    for (int i = -1; i <= 1; i++) {
      _blade(_crowns, at(0, -7.1), at(i * 2.2, -10.5 + i.abs() * 0.8),
          1.15 * scale);
    }
  }

  void _blade(Path path, Offset base, Offset tip, double width) {
    final bend = base + (tip - base) * 0.55;
    path
      ..moveTo(base.dx - width * 0.45, base.dy)
      ..quadraticBezierTo(bend.dx - width, bend.dy - width, tip.dx, tip.dy)
      ..quadraticBezierTo(
          bend.dx + width, bend.dy, base.dx + width * 0.45, base.dy)
      ..close();
  }

  void paint(Canvas canvas, Color Function(Color) tone) {
    final paint = Paint();
    canvas.drawPath(_shadows,
        paint..color = tone(const Color(0xFF35271E)).withValues(alpha: 0.3));
    canvas.drawPath(_leaves, paint..color = tone(const Color(0xFF3D624D)));
    canvas.drawPath(_litLeaves, paint..color = tone(const Color(0xFF789767)));
    canvas.drawPath(_fruitShadows, paint..color = tone(const Color(0xFF9A622E)));
    canvas.drawPath(_fruit, paint..color = tone(const Color(0xFFD4A254)));
    canvas.drawPath(_eyes, paint..color = tone(const Color(0xFFB67938)));
    canvas.drawPath(_crowns, paint..color = tone(const Color(0xFF628658)));
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
  final Color brick; // 紅磚（三合院）
  final Color templeRed; // 廟宇紅牆
  final Color lantern; // 紅燈籠／天燈
  final Color haze; // 空氣透視：遠景與山腳霧化的目標色

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
    required this.brick,
    required this.templeRed,
    required this.lantern,
    required this.haze,
  });
}
