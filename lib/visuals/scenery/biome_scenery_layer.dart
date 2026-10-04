import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/field_state.dart';

/// 細分的台灣景觀變體。
///
/// 12 種涵蓋北中南東不同地形的實景風格。
///
/// 地景：分層山脈（背光面、溪谷紋、稜線受光、樹冠起伏、山腳霧化）、
/// 透視棋盤水田（秧苗、金黃稻穗、映天光的水田）、立體梯田、
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

class _SceneLayout {
  final List<_Placement> placements;
  final bool road; // 有道路 → 自行車騎士
  final bool pineappleHills; // 中部丘陵：鳳梨田 or 茶園

  const _SceneLayout({
    required this.placements,
    this.road = false,
    this.pineappleHills = false,
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
    var pineappleHills = false;

    switch (v) {
      case LandscapeVariant.centralPlains:
        road = true;
        slots = const [
          _Slot(0.14, 0.665, 0.9, [
            _Decor.sanheyuan,
            _Decor.temple,
            _Decor.modernHouse,
            _Decor.artHouse,
          ]),
          _Slot(0.84, 0.665, 0.85, [
            _Decor.modernHouse,
            _Decor.sanheyuan,
            _Decor.nightMarket,
            _Decor.temple,
          ]),
          _Slot(0.37, 0.75, 0.9, [
            _Decor.artHouse,
            _Decor.modernHouse,
            _Decor.houseCluster,
          ]),
          _Slot(0.17, 0.85, 1.15, [
            _Decor.nightMarket,
            _Decor.nightMarket,
            _Decor.artHouse,
            _Decor.modernHouse,
          ]),
        ];
      case LandscapeVariant.southPlains:
        road = true;
        slots = const [
          _Slot(0.16, 0.67, 1.0, [_Decor.temple]),
          _Slot(0.84, 0.67, 0.85, [
            _Decor.sanheyuan,
            _Decor.modernHouse,
            _Decor.artHouse,
            _Decor.houseCluster,
          ]),
          _Slot(0.48, 0.665, 0.7, [_Decor.artHouse, _Decor.modernHouse]),
          _Slot(0.17, 0.86, 1.1, [
            _Decor.nightMarket,
            _Decor.nightMarket,
            _Decor.artHouse,
          ]),
        ];
      case LandscapeVariant.southWetlands:
        slots = const [
          _Slot(0.12, 0.66, 0.8, [
            _Decor.modernHouse,
            _Decor.sanheyuan,
            _Decor.temple,
            _Decor.artHouse,
          ]),
          _Slot(0.48, 0.655, 0.7, [
            _Decor.temple,
            _Decor.modernHouse,
            _Decor.houseCluster,
          ]),
          _Slot(0.86, 0.66, 0.8, [
            _Decor.nightMarket,
            _Decor.modernHouse,
            _Decor.sanheyuan,
          ]),
        ];
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
        slots = const [
          _Slot(0.18, 0.71, 0.55, [_Decor.shrine]),
          _Slot(0.42, 0.69, 0.8, [
            _Decor.modernHouse,
            _Decor.houseCluster,
            _Decor.artHouse,
          ]),
        ];
      case LandscapeVariant.centralHills:
        pineappleHills = rng.nextBool();
        slots = const [
          _Slot(0.45, 0.69, 0.8, [
            _Decor.modernHouse,
            _Decor.sanheyuan,
            _Decor.shrine,
            _Decor.artHouse,
          ]),
          _Slot(0.74, 0.7, 0.85, [
            _Decor.sanheyuan,
            _Decor.modernHouse,
            _Decor.houseCluster,
          ]),
        ];
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
      pineappleHills: pineappleHills,
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

  const BiomeSceneryLayer({
    super.key,
    required this.biome,
    required this.dayPhase,
    this.variantOverride,
  });

  @override
  State<BiomeSceneryLayer> createState() => _BiomeSceneryLayerState();
}

class _BiomeSceneryLayerState extends State<BiomeSceneryLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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

    _updateScene(force: true);
  }

  @override
  void didUpdateWidget(covariant BiomeSceneryLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.biome != widget.biome ||
        oldWidget.variantOverride != widget.variantOverride) {
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
          LandscapeVariant.southWetlands,
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
              layout: _layout,
              cache: _cache,
            ),
            size: Size.infinite,
          );
        },
      ),
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

  const _Cyclist({
    required this.pos,
    required this.scale,
    required this.approach,
    required this.helmet,
    required this.jersey,
    required this.pedal,
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

  _SceneryPainter({
    required this.biome,
    required this.dayPhase,
    required this.variant,
    required this.animationValue,
    required this.seed,
    required this.layout,
    required this.cache,
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

  // 河道（中部溪谷）
  static const _riverCtrl = [
    Offset(0.5, 0.675),
    Offset(0.68, 0.75),
    Offset(0.32, 0.83),
    Offset(-0.1, 0.93),
  ];

  (Offset, Offset, double) _riverFrame(Size size, double t) {
    Offset sc(Offset o) => Offset(o.dx * size.width, o.dy * size.height);
    final a = sc(_riverCtrl[0]),
        b = sc(_riverCtrl[1]),
        c = sc(_riverCtrl[2]),
        d = sc(_riverCtrl[3]);
    final pt = _cubic(a, b, c, d, t);
    final tan = _cubicTangent(a, b, c, d, t);
    final len = tan.distance == 0 ? 1.0 : tan.distance;
    return (pt, Offset(-tan.dy / len, tan.dx / len), (0.012 + 0.13 * t) * size.width);
  }

  Offset _channelCenter(Size size, double t, int ch) {
    final (pt, nrm, half) = _riverFrame(size, t);
    return pt + nrm * (half * sin(t * 7 + ch * 2.1 + 0.7) * (ch == 0 ? 0.35 : 0.6));
  }

  double _channelHalf(Size size, double t, int ch) =>
      (0.002 + 0.028 * t) * size.width * (ch == 0 ? 1.2 : 0.65);

  // 貓空纜車
  Offset _gondA(Size s) => Offset(-0.05 * s.width, 0.47 * s.height);
  Offset _gondB(Size s) => Offset(0.62 * s.width, 0.652 * s.height);
  Offset _gondC(Size s) => (_gondA(s) + _gondB(s)) / 2 + const Offset(0, 14);

  // 阿里山森林鐵路
  // 落在遠丘稜線（0.51–0.59）之下、近丘（0.63+）之上
  List<Offset> _alishanCtrl(Size s) => [
        Offset(-0.05 * s.width, 0.615 * s.height),
        Offset(0.3 * s.width, 0.59 * s.height),
        Offset(0.62 * s.width, 0.63 * s.height),
        Offset(1.05 * s.width, 0.6 * s.height),
      ];

  // 高鐵
  double _hsrDeckY(Size s) => s.height * 0.618;

  // 平原透視（棋盤田、水塘、光電板、蚵架、金針花、道路共用）
  static const double _plainsTop = 0.64;

  Offset _plainsVp(Size s, [double startY = _plainsTop]) =>
      Offset(s.width * 0.5, s.height * startY - s.height * 0.06);

  /// 把「地面基準座標 xb」（以畫面底邊為基準）投影到螢幕 y 高度上的 x
  double _plainsX(Size s, double xb, double y, [double startY = _plainsTop]) {
    final vp = _plainsVp(s, startY);
    return vp.dx + (xb - vp.dx) * (y - vp.dy) / (s.height - vp.dy);
  }

  /// 該螢幕 y 的透視縮放（底邊 = 1，地平線 = 0）
  double _plainsScale(Size s, double y, [double startY = _plainsTop]) {
    final vp = _plainsVp(s, startY);
    return (y - vp.dy) / (s.height - vp.dy);
  }

  Path _plainsQuad(Size s, double xb0, double xb1, double y0, double y1) =>
      Path()
        ..moveTo(_plainsX(s, xb0, y0), y0)
        ..lineTo(_plainsX(s, xb1, y0), y0)
        ..lineTo(_plainsX(s, xb1, y1), y1)
        ..lineTo(_plainsX(s, xb0, y1), y1)
        ..close();

  // 鄉間道路：由中間偏右的地平線往右下延伸，避開畫面中央的稻株
  double _roadCx(double t) => 0.64 + 0.22 * t;
  double _roadHalf(double t) => 0.02 + 0.09 * t;
  double _roadY(double t) => _plainsTop + (1 - _plainsTop) * t;

  // 溼地水塘（基準座標），solar = 漁電共生，否則蚵架
  List<({double xb0, double xb1, double y0, double y1, bool solar})>
      _wetlandPonds(Size s) {
    final w = s.width, h = s.height;
    return [
      (xb0: -0.35 * w, xb1: 0.42 * w, y0: 0.665 * h, y1: 0.715 * h, solar: false),
      (xb0: -0.15 * w, xb1: 0.38 * w, y0: 0.775 * h, y1: 0.855 * h, solar: false),
      (xb0: 0.58 * w, xb1: 1.55 * w, y0: 0.67 * h, y1: 0.73 * h, solar: true),
      (xb0: 0.62 * w, xb1: 1.7 * w, y0: 0.77 * h, y1: 0.85 * h, solar: true),
    ];
  }

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
    final p = _palette();

    final currentKey =
        '${variant.name}_${size.width}x${size.height}_${dayPhase.name}_$seed';

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

    _drawDynamicScene(canvas, size, p);
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
        _drawMountain(canvas, size, p, p.nearMountain, 0.65, h * 0.2, h * 0.8,
            60, 6, 1.4, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.64, 34, p, 0.12);
      case LandscapeVariant.northHills:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.4, h * 0.55, 60, rng);
        _drawMistBand(canvas, size, h * 0.6, 36, p, 0.14);
        _drawCitySkyline(canvas, size, p, rng);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.65, h * 0.65, 40, rng,
            forested: true);
      case LandscapeVariant.centralHills:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.45, h * 0.55, 60, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.6, 36, p, 0.12);
        _drawAlishanLine(canvas, size, p, rng);
        _drawRollingHills(
            canvas, size, p, p.nearMountain, 0.65, h * 0.65, 40, rng,
            forested: true);
      case LandscapeVariant.centralPlains:
        _drawMountain(canvas, size, p, p.farMountain, 0.3, h * 0.52,
            h * 0.56, 40, 6, 1.2, rng);
        _drawMountain(canvas, size, p, p.farMountain, 0.55, h * 0.6, h * 0.6,
            30, 6, 1.0, rng);
        _drawMistBand(canvas, size, h * 0.63, 26, p, 0.10);
      case LandscapeVariant.southCoast:
      case LandscapeVariant.eastCoast:
        _drawOcean(canvas, size, p, h * 0.58);
        if (variant == LandscapeVariant.eastCoast) {
          _drawDistantIsland(canvas, size, p, h * 0.58);
          // 清水斷崖意象：只佔左半，直落海面
          _drawMountain(canvas, size, p, p.nearMountain, 0.78, h * 0.34,
              h * 0.575, 30, 5, 1.2, rng,
              forested: true, xEndFrac: 0.55, bottomY: h * 0.6);
          _drawMistBand(canvas, size, h * 0.47, 30, p, 0.14);
        }
      case LandscapeVariant.northEstuary:
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.45, h * 0.6, 30, rng,
            forested: true);
        _drawMistBand(canvas, size, h * 0.62, 24, p, 0.10);
      case LandscapeVariant.southPlains:
      case LandscapeVariant.southWetlands:
        _drawMountain(canvas, size, p, p.farMountain, 0.35, h * 0.55, h * 0.6,
            35, 6, 1.1, rng);
        _drawRollingHills(
            canvas, size, p, p.farMountain, 0.5, h * 0.63, 15, rng);
    }

    // 2. 中景
    switch (variant) {
      case LandscapeVariant.centralPlains:
      case LandscapeVariant.eastRiftValley:
        _drawPlainsFields(canvas, size, p, rng);
      case LandscapeVariant.southPlains:
        _drawPlainsFields(canvas, size, p, rng);
        _drawPineapplePerspective(
            canvas, size, p, rng, -0.55 * w, 0.28 * w, h * 0.695, h * 0.8);
      case LandscapeVariant.northHills:
        _drawTerracedFields(canvas, size, p, rng);
        _drawTeaRows(canvas, size, p, rng);
      case LandscapeVariant.centralHills:
        _drawTerracedFields(canvas, size, p, rng);
        if (layout.pineappleHills) {
          _drawPineappleField(canvas, Rect.fromLTRB(0, h * 0.73, w, h), rng,
              soil: false, waveAmp: 26);
        } else {
          _drawTeaRows(canvas, size, p, rng);
        }
      case LandscapeVariant.northTerraces:
      case LandscapeVariant.eastFoothills:
        _drawTerracedFields(canvas, size, p, rng, flooded: true);
      case LandscapeVariant.southWetlands:
        _drawPlainsFields(canvas, size, p, rng);
        _drawWetlandWater(canvas, size, p, rng);
        _drawSolarFishFarm(canvas, size, p);
      case LandscapeVariant.centralValley:
        _drawPlainsFields(canvas, size, p, rng, startY: 0.69);
        _drawRiver(canvas, size, p, rng);
      case LandscapeVariant.northEstuary:
        _drawEstuary(canvas, size, p, rng);
      case LandscapeVariant.southCoast:
      case LandscapeVariant.eastCoast:
        _drawCoastBeach(canvas, size, p);
    }

    // 3. 地形專屬的固定元素
    switch (variant) {
      case LandscapeVariant.centralPlains:
        _drawHSRViaduct(canvas, size, p);
        _drawRoadAndPoles(canvas, size, p);
        _drawTrees(canvas, size, p, rng,
            count: 2, y: h * 0.7, spread: w * 0.18, x0: w * 0.8);
        _drawBuffalo(canvas, p, Offset(w * 0.12, h * 0.78), 0.8);
      case LandscapeVariant.southPlains:
        _drawHSRViaduct(canvas, size, p);
        _drawRoadAndPoles(canvas, size, p);
      case LandscapeVariant.eastRiftValley:
        _drawDaylilyPatch(canvas, size, p, rng);
        _drawRoadAndPoles(canvas, size, p);
      case LandscapeVariant.northHills:
        _drawBamboo(canvas, p, rng, Offset(w * 0.85, h * 0.68), 0.8);
        _drawGondolaLine(canvas, size, p);
      case LandscapeVariant.centralHills:
        _drawBamboo(canvas, p, rng, Offset(w * 0.12, h * 0.68), 0.8);
      case LandscapeVariant.northTerraces:
        _drawSilvergrassCluster(canvas, p, rng, Offset(w * 0.8, h * 0.78), 1.0);
        _drawTrees(canvas, size, p, rng, count: 4, y: h * 0.7, spread: w);
      case LandscapeVariant.eastFoothills:
        _drawSilvergrassCluster(canvas, p, rng, Offset(w * 0.2, h * 0.8), 1.1);
        _drawTrees(canvas, size, p, rng, count: 5, y: h * 0.7, spread: w);
      case LandscapeVariant.centralValley:
        _drawRailwayTrack(canvas, size, p);
        _drawTrees(canvas, size, p, rng,
            count: 3, y: h * 0.76, spread: w * 0.4, x0: w * 0.58);
      case LandscapeVariant.eastCoast:
        _drawRailwayTrack(canvas, size, p);
      case LandscapeVariant.southCoast:
        _drawPalmTrees(canvas, p, rng,
            count: 3, y: h * 0.62, spread: w * 0.45);
        _drawLighthouse(canvas, size, p);
      case LandscapeVariant.northEstuary:
        _drawWindTurbinePylons(canvas, size, p);
        _drawSilvergrassCluster(canvas, p, rng, Offset(w * 0.15, h * 0.82), 1.0);
      case LandscapeVariant.southWetlands:
        _drawOysterRacks(canvas, size, p, rng);
        for (int i = 0; i < 2; i++) {
          _drawEgretStanding(
              canvas,
              p,
              Offset(w * (0.2 + rng.nextDouble() * 0.3),
                  h * (0.76 + rng.nextDouble() * 0.1)),
              0.7 + rng.nextDouble() * 0.5);
        }
        _drawTrees(canvas, size, p, rng,
            count: 3, y: h * 0.65, spread: w * 0.8);
    }

    // 4. 聚落點綴：遠的先畫
    final sorted = [...layout.placements]
      ..sort((a, b) => a.fy.compareTo(b.fy));
    for (final pl in sorted) {
      _drawDecor(canvas, size, p, rng, pl);
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

    if (variant == LandscapeVariant.centralPlains ||
        variant == LandscapeVariant.southPlains) {
      _drawHSRTrain(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralValley ||
        variant == LandscapeVariant.eastCoast) {
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
        variant == LandscapeVariant.northEstuary ||
        variant == LandscapeVariant.southWetlands) {
      _drawWaterShimmer(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralPlains ||
        variant == LandscapeVariant.southPlains ||
        variant == LandscapeVariant.southWetlands ||
        variant == LandscapeVariant.eastRiftValley) {
      _drawEgretsFlying(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.northEstuary) {
      _drawWindTurbineBlades(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.northHills) {
      _drawGondolaCabins(canvas, size, p, anim);
    }

    if (variant == LandscapeVariant.centralHills) {
      _drawAlishanTrain(canvas, size, p, anim);
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
  // 地形：田、梯田、河、河口、海岸
  // ===========================================================================

  /// 透視棋盤水田：嫩綠秧苗、金黃稻穗、映天光的水田、深綠田
  void _drawPlainsFields(
      Canvas canvas, Size size, _SceneryPalette p, Random rng,
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

    double xAt(double xb, double y) => _plainsX(size, xb, y, startY);

    const rows = 7;
    const cols = 10;
    final rowY = [
      for (int k = 0; k <= rows; k++)
        top + (h - top) * pow(k / rows, 1.6).toDouble()
    ];
    final colX = [for (int j = 0; j <= cols; j++) -0.8 * w + j * 2.6 * w / cols];

    final young = Color.lerp(p.land, p.accent, 0.35)!;
    final golden =
        Color.lerp(p.land, const Color(0xFFD9B35A), isNight ? 0.2 : 0.55)!;
    final flooded = Color.lerp(p.water, p.haze, 0.35)!;
    final deep = Color.lerp(p.darkLand, p.land, 0.3)!;
    final types = [young, golden, flooded, deep];
    final texture = Paint()
      ..color = p.darkLand.withValues(alpha: 0.28)
      ..strokeWidth = 0.8;
    final seedling = Paint()..color = young.withValues(alpha: 0.85);

    for (int k = 0; k < rows; k++) {
      final y0 = rowY[k], y1 = rowY[k + 1];
      final near = k >= rows - 3;
      for (int j = 0; j < cols; j++) {
        final a0 = xAt(colX[j], y0), a1 = xAt(colX[j + 1], y0);
        final b0 = xAt(colX[j], y1), b1 = xAt(colX[j + 1], y1);
        if (max(a1, b1) < 0 || min(a0, b0) > w) continue;

        final r = rng.nextDouble();
        final type = r < 0.33 ? 0 : (r < 0.53 ? 1 : (r < 0.8 ? 2 : 3));
        final cell = Path()
          ..moveTo(a0, y0)
          ..lineTo(a1, y0)
          ..lineTo(b1, y1)
          ..lineTo(b0, y1)
          ..close();
        canvas.drawPath(cell, Paint()..color = types[type].withValues(alpha: 0.92));

        if (type == 2) {
          canvas.drawPath(
              cell,
              Paint()
                ..shader = ui.Gradient.linear(Offset(0, y0), Offset(0, y1), [
                  p.light.withValues(alpha: isNight ? 0.05 : 0.22),
                  p.light.withValues(alpha: 0),
                ]));
        }

        if (near) {
          if (type == 2) {
            for (int m = 1; m < 5; m++) {
              for (int n = 1; n < 4; n++) {
                final y = y0 + (y1 - y0) * n / 4;
                final xb = colX[j] + (colX[j + 1] - colX[j]) * m / 5;
                canvas.drawCircle(Offset(xAt(xb, y), y),
                    0.6 + 1.2 * (y - top) / (h - top), seedling);
              }
            }
          } else {
            for (int m = 1; m < 5; m++) {
              final xb = colX[j] + (colX[j + 1] - colX[j]) * m / 5;
              canvas.drawLine(Offset(xAt(xb, y0 + 1), y0 + 1),
                  Offset(xAt(xb, y1 - 1), y1 - 1), texture);
            }
          }
        }
      }
    }

    // 田埂
    final ridge = Paint()
      ..color = Color.lerp(p.accent, p.light, 0.25)!
          .withValues(alpha: isNight ? 0.15 : 0.45)
      ..style = PaintingStyle.stroke;
    for (int k = 1; k <= rows; k++) {
      ridge.strokeWidth = 0.5 + 2.2 * pow(k / rows, 1.6);
      canvas.drawLine(Offset(0, rowY[k]), Offset(w, rowY[k]), ridge);
    }
    ridge.strokeWidth = 1.1;
    for (int j = 0; j <= cols; j++) {
      canvas.drawLine(
          Offset(xAt(colX[j], top), top), Offset(xAt(colX[j], h), h), ridge);
    }
  }

  /// 立體梯田：每階有受光田埂、立面陰影；flooded 時呈現映天光的水梯田
  void _drawTerracedFields(
      Canvas canvas, Size size, _SceneryPalette p, Random rng,
      {bool flooded = false}) {
    final w = size.width, h = size.height;
    const bands = 8;
    const n = 24;
    final curves = <List<Offset>>[];
    for (int i = 0; i <= bands; i++) {
      final per = i / bands;
      final base = h * (0.62 + 0.42 * pow(per, 1.25));
      final amp = 6 + 22 * per;
      final phase = rng.nextDouble() * 0.6;
      final tilt = 8 + 10 * per;
      curves.add([
        for (int m = 0; m <= n; m++)
          Offset(w * m / n,
              base + sin((m / n) * pi * 1.1 + phase) * amp - tilt * (m / n))
      ]);
    }

    final land = Path()..moveTo(0, h);
    for (final o in curves[0]) {
      land.lineTo(o.dx, o.dy);
    }
    land
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
        land,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, h * 0.6), Offset(0, h), [
            Color.lerp(p.land, p.haze, 0.2)!,
            p.darkLand,
          ]));

    final skyTint = isNight
        ? const Color(0xFF2A4258)
        : (isEvening ? const Color(0xFFD9A06B) : const Color(0xFFBCD8DD));
    final riserColor = Color.lerp(p.darkLand, Colors.black, 0.25)!;
    final lipColor = Color.lerp(p.accent, p.light, 0.3)!;

    for (int i = 0; i < bands; i++) {
      final per = i / bands;
      final upper = curves[i], lower = curves[i + 1];

      final band = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final o in upper.skip(1)) {
        band.lineTo(o.dx, o.dy);
      }
      for (final o in lower.reversed) {
        band.lineTo(o.dx, o.dy);
      }
      band.close();

      final yTop = upper.map((o) => o.dy).reduce(min);
      final yBot = lower.map((o) => o.dy).reduce(max);

      if (flooded && (i.isEven || rng.nextDouble() < 0.3)) {
        canvas.drawPath(
            band,
            Paint()
              ..shader = ui.Gradient.linear(Offset(0, yTop), Offset(0, yBot), [
                Color.lerp(skyTint, p.water, 0.3)!
                    .withValues(alpha: isNight ? 0.5 : 0.85),
                Color.lerp(p.water, p.land, 0.4)!.withValues(alpha: 0.85),
              ]));
      } else {
        final c = i.isEven ? p.land : Color.lerp(p.land, p.accent, 0.25)!;
        canvas.drawPath(
            band,
            Paint()
              ..shader = ui.Gradient.linear(Offset(0, yTop), Offset(0, yBot), [
                c.withValues(alpha: 0.9),
                Color.lerp(c, p.darkLand, 0.35)!.withValues(alpha: 0.9),
              ]));
      }

      final riser = 2 + 6 * per;
      final shadow = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final o in upper.skip(1)) {
        shadow.lineTo(o.dx, o.dy);
      }
      for (final o in upper.reversed) {
        shadow.lineTo(o.dx, o.dy + riser);
      }
      shadow.close();
      canvas.drawPath(shadow, Paint()..color = riserColor.withValues(alpha: 0.45));

      final lip = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final o in upper.skip(1)) {
        lip.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
          lip,
          Paint()
            ..color = lipColor.withValues(alpha: isNight ? 0.12 : 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + per * 1.5);
    }
  }

  /// 茶園：沿坡等高線的一排排茶樹
  void _drawTeaRows(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    for (int r = 0; r < 6; r++) {
      final baseY = size.height * (0.68 + r * 0.05);
      final amp = 8.0 + r * 2.5;
      final bushes = Path();
      final shades = Path();
      const n = 30;
      final phase = rng.nextDouble() * pi;
      final radius = 2.8 + r * 0.5;
      for (int i = 0; i <= n; i++) {
        final x = i * size.width / n;
        final y = baseY + sin(x / size.width * pi * 1.2 + phase) * amp;
        shades.addOval(
            Rect.fromCircle(center: Offset(x, y + 1.5), radius: radius));
        bushes.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
      }
      canvas.drawPath(shades, Paint()..color = p.darkLand.withValues(alpha: 0.4));
      canvas.drawPath(
          bushes,
          Paint()
            ..color = Color.lerp(p.tree, p.land, 0.3)!
                .withValues(alpha: isNight ? 0.5 : 0.8));
    }
  }

  /// 鳳梨田（平原版）：紅土梯形隨棋盤田透視，植株隨距離縮小
  void _drawPineapplePerspective(Canvas canvas, Size size, _SceneryPalette p,
      Random rng, double xb0, double xb1, double y0, double y1) {
    final w = size.width;
    canvas.drawPath(
        _plainsQuad(size, xb0, xb1, y0, y1),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, y0), Offset(0, y1), [
            Color.lerp(_tone(const Color(0xFF9B5A3A)), p.haze, 0.25)!,
            _tone(const Color(0xFF8A4E33)),
          ]));

    final leafA = Path(), leafB = Path(), fruits = Path(), crowns = Path();
    const rows = 7;
    for (int r = 0; r < rows; r++) {
      final y = y0 + (y1 - y0) * (0.08 + 0.86 * r / (rows - 1));
      final sc = _plainsScale(size, y);
      final s = 0.35 + 1.6 * sc;
      final spacing = 0.032 * w;
      for (double xb = xb0 + spacing * (r.isOdd ? 0.9 : 0.4);
          xb < xb1 - spacing * 0.3;
          xb += spacing) {
        final x = _plainsX(size, xb, y);
        if (x < -4 || x > w + 4) continue;
        for (int k = 0; k < 5; k++) {
          final ang =
              -pi / 2 + (k - 2) * 0.45 + (rng.nextDouble() - 0.5) * 0.15;
          final len = (6.5 - (k - 2).abs() * 1.0 + rng.nextDouble() * 2) * s;
          (k.isEven ? leafA : leafB)
            ..moveTo(x, y)
            ..lineTo(x + cos(ang) * len, y + sin(ang) * len);
        }
        if (rng.nextDouble() < 0.35) {
          fruits.addOval(Rect.fromCenter(
              center: Offset(x, y - 4.2 * s), width: 3.2 * s, height: 4.4 * s));
          crowns
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x - 1.2 * s, y - 8.6 * s)
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x + 1.2 * s, y - 8.6 * s)
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x, y - 9.0 * s);
        }
      }
    }

    Paint stroke(Color c, double width) => Paint()
      ..color = _tone(c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leafB, stroke(const Color(0xFF4F6E4A), 1.0));
    canvas.drawPath(leafA, stroke(const Color(0xFF7A9A6A), 1.0));
    canvas.drawPath(fruits, Paint()..color = _tone(const Color(0xFFD9A43A)));
    canvas.drawPath(crowns, stroke(const Color(0xFF7A9A6A), 0.8));
  }

  /// 鳳梨田（丘陵版）：列沿坡面起伏
  void _drawPineappleField(Canvas canvas, Rect region, Random rng,
      {bool soil = true, double waveAmp = 0}) {
    if (soil) {
      canvas.drawPath(
          Path()
            ..moveTo(region.left + region.width * 0.1, region.top)
            ..lineTo(region.right, region.top)
            ..lineTo(region.right, region.bottom)
            ..lineTo(region.left, region.bottom)
            ..close(),
          Paint()
            ..color = _tone(const Color(0xFF9B5A3A)).withValues(alpha: 0.9));
    }

    final leafA = Path();
    final leafB = Path();
    final fruits = Path();
    final crowns = Path();
    const rows = 6;

    for (int r = 0; r < rows; r++) {
      final per = pow(r / (rows - 1), 1.4).toDouble();
      final rowY = region.top + region.height * (0.1 + 0.88 * per);
      final s = 0.45 + 0.9 * per;
      final spacing = 14 * s;
      final rowLeft =
          soil ? region.left + region.width * 0.1 * (1 - per) : region.left;
      final amp = waveAmp * (0.3 + per);
      final tilt = waveAmp * 0.5 * (0.4 + per);

      for (double x = rowLeft + spacing * (r.isOdd ? 0.75 : 0.25);
          x < region.right;
          x += spacing) {
        final fx = (x - region.left) / region.width;
        final y = rowY + sin(fx * pi * 1.1 + 0.3) * amp - tilt * fx;
        for (int k = 0; k < 5; k++) {
          final ang =
              -pi / 2 + (k - 2) * 0.45 + (rng.nextDouble() - 0.5) * 0.15;
          final len = (6.5 - (k - 2).abs() * 1.0 + rng.nextDouble() * 2) * s;
          (k.isEven ? leafA : leafB)
            ..moveTo(x, y)
            ..lineTo(x + cos(ang) * len, y + sin(ang) * len);
        }
        if (rng.nextDouble() < 0.35) {
          fruits.addOval(Rect.fromCenter(
              center: Offset(x, y - 4.2 * s), width: 3.2 * s, height: 4.4 * s));
          crowns
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x - 1.2 * s, y - 8.6 * s)
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x + 1.2 * s, y - 8.6 * s)
            ..moveTo(x, y - 6.4 * s)
            ..lineTo(x, y - 9.0 * s);
        }
      }
    }

    Paint stroke(Color c, double width) => Paint()
      ..color = _tone(c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(leafB, stroke(const Color(0xFF4F6E4A), 1.1));
    canvas.drawPath(leafA, stroke(const Color(0xFF7A9A6A), 1.1));
    canvas.drawPath(fruits, Paint()..color = _tone(const Color(0xFFD9A43A)));
    canvas.drawPath(crowns, stroke(const Color(0xFF7A9A6A), 0.9));
  }

  /// 魚塭：沿棋盤田透視的水塘，映天光
  void _drawWetlandWater(
      Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final skyTint = isNight
        ? const Color(0xFF2A4258)
        : (isEvening ? const Color(0xFFD9A06B) : const Color(0xFFBCD8DD));
    for (final pond in _wetlandPonds(size)) {
      final quad = _plainsQuad(size, pond.xb0, pond.xb1, pond.y0, pond.y1);
      canvas.drawPath(
          quad,
          Paint()
            ..shader = ui.Gradient.linear(
                Offset(0, pond.y0), Offset(0, pond.y1), [
              Color.lerp(skyTint, p.water, 0.35)!.withValues(alpha: 0.92),
              Color.lerp(p.water, p.darkLand, 0.25)!.withValues(alpha: 0.95),
            ]));
      // 塘埂
      canvas.drawPath(
          quad,
          Paint()
            ..color = Color.lerp(p.darkLand, p.accent, 0.3)!
                .withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + 1.5 * _plainsScale(size, pond.y1));
    }
  }

  /// 漁電共生：魚塭上的光電板，隨透視縮小
  void _drawSolarFishFarm(Canvas canvas, Size size, _SceneryPalette p) {
    final w = size.width;
    final panel = Paint()..color = _tone(const Color(0xFF26456E));
    final edge = _tone(const Color(0xFF8FB3D9));

    for (final pond in _wetlandPonds(size).where((e) => e.solar)) {
      for (final fy in [0.3, 0.72]) {
        final y = pond.y0 + (pond.y1 - pond.y0) * fy;
        final sc = _plainsScale(size, y);
        final pw = 0.05 * w * sc;
        final ph = 1.5 + 5 * sc;
        final topEdge = Paint()
          ..color = edge.withValues(alpha: isNight ? 0.2 : 0.7)
          ..strokeWidth = 0.4 + 0.5 * sc;
        final leg = Paint()
          ..color = p.infrastructure.withValues(alpha: 0.6)
          ..strokeWidth = 0.4 + 0.5 * sc;
        for (double xb = pond.xb0 + 0.05 * w;
            xb < pond.xb1 - 0.06 * w;
            xb += 0.065 * w) {
          final x = _plainsX(size, xb, y);
          if (x > w + pw || x + pw < 0) continue;
          canvas.drawLine(Offset(x + pw / 2, y), Offset(x + pw / 2, y + ph * 0.5), leg);
          canvas.drawPath(
              Path()
                ..moveTo(x, y)
                ..lineTo(x + pw, y)
                ..lineTo(x + pw + ph * 0.4, y - ph)
                ..lineTo(x + ph * 0.4, y - ph)
                ..close(),
              panel);
          canvas.drawLine(Offset(x + ph * 0.4, y - ph),
              Offset(x + pw + ph * 0.4, y - ph), topEdge);
        }
      }
    }
  }

  /// 辮狀礫石河床：寬闊灰白卵石灘、數條交織水道、河岸植被
  void _drawRiver(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    const n = 40;
    final h = size.height;
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
    bed.close();

    final gravel = _tone(const Color(0xFFBDB6A4));
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
    final sand = _tone(const Color(0xFFDCCBA4));
    canvas.drawPath(
        beach,
        Paint()
          ..shader =
              ui.Gradient.linear(beachRect.topCenter, beachRect.bottomCenter, [
            Color.lerp(sand, p.haze, 0.25)!,
            Color.lerp(sand, const Color(0xFF9A8460), 0.35)!,
          ]));
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

  /// 高鐵高架橋
  void _drawHSRViaduct(Canvas canvas, Size size, _SceneryPalette p) {
    final w = size.width;
    final deckY = _hsrDeckY(size);
    final groundY = size.height * 0.672;
    final concrete = Color.lerp(_tone(const Color(0xFFD2CEC6)), p.haze, 0.25)!;
    final pierPaint = Paint()..color = Color.lerp(concrete, Colors.black, 0.12)!;

    for (double x = 12; x < w; x += 34) {
      canvas.drawRect(Rect.fromLTRB(x - 1.6, deckY + 4, x + 1.6, groundY), pierPaint);
    }
    canvas.drawRect(Rect.fromLTWH(0, deckY, w, 4), Paint()..color = concrete);
    canvas.drawRect(Rect.fromLTWH(0, deckY + 4, w, 1.2),
        Paint()..color = Color.lerp(concrete, Colors.black, 0.3)!);

    final mast = Paint()
      ..color = Color.lerp(concrete, Colors.black, 0.35)!
      ..strokeWidth = 0.7;
    for (double x = 29; x < w; x += 34) {
      canvas.drawLine(Offset(x, deckY), Offset(x, deckY - 12), mast);
    }
    mast.strokeWidth = 0.5;
    canvas.drawLine(Offset(0, deckY - 11), Offset(w, deckY - 11), mast);
  }

  /// 鄉間道路與電線桿（電線桿在路右側）
  void _drawRoadAndPoles(Canvas canvas, Size size, _SceneryPalette p) {
    final w = size.width, h = size.height;
    final roadColor = Color.lerp(p.darkLand, const Color(0xFF9A9388), 0.5)!;
    canvas.drawPath(
        Path()
          ..moveTo(w * (_roadCx(0) - _roadHalf(0)), h * _roadY(0))
          ..lineTo(w * (_roadCx(0) + _roadHalf(0)), h * _roadY(0))
          ..lineTo(w * (_roadCx(1) + _roadHalf(1)), h * _roadY(1))
          ..lineTo(w * (_roadCx(1) - _roadHalf(1)), h * _roadY(1))
          ..close(),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, h * _roadY(0)), Offset(0, h), [
            Color.lerp(roadColor, p.haze, 0.3)!,
            roadColor,
          ]));

    final dash = Paint()
      ..color = const Color(0xFFF2E6B8).withValues(alpha: isNight ? 0.12 : 0.45);
    for (int i = 0; i < 8; i++) {
      final t0 = pow(i / 8, 1.4).toDouble();
      final t1 = pow((i + 0.45) / 8, 1.4).toDouble();
      dash.strokeWidth = 0.6 + 1.6 * t0;
      canvas.drawLine(
        Offset(w * _roadCx(t0), h * _roadY(t0)),
        Offset(w * _roadCx(t1), h * _roadY(t1)),
        dash,
      );
    }

    final polePaint = Paint()
      ..color = p.infrastructure.withValues(alpha: 0.8)
      ..strokeWidth = 1.5;
    final wirePaint = Paint()
      ..color = p.infrastructure.withValues(alpha: 0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final poleTops = <Offset>[];
    const poleCount = 6;
    for (int i = 0; i < poleCount; i++) {
      final per = pow(i / (poleCount - 1), 1.5).toDouble();
      final t = per * 0.9;
      final x = w * (_roadCx(t) + _roadHalf(t) + 0.015);
      final y = h * _roadY(t);
      final ph = 10 + 40 * per;
      canvas.drawLine(Offset(x, y), Offset(x, y - ph), polePaint);
      canvas.drawLine(Offset(x - ph * 0.2, y - ph + ph * 0.1),
          Offset(x + ph * 0.2, y - ph + ph * 0.1), polePaint);
      poleTops.add(Offset(x, y - ph + ph * 0.1));
    }

    for (int side = -1; side <= 1; side += 2) {
      final wire = Path()..moveTo(poleTops[0].dx + side * 2, poleTops[0].dy);
      for (int i = 1; i < poleTops.length; i++) {
        final pPrev = pow((i - 1) / (poleCount - 1), 1.5).toDouble();
        final pCurr = pow(i / (poleCount - 1), 1.5).toDouble();
        final startX = poleTops[i - 1].dx + side * (2 + 4 * pPrev);
        final endX = poleTops[i].dx + side * (2 + 4 * pCurr);
        final midY = (poleTops[i - 1].dy + poleTops[i].dy) / 2 + 8 * pCurr;
        wire.quadraticBezierTo((startX + endX) / 2, midY, endX, poleTops[i].dy);
      }
      canvas.drawPath(wire, wirePaint);
    }
  }

  /// 鐵軌只畫在陸地上（海岸：沙灘內；山谷：河的右側）
  Path? _railClip(Size size) {
    if (variant == LandscapeVariant.eastCoast) return _beachPath(size);
    if (variant == LandscapeVariant.centralValley) {
      return Path()
        ..addRect(Rect.fromLTWH(size.width * 0.56, 0, size.width, size.height));
    }
    return null;
  }

  void _drawRailwayTrack(Canvas canvas, Size size, _SceneryPalette p) {
    final clip = _railClip(size);
    canvas.save();
    if (clip != null) canvas.clipPath(clip);
    _drawRailwayTrackUnclipped(canvas, size, p);
    canvas.restore();
  }

  void _drawRailwayTrackUnclipped(
      Canvas canvas, Size size, _SceneryPalette p) {
    final railPaint = Paint()
      ..color = p.village.withValues(alpha: 0.5)
      ..strokeWidth = 2.0;
    final sleeperPaint = Paint()
      ..color = p.roof.withValues(alpha: 0.7)
      ..strokeWidth = 3.0;

    final y = size.height * 0.70;
    canvas.drawLine(Offset(0, y), Offset(size.width, y + 10), railPaint);
    canvas.drawLine(Offset(0, y + 8), Offset(size.width, y + 18), railPaint);

    for (int i = 0; i < 25; i++) {
      final x = i * size.width / 24;
      final yOffset = (x / size.width) * 10;
      canvas.drawLine(Offset(x, y + yOffset - 2),
          Offset(x + 2, y + yOffset + 18), sleeperPaint);
    }
  }

  /// 台北盆地天際線 + 101
  void _drawCitySkyline(
      Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width, h = size.height;
    final baseY = h * 0.66;
    final bColor = Color.lerp(_tone(const Color(0xFF8A97A3)), p.haze, 0.4)!;
    final windows = Path();

    double x = w * 0.48;
    while (x < w * 0.99) {
      final bw = 6 + rng.nextDouble() * 9;
      final bh = 10 + rng.nextDouble() * 34;
      canvas.drawRect(Rect.fromLTWH(x, baseY - bh, bw, bh),
          Paint()..color = Color.lerp(bColor, Colors.black, rng.nextDouble() * 0.12)!);
      if (isNight) {
        for (double wy = baseY - bh + 2; wy < baseY - 2; wy += 3) {
          for (double wx = x + 1.5; wx < x + bw - 1; wx += 2.5) {
            if (rng.nextDouble() < 0.35) {
              windows.addRect(Rect.fromLTWH(wx, wy, 1, 1.2));
            }
          }
        }
      }
      x += bw + 1 + rng.nextDouble() * 3;
    }
    if (isNight) {
      canvas.drawPath(windows, Paint()..color = p.light.withValues(alpha: 0.7));
    }

    // 101
    final tx = w * 0.72;
    final th = min(h * 0.19, 170.0);
    final tower = Color.lerp(_tone(const Color(0xFF6E8E8E)), p.haze, 0.25)!;
    final tp = Paint()..color = tower;
    final ring = Paint()
      ..color = isNight
          ? p.light.withValues(alpha: 0.6)
          : Color.lerp(tower, Colors.white, 0.25)!
      ..strokeWidth = 0.8;

    final podiumH = th * 0.13;
    canvas.drawRect(Rect.fromLTRB(tx - 9, baseY - podiumH, tx + 9, baseY), tp);
    final segH = th * 0.075;
    double y = baseY - podiumH;
    for (int k = 0; k < 8; k++) {
      canvas.drawPath(
          Path()
            ..moveTo(tx - 5.2, y)
            ..lineTo(tx + 5.2, y)
            ..lineTo(tx + 6.6, y - segH)
            ..lineTo(tx - 6.6, y - segH)
            ..close(),
          tp);
      canvas.drawLine(Offset(tx - 6.6, y - segH), Offset(tx + 6.6, y - segH), ring);
      y -= segH;
    }
    canvas.drawRect(Rect.fromLTRB(tx - 3.6, y - th * 0.06, tx + 3.6, y), tp);
    y -= th * 0.06;
    canvas.drawRect(Rect.fromLTRB(tx - 2.2, y - th * 0.04, tx + 2.2, y), tp);
    y -= th * 0.04;
    canvas.drawLine(Offset(tx, y), Offset(tx, y - th * 0.14),
        Paint()
          ..color = tower
          ..strokeWidth = 1.2);
    if (isNight) {
      canvas.drawCircle(Offset(tx, y - th * 0.14), 1.6, Paint()..color = p.light);
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

  /// 阿里山森林鐵路：檜木林與蜿蜒軌道
  void _drawAlishanLine(
      Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final c = _alishanCtrl(size);

    final trees = Path();
    for (int i = 0; i < 34; i++) {
      final pt = _cubic(c[0], c[1], c[2], c[3], rng.nextDouble());
      final ht = 6 + rng.nextDouble() * 7;
      final bx = pt.dx + (rng.nextDouble() - 0.5) * 12;
      final by = pt.dy - 1 - rng.nextDouble() * 5;
      trees
        ..moveTo(bx - ht * 0.28, by)
        ..lineTo(bx, by - ht)
        ..lineTo(bx + ht * 0.28, by)
        ..close();
    }
    canvas.drawPath(trees,
        Paint()..color = Color.lerp(p.tree, p.farMountain, 0.3)!.withValues(alpha: 0.95));

    canvas.drawPath(
        Path()
          ..moveTo(c[0].dx, c[0].dy)
          ..cubicTo(c[1].dx, c[1].dy, c[2].dx, c[2].dy, c[3].dx, c[3].dy),
        Paint()
          ..color = _tone(const Color(0xFF5B4632))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);

    final sleeper = Paint()
      ..color = _tone(const Color(0xFF7A6248))
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 60; i++) {
      final t = i / 60;
      final pt = _cubic(c[0], c[1], c[2], c[3], t);
      final tan = _cubicTangent(c[0], c[1], c[2], c[3], t);
      final len = tan.distance == 0 ? 1.0 : tan.distance;
      final nrm = Offset(-tan.dy / len, tan.dx / len);
      canvas.drawLine(pt - nrm * 1.6, pt + nrm * 1.6, sleeper);
    }
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

      canvas.drawRect(Rect.fromLTWH(x, y - h, w, h), wallPaint);
      canvas.drawPath(
          Path()
            ..moveTo(x - 3, y - h)
            ..lineTo(x + w / 2, y - h - 10 * scale)
            ..lineTo(x + w + 3, y - h)
            ..close(),
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
      double x0 = 0}) {
    final trunkPaint = Paint()
      ..color = p.village.withValues(alpha: 0.7)
      ..strokeWidth = 2;
    final crownPaint = Paint()..color = p.tree.withValues(alpha: 0.85);
    final crownLight = Paint()
      ..color = Color.lerp(p.tree, p.light, 0.2)!.withValues(alpha: isNight ? 0.2 : 0.5);

    for (int i = 0; i < count; i++) {
      final x = x0 + spread * (0.1 + rng.nextDouble() * 0.8);
      final h = 15 + rng.nextDouble() * 20;
      final r = 8 + rng.nextDouble() * 8;
      canvas.drawLine(Offset(x, y), Offset(x, y - h), trunkPaint);
      canvas.drawCircle(Offset(x, y - h), r, crownPaint);
      canvas.drawCircle(Offset(x - r * 0.6, y - h + 4), r * 0.8, crownPaint);
      canvas.drawCircle(Offset(x + r * 0.6, y - h + 4), r * 0.8, crownPaint);
      canvas.drawCircle(Offset(x - r * 0.3, y - h - r * 0.3), r * 0.45, crownLight);
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

  /// 蚵架：魚塭上的細桿排，隨透視縮小
  void _drawOysterRacks(
      Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width;
    for (final pond in _wetlandPonds(size).where((e) => !e.solar)) {
      for (final fy in [0.35, 0.75]) {
        final y = pond.y0 + (pond.y1 - pond.y0) * fy;
        final sc = _plainsScale(size, y);
        final ph = 2 + 7 * sc;
        final pole = Paint()
          ..color = p.infrastructure.withValues(alpha: 0.75)
          ..strokeWidth = 0.5 + 0.8 * sc;
        final bar = Paint()
          ..color = p.infrastructure.withValues(alpha: 0.6)
          ..strokeWidth = 0.4 + 0.6 * sc;
        final xbStart = pond.xb0 + 0.06 * w + rng.nextDouble() * 0.05 * w;
        final xbEnd = pond.xb1 - 0.08 * w;
        double? firstX, lastX;
        for (double xb = xbStart; xb < xbEnd; xb += 0.03 * w) {
          final x = _plainsX(size, xb, y);
          if (x < -5 || x > w + 5) continue;
          firstX ??= x;
          lastX = x;
          canvas.drawLine(Offset(x, y), Offset(x, y - ph), pole);
        }
        if (firstX != null && lastX != null) {
          canvas.drawLine(Offset(firstX, y - ph), Offset(lastX, y - ph), bar);
        }
      }
    }
  }

  void _drawEgretStanding(
      Canvas canvas, _SceneryPalette p, Offset pos, double scale) {
    final white = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.3 : 0.9);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.3 : 0.9)
      ..strokeWidth = 1.3 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leg = Paint()
      ..color = p.infrastructure.withValues(alpha: 0.8)
      ..strokeWidth = 1.0 * scale;

    canvas.drawOval(
        Rect.fromCenter(center: pos, width: 10 * scale, height: 6 * scale), white);
    canvas.drawPath(
        Path()
          ..moveTo(pos.dx + 4 * scale, pos.dy - 1 * scale)
          ..quadraticBezierTo(pos.dx + 7 * scale, pos.dy - 7 * scale,
              pos.dx + 5 * scale, pos.dy - 10 * scale),
        line);
    canvas.drawCircle(
        Offset(pos.dx + 5 * scale, pos.dy - 10 * scale), 1.6 * scale, white);
    canvas.drawLine(Offset(pos.dx + 6.5 * scale, pos.dy - 10 * scale),
        Offset(pos.dx + 9.5 * scale, pos.dy - 9.5 * scale), leg);
    canvas.drawLine(Offset(pos.dx - 1 * scale, pos.dy + 2 * scale),
        Offset(pos.dx - 1 * scale, pos.dy + 9 * scale), leg);
    canvas.drawLine(Offset(pos.dx + 2 * scale, pos.dy + 2 * scale),
        Offset(pos.dx + 2 * scale, pos.dy + 9 * scale), leg);
  }

  void _drawBuffalo(
      Canvas canvas, _SceneryPalette p, Offset pos, double scale) {
    final body = Paint()..color = p.infrastructure.withValues(alpha: 0.85);
    final horn = Paint()
      ..color = p.infrastructure.withValues(alpha: 0.85)
      ..strokeWidth = 1.6 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final s = scale;
    // 身體：前高後低的厚實橢圓，背上有隆起
    canvas.drawPath(
        Path()
          ..moveTo(pos.dx - 13 * s, pos.dy + 2 * s)
          ..cubicTo(pos.dx - 14 * s, pos.dy - 6 * s, pos.dx - 2 * s,
              pos.dy - 9 * s, pos.dx + 6 * s, pos.dy - 7.5 * s)
          ..cubicTo(pos.dx + 11 * s, pos.dy - 6.5 * s, pos.dx + 13 * s,
              pos.dy - 1 * s, pos.dx + 12 * s, pos.dy + 3 * s)
          ..lineTo(pos.dx - 12 * s, pos.dy + 4 * s)
          ..close(),
        body);
    // 頭：低垂向前
    final head = Offset(pos.dx + 14 * s, pos.dy + 1 * s);
    canvas.drawPath(
        Path()
          ..moveTo(pos.dx + 9 * s, pos.dy - 6 * s)
          ..lineTo(head.dx + 3 * s, head.dy - 1 * s)
          ..lineTo(head.dx + 3.5 * s, head.dy + 4 * s)
          ..lineTo(head.dx - 1 * s, head.dy + 5 * s)
          ..lineTo(pos.dx + 8 * s, pos.dy + 1 * s)
          ..close(),
        body);
    // 角：從頭頂向後、向上彎成弧
    for (final side in [-1.0, 1.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(pos.dx + 10 * s, pos.dy - 5 * s)
            ..quadraticBezierTo(pos.dx + (7 + side * 2) * s, pos.dy - 12 * s,
                pos.dx + (2 + side * 4) * s, pos.dy - 9 * s),
          horn);
    }
    // 腳：短而粗
    final leg = Paint()
      ..color = body.color
      ..strokeWidth = 2.6 * s
      ..strokeCap = StrokeCap.round;
    for (final dx in [-10.0, -6.0, 5.0, 9.0]) {
      canvas.drawLine(Offset(pos.dx + dx * s, pos.dy + 2 * s),
          Offset(pos.dx + dx * s, pos.dy + 9 * s), leg);
    }
  }

  /// 金針花田：佔據幾格田的密集橙黃花海，隨透視縮小
  void _drawDaylilyPatch(
      Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width, h = size.height;
    final xb0 = -0.45 * w, xb1 = 0.3 * w;
    final y0 = 0.69 * h, y1 = 0.775 * h;

    canvas.drawPath(
        _plainsQuad(size, xb0, xb1, y0, y1),
        Paint()
          ..color = Color.lerp(p.land, const Color(0xFFC9A93A), 0.45)!
              .withValues(alpha: 0.9));

    final orange = Path(), yellow = Path();
    for (int i = 0; i < 160; i++) {
      final xb = xb0 + rng.nextDouble() * (xb1 - xb0);
      final y = y0 + rng.nextDouble() * (y1 - y0);
      final x = _plainsX(size, xb, y);
      if (x < -3 || x > w + 3) continue;
      final r = (0.5 + rng.nextDouble() * 0.6) * (0.6 + 2.2 * _plainsScale(size, y));
      (i.isEven ? orange : yellow).addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
    }
    final a = isNight ? 0.25 : 0.85;
    canvas.drawPath(orange, Paint()..color = const Color(0xFFE8963C).withValues(alpha: a));
    canvas.drawPath(yellow, Paint()..color = const Color(0xFFF2C14E).withValues(alpha: a));
  }

  // ===========================================================================
  // 動態元素
  // ===========================================================================

  /// 高鐵：白色車身、橘色帶，往返穿越
  void _drawHSRTrain(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final w = size.width;
    final deckY = _hsrDeckY(size);
    final len = max(w * 0.55, 160.0);
    final cyc = anim * 3;
    final pass = cyc.floor();
    final ph = (cyc - pass) / 0.5;
    if (ph > 1) return;
    final dir = pass.isEven ? 1 : -1;
    final x0 = dir == 1 ? -len + ph * (w + len) : w - ph * (w + len);
    final top = deckY - 9, bottom = deckY - 0.5;
    const nose = 16.0;

    final body = Path()
      ..moveTo(x0 + nose, top)
      ..lineTo(x0 + len - nose, top)
      ..quadraticBezierTo(x0 + len, top + 1, x0 + len, bottom)
      ..lineTo(x0, bottom)
      ..quadraticBezierTo(x0, top + 1, x0 + nose, top)
      ..close();
    canvas.drawPath(body, Paint()..color = _tone(const Color(0xFFF2F1EC)));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
        Rect.fromLTWH(x0, top + 2, len, 2.3),
        Paint()
          ..color = isNight
              ? p.light.withValues(alpha: 0.9)
              : const Color(0xFF2E3A46));
    canvas.drawRect(Rect.fromLTWH(x0, top + 5.3, len, 1.1),
        Paint()..color = _tone(const Color(0xFFE8792B)));
    final sep = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 0.6;
    for (int k = 1; k < 8; k++) {
      final x = x0 + len * k / 8;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), sep);
    }
    canvas.restore();
  }

  /// 台鐵區間車
  void _drawTrain(Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final trainX = -150 + anim * (size.width + 300);
    final yOffset = (trainX / size.width) * 10;
    final y = size.height * 0.70 + yOffset;

    final clip = _railClip(size);
    canvas.save();
    if (clip != null) canvas.clipPath(clip);
    _drawTrainBody(canvas, p, trainX, y);
    canvas.restore();
  }

  void _drawTrainBody(
      Canvas canvas, _SceneryPalette p, double trainX, double y) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(trainX, y - 22, 125, 18), const Radius.circular(3)),
        Paint()
          ..color = (isNight ? const Color(0xFF9AA4AC) : const Color(0xFFE8ECEF))
              .withValues(alpha: isNight ? 0.55 : 0.92));
    canvas.drawRect(
        Rect.fromLTWH(trainX, y - 9, 125, 3.5),
        Paint()
          ..color =
              const Color(0xFF2E5FA3).withValues(alpha: isNight ? 0.5 : 0.9));
    final winPaint = Paint()
      ..color = isNight
          ? p.light.withValues(alpha: 0.85)
          : const Color(0xFF3A4E5C).withValues(alpha: 0.6);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(trainX + 8 + i * 22, y - 18, 12, 7), winPaint);
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

  /// 阿里山小火車
  void _drawAlishanTrain(
      Canvas canvas, Size size, _SceneryPalette p, double anim) {
    final c = _alishanCtrl(size);
    final head = (anim * 1.5) % 1.3 - 0.15;
    for (int k = 0; k < 4; k++) {
      final t = head - k * 0.03;
      if (t < 0 || t > 1) continue;
      final pt = _cubic(c[0], c[1], c[2], c[3], t);
      final tan = _cubicTangent(c[0], c[1], c[2], c[3], t);
      canvas.save();
      canvas.translate(pt.dx, pt.dy);
      canvas.rotate(atan2(tan.dy, tan.dx));
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-5, -5.5, 10, 5), const Radius.circular(1.2)),
          Paint()
            ..color = _tone(
                k == 0 ? const Color(0xFF2F2A26) : const Color(0xFFB8322A)));
      canvas.drawRect(
          const Rect.fromLTWH(-4, -4.6, 8, 1.4),
          Paint()
            ..color = isNight
                ? p.light.withValues(alpha: 0.9)
                : _tone(const Color(0xFFF1E3C4)));
      canvas.restore();
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
      final t = u * 1.04;
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
      ));
    }

    list.sort((a, b) => a.pos.dy.compareTo(b.pos.dy));
    for (final c in list) {
      _drawCyclist(canvas, p, c);
    }
  }

  void _drawCyclist(Canvas canvas, _SceneryPalette p, _Cyclist c) {
    final pos = c.pos;
    final s = c.scale;

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
        Rect.fromCenter(center: pos.translate(0, 0.5 * s), width: 7 * s, height: 1.6 * s),
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
    canvas.drawLine(hip.translate(-1.2 * s, 0), pos.translate(-1.6 * s, -4 * s - lift), legPaint);
    canvas.drawLine(hip.translate(1.2 * s, 0), pos.translate(1.6 * s, -4 * s + lift), legPaint);

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
            center: Offset(pos.dx, pos.dy - 18.6 * s), width: 4.6 * s, height: 3.2 * s),
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
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) {
    return oldDelegate.biome != biome ||
        oldDelegate.dayPhase != dayPhase ||
        oldDelegate.variant != variant ||
        oldDelegate.seed != seed ||
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
        brick: Color(0xFF3C2822),
        templeRed: Color(0xFF4E2420),
        lantern: Color(0xFFC84A38),
        haze: Color(0xFF223040),
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
        brick: Color(0xFF7E4634),
        templeRed: Color(0xFF93352A),
        lantern: Color(0xFFE0523C),
        haze: Color(0xFFD9A57A),
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
        brick: Color(0xFFA66A52),
        templeRed: Color(0xFFB54A3C),
        lantern: Color(0xFFDE5B45),
        haze: Color(0xFFE8E2CC),
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
      brick: Color(0xFF9E5A43),
      templeRed: Color(0xFFB03A2E),
      lantern: Color(0xFFD84B3A),
      haze: Color(0xFFD8E4DC),
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