import 'dart:math';
import 'package:flutter/material.dart';

Future<T?> showBookModal<T>(
  BuildContext context, {
  required String title,
  required Widget content,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _BookModalContent(
        title: title,
        content: content,
        animation: animation,
      );
    },
    barrierDismissible: true,
    barrierLabel: 'Close Book',
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 900),
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.88,
            end: 1.0,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _BookModalContent extends StatefulWidget {
  final String title;
  final Widget content;
  final Animation<double> animation;

  const _BookModalContent({
    required this.title,
    required this.content,
    required this.animation,
  });

  @override
  State<_BookModalContent> createState() => _BookModalContentState();
}

class _BookModalContentState extends State<_BookModalContent> {
  static const leatherDark = Color(0xFF2E211B);
  static const leather = Color(0xFF4A3025);
  static const leatherLight = Color(0xFF674638);

  static const paper = Color(0xFFE9DFC8);
  static const paperLight = Color(0xFFF2E9D6);
  static const ink = Color(0xFF3D2A20);
  static const fadedInk = Color(0xFF665246);
  static const oldGold = Color(0xFF9A7A42);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    final maxWidth = min(
      520.0,
      screen.width - 28,
    );

    final maxHeight = min(
      820.0,
      screen.height - 40,
    );

    return Center(
      child: SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            final openProgress = Interval(
              0.20,
              1.0,
              curve: Curves.easeInOutCubic,
            ).transform(widget.animation.value);

            final angle = openProgress * pi;

            final isCoverFront = angle <= pi / 2;

            return Padding(
              padding: const EdgeInsets.all(14),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==========================================================
                  // Book shadow
                  // ==========================================================

                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 8,
                          left: 4,
                          right: 2,
                          bottom: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 30,
                              spreadRadius: 4,
                              offset: const Offset(8, 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // Book interior
                  // ==========================================================

                  Positioned.fill(
                    child: _buildBookInterior(),
                  ),

                  // ==========================================================
                  // Front cover
                  // ==========================================================

                  Positioned.fill(
                    child: Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateY(angle),
                      child: isCoverFront
                          ? _buildCoverFront()
                          : _buildCoverBack(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // Book Interior
  // ==========================================================================

  Widget _buildBookInterior() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: paper,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(5, 8),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // ---------------------------------------------------------------
            // Paper background
            // ---------------------------------------------------------------

            Positioned.fill(
              child: CustomPaint(
                painter: _OldPaperPainter(),
              ),
            ),

            // ---------------------------------------------------------------
            // Inner border
            // ---------------------------------------------------------------

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: oldGold.withValues(alpha: 0.38),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // Content
            // ---------------------------------------------------------------

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.content,
                      ),

                      // Close button
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            tooltip: 'Close',
                            icon: const Icon(
                              Icons.close,
                              color: ink,
                              size: 21,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Front Cover
  // ==========================================================================

  Widget _buildCoverFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            leatherLight,
            leather,
            leatherDark,
          ],
        ),

        border: Border.all(
          color: const Color(0xFF211610),
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(7, 9),
          ),
        ],
      ),

      child: Stack(
        children: [
          // ================================================================
          // Leather grain
          // ================================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _LeatherTexturePainter(),
            ),
          ),

          // ================================================================
          // Double golden border
          // ================================================================

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: oldGold.withValues(alpha: 0.72),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: oldGold.withValues(alpha: 0.32),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // ================================================================
          // Cover content
          // ================================================================

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --------------------------------------------------------
                  // Old seal
                  // --------------------------------------------------------

                  _OldSeal(),

                  const SizedBox(height: 28),

                  // --------------------------------------------------------
                  // Title
                  // --------------------------------------------------------

                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: const TextStyle(
                      color: Color(0xFFD8BD82),
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: 3.0,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: 110,
                    height: 1,
                    color: oldGold.withValues(alpha: 0.65),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'FIELD RECORD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: oldGold.withValues(alpha: 0.68),
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================================================================
          // Aged corners
          // ================================================================

          Positioned(
            top: 10,
            left: 10,
            child: _CornerDecoration(),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: Transform.scale(
              scaleX: -1,
              child: _CornerDecoration(),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            child: Transform.scale(
              scaleY: -1,
              child: _CornerDecoration(),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 10,
            child: Transform.scale(
              scaleX: -1,
              scaleY: -1,
              child: _CornerDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Back of cover
  // ==========================================================================

  Widget _buildCoverBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),

          color: const Color(0xFF39271F),

          border: Border.all(
            color: const Color(0xFF211610),
            width: 2,
          ),
        ),

        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LeatherTexturePainter(
                  darker: true,
                ),
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: oldGold.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Old Seal
// ============================================================================

class _OldSeal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD1B16B).withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD1B16B).withValues(alpha: 0.35),
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.grass,
              size: 38,
              color: Color(0xFFD1B16B),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Corner decoration
// ============================================================================

class _CornerDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CornerPainter(),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFD1B16B).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    path.moveTo(2, size.height);
    path.lineTo(2, 7);
    path.quadraticBezierTo(
      2,
      2,
      7,
      2,
    );

    path.lineTo(
      size.width,
      2,
    );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// Old Paper
// ============================================================================

class _OldPaperPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // Base paper color
    final background = Paint()
      ..color = const Color(0xFFE9DFC8);

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    // Slightly darker edges
    final edgeGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        Colors.transparent,
        const Color(0xFF9A8060).withValues(alpha: 0.16),
      ],
    );

    final edgePaint = Paint()
      ..shader = edgeGradient.createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      edgePaint,
    );

    // Old paper stains
    final stainPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.035);

    final random = Random(17);

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final radius = 1 + random.nextDouble() * 3;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        stainPaint,
      );
    }

    // Faint horizontal paper fibers
    final fiberPaint = Paint()
      ..color = const Color(0xFF6D5945).withValues(alpha: 0.025)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 35; i++) {
      final y = random.nextDouble() * size.height;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + random.nextDouble() * 2),
        fiberPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// Leather Texture
// ============================================================================

class _LeatherTexturePainter extends CustomPainter {
  final bool darker;

  _LeatherTexturePainter({
    this.darker = false,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random = Random(42);

    final color = darker
        ? const Color(0xFF9A7258)
        : const Color(0xFFB48A68);

    final paint = Paint()
      ..color = color.withValues(alpha: 0.045)
      ..strokeWidth = 0.5;

    // Fine leather scratches
    for (int i = 0; i < 220; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final length = 2 + random.nextDouble() * 8;

      canvas.drawLine(
        Offset(x, y),
        Offset(
          x + length,
          y + (random.nextDouble() - 0.5) * 2,
        ),
        paint,
      );
    }

    // Larger faded patches
    final stainPaint = Paint()
      ..color = const Color(0xFF160C08).withValues(alpha: 0.035);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      canvas.drawCircle(
        Offset(x, y),
        8 + random.nextDouble() * 18,
        stainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
