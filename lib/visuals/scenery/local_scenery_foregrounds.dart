part of 'biome_scenery_layer.dart';

extension _LocalSceneryForegrounds on _SceneryPainter {
  void _frameLandscape(Canvas canvas, Size size) {
    final (x, zoom) = switch (variant) {
      LandscapeVariant.centralPlains => (0.58, 1.32),
      LandscapeVariant.southPlains => (0.40, 1.36),
      LandscapeVariant.northHills => (0.62, 1.32),
      LandscapeVariant.northTerraces => (0.46, 1.28),
      LandscapeVariant.centralHills => (0.38, 1.30),
      LandscapeVariant.centralValley => (0.48, 1.30),
      LandscapeVariant.eastRiftValley => (0.65, 1.26),
      LandscapeVariant.eastFoothills => (0.52, 1.29),
      LandscapeVariant.northEstuary => (0.68, 1.26),
      LandscapeVariant.southCoast => (0.12, 1.30),
      LandscapeVariant.eastCoast => (0.36, 1.32),
    };
    final anchor = Offset(size.width * x, size.height * 0.60);
    canvas.translate(anchor.dx, anchor.dy);
    canvas.scale(zoom);
    canvas.translate(-anchor.dx, -anchor.dy);
    if (variant == LandscapeVariant.centralPlains) {
      canvas.translate(0, -size.height * 0.15);
    } else if (variant == LandscapeVariant.southPlains) {
      canvas.translate(0, -size.height * 0.075);
    }
  }

  void _drawLocalForeground(Canvas canvas, Size size, _SceneryPalette p) {
    final rng = Random(seed + 101);
    final w = size.width, h = size.height;
    final scale = min(w / 540, h / 410);
    switch (variant) {
      case LandscapeVariant.centralPlains:
        _ershuiCanal(canvas, size, p, rng);
        _canalCanopy(canvas, size, p, rng);
      case LandscapeVariant.southPlains:
        _nearPineapples(canvas, size, p, rng, scale);
      case LandscapeVariant.northHills:
        _maokongTeaWalk(canvas, size, p, rng);
      case LandscapeVariant.northTerraces:
        _terraceWall(canvas, size, p, rng, scale);
      case LandscapeVariant.centralHills:
        _songbolingTeaLane(canvas, size, p, rng, scale);
      case LandscapeVariant.centralValley:
        _gravelEdge(canvas, size, p, rng, scale, coast: false);
      case LandscapeVariant.eastRiftValley:
        _nearRice(canvas, size, p, rng, scale);
      case LandscapeVariant.eastFoothills:
        _nearDaylilies(canvas, size, p, rng, scale);
      case LandscapeVariant.northEstuary:
        _mangroveWalk(canvas, size, p, rng, scale);
      case LandscapeVariant.southCoast:
        _coralShelf(canvas, size, p, rng, scale);
      case LandscapeVariant.eastCoast:
        _gravelEdge(canvas, size, p, rng, scale, coast: true);
    }
  }

  void _ershuiCanal(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width, h = size.height;
    final view = _ErshuiPerspective(size);
    final ground = Rect.fromLTRB(0, h * 0.465, w, h);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = ui.Gradient.linear(ground.topCenter, ground.bottomCenter, [
          Color.lerp(p.land, p.haze, 0.19)!,
          Color.lerp(p.land, p.water, 0.21)!,
        ]),
    );

    final stems = Path();
    const near = -0.27;
    const far = 3.6;
    for (double z = near; z < far; z += 0.165 + max(z, 0) * 0.07) {
      for (double x = 1.18; x < 10; x += 0.21) {
        final rowX = x + rng.nextDouble() * 0.13;
        final rowZ = z + rng.nextDouble() * 0.08;
        final foot = view.at(rowX, rowZ);
        if (foot.dx > w + 4 || foot.dy > h + 8) continue;
        final tip = view.at(
          rowX + 0.035,
          rowZ,
          0.018 + rng.nextDouble() * 0.012,
        );
        final leaf = view.at(rowX - 0.045, rowZ, 0.014);
        stems
          ..moveTo(leaf.dx, leaf.dy)
          ..lineTo(foot.dx, foot.dy)
          ..lineTo(tip.dx, tip.dy);
      }
    }
    canvas.drawPath(
      stems,
      Paint()
        ..color = Color.lerp(p.tree, p.accent, 0.18)!
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = min(w, h) * 0.0018,
    );

