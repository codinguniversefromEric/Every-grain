import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/weather_metrics.dart';
import '../services/state_manager.dart';

enum BweiResult {
  holy,      // 聖筊：一凸一平
  laughing,  // 笑筊：兩平
  negative,  // 陰筊：兩凸
  standing,  // 立筊：一筊直立
}

class BwaBweiDialog extends StatefulWidget {
  final StateManager stateManager;

  const BwaBweiDialog({
    super.key,
    required this.stateManager,
  });

  @override
  State<BwaBweiDialog> createState() => _BwaBweiDialogState();
}

class _BwaBweiDialogState extends State<BwaBweiDialog>
    with SingleTickerProviderStateMixin {
  bool _tossing = false;
  bool _showResult = false;

  BweiResult? _result;
  String _resultText = '';

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================================================
  // Toss
  // ==========================================================================

  Future<void> _tossBwei() async {
    if (_tossing) return;

    setState(() {
      _tossing = true;
      _showResult = false;
      _result = null;
      _resultText = '';
    });

    _controller.reset();

    // 先讓筊杯拋起，再翻轉。
    await _controller.forward();

    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;
    final result = _randomResult();

    String resultText;

    switch (result) {
      case BweiResult.holy:
        resultText = loc.bwaResultHoly;

        // 聖筊才套用晴天天氣
        widget.stateManager.applyWeatherOverride(
          const WeatherMetrics(
            temperature: 28,
            humidity: 50,
            windSpeed: 2,
            windDirection: 0,
            cloudCoverPercentage: 10,
            precipitationIntensity: 0,
          ),
        );
        break;

      case BweiResult.laughing:
        resultText = loc.bwaResultLaughing;
        break;

      case BweiResult.negative:
        resultText = loc.bwaResultNegative;
        break;

      case BweiResult.standing:
        // 如果你目前 l10n 沒有 standing，
        // 可以暫時使用 bwaResultHoly。
        resultText = loc.bwaResultHoly;
        break;
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _resultText = resultText;
      _showResult = true;
      _tossing = false;
    });
  }

  // ==========================================================================
  // Result Probability
  // ==========================================================================

  BweiResult _randomResult() {
    final random = Random().nextDouble();

    // 遊戲機率，可自行調整。
    //
    // Holy      45%
    // Laughing  30%
    // Negative  23%
    // Standing   2%

    if (random < 0.45) {
      return BweiResult.holy;
    }

    if (random < 0.75) {
      return BweiResult.laughing;
    }

    if (random < 0.98) {
      return BweiResult.negative;
    }

    return BweiResult.standing;
  }

  // ==========================================================================
  // Build
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final size = MediaQuery.sizeOf(context);
    final isSmallPhone = size.width < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),

      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: size.height - 48,
        ),

        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),

          child: Container(
            width: double.infinity,

            padding: EdgeInsets.fromLTRB(
              isSmallPhone ? 18 : 24,
              24,
              isSmallPhone ? 18 : 24,
              20,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFF4EAD5),
              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.55),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============================================================
                // Title
                // ============================================================

                Text(
                  loc.bwaTitle,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: const Color(0xFF5D4037),
                    fontSize: isSmallPhone ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 18),

                // ============================================================
                // Description
                // ============================================================

                if (!_showResult)
                  Text(
                    loc.bwaDesc,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      color: const Color(0xFF3E2723),
                      fontSize: isSmallPhone ? 14 : 16,
                      height: 1.55,
                    ),
                  ),

                // ============================================================
                // Bwei
                // ============================================================

                const SizedBox(height: 18),

                _buildBweiScene(
                  isSmallPhone,
                ),

                const SizedBox(height: 18),

                // ============================================================
                // Result
                // ============================================================

                if (_showResult)
                  _buildResult(
                    isSmallPhone,
                  ),

                if (!_showResult)
                  const SizedBox(height: 4),

                const SizedBox(height: 18),

                // ============================================================
                // Action
                // ============================================================

                if (_showResult)
                  _buildCloseButton(loc)
                else
                  _buildTossButton(
                    loc,
                    isSmallPhone,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Bwei Scene
  // ==========================================================================

  Widget _buildBweiScene(
    bool isSmallPhone,
  ) {
    final sceneWidth = isSmallPhone ? 190.0 : 220.0;

    return SizedBox(
      width: sceneWidth,
      height: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(
            _controller.value,
          );

          if (!_tossing && _result == null) {
            return const Center(
              child: _BweiPair(
                leftAngle: 0,
                rightAngle: 0,
                leftFace: _BweiFace.flat,
                rightFace: _BweiFace.flat,
                standing: false,
              ),
            );
          }

          if (_tossing) {
            return _buildThrowingBwei(t);
          }

          return _buildFinalBwei();
        },
      ),
    );
  }

  // ==========================================================================
  // Throwing Animation
  // ==========================================================================

  Widget _buildThrowingBwei(
    double t,
  ) {
    // 拋起高度。
    final height = sin(t * pi) * 45;

    // 左右稍微錯開。
    final leftX = -22 + sin(t * pi * 1.2) * 10;
    final rightX = 22 - sin(t * pi * 1.1) * 10;

    // 翻轉很多圈。
    final leftAngle = t * pi * 5;
    final rightAngle = -t * pi * 5.4;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(leftX, -height),
          child: Transform.rotate(
            angle: sin(t * pi * 2) * 0.15,
            child: _BweiPiece3D(
              angleX: leftAngle,
              angleZ: 0.12,
              face: _BweiFace.flat,
            ),
          ),
        ),

        Transform.translate(
          offset: Offset(rightX, -height * 0.9),
          child: Transform.rotate(
            angle: sin(t * pi * 2 + 0.7) * -0.15,
            child: _BweiPiece3D(
              angleX: rightAngle,
              angleZ: -0.12,
              face: _BweiFace.convex,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Final Result
  // ==========================================================================

  Widget _buildFinalBwei() {
    final result = _result;

    if (result == null) {
      return const SizedBox.shrink();
    }

    switch (result) {
      case BweiResult.holy:
        return const _BweiPair(
          leftAngle: 0.0,
          rightAngle: pi,
          leftFace: _BweiFace.convex,
          rightFace: _BweiFace.flat,
          standing: false,
        );

      case BweiResult.laughing:
        return const _BweiPair(
          leftAngle: pi,
          rightAngle: pi,
          leftFace: _BweiFace.flat,
          rightFace: _BweiFace.flat,
          standing: false,
        );

      case BweiResult.negative:
        return const _BweiPair(
          leftAngle: 0.0,
          rightAngle: 0.0,
          leftFace: _BweiFace.convex,
          rightFace: _BweiFace.convex,
          standing: false,
        );

      case BweiResult.standing:
        return const _BweiPair(
          leftAngle: 0.0,
          rightAngle: 0.0,
          leftFace: _BweiFace.flat,
          rightFace: _BweiFace.convex,
          standing: true,
        );
    }
  }

  // ==========================================================================
  // Result Card
  // ==========================================================================

  Widget _buildResult(
    bool isSmallPhone,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 12 : 16,
        vertical: 15,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF3E2723).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
        ),
      ),

      child: Text(
        _resultText,
        textAlign: TextAlign.center,
        softWrap: true,

        style: TextStyle(
          color: const Color(0xFF3E2723),
          fontSize: isSmallPhone ? 15 : 17,
          height: 1.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==========================================================================
  // Toss Button
  // ==========================================================================

  Widget _buildTossButton(
    AppLocalizations loc,
    bool isSmallPhone,
  ) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: _tossing ? null : _tossBwei,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D6E63),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF8D6E63),
          disabledForegroundColor: Colors.white70,

          elevation: 2,

          minimumSize: const Size(
            double.infinity,
            48,
          ),

          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 16 : 24,
            vertical: 12,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
        ),

        child: Text(
          loc.bwaButton,
          textAlign: TextAlign.center,
          softWrap: true,

          style: TextStyle(
            fontSize: isSmallPhone ? 15 : 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Close Button
  // ==========================================================================

  Widget _buildCloseButton(
    AppLocalizations loc,
  ) {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },

        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF5D4037),

          side: const BorderSide(
            color: Color(0xFF5D4037),
          ),

          minimumSize: const Size(
            double.infinity,
            46,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        child: Text(
          loc.bwaClose,
          textAlign: TextAlign.center,
          softWrap: true,

          style: const TextStyle(
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// Bwei Face
// ==============================================================================

enum _BweiFace {
  flat,
  convex,
}

// ==============================================================================
// Pair
// ==============================================================================

class _BweiPair extends StatelessWidget {
  final double leftAngle;
  final double rightAngle;

  final _BweiFace leftFace;
  final _BweiFace rightFace;

  final bool standing;

  const _BweiPair({
    required this.leftAngle,
    required this.rightAngle,
    required this.leftFace,
    required this.rightFace,
    required this.standing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: standing
              ? const Offset(-25, 14)
              : const Offset(-25, 8),

          child: _BweiPiece3D(
            angleX: leftAngle,
            angleZ: standing ? 0 : -0.08,
            face: leftFace,
            standing: false,
          ),
        ),

        Transform.translate(
          offset: standing
              ? const Offset(28, -8)
              : const Offset(25, 5),

          child: _BweiPiece3D(
            angleX: rightAngle,
            angleZ: standing ? 0.08 : 0.08,
            face: rightFace,
            standing: standing,
          ),
        ),
      ],
    );
  }
}

// ==============================================================================
// 3D Bwei Piece
// ==============================================================================

class _BweiPiece3D extends StatelessWidget {
  final double angleX;
  final double angleZ;

  final _BweiFace face;
  final bool standing;

  const _BweiPiece3D({
    required this.angleX,
    required this.angleZ,
    required this.face,
    this.standing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (standing) {
      return Transform.rotate(
        angle: pi / 2,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(angleX)
            ..rotateZ(angleZ),
          child: CustomPaint(
            size: const Size(74, 48),
            painter: _BweiPainter(
              face: face,
            ),
          ),
        ),
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateX(angleX)
        ..rotateZ(angleZ),

      child: CustomPaint(
        size: const Size(74, 48),
        painter: _BweiPainter(
          face: face,
        ),
      ),
    );
  }
}

// ==============================================================================
// Bwei Painter
// ==============================================================================

class _BweiPainter extends CustomPainter {
  final _BweiFace face;

  const _BweiPainter({
    required this.face,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final path = Path();

    final left = 5.0;
    final right = size.width - 5.0;
    final top = 6.0;
    final bottom = size.height - 6.0;
    final centerY = size.height / 2;

    // --------------------------------------------------------------------------
    // 筊杯輪廓
    //
    // 一端較厚、另一端較薄，
    // 上下都是弧線，不是圓角矩形。
    // --------------------------------------------------------------------------

    path.moveTo(left + 8, top + 4);

    path.cubicTo(
      left + 20,
      top - 2,
      right - 20,
      top,
      right - 6,
      centerY - 5,
    );

    path.cubicTo(
      right - 2,
      centerY + 3,
      right - 10,
      bottom - 2,
      right - 20,
      bottom - 1,
    );

    path.cubicTo(
      left + 28,
      bottom + 2,
      left + 12,
      bottom - 1,
      left + 5,
      centerY + 5,
    );

    path.cubicTo(
      left + 1,
      centerY - 1,
      left + 2,
      top + 8,
      left + 8,
      top + 4,
    );

    path.close();

    // --------------------------------------------------------------------------
    // 紅色筊杯
    // --------------------------------------------------------------------------

    final baseColor = face == _BweiFace.convex
        ? const Color(0xFFA52A2A)
        : const Color(0xFFC43B32);

    final shadowColor = const Color(0xFF651717);

    final paint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // --------------------------------------------------------------------------
    // 陰影
    // --------------------------------------------------------------------------

    final shadowPath = Path();

    shadowPath.moveTo(
      left + 4,
      centerY,
    );

    shadowPath.cubicTo(
      left + 14,
      bottom - 2,
      right - 14,
      bottom + 1,
      right - 5,
      centerY + 1,
    );

    shadowPath.cubicTo(
      right - 15,
      bottom - 4,
      left + 15,
      bottom - 3,
      left + 4,
      centerY,
    );

    shadowPath.close();

    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, shadowPaint);

    // --------------------------------------------------------------------------
    // 凸面高光
    // --------------------------------------------------------------------------

    if (face == _BweiFace.convex) {
      final highlight = Paint()
        ..color = const Color(0xFFE46B5D).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final highlightPath = Path();

      highlightPath.moveTo(
        left + 14,
        centerY - 7,
      );

      highlightPath.quadraticBezierTo(
        centerY,
        top + 3,
        right - 17,
        centerY - 5,
      );

      canvas.drawPath(
        highlightPath,
        highlight,
      );
    }

    // --------------------------------------------------------------------------
    // 邊線
    // --------------------------------------------------------------------------

    final outline = Paint()
      ..color = const Color(0xFF571313)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(
      path,
      outline,
    );
  }

  @override
  bool shouldRepaint(
    covariant _BweiPainter oldDelegate,
  ) {
    return oldDelegate.face != face;
  }
}
