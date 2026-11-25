import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RainyFieldLane extends StatefulWidget {
  const RainyFieldLane({super.key, this.interactive = false});

  final bool interactive;

  @override
  State<RainyFieldLane> createState() => _RainyFieldLaneState();
}

class _RainyFieldLaneState extends State<RainyFieldLane>
    with TickerProviderStateMixin {
  late final _rippleAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  );
  late final _rainAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _flightAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  bool _lightsOn = false;
  bool _raining = false;
  Offset? _rippleCenter;
  Offset? _flightStart;

  @override
  void dispose() {
    _rippleAnimation.dispose();
    _rainAnimation.dispose();
    _flightAnimation.dispose();
    super.dispose();
  }

  void _touch(Offset point) {
    if (_house.contains(point)) {
      setState(() => _lightsOn = !_lightsOn);
    } else if (_openChannel.contains(point)) {
      setState(() => _rippleCenter = point);
      _rippleAnimation.forward(from: 0);
    } else if (point.dy < 128) {
      setState(() => _raining = !_raining);
      if (_raining) {
        _rainAnimation.repeat();
      } else {
        _rainAnimation.stop();
      }
    } else if (_riceBank.contains(point) && !_houseYard.contains(point)) {
      setState(() => _flightStart = point);
      _flightAnimation.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = RepaintBoundary(
      child: CustomPaint(
        painter: _RainyFieldLanePainter(lightsOn: _lightsOn),
        size: Size.infinite,
      ),
    );
    if (!widget.interactive) return scene;

    return LayoutBuilder(
      builder: (context, constraints) {
        final view = _LaneView(constraints.biggest);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _touch(view.toScene(details.localPosition)),
          onPanUpdate: (details) {
            final point = view.toScene(details.localPosition);
            if (_openChannel.contains(point) &&
                (_rippleCenter == null ||
                    (point - _rippleCenter!).distance > 20)) {
              setState(() => _rippleCenter = point);
              _rippleAnimation.forward(from: 0);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              scene,
              if (_rippleCenter case final center?)
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _RipplePainter(center, _rippleAnimation),
                  ),
                ),
              if (_raining || _flightStart != null)
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _WeatherAndBirdsPainter(
                      raining: _raining,
                      flightStart: _flightStart,
                      rain: _rainAnimation,
                      flight: _flightAnimation,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

const _house = Rect.fromLTRB(443, 183, 653, 332);
final _channel = Path()
  ..moveTo(718, 326)
  ..cubicTo(680, 373, 442, 446, 262, 600)
  ..lineTo(204, 600)
  ..cubicTo(386, 462, 675, 362, 718, 326)
  ..close();

final _channelFieldRim = Path()
  ..moveTo(725, 318)
  ..cubicTo(690, 353, 375, 450, 180, 600);

final _laneOuterEdge = Path()
  ..moveTo(757, 299)
  ..cubicTo(730, 320, 766, 349, 724, 382)
  ..cubicTo(674, 419, 612, 480, 570, 600);

final _laneInnerEdge = Path()
  ..moveTo(279, 600)
  ..cubicTo(402, 488, 560, 407, 685, 362)
  ..quadraticBezierTo(730, 344, 730, 304);

final _laneAsphalt = Path.from(_laneOuterEdge)
  ..extendWithPath(_laneInnerEdge, Offset.zero)
  ..close();

final _houseYard = Path.combine(
  PathOperation.difference,
  Path()
    ..moveTo(443, 309)
    ..lineTo(700, 307)
    ..quadraticBezierTo(724, 309, 743, 323)
    ..lineTo(744, 333)
    ..quadraticBezierTo(724, 331, 708, 339)
    ..lineTo(653, 345)
    ..lineTo(548, 350)
    ..quadraticBezierTo(487, 351, 434, 345)
    ..close(),
  _laneAsphalt,
);

final _openChannel = Path.combine(
  PathOperation.difference,
  _channel,
  Path.combine(PathOperation.union, _houseYard, _laneAsphalt),
);

final _riceBank =
    (Path()
        ..moveTo(0, 299)
        ..lineTo(725, 299))
      ..extendWithPath(_channelFieldRim, Offset.zero)
      ..lineTo(0, 600)
      ..close();

class _LaneView {
  _LaneView(Size size) {
    final widthScale = size.width / 800;
    final heightScale = size.height / 600;
    scaleX = max(widthScale, min(heightScale, size.width / 400));
    scaleY = max(heightScale, min(widthScale, size.height / 520));
    origin = Offset(
      (size.width - 800 * scaleX) * 0.86,
      size.height - 600 * scaleY,
    );
  }

  late final double scaleX;
  late final double scaleY;
  late final Offset origin;

  void apply(Canvas canvas) {
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scaleX, scaleY);
  }

  Offset toScene(Offset point) =>
      Offset((point.dx - origin.dx) / scaleX, (point.dy - origin.dy) / scaleY);
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.center, this.animation) : super(repaint: animation);

  final Offset center;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.isCompleted) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _LaneView(size).apply(canvas);
    canvas.clipPath(_openChannel);
    final progress = animation.value;
    final paint = Paint()
      ..color = const Color(0xFFD3E6DA).withValues(alpha: 0.8 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final radius in [4 + 30 * progress, 2 + 17 * progress]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2, height: radius),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      center != oldDelegate.center;
}

class _WeatherAndBirdsPainter extends CustomPainter {
  _WeatherAndBirdsPainter({
    required this.raining,
    required this.flightStart,
    required this.rain,
    required this.flight,
  }) : super(repaint: Listenable.merge([rain, flight]));

  final bool raining;
  final Offset? flightStart;
  final Animation<double> rain;
  final Animation<double> flight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _LaneView(size).apply(canvas);
    final start = flightStart;
    if (start != null && !flight.isCompleted) {
      _drawEgrets(canvas, start);
    }
    if (raining) {
      _drawRain(canvas);
    }
    canvas.restore();
  }

  void _drawRain(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 800, 600),
      Paint()..color = const Color(0x19344756),
    );
    final streaks = Path();
    final random = Random(93);
    for (int i = 0; i < 155; i++) {
      final x = random.nextDouble() * 820 - 10;
      final initialY = random.nextDouble() * 620;
      final length = 5 + random.nextDouble() * 10;
      final y = (initialY + rain.value * 620) % 620 - 10;
      final drift = (y - initialY) * 0.20;
      streaks
        ..moveTo(x + drift, y)
        ..relativeLineTo(length * 0.2, length);
    }
    canvas.drawPath(
      streaks,
      Paint()
        ..color = const Color(0x6BCFE1E6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawEgrets(Canvas canvas, Offset start) {
    final direction = start.dx < 470 ? 1.0 : -1.0;
    for (int i = 0; i < 3; i++) {
      final t = flight.value - i * 0.09;
      if (t < 0) continue;
      final fade = ((1 - flight.value) * 5).clamp(0.0, 1.0);
      final x = start.dx + direction * (t * 154 - i * 10);
      final y = start.dy - 7 - sqrt(t) * 112 + i * 8;
      final wingTip = sin(t * 34) * 6 - 3;
      final feather = Paint()
        ..color = const Color(0xFFF1F1DB).withValues(alpha: fade);

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(direction * (1 - t * 0.25), 1 - t * 0.25);
      final silhouette = Path()
        ..moveTo(-6, 1)
        ..quadraticBezierTo(-2, -2, 3, -1)
        ..quadraticBezierTo(4, -4, 7, -3)
        ..lineTo(10, -2)
        ..lineTo(5, -1)
        ..quadraticBezierTo(3, 3, -6, 1)
        ..moveTo(1, 1)
        ..quadraticBezierTo(-5, wingTip - 5, -12, wingTip)
        ..quadraticBezierTo(-5, wingTip + 2, -2, 3)
        ..close();
      canvas.drawPath(silhouette, feather);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WeatherAndBirdsPainter oldDelegate) =>
      raining != oldDelegate.raining || flightStart != oldDelegate.flightStart;
}

class _RainyFieldLanePainter extends CustomPainter {
  const _RainyFieldLanePainter({required this.lightsOn});

  final bool lightsOn;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _LaneView(size).apply(canvas);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 800, 600),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, 310),
          const [Color(0xFF9EADB9), Color(0xFFD8DFDD)],
        ),
    );

    for (final (x, y, radius) in [
      (95.0, 46.0, 190.0),
      (380.0, 83.0, 250.0),
      (680.0, 27.0, 210.0),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(1, 0.25);
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(Offset.zero, radius, const [
            Color(0x44717F93),
            Color(0x00717F93),
          ]),
      );
      canvas.restore();
    }

    final rng = Random(31);
    _hills(canvas, rng, 182, 28, const Color(0xFF82949C));
    _hills(canvas, rng, 224, 23, const Color(0xFF738985));
    _hills(canvas, rng, 259, 15, const Color(0xFF64796A));
    _fields(canvas, rng);
    _lane(canvas, rng);
    _drawHouseYard(canvas);
    canvas.drawPath(_laneOuterEdge, _stroke(const Color(0xFF454F40), 1.5));
    canvas.drawPath(_laneInnerEdge, _stroke(const Color(0xFF535B54), 1.2));
    _houses(canvas);
    _drawYardWall(canvas);
    _bananaLeaves(canvas);
    _utilityLines(canvas);
    canvas.restore();
  }

  void _hills(Canvas canvas, Random rng, double y, double rise, Color color) {
    final ridge = Path()..moveTo(0, y);
    var previous = Offset(0, y);
    for (var x = 12.0; x <= 804; x += 12) {
      final next = Offset(
        x,
        y +
            sin(x * 0.012 + y) * rise +
            sin(x * 0.028) * rise * 0.24 +
            rng.nextDouble() * 5,
      );
      final middle = Offset.lerp(previous, next, 0.5)!;
      ridge.quadraticBezierTo(previous.dx, previous.dy, middle.dx, middle.dy);
      previous = next;
    }
    ridge
      ..lineTo(806, 340)
      ..lineTo(0, 340)
      ..close();
    canvas.drawPath(ridge, _fill(color));
  }

  void _fields(Canvas canvas, Random rng) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 290, 800, 310),
      _fill(const Color(0xFF586547)),
    );
    canvas.save();
    canvas.clipPath(_riceBank);
    const terraces = [
      (298.0, 314.0, 301.0, 318.0, 4.0),
      (320.0, 345.0, 325.0, 347.0, 5.0),
      (353.0, 392.0, 347.0, 378.0, 8.0),
      (401.0, 468.0, 379.0, 433.0, 12.0),
      (482.0, 618.0, 429.0, 570.0, 17.0),
    ];
    final shoots = Path();
    for (final (top, bottom, farTop, farBottom, bow) in terraces) {
      final plot = Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(380, top + bow, 800, farTop)
        ..lineTo(800, farBottom)
        ..quadraticBezierTo(370, bottom + bow, 0, bottom)
        ..close();
      canvas.drawPath(
        plot,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, farTop),
            Offset(0, bottom),
            const [Color(0xFF91A69C), Color(0xFF758D56)],
          ),
      );

      // Transplanting rows curve with the waterline and open up in front.
      for (double y0 = top + 3; y0 < bottom; y0 += 3 + (y0 - 290) * 0.035) {
        final depth = (y0 - top) / (bottom - top);
        final y1 = farTop + (farBottom - farTop) * depth;
        final spacing = 4 + (y0 - 290) * 0.027;
        for (double x0 = rng.nextDouble() * spacing; x0 < 800; x0 += spacing) {
          final x = x0 + (rng.nextDouble() - 0.5) * spacing * 0.45;
          final t = x / 800;
          final y =
              y0 +
              (y1 - y0) * t +
              2 * bow * t * (1 - t) +
              (rng.nextDouble() - 0.5) * spacing * 0.35;
          if (!plot.contains(Offset(x, y))) continue;
          final blade = 1.3 + (y - 290) * 0.021;
          shoots
            ..moveTo(x - blade * 0.45, y - blade * 0.64)
            ..quadraticBezierTo(x - 1, y - 1, x, y)
            ..lineTo(x + blade * 0.28, y - blade);
        }
      }
    }
    canvas.drawPath(shoots, _stroke(const Color(0xFF536E39), 0.9));
    canvas.restore();
  }

  void _lane(Canvas canvas, Random rng) {
    canvas.drawPath(
      _laneAsphalt,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 305),
          const Offset(0, 600),
          const [Color(0xFF898C82), Color(0xFF646B6C)],
        ),
    );
    canvas.save();
    canvas.clipPath(_laneAsphalt);
    final puddles = Path();
    for (int i = 0; i < 95; i++) {
      final y = 336 + rng.nextDouble() * 264;
      final x = 300 + rng.nextDouble() * 465;
      puddles.addOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 2 + rng.nextDouble() * (y - 330) * 0.22,
          height: 1 + rng.nextDouble() * (y - 330) * 0.023,
        ),
      );
    }
    canvas.drawPath(puddles, _fill(const Color(0x708FABB6)));
    canvas.restore();

    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(const Rect.fromLTWH(0, 0, 800, 600)),
        _laneAsphalt,
      ),
    );
    final ditch = Path()
      ..moveTo(725, 318)
      ..cubicTo(701, 365, 455, 433, 281, 600)
      ..lineTo(180, 600)
      ..cubicTo(375, 450, 690, 353, 725, 318)
      ..close();
    canvas.drawPath(ditch, _fill(const Color(0xFF8B8B78)));
    canvas.drawPath(_channel, _fill(const Color(0xFF435A57)));
    final bank = Path()
      ..moveTo(718, 324)
      ..cubicTo(681, 357, 395, 445, 184, 600);
    canvas.drawPath(bank, _stroke(const Color(0xFF676F51), 4));
    final grass = Path();
    final edge = bank.computeMetrics().first;
    for (double d = 6; d < edge.length; d += 2.1 + rng.nextDouble() * 4) {
      final point = edge.getTangentForOffset(d)!.position;
      final length = 2 + 13 * d / edge.length * rng.nextDouble();
      grass
        ..moveTo(point.dx - length * 0.65, point.dy - length)
        ..quadraticBezierTo(
          point.dx - 2,
          point.dy - length / 2,
          point.dx,
          point.dy + 2,
        );
    }
    canvas.drawPath(grass, _stroke(const Color(0xFF566D41), 1.7));
    canvas.restore();
  }

  void _drawHouseYard(Canvas canvas) {
    canvas.drawPath(
      _houseYard,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 310),
          const Offset(0, 350),
          const [Color(0xFF8A887A), Color(0xFFA09D8D)],
        ),
    );
    canvas.save();
    canvas.clipPath(_houseYard);
    final seam = _stroke(const Color(0xFF878678), 0.8);
    canvas.drawLine(const Offset(694, 327), const Offset(711, 337), seam);
    canvas.drawLine(const Offset(715, 319), const Offset(733, 332), seam);
    canvas.restore();
  }

  void _drawYardWall(Canvas canvas) {
    const base = [
      Offset(434, 345),
      Offset(473, 348),
      Offset(548, 350),
      Offset(594, 348),
      Offset(653, 345),
      Offset(699, 339),
    ];
    const top = [
      Offset(434, 335),
      Offset(473, 331),
      Offset(548, 333),
      Offset(594, 332),
      Offset(653, 332),
      Offset(699, 328),
    ];
    final wall = Path()..addPolygon([...top, ...base.reversed], true);
    canvas.drawPath(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 329),
          const Offset(0, 351),
          const [Color(0xFF989587), Color(0xFF6D6E5F)],
        ),
    );
    _polygon(canvas, [
      ...top.map((point) => point.translate(2, -2)),
      ...top.reversed,
    ], const Color(0xFFB0A998));

    final random = Random(46);
    final joints = _stroke(const Color(0xFF767768), 0.8);
    final weeds = Path();
    for (int i = 0; i < base.length - 1; i++) {
      for (double t = 0.12; t < 1; t += 0.12 + random.nextDouble() * 0.22) {
        final foot = Offset.lerp(base[i], base[i + 1], t)!;
        final cap = Offset.lerp(top[i], top[i + 1], t)!;
        canvas.drawLine(foot, Offset.lerp(foot, cap, 0.65)!, joints);
        final height = 3 + random.nextDouble() * 7;
        weeds
          ..moveTo(foot.dx - 4, foot.dy - height * 0.7)
          ..quadraticBezierTo(foot.dx - 1, foot.dy - 3, foot.dx, foot.dy + 2)
          ..lineTo(foot.dx + 3, foot.dy - height);
      }
    }
    canvas.drawPath(weeds, _stroke(const Color(0xFF5F7449), 1.6));
  }

  void _houses(Canvas canvas) {
    const frontLeft = Offset(451, 190);
    const frontRight = Offset(604, 190);
    const sideRight = Offset(654, 178);
    canvas.drawRect(
      Rect.fromPoints(frontLeft, const Offset(605, 332)),
      _fill(const Color(0xFFCBC6B2)),
    );
    _polygon(canvas, const [
      frontRight,
      sideRight,
      Offset(654, 330),
      Offset(604, 332),
    ], const Color(0xFFA8A68F));
    _polygon(canvas, const [
      Offset(443, 182),
      Offset(492, 169),
      Offset(661, 169),
      Offset(608, 182),
    ], const Color(0xFFA1A198));
    _polygon(canvas, const [
      Offset(443, 182),
      Offset(608, 182),
      Offset(608, 192),
      Offset(443, 192),
    ], const Color(0xFF83867D));
    _polygon(canvas, const [
      Offset(608, 182),
      Offset(661, 169),
      Offset(661, 179),
      Offset(608, 192),
    ], const Color(0xFF72796F));
    for (double x = 455; x < 604; x += 6) {
      canvas.drawLine(
        Offset(x, 194),
        Offset(x, 332),
        _stroke(const Color(0xFFAAA792), 0.45),
      );
    }
    for (double y = 197; y < 332; y += 5) {
      canvas.drawLine(
        Offset(451, y),
        Offset(604, y),
        _stroke(const Color(0xFFAAA792), 0.45),
      );
    }
    for (final y in [215.0, 270.0]) {
      for (final x in [474.0, 547.0]) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, 32, 28),
          _fill(lightsOn ? const Color(0xFFE7BD75) : const Color(0xFF616E66)),
        );
        canvas.drawRect(
          Rect.fromLTWH(x - 3, y - 3, 38, 4),
          _fill(const Color(0xFF798579)),
        );
        for (double dx = 4; dx < 32; dx += 4) {
          canvas.drawLine(
            Offset(x + dx, y),
            Offset(x + dx, y + 28),
            _stroke(const Color(0xFFA4A99A), 1),
          );
        }
      }
    }
    _polygon(canvas, const [
      Offset(450, 326),
      Offset(604, 326),
      Offset(655, 324),
      Offset(655, 331),
      Offset(604, 336),
      Offset(450, 336),
    ], const Color(0xFF87877A));
    canvas.drawLine(
      const Offset(450, 336),
      const Offset(604, 336),
      _stroke(const Color(0xFF5C6056), 1.2),
    );
    _waterTank(canvas);

    const gableLeft = Offset(580, 279);
    const gablePeak = Offset(632, 246);
    const gableRight = Offset(692, 277);
    const frontFoot = Offset(692, 332);
    const backFoot = Offset(724, 319);
    const depth = Offset(32, -13);
    final backEave = gableRight + depth;
    _polygon(canvas, const [
      Offset(574, 334),
      frontFoot,
      backFoot,
      Offset(728, 324),
      Offset(703, 338),
      Offset(582, 339),
    ], const Color(0x7044503B));
    _polygon(canvas, [
      gableRight,
      backEave,
      backFoot,
      frontFoot,
    ], const Color(0xFF795744));
    final sideMortar = _stroke(const Color(0xFF9A7760), 0.7);
    for (int row = 1; row < 11; row++) {
      final near = gableRight.translate(0, row * 5);
      final far = near + depth;
      canvas.drawLine(near, far, sideMortar);
      for (double t = row.isEven ? 0.2 : 0.36; t < 1; t += 0.32) {
        final joint = Offset.lerp(near, far, t)!;
        canvas.drawLine(joint, joint.translate(0, -5), sideMortar);
      }
    }
    final brickWall = Path()
      ..addPolygon(const [
        gableLeft,
        gablePeak,
        gableRight,
        frontFoot,
        Offset(580, 333),
      ], true);
    canvas.drawPath(brickWall, _fill(const Color(0xFF9B6F56)));
    canvas.save();
    canvas.clipPath(brickWall);
    final bricks = _stroke(const Color(0xFFB49073), 0.7);
    for (double y = 250; y < 333; y += 5) {
      canvas.drawLine(Offset(580, y), Offset(692, y), bricks);
      for (double x = 584 + (y % 10); x < 692; x += 11) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 5), bricks);
      }
    }
    canvas.restore();

    const ridge = Offset(631, 240);
    const frontEave = Offset(699, 273);
    final rearRidge = ridge + depth;
    final rearEave = frontEave + depth;
    _polygon(canvas, [
      ridge,
      rearRidge,
      rearEave,
      frontEave,
    ], const Color(0xFF788174));
    final roofSeams = _stroke(const Color(0xFF646E62), 0.7);
    for (int i = 1; i < 8; i++) {
      final t = i / 8;
      canvas.drawLine(
        Offset.lerp(ridge, rearRidge, t)!,
        Offset.lerp(frontEave, rearEave, t)!,
        roofSeams,
      );
    }
    _polygon(canvas, [
      frontEave,
      rearEave,
      rearEave.translate(0, 5),
      frontEave.translate(0, 5),
    ], const Color(0xFF4E5A50));
    _polygon(canvas, const [
      Offset(573, 278),
      ridge,
      frontEave,
      Offset(698, 281),
      gableRight,
      gablePeak,
      gableLeft,
      Offset(575, 286),
    ], const Color(0xFF5D665E));
    _polygon(canvas, const [
      gableLeft,
      gablePeak,
      gableRight,
      Offset(692, 282),
      Offset(632, 252),
      Offset(580, 284),
    ], const Color(0x55704837));
    canvas.drawRect(
      const Rect.fromLTWH(611, 292, 28, 41),
      _fill(const Color(0xFF55594C)),
    );
    _polygon(canvas, const [
      Offset(609, 331),
      Offset(640, 331),
      Offset(645, 337),
      Offset(606, 338),
    ], const Color(0xFFB0AA95));
    _polygon(canvas, const [
      Offset(606, 338),
      Offset(645, 337),
      Offset(645, 340),
      Offset(606, 341),
    ], const Color(0xFF747363));

    // The upper edge mounts against the brick wall. Posts support the lower eave.
    const topLeft = Offset(585, 287);
    const topRight = Offset(656, 286);
    const eaveLeft = Offset(571, 306);
    const eaveRight = Offset(653, 305);
    final posts = _stroke(const Color(0xFF596258), 2);
    canvas.drawLine(eaveLeft.translate(2, 0), const Offset(573, 335), posts);
    canvas.drawLine(eaveRight.translate(-2, 0), const Offset(651, 333), posts);
    _polygon(canvas, const [
      topLeft,
      topRight,
      eaveRight,
      eaveLeft,
    ], const Color(0xFF7B8881));
    final ribs = _stroke(const Color(0xFF606C64), 0.8);
    for (int i = 0; i <= 12; i++) {
      final t = i / 12;
      canvas.drawLine(
        Offset.lerp(topLeft, topRight, t)!,
        Offset.lerp(eaveLeft, eaveRight, t)!,
        ribs,
      );
    }
  }

  void _waterTank(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(525, 172, 44, 9),
      _fill(const Color(0x3954635D)),
    );
    final rearStand = _stroke(const Color(0xFF687674), 1.6);
    canvas.drawLine(const Offset(540, 158), const Offset(534, 174), rearStand);
    canvas.drawLine(const Offset(557, 158), const Offset(565, 174), rearStand);
    canvas.drawLine(const Offset(534, 174), const Offset(565, 174), rearStand);
    final stand = _stroke(const Color(0xFF515F5F), 1.8);
    canvas.drawLine(const Offset(534, 159), const Offset(527, 180), stand);
    canvas.drawLine(const Offset(551, 159), const Offset(560, 180), stand);
    canvas.drawLine(const Offset(529, 174), const Offset(557, 174), stand);
    canvas.drawLine(const Offset(531, 166), const Offset(557, 174), stand);

    final barrel = Path()
      ..moveTo(525, 129)
      ..lineTo(525, 158)
      ..cubicTo(525, 167, 563, 167, 563, 158)
      ..lineTo(563, 129)
      ..close();
    canvas.drawPath(
      barrel,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(525, 0),
          const Offset(563, 0),
          const [
            Color(0xFF627376),
            Color(0xFF9EADAD),
            Color(0xFFE2E6DE),
            Color(0xFFA3AFAC),
            Color(0xFF637575),
          ],
          const [0, 0.24, 0.40, 0.64, 1],
        ),
    );

    final ribShadow = _stroke(const Color(0x80536266), 0.75);
    final ribLight = _stroke(const Color(0x80EDF0EA), 0.65);
    for (double y = 135; y < 159; y += 5.5) {
      for (final (lift, paint) in [(0.0, ribShadow), (-0.9, ribLight)]) {
        final rib = Path()
          ..moveTo(525.5, y + lift)
          ..cubicTo(528, y + lift + 5, 559, y + lift + 5, 562.5, y + lift);
        canvas.drawPath(rib, paint);
      }
    }

    canvas.drawOval(
      const Rect.fromLTRB(525, 123, 563, 135),
      _fill(const Color(0xFF8C9A99)),
    );
    canvas.drawOval(
      const Rect.fromLTRB(526, 122, 562, 133),
      _fill(const Color(0xFFB8C3BF)),
    );
    canvas.drawOval(
      const Rect.fromLTRB(537, 122, 551, 127),
      _fill(const Color(0xFFD6DDD5)),
    );
  }

  void _bananaLeaves(Canvas canvas) {
    final stem = _stroke(const Color(0xFF666E48), 4);
    for (final x in [394.0, 408.0, 421.0]) {
      final base = Offset(x, 327);
      final top = Offset(x - 4, 267 - (x % 9));
      canvas.drawLine(base, top, stem);
      for (int j = -2; j <= 2; j++) {
        final tip = top.translate(j * 16, -21 + j.abs() * 14);
        final mid = Offset.lerp(top, tip, 0.5)!;
        final leaf = Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(mid.dx - 4, mid.dy - 17, tip.dx, tip.dy)
          ..quadraticBezierTo(mid.dx + 2, mid.dy + 4, top.dx, top.dy)
          ..close();
        canvas.drawPath(
          leaf,
          _fill(j.isEven ? const Color(0xFF61794A) : const Color(0xFF748957)),
        );
      }
    }
  }

  void _utilityLines(Canvas canvas) {
    final roadEdge = _laneOuterEdge.computeMetrics().first;
    final tops = <Offset>[];
    for (final (position, height, width) in [
      (0.14, 72.0, 3.0),
      (0.41, 111.0, 4.5),
      (0.77, 176.0, 7.0),
    ]) {
      final edge = roadEdge.getTangentForOffset(roadEdge.length * position)!;
      final base = edge.position.translate(width + 3, 0);
      final top = base.translate(-width * 0.35, -height);
      tops.add(top);

      canvas.drawLine(base, top, _stroke(const Color(0xFF777D76), width));
      final guard = Rect.fromLTWH(
        base.dx - width / 2,
        base.dy - width * 4.7,
        width,
        width * 4.7,
      );
      canvas.drawRect(guard, _fill(const Color(0xFFBD9B54)));
      canvas.save();
      canvas.clipRect(guard);
      for (int stripe = 0; stripe < 4; stripe++) {
        final y = guard.top + width * stripe * 1.35;
        canvas.drawLine(
          Offset(guard.left, y + width * 0.6),
          Offset(guard.right, y),
          _stroke(const Color(0xFF4D544D), width * 0.4),
        );
      }
      canvas.restore();
    }

    for (final drop in [2.0, 8.0]) {
      final first = tops.first.translate(0, drop * 0.45);
      final wires = Path()..moveTo(first.dx, first.dy);
      var previous = first;
      for (int i = 1; i < tops.length; i++) {
        final next = tops[i].translate(0, drop * (i == 1 ? 0.7 : 1));
        final middle = Offset.lerp(previous, next, 0.5)!;
        final sag = (next - previous).distance * 0.16;
        wires.quadraticBezierTo(middle.dx, middle.dy + sag, next.dx, next.dy);
        previous = next;
      }
      canvas.drawPath(wires, _stroke(const Color(0xFF5F696A), 0.9));
    }
  }

  void _polygon(Canvas canvas, List<Offset> points, Color color) {
    canvas.drawPath(Path()..addPolygon(points, true), _fill(color));
  }

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(_RainyFieldLanePainter oldDelegate) =>
      lightsOn != oldDelegate.lightsOn;
}