    canvas.drawPath(
      view.strip(-3.2, -1, near, far),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.46), Offset(0, h), [
          _tone(const Color(0xFF9A9E91)),
          _tone(const Color(0xFF717A75)),
        ]),
    );
    const waterLevel = -0.046;
    const channelLeft = -0.92, channelRight = 0.92;
    final water = view.strip(channelLeft, channelRight, near, far, waterLevel);
    canvas.drawPath(
      water,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.45), Offset(0, h), [
          Color.lerp(p.water, p.haze, 0.28)!,
          Color.lerp(p.water, p.darkLand, 0.42)!,
        ]),
    );
    _waterMarks(canvas, size, p, rng, water, xMax: 0.84);
    for (final (side, edge) in [(-1.0, channelLeft), (1.0, channelRight)]) {
      final wall = Path()
        ..addPolygon([
          view.at(edge, near),
          view.at(edge, far),
          view.at(edge, far, waterLevel),
          view.at(edge, near, waterLevel),
        ], true);
      final shade = _tone(Color(side > 0 ? 0xFF6B7261 : 0xFF828477));
      canvas.drawPath(wall, Paint()..color = shade);
      canvas.drawPath(
        view.strip(min(side, edge), max(side, edge), near, far),
        Paint()..color = _tone(const Color(0xFF9D9E8A)),
      );
      final joints = Paint()
        ..color = p.darkLand.withValues(alpha: 0.37)
        ..strokeWidth = min(w, h) * 0.0013;
      for (double z = -0.14; z <= 2.5; z += 0.24) {
        canvas.drawLine(view.at(edge, z), view.at(edge, z, waterLevel), joints);
      }
    }

    _irrigationGate(canvas, p, view);
  }

  void _irrigationGate(
    Canvas canvas,
    _SceneryPalette p,
    _ErshuiPerspective view,
  ) {
    final concrete = _tone(const Color(0xFF9E9E8D));
    final shade = _tone(const Color(0xFF646B5D));
    final lit = Color.lerp(concrete, p.haze, 0.30)!;
    final oxide = _tone(const Color(0xFF625F56));
    const front = -0.035, back = 0.075;
    const lintel = 0.31, rim = 0.365;

    void box(
      double left,
      double right,
      double low,
      double high, {
      required double zFront,
      required double zBack,
    }) {
      final frontLeft = view.at(left, zFront, low);
      final frontRight = view.at(right, zFront, low);
      final topLeft = view.at(left, zFront, high);
      final topRight = view.at(right, zFront, high);
      canvas.drawPath(
        Path()..addPolygon([
          frontRight,
          view.at(right, zBack, low),
          view.at(right, zBack, high),
          topRight,
        ], true),
        Paint()..color = shade,
      );
      canvas.drawPath(
        Path()..addPolygon([
          topLeft,
          topRight,
          view.at(right, zBack, high),
          view.at(left, zBack, high),
        ], true),
        Paint()..color = lit,
      );
      canvas.drawPath(
        Path()..addPolygon([frontLeft, frontRight, topRight, topLeft], true),
        Paint()..color = concrete,
      );
    }

    final panel = Path()
      ..addPolygon([
        view.at(-0.90, 0, -0.022),
        view.at(0.90, 0, -0.022),
        view.at(0.90, 0, 0.132),
        view.at(-0.90, 0, 0.132),
      ], true);
    final top = view.at(0, 0, 0.132);
    final bottom = view.at(0, 0, -0.022);
    canvas.drawPath(
      panel,
      Paint()
        ..shader = ui.Gradient.linear(top, bottom, [
          Color.lerp(oxide, concrete, 0.18)!,
          Color.lerp(oxide, p.darkLand, 0.4)!,
        ]),
    );
    final metal = Paint()
      ..color = oxide
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, min(view.size.width, view.size.height) * 0.005);
    canvas.drawLine(top, view.at(0, 0, 0.498), metal);
    final wheel = Path();
    for (int i = 0; i <= 36; i++) {
      final angle = i * 2 * pi / 36;
      final point = view.at(cos(angle) * 0.43, sin(angle) * 0.105, 0.462);
      if (i == 0) {
        wheel.moveTo(point.dx, point.dy);
      } else {
        wheel.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(wheel..close(), metal);
    canvas.drawLine(view.at(-0.4, 0, 0.462), view.at(0.4, 0, 0.462), metal);

    box(0.84, 1.14, -0.04, lintel, zFront: front, zBack: back);
    box(-1.15, -0.83, -0.04, lintel, zFront: front, zBack: back);
    box(-1.18, 1.16, lintel, rim, zFront: front - 0.009, zBack: back + 0.01);
  }

  void _canalCanopy(Canvas canvas, Size size, _SceneryPalette p, Random rng) {
    final w = size.width, h = size.height;
    final branches = Path()
      ..moveTo(-w * 0.013, h * 0.28)
      ..quadraticBezierTo(w * 0.04, h * 0.13, w * 0.19, h * 0.065)
      ..moveTo(w * 0.02, h * 0.20)
      ..quadraticBezierTo(w * 0.12, h * 0.17, w * 0.23, h * 0.14);
    final pen = Paint()
      ..color = _tone(const Color(0xFF626B56))
      ..strokeWidth = min(w, h) * 0.012
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(branches, pen);

    final shade = Path(), light = Path();
    final unit = min(w, h);
    for (int i = 0; i < 82; i++) {
      final x = w * (rng.nextDouble() * 0.28 - 0.035);
      final y = h * (0.018 + rng.nextDouble() * 0.137 + x / w * 0.19);
      final radius = unit * (0.009 + rng.nextDouble() * 0.018);
      final center = Offset(x, y);
      final tip = center.translate(radius * 1.2, radius * 0.42);
      final base = center.translate(-radius, -radius * 0.45);
      final layer = i.isEven ? shade : light;
      layer
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(x + radius * 0.35, y - radius, tip.dx, tip.dy)
        ..quadraticBezierTo(
          x - radius * 0.18,
          y + radius * 0.70,
          base.dx,
          base.dy,
        )
        ..close();
    }
    canvas.drawPath(shade, Paint()..color = p.tree);
    canvas.drawPath(
      light,
      Paint()..color = Color.lerp(p.tree, p.accent, 0.24)!,
    );
  }

  void _nearPineapples(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    const horizon = 0.55;
    double edge(double t) => w * (0.74 - 0.22 * t + 0.04 * sin(t * pi));
    double yAt(double t) => h * (horizon + (1 - horizon) * t);
    final road = Path();
    const samples = 22;
    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      if (i == 0) {
        road.moveTo(edge(t), yAt(t));
      } else {
        road.lineTo(edge(t), yAt(t));
      }
    }
    for (int i = samples; i >= 0; i--) {
      final t = i / samples;
      road.lineTo(edge(t) + w * (0.05 + 0.43 * t), yAt(t));
    }
    road.close();

    final ground = Rect.fromLTRB(0, h * horizon, w, h);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = ui.Gradient.linear(ground.topCenter, ground.bottomCenter, [
          _tone(const Color(0xFF98806A)),
          _tone(const Color(0xFF815841)),
        ]),
    );
    canvas.drawPath(
      road,
      Paint()
        ..shader = ui.Gradient.linear(ground.topCenter, ground.bottomCenter, [
          _tone(const Color(0xFF9E9B8B)),
          _tone(const Color(0xFF777B74)),
        ]),
    );
    canvas.save();
    canvas.clipPath(road);
    for (final (depth, across, width) in [
      (0.29, 0.075, 0.026),
      (0.53, 0.19, 0.066),
      (0.80, 0.16, 0.118),
      (0.93, 0.32, 0.077),
    ]) {
      final center = Offset(edge(depth) + w * across, yAt(depth));
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: w * width,
          height: h * (0.006 + depth * 0.014),
        ),
        Paint()..color = _tone(const Color(0xFF97AAA9)).withValues(alpha: 0.52),
      );
    }
    canvas.restore();

    final verge = Path()..moveTo(edge(0), yAt(0));
    for (int i = 1; i <= samples; i++) {
      final depth = i / samples;
      verge.lineTo(edge(depth), yAt(depth));
    }
    canvas.drawPath(
      verge,
      Paint()
        ..color = p.tree.withValues(alpha: 0.64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, scale * 2.3),
    );

    _farmShed(canvas, p, Offset(w * 0.94, h * 0.64), scale * 1.5);

    const rows = 10;
    for (int row = 0; row < rows; row++) {
      final d = pow((row + 0.4) / (rows - 0.55), 1.62).toDouble();
      final s = scale * (1.05 + 7.8 * d);
      final offset = (row.isEven ? 0.4 : 0.8) * 12 * s;
      final plants = _PineapplePlants();
      final furrow = Path()
        ..moveTo(-0.03 * w, yAt(d))
        ..quadraticBezierTo(
          edge(d) * 0.51,
          yAt(d) - h * 0.025 * d,
          edge(d) - s * 4,
          yAt(d) - h * 0.018,
        );
      canvas.drawPath(
        furrow,
        Paint()
          ..color = _tone(const Color(0xFF634B3B)).withValues(alpha: 0.56)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 * s,
      );
      for (double x = offset - 12 * s; x < edge(d) - s * 5; x += 12 * s) {
        final jitter = rng.nextDouble() * s * 1.2;
        plants.add(
          x + jitter,
          yAt(d) - h * 0.018 * (x / edge(d)) + jitter * 0.4,
          s,
          rng,
          canFruit: row >= 4,
          fruitChance: row >= 7 ? 0.62 : 0.34,
        );
      }
      plants.paint(canvas, _tone);
    }
  }

  void _farmShed(Canvas canvas, _SceneryPalette p, Offset base, double scale) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale);
    final shadow = _tone(const Color(0xFF68675A));
    final siding = _tone(const Color(0xFFA3A08C));
    canvas.drawOval(
      const Rect.fromLTWH(-38, -4, 82, 10),
      Paint()..color = p.darkLand.withValues(alpha: 0.48),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-33, -35, 72, 35),
      Paint()..color = siding,
    );
    final seam = Paint()
      ..color = shadow.withValues(alpha: 0.42)
      ..strokeWidth = 0.8;
    for (double x = -29; x < 38; x += 4) {
      canvas.drawLine(Offset(x, -34), Offset(x, 0), seam);
    }
    canvas.drawRect(
      const Rect.fromLTWH(-22, -25, 21, 25),
      Paint()..color = shadow,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, -23, 15, 11),
      Paint()..color = _tone(const Color(0xFF686F63)),
    );
    final roof = Path()
      ..addPolygon(const [
        Offset(-39, -34),
        Offset(-32, -46),
        Offset(30, -50),
        Offset(44, -38),
      ], true);
    canvas.drawPath(roof, Paint()..color = _tone(const Color(0xFF6C786F)));
    canvas.drawLine(
      const Offset(-39, -34),
      const Offset(44, -38),
      seam..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _footpath(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Offset far,
    Rect near, {
    bool timber = false,
    bool railing = false,
    bool rightRailingOnly = false,
    double bend = -0.043,
  }) {
    final nearLeft = near.bottomLeft, nearRight = near.bottomRight;
    final mouth = near.width * 0.12;
    final farLeft = far.translate(-mouth, 0),
        farRight = far.translate(mouth, 0);
    Offset edge(Offset distant, Offset close, double t) {
      final pos = Offset.lerp(distant, close, t)!;
      return pos.translate(sin(pi * t) * size.width * bend, 0);
    }

    final path = Path();
    const steps = 20;
    for (int i = 0; i <= steps; i++) {
      final v = edge(farLeft, nearLeft, i / steps);
      if (i == 0) {
        path.moveTo(v.dx, v.dy);
      } else {
        path.lineTo(v.dx, v.dy);
      }
    }
    for (int i = steps; i >= 0; i--) {
      final v = edge(farRight, nearRight, i / steps);
      path.lineTo(v.dx, v.dy);
    }
    path.close();
    final surface = _tone(Color(timber ? 0xFF9B8670 : 0xFFA8A393));
    canvas.drawPath(
      path,
      Paint()..color = Color.lerp(surface, p.darkLand, 0.16)!,
    );
    final seam = Paint()
      ..color = Color.lerp(surface, p.darkLand, 0.54)!
      ..strokeWidth = 1.0;
    for (int i = 1; i < (timber ? 16 : 8); i++) {
      final t = pow(i / (timber ? 16 : 8), 1.5).toDouble();
      canvas.drawLine(
        edge(farLeft, nearLeft, t),
        edge(farRight, nearRight, t),
        seam,
      );
    }
    if (railing) {
      final wood = Color.lerp(surface, p.darkLand, 0.46)!;
      final rail = Paint()
        ..color = wood
        ..strokeCap = StrokeCap.round;
      final face = Paint()..color = Color.lerp(wood, p.darkLand, 0.28)!;
      final unit = min(size.width, size.height);
      for (final (farEdge, nearEdge) in [
        if (!rightRailingOnly) (farLeft, nearLeft),
        (farRight, nearRight),
      ]) {
        Offset topAt(double t) => edge(
          farEdge,
          nearEdge,
          t,
        ).translate(0, -unit * (0.023 + t * 0.092));
        for (int i = 0; i < 20; i++) {
          final t = i / 20;
          rail.strokeWidth = max(1.0, unit * (0.003 + 0.011 * t));
          canvas.drawLine(topAt(t), topAt((i + 1) / 20), rail);
        }
        for (int i = 0; i <= 9; i++) {
          final t = pow(i / 9, 1.47).toDouble();
          final base = edge(farEdge, nearEdge, t);
          final top = topAt(t);
          final halfWidth = max(0.65, unit * (0.0015 + 0.0095 * t));
          canvas.drawRect(
            Rect.fromLTRB(
              top.dx - halfWidth,
              top.dy - halfWidth,
              top.dx + halfWidth,
              base.dy,
            ),
            Paint()..color = wood,
          );
          canvas.drawRect(
            Rect.fromLTRB(
              top.dx + halfWidth * 0.35,
              top.dy - halfWidth,
              top.dx + halfWidth,
              base.dy,
            ),
            face,
          );
        }
      }
    }
  }

  void _maokongTeaWalk(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
  ) {
    final w = size.width, h = size.height;
    final ground = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.31, h * 0.56, w * 0.73, h * 0.61)
      ..quadraticBezierTo(w * 0.91, h * 0.60, w, h * 0.57)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      ground,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.61), Offset(0, h), [
          Color.lerp(p.land, p.darkLand, 0.24)!,
          p.darkLand,
        ]),
    );

    for (int row = 0; row < 6; row++) {
      final depth = row / 5;
      final height = h * (0.047 + depth * 0.119);
      final top = h * (0.62 + 0.29 * depth * depth);
      final right = w * (0.79 - 0.20 * depth);
      if (row >= 4) {
        // A brown lip and exposed stems break up the clipped hedge face.
        final edge = Path()
          ..moveTo(0, top + height * 0.89)
          ..quadraticBezierTo(
            right * 0.47,
            top + height * 0.56,
            right - height * 0.16,
            top - height * 0.08,
          );
        canvas.drawPath(
          edge,
          Paint()
            ..color = _tone(const Color(0xFF776D55))
            ..style = PaintingStyle.stroke
            ..strokeWidth = height * 0.17,
        );
        final stems = Path();
        final step = min(w, h) * 0.027;
        for (double x = step * 0.2; x < right - height * 0.13; x += step) {
          final t = x / right;
          final foot = top + height * (0.89 - 0.63 * t - 0.34 * t * t);
          final crown = foot - height * (0.28 + rng.nextDouble() * 0.14);
          stems
            ..moveTo(x, foot)
            ..quadraticBezierTo(
              x - step * 0.13,
              foot - height * 0.17,
              x - step * 0.37,
              crown,
            )
            ..moveTo(x - step * 0.07, foot - height * 0.09)
            ..lineTo(x + step * 0.22, crown + height * 0.06);
        }
        canvas.drawPath(
          stems,
          Paint()
            ..color = _tone(const Color(0xFF5B5743))
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = max(1.0, step * 0.1),
        );
      }
      final hedge = Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(
          right * 0.44,
          top - height * 0.7,
          right,
          top - height * 0.65,
        )
        ..quadraticBezierTo(
          right + height * 0.12,
          top - height * 0.46,
          right - height * 0.18,
          top - height * 0.26,
        )
        ..quadraticBezierTo(
          right * 0.47,
          top + height * 0.36,
          0,
          top + height * 0.75,
        )
        ..close();
      canvas.drawPath(
        hedge,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, top - height * 0.5),
            Offset(0, top + height * 0.66),
            [
              Color.lerp(p.tree, p.accent, 0.32)!,
              p.tree,
              Color.lerp(p.tree, p.darkLand, 0.58)!,
            ],
            [0, 0.48, 1],
          ),
      );
      final leaves = Path();
      for (int i = 0; i < 105; i++) {
        final x = rng.nextDouble() * right;
        final y = top + height * (rng.nextDouble() * 1.33 - 0.64);
        final center = Offset(x, y);
        if (!hedge.contains(center)) continue;
        final radius = min(w, h) * (0.0016 + depth * 0.0037);
        leaves.addOval(
          Rect.fromCenter(
            center: center,
            width: radius * (1.4 + rng.nextDouble()),
            height: radius,
          ),
        );
      }
      canvas.drawPath(
        leaves,
        Paint()
          ..color = Color.lerp(p.tree, p.accent, 0.47)!.withValues(alpha: 0.60),
      );
    }

    _footpath(
      canvas,
      size,
      p,
      Offset(w * 1.075, h * 0.58),
      Rect.fromLTRB(w * 0.54, h, w * 1.01, h),
      timber: true,
      railing: true,
      rightRailingOnly: true,
      bend: -0.13,
    );

    final trunk = Path()
      ..moveTo(w * 0.986, h * 0.81)
      ..cubicTo(w * 0.993, h * 0.51, w * 0.973, h * 0.26, w * 0.947, h * 0.12)
      ..lineTo(w * 0.978, h * 0.094)
      ..cubicTo(w * 1.005, h * 0.29, w * 1.025, h * 0.53, w * 1.018, h * 0.82)
      ..close();
    canvas.drawPath(trunk, Paint()..color = _tone(const Color(0xFF626455)));
    canvas.save();
    canvas.translate(w, 0);
    canvas.scale(-1, 1);
    _canalCanopy(canvas, size, p, rng);
    canvas.restore();
  }

  void _songbolingTeaLane(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    const start = 0.60;
    double yAt(double depth) => h * (start + 0.40 * depth);
    double center(double depth) =>
        w * (0.56 + 0.15 * depth - 0.072 * sin(pi * depth));
    double half(double depth) => w * (0.017 + 0.207 * depth);
    Offset edge(double depth, double side) =>
        Offset(center(depth) + half(depth) * side, yAt(depth));
    Path laneBand(double from, double to) {
      final boundary = <Offset>[
        for (int i = 0; i <= 24; i++) edge(i / 24, from),
        for (int i = 24; i >= 0; i--) edge(i / 24, to),
      ];
      return Path()..addPolygon(boundary, true);
    }

    final earth = Path()
      ..moveTo(0, h * 0.68)
      ..quadraticBezierTo(w * 0.26, h * 0.64, w * 0.55, h * start)
      ..quadraticBezierTo(w * 0.82, h * 0.59, w, h * 0.67)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      earth,
      Paint()..color = Color.lerp(p.land, p.darkLand, 0.37)!,
    );
    canvas.drawPath(
      laneBand(-1.13, 1.19),
      Paint()..color = _tone(const Color(0xFF6C6F60)),
    );
    final lane = laneBand(-1, 1);
    canvas.drawPath(
      lane,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * start), Offset(0, h), [
          _tone(const Color(0xFFACA99B)),
          _tone(const Color(0xFF8C9087)),
        ]),
    );
    canvas.save();
    canvas.clipPath(lane);
    final joints = Paint()
      ..color = _tone(const Color(0xFF757B70)).withValues(alpha: 0.68)
      ..strokeWidth = max(0.8, scale);
    for (final depth in [0.18, 0.34, 0.56, 0.79]) {
      canvas.drawLine(edge(depth, -1), edge(depth + 0.024, 1), joints);
      final pos = edge(depth + 0.08, -0.15);
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: w * (0.016 + 0.11 * depth),
          height: h * (0.004 + 0.011 * depth),
        ),
        Paint()..color = p.haze.withValues(alpha: 0.22),
      );
    }
    canvas.restore();

    for (int row = 0; row < 8; row++) {
      final depth = 0.09 + 0.93 * pow(row / 7, 1.34).toDouble();
      final rowHeight = h * (0.022 + 0.081 * depth);
      for (final side in [-1.0, 1.0]) {
        if (side > 0 && depth > 0.30 && depth < 0.59) continue;
        final tip = edge(depth, side * 1.18);
        final outside = side < 0 ? -w * 0.06 : w * 1.05;
        final hedge = Path()
          ..moveTo(outside, tip.dy + rowHeight * 0.66)
          ..quadraticBezierTo(
            (outside + tip.dx) / 2,
            tip.dy - rowHeight * 0.34,
            tip.dx,
            tip.dy - rowHeight * 0.45,
          )
          ..quadraticBezierTo(
            tip.dx - side * rowHeight * 0.08,
            tip.dy - rowHeight * 0.06,
            tip.dx + side * rowHeight * 0.18,
            tip.dy + rowHeight * 0.23,
          )
          ..quadraticBezierTo(
            (outside + tip.dx) / 2,
            tip.dy + rowHeight * 0.54,
            outside,
            tip.dy + rowHeight * 1.23,
          )
          ..close();
        canvas.drawPath(
          hedge,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, tip.dy - rowHeight * 0.42),
              Offset(0, tip.dy + rowHeight),
              [Color.lerp(p.tree, p.accent, 0.44)!, p.tree, p.darkLand],
              [0, 0.53, 1],
            ),
        );
        final leaves = Path();
        for (int i = 0; i < 86; i++) {
          final x = tip.dx + (outside - tip.dx) * rng.nextDouble();
          final y = tip.dy + rowHeight * (rng.nextDouble() * 1.45 - 0.45);
          if (!hedge.contains(Offset(x, y))) continue;
          final r = scale * (0.62 + 1.8 * depth * rng.nextDouble());
          leaves.addOval(
            Rect.fromCenter(center: Offset(x, y), width: r * 2.1, height: r),
          );
        }
        canvas.drawPath(
          leaves,
          Paint()..color = p.accent.withValues(alpha: isNight ? 0.2 : 0.49),
        );
      }
    }
    final bendHedge = Path()
      ..moveTo(w * 0.41, h * 0.609)
      ..quadraticBezierTo(w * 0.44, h * 0.581, w * 0.52, h * 0.585)
      ..quadraticBezierTo(w * 0.58, h * 0.577, w * 0.58, h * 0.603)
      ..quadraticBezierTo(w * 0.55, h * 0.616, w * 0.47, h * 0.625)
      ..close();
    canvas.drawPath(
      bendHedge,
      Paint()..color = Color.lerp(p.tree, p.land, 0.17)!,
    );
    _songbolingShed(canvas, p, Offset(w * 0.83, h * 0.72), scale * 1.29);
  }

  void _songbolingShed(
    Canvas canvas,
    _SceneryPalette p,
    Offset base,
    double scale,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale);
    final stone = Paint()..color = _tone(const Color(0xFF727467));
    canvas.drawPath(
      Path()..addPolygon(const [
        Offset(-35, -3),
        Offset(35, -3),
        Offset(52, -13),
        Offset(52, -4),
        Offset(34, 7),
        Offset(-35, 7),
      ], true),
      stone,
    );
    const front = Rect.fromLTRB(-31, -41, 33, -3);
    canvas.drawRect(front, Paint()..color = p.brick);
    canvas.drawPath(
      Path()..addPolygon(const [
        Offset(33, -41),
        Offset(49, -48),
        Offset(49, -12),
        Offset(33, -3),
      ], true),
      Paint()..color = Color.lerp(p.brick, p.darkLand, 0.37)!,
    );
    final mortar = Paint()
      ..color = Color.lerp(p.brick, p.haze, 0.32)!.withValues(alpha: 0.77)
      ..strokeWidth = 0.65;
    for (double y = -37; y < -3; y += 4) {
      canvas.drawLine(Offset(-31, y), Offset(33, y), mortar);
      for (double x = -28 + (y.round().abs() % 8); x < 33; x += 9) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 4), mortar);
      }
    }
    canvas.drawRect(
      const Rect.fromLTRB(2, -31, 18, -3),
      Paint()..color = _tone(const Color(0xFF757769)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-23, -30, -10, -21),
      Paint()..color = _tone(const Color(0xFF59645D)),
    );
    canvas.drawPath(
      Path()..addPolygon(const [
        Offset(-37, -41),
        Offset(-14, -57),
        Offset(39, -53),
        Offset(56, -47),
        Offset(36, -40),
      ], true),
      Paint()..color = p.roof,
    );
    canvas.drawLine(
      const Offset(-37, -41),
      const Offset(36, -40),
      Paint()
        ..color = p.infrastructure
        ..strokeWidth = 1.7,
    );
    canvas.restore();
  }

  void _drawSceneryTouch(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Offset point,
    double progress,
  ) {
    final x = point.dx / size.width, y = point.dy / size.height;
    if (y < 0.47) return;
    final water = switch (variant) {
      LandscapeVariant.centralPlains => _ErshuiPerspective(
        size,
      ).strip(-0.92, 0.92, -0.27, 3.6, -0.046),
      LandscapeVariant.northTerraces => _shimenWater(size),
      LandscapeVariant.eastRiftValley => _nearRiceWater(size),
      _ => null,
    };
    final onWater =
        water?.contains(point) ??
        switch (variant) {
          LandscapeVariant.centralValley => x < 0.40 && y > 0.76 && y < 0.88,
          LandscapeVariant.northEstuary => x < 0.35 && y > 0.61 && y < 0.72,
          LandscapeVariant.southCoast ||
          LandscapeVariant.eastCoast => x > 0.70 && y > 0.61 && y < 0.82,
          _ => false,
        };

    final unit = min(size.width, size.height);
    final fade = 1 - progress;
    if (onWater) {
      canvas.save();
      if (water != null) canvas.clipPath(water);
      final paint = Paint()
        ..color = p.light.withValues(alpha: 0.8 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.1, unit * 0.003);
      for (final scale in [1.0, 0.68, 0.42]) {
        final radius = unit * (0.018 + progress * 0.115) * scale;
        canvas.drawOval(
          Rect.fromCenter(
            center: point,
            width: radius * 2,
            height: radius * 0.72,
          ),
          paint,
        );
      }
      canvas.restore();
      return;
    }

    final strokes = Path();
    for (int i = 0; i < 5; i++) {
      final start = point.translate(
        unit * (progress * 0.21 - i * 0.028),
        unit * (-i * 0.023 - progress * 0.08),
      );
      strokes
        ..moveTo(start.dx, start.dy)
        ..relativeQuadraticBezierTo(
          unit * 0.025,
          -unit * 0.019,
          unit * (0.055 + i * 0.009),
          -unit * 0.017,
        );
    }
    canvas.drawPath(
      strokes,
      Paint()
        ..color = p.light.withValues(alpha: fade * 0.62)
        ..strokeWidth = max(1.1, unit * 0.0026)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    if (variant == LandscapeVariant.centralHills) {
      final leaves = Path();
      final r = unit * 0.008;
      for (int i = 0; i < 5; i++) {
        final center = point.translate(
          unit * (progress * 0.23 - i * 0.028),
          unit * (-progress * 0.11 + 0.024 * sin(progress * pi * 2 + i)),
        );
        leaves
          ..moveTo(center.dx - r, center.dy + r * 0.35)
          ..relativeQuadraticBezierTo(r * 0.6, -r * 1.6, r * 2, -r * 0.7)
          ..relativeQuadraticBezierTo(-r * 0.8, r * 1.4, -r * 2, r * 0.7)
          ..close();
      }
      canvas.drawPath(
        leaves,
        Paint()..color = p.accent.withValues(alpha: fade),
      );
    }
  }

  Path _shimenWater(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w * 0.43, h * 0.64)
      ..quadraticBezierTo(w * 0.72, h * 0.61, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(w * 0.52, h)
      ..cubicTo(w * 0.42, h * 0.86, w * 0.61, h * 0.77, w * 0.43, h * 0.64)
      ..close();
  }

  void _terraceWall(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    final water = _shimenWater(size);
    final slope = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.43, h * 0.54, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      slope,
      Paint()..color = Color.lerp(p.darkLand, p.land, 0.45)!,
    );
    final lane = Path()
      ..moveTo(w * 0.35, h * 0.64)
      ..cubicTo(w * 0.56, h * 0.79, w * 0.35, h * 0.87, w * 0.52, h)
      ..lineTo(w * 0.27, h)
      ..cubicTo(w * 0.29, h * 0.86, w * 0.45, h * 0.77, w * 0.35, h * 0.64)
      ..close();
    canvas.drawPath(lane, Paint()..color = _tone(const Color(0xFF84877A)));
    canvas.drawPath(
      water,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.64), Offset(0, h), [
          Color.lerp(p.water, p.haze, 0.30)!,
          Color.lerp(p.water, p.land, 0.18)!,
        ]),
    );
    final bund = Path()
      ..moveTo(w * 0.54, h * 0.77)
      ..quadraticBezierTo(w * 0.71, h * 0.80, w, h * 0.87);
    canvas.drawPath(
      bund,
      Paint()
        ..color = p.darkLand
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 5,
    );
    final rice = Path();
    for (int row = 0; row < 9; row++) {
      final y = h * (0.68 + 0.041 * row);
      final step = scale * (7 + row * 1.15);
      for (double x = w * 0.43 + rng.nextDouble() * step; x < w; x += step) {
        final foot = Offset(x, y + (x / w - 0.45) * h * 0.14);
        if (!water.contains(foot)) continue;
        final leaf = scale * (2.6 + row * 0.61);
        rice
          ..moveTo(foot.dx - leaf * 0.36, foot.dy - leaf * 0.7)
          ..lineTo(foot.dx, foot.dy)
          ..lineTo(foot.dx + leaf * 0.25, foot.dy - leaf);
      }
    }
    canvas.drawPath(
      rice,
      Paint()
        ..color = p.tree
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(0.8, scale * 0.85),
    );
    final wall = Path()
      ..moveTo(0, h * 0.52)
      ..quadraticBezierTo(w * 0.21, h * 0.56, w * 0.35, h * 0.66)
      ..quadraticBezierTo(w * 0.42, h * 0.79, w * 0.27, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wall, Paint()..color = _tone(const Color(0xFF535950)));
    canvas.save();
    canvas.clipPath(wall);
    for (int row = 0; row < (h * 0.5 / (scale * 13)).ceil(); row++) {
      final step = 24 * scale;
      for (double x = -step; x < w * 0.42; x += step) {
        final cx = x + step * (row.isEven ? 0.28 : 0.72);
        final y = h * (0.52 + 0.32 * cx / w) + row * scale * 13;
        final stone = _stone(
          Offset(cx, y),
          step * 0.49,
          scale * 5.9,
          rng,
          angular: true,
        );
        canvas.drawPath(
          stone,
          Paint()
            ..color = Color.lerp(
              _tone(const Color(0xFF646B61)),
              p.haze,
              rng.nextDouble() * 0.28,
            )!,
        );
      }
    }
    canvas.restore();
    final lip = Path()
      ..moveTo(0, h * 0.52)
      ..quadraticBezierTo(w * 0.21, h * 0.56, w * 0.35, h * 0.66);
    canvas.drawPath(
      lip,
      Paint()
        ..color = p.land
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * scale,
    );
  }

  Path _nearRiceWater(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(0, h * 0.76)
      ..quadraticBezierTo(w * 0.30, h * 0.77, w * 0.63, h * 0.88)
      ..lineTo(w * 0.70, h)
      ..lineTo(0, h)
      ..close();
  }

  void _nearRice(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    final paddy = _nearRiceWater(size);
    canvas.drawPath(paddy, Paint()..color = Color.lerp(p.water, p.land, 0.42)!);
    canvas.save();
    canvas.clipPath(paddy);
    final stems = Path(), light = Path();
    for (int row = 0; row < 5; row++) {
      final length = (7 + row * 3) * scale;
      final spacing = length * 0.86;
      for (double x = rng.nextDouble() * spacing; x < w * 0.7; x += spacing) {
        final y = h * (0.785 + row * 0.056 + 0.115 * x / w);
        final lean = (rng.nextDouble() - 0.3) * length * 0.5;
        stems
          ..moveTo(x - length * 0.3, y - length * 0.53)
          ..quadraticBezierTo(x - 1, y - length * 0.4, x, y)
          ..quadraticBezierTo(
            x + lean * 0.4,
            y - length * 0.6,
            x + lean,
            y - length,
          );
        light
          ..moveTo(x + lean, y - length)
          ..relativeLineTo(length * 0.10, -length * 0.14);
      }
    }
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      stems,
      pen
        ..color = p.tree
        ..strokeWidth = 1.45 * scale,
    );
    canvas.drawPath(
      light,
      pen
        ..color = p.accent
        ..strokeWidth = 2 * scale,
    );
    canvas.restore();
  }

  void _nearDaylilies(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    final verge = Path()
      ..moveTo(w * 0.40, h)
      ..quadraticBezierTo(w * 0.63, h * 0.82, w, h * 0.74)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(verge, Paint()..color = p.land);
    final stems = Path(), petals = Path(), hearts = Path();
    for (int i = 0; i < 92; i++) {
      final x = w * (0.41 + rng.nextDouble() * 0.61);
      final y = h * (0.765 + rng.nextDouble() * 0.25);
      if (!verge.contains(Offset(x, y))) continue;
      final len = (12 + rng.nextDouble() * 21) * scale;
      final bloom = Offset(x + len * 0.13, y - len);
      stems
        ..moveTo(x, y)
        ..quadraticBezierTo(x - len * 0.13, y - len * 0.62, bloom.dx, bloom.dy)
        ..moveTo(x, y)
        ..quadraticBezierTo(
          x + len * 0.22,
          y - len * 0.38,
          x + len * 0.54,
          y - len * 0.52,
        );
      final r = len * 0.16;
      for (int petal = 0; petal < 5; petal++) {
        final angle = pi * (1 + petal / 4);
        final tip = bloom.translate(cos(angle) * r * 1.6, sin(angle) * r);
        petals.addOval(
          Rect.fromCenter(center: tip, width: r * 1.28, height: r * 0.9),
        );
      }
      hearts.addOval(Rect.fromCircle(center: bloom, radius: r * 0.47));
    }
    canvas.drawPath(
      stems,
      Paint()
        ..color = p.tree
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35 * scale,
    );
    canvas.drawPath(petals, Paint()..color = _tone(const Color(0xFFDE9C48)));
    canvas.drawPath(hearts, Paint()..color = _tone(const Color(0xFFE7BC61)));
  }

  void _mangroveWalk(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    final mud = Path()
      ..moveTo(w, h * 0.72)
      ..quadraticBezierTo(w * 0.53, h * 0.82, w * 0.49, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(mud, Paint()..color = _tone(const Color(0xFF747666)));
    for (int i = 0; i < 11; i++) {
      final x = w * (0.67 + rng.nextDouble() * 0.34);
      final y = h * (0.80 + rng.nextDouble() * 0.18);
      final s = scale * (0.6 + 2.2 * (y / h - 0.72));
      final roots = Path();
      for (int j = -3; j <= 3; j++) {
        roots
          ..moveTo(x, y - s * 16)
          ..lineTo(x + j * s * 3.4, y + s * 3);
      }
      canvas.drawPath(
        roots,
        Paint()
          ..color = p.darkLand
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 1.5,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y - s * 24),
          width: s * 37,
          height: s * 25,
        ),
        Paint()..color = p.tree,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - s * 5, y - s * 28),
          width: s * 26,
          height: s * 14,
        ),
        Paint()..color = Color.lerp(p.tree, p.accent, 0.25)!,
      );
    }
    _footpath(
      canvas,
      size,
      p,
      Offset(w * 0.56, h * 0.71),
      Rect.fromLTRB(w * 0.18, h, w * 0.52, h),
      timber: true,
      railing: true,
    );
  }

  void _coralShelf(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale,
  ) {
    final w = size.width, h = size.height;
    final shelf = Path()
      ..moveTo(0, h * 0.75)
      ..quadraticBezierTo(w * 0.27, h * 0.76, w * 0.64, h * 0.91)
      ..lineTo(w * 0.79, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(shelf, Paint()..color = _tone(const Color(0xFF79786D)));
    canvas.save();
    canvas.clipPath(shelf);
    for (int i = 0; i < 57; i++) {
      final center = Offset(
        w * rng.nextDouble() * 0.78,
        h * (0.75 + rng.nextDouble() * 0.26),
      );
      final radius =
          scale * (6 + (center.dy / h - 0.72) * rng.nextDouble() * 110);
      final rock = _stone(center, radius, radius * 0.44, rng, angular: true);
      canvas.drawPath(
        rock,
        Paint()
          ..color = Color.lerp(
            _tone(const Color(0xFF535750)),
            p.haze,
            rng.nextDouble() * 0.29,
          )!,
      );
      if (i % 5 == 0) {
        final pool = _stone(
          center.translate(1, -radius * 0.09),
          radius * 0.78,
          radius * 0.24,
          rng,
          angular: true,
        );
        canvas.drawPath(
          pool,
          Paint()..color = Color.lerp(p.water, p.haze, 0.28)!,
        );
      }
    }
    canvas.restore();
  }

  void _gravelEdge(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    double scale, {
    required bool coast,
  }) {
    final w = size.width, h = size.height;
    final end = coast ? 0.76 : 0.49;
    final bank = Path()
      ..moveTo(0, h * (coast ? 0.67 : 0.78))
      ..quadraticBezierTo(w * 0.27, h * 0.81, w * end, h * 0.96)
      ..lineTo(w * (end + 0.04), h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      bank,
      Paint()
        ..color = Color.lerp(
          _tone(Color(coast ? 0xFF81847E : 0xFFA19B88)),
          p.haze,
          0.10,
        )!,
    );
    canvas.save();
    canvas.clipPath(bank);
    for (int i = 0; i < 150; i++) {
      final y = h * (0.68 + rng.nextDouble() * 0.33);
      final center = Offset(w * rng.nextDouble() * (end + 0.04), y);
      if (!bank.contains(center)) continue;
      final r = scale * (1.5 + 33 * (y / h - 0.65) * rng.nextDouble());
      final skin = Color.lerp(
        _tone(const Color(0xFF5B615C)),
        p.haze,
        0.13 + rng.nextDouble() * 0.49,
      )!;
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(1, r * 0.17),
          width: 2.1 * r,
          height: r * 0.9,
        ),
        Paint()..color = p.darkLand.withValues(alpha: 0.4),
      );
      canvas.drawPath(_stone(center, r, r * 0.59, rng), Paint()..color = skin);
    }
    canvas.restore();
  }

  Path _stone(
    Offset center,
    double width,
    double height,
    Random rng, {
    bool angular = false,
  }) {
    final outline = <Offset>[
      for (int i = 0; i < 7; i++)
        center.translate(
          cos(i * 2 * pi / 7) * width * (0.78 + rng.nextDouble() * 0.22),
          sin(i * 2 * pi / 7) * height * (0.8 + rng.nextDouble() * 0.2),
        ),
    ];
    if (angular) return Path()..addPolygon(outline, true);
    final start = Offset.lerp(outline.last, outline.first, 0.5)!;
    final path = Path()..moveTo(start.dx, start.dy);
    for (int i = 0; i < outline.length; i++) {
      final current = outline[i];
      final mid = Offset.lerp(current, outline[(i + 1) % outline.length], 0.5)!;
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    return path..close();
  }

  void _waterMarks(
    Canvas canvas,
    Size size,
    _SceneryPalette p,
    Random rng,
    Path water, {
    required double xMax,
  }) {
    canvas.save();
    canvas.clipPath(water);
    final marks = Path();
    for (int i = 0; i < 75; i++) {
      final x = size.width * xMax * rng.nextDouble();
      final y = size.height * (0.71 + 0.29 * rng.nextDouble());
      marks
        ..moveTo(x, y)
        ..relativeLineTo(size.width * (0.005 + 0.025 * rng.nextDouble()), 0);
    }
    canvas.drawPath(
      marks,
      Paint()
        ..color = p.haze.withValues(alpha: isNight ? 0.12 : 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }
}

/// Level ground and water share the horizon; only their elevations differ.
class _ErshuiPerspective {
  const _ErshuiPerspective(this.size);

  final Size size;

  Offset at(double across, double forward, [double elevation = 0]) {
    const horizon = 0.345;
    final crossDepth = across * 0.026;
    final depth = 1 + forward + crossDepth;
    return Offset(
      size.width * (0.542 + crossDepth * 6.9 + forward * 0.088) / depth,
      size.height * (horizon + (0.548 - elevation) / depth),
    );
  }

  Path strip(
    double left,
    double right,
    double near,
    double far, [
    double elevation = 0,
  ]) => Path()
    ..addPolygon([
      at(left, near, elevation),
      at(right, near, elevation),
      at(right, far, elevation),
      at(left, far, elevation),
    ], true);
}
