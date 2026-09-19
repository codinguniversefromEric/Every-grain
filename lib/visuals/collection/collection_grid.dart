import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/rice_variety.dart';
import '../../utils/variety_l10n_extension.dart';

class CollectionGrid extends StatelessWidget {
  final Set<String> unlockedIds;

  const CollectionGrid({
    super.key,
    required this.unlockedIds,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final allVarieties = RiceVariety.allVarieties;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isTablet = width >= 600;
        final bool isSmallPhone = width < 360;

        final int crossAxisCount = isTablet ? 3 : 2;

        final double horizontalPadding = isTablet
            ? 32.0
            : isSmallPhone
                ? 16.0
                : 20.0;

        final double spacing = isTablet
            ? 20.0
            : isSmallPhone
                ? 12.0
                : 16.0;

        return Column(
          children: [
            const SizedBox(height: 8),

            // ============================================================
            // Collection Grid
            // ============================================================

            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  20,
                ),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,

                  // 使用固定高度。
                  //
                  // 對於這種「書卡」設計，比 childAspectRatio
                  // 更容易控制中文、英文、日文的內容高度。
                  mainAxisExtent: isTablet
                      ? 230
                      : isSmallPhone
                          ? 205
                          : 220,
                ),
                itemCount: allVarieties.length,
                itemBuilder: (context, index) {
                  final variety = allVarieties[index];

                  return _CollectionCard(
                    variety: variety,
                    isUnlocked:
                        unlockedIds.contains(variety.id),
                  );
                },
              ),
            ),

            // ============================================================
            // Collection Hint
            // ============================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: _OldPaperNotice(
                child: Text(
                  loc.collectionHintText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF5D4037)
                        .withValues(alpha: 0.75),
                    fontSize: isSmallPhone ? 11 : 12,
                    height: 1.45,
                  ),
                ),
              ),
            ),

            // ============================================================
            // Academic Attribution
            // ============================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                9,
                16,
                12,
              ),
              child: Text(
                loc.collectionSourceText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF3E2723)
                      .withValues(alpha: 0.45),
                  fontSize: isSmallPhone ? 10 : 11,
                  letterSpacing:
                      isSmallPhone ? 0.4 : 0.7,
                  height: 1.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// Old Paper Notice
// ============================================================================

class _OldPaperNotice extends StatelessWidget {
  final Widget child;

  const _OldPaperNotice({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7D8B8)
            .withValues(alpha: 0.65),
        border: Border.all(
          color: const Color(0xFF7A6045)
              .withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

// ============================================================================
// Collection Card
// ============================================================================

class _CollectionCard extends StatefulWidget {
  final RiceVariety variety;
  final bool isUnlocked;

  const _CollectionCard({
    required this.variety,
    required this.isUnlocked,
  });

  @override
  State<_CollectionCard> createState() =>
      _CollectionCardState();
}

class _CollectionCardState
    extends State<_CollectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 520,
      ),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!widget.isUnlocked) return;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUnlocked) {
      return _buildLockedCard();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBackVisible =
              angle > pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isBackVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..rotateY(pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // Locked
  // ==========================================================================

  Widget _buildLockedCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF6B6256)
            .withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF5D4037)
              .withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037)
                    .withValues(alpha: 0.10),
                border: Border.all(
                  color: const Color(0xFF5D4037)
                      .withValues(alpha: 0.16),
                ),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 19,
                color: const Color(0xFF5D4037)
                    .withValues(alpha: 0.22),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '—',
              style: TextStyle(
                color: const Color(0xFF5D4037)
                    .withValues(alpha: 0.22),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Front — Old Botanical Book
  // ==========================================================================

  Widget _buildFront() {
    final loc =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1E5C9),
        borderRadius:
            BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.20),
            blurRadius: 7,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _OldPaperBorderPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            10,
          ),
          child: Column(
            children: [
              // ----------------------------------------------------------
              // Header
              // ----------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFF8B7355)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 7,
                    ),
                    child: Text(
                      'RICE VARIETY',
                      style:
                          TextStyle(
                        color:
                            const Color(
                          0xFF6D5540,
                        ),
                        fontSize: 7.5,
                        letterSpacing: 1.4,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFF8B7355)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // ----------------------------------------------------------
              // Illustration
              // ----------------------------------------------------------

              Expanded(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 3,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter:
                            _SingleStalkPainter(
                          widget
                              .variety
                              .visualTraits,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // ----------------------------------------------------------
              // Variety Name
              // ----------------------------------------------------------

              SizedBox(
                height: 38,
                child: Center(
                  child: Text(
                    widget.variety
                        .localizedName(loc),
                    textAlign:
                        TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF4E392C),
                      fontSize: 15,
                      height: 1.15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // ----------------------------------------------------------
              // Footer
              // ----------------------------------------------------------

              Text(
                'FIELD RECORD',
                style: TextStyle(
                  color: const Color(
                    0xFF6D5540,
                  ).withValues(alpha: 0.55),
                  fontSize: 6.5,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Back — Old Agricultural Record
  // ==========================================================================

  Widget _buildBack() {
    final loc =
        AppLocalizations.of(context)!;
    final data =
        widget.variety.tariData;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF403229),
        borderRadius:
            BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.35),
            blurRadius: 7,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _OldBookBackPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            11,
            12,
            11,
          ),
          child: Center(
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      // --------------------------------------------------
                      // Book heading
                      // --------------------------------------------------

                      Text(
                        widget.variety
                            .localizedName(loc),
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFFD4AF37),
                          fontSize: 16,
                          height: 1.15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Container(
                        height: 1,
                        color:
                            const Color(
                          0xFFD4AF37,
                        ).withValues(
                          alpha: 0.45,
                        ),
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      // --------------------------------------------------
                      // Data
                      // --------------------------------------------------

                      _buildBackRow(
                        loc.tariGrowthDays,
                        loc.growthDaysFormat(
                          data.growthDays,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      _buildBackRow(
                        loc.tariWeight,
                        '${data.thousandGrainWeight}g',
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      _buildBackRow(
                        loc.tariType,
                        data.localizedGrainType(
                          loc,
                          widget.variety,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      _buildBackRow(
                        loc.tariBlast,
                        data.localizedBlast(
                          loc,
                          widget.variety,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      _buildBackRow(
                        loc.tariParents,
                        data.localizedParents(
                          loc,
                          widget.variety,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Container(
                        height: 1,
                        color:
                            const Color(
                          0xFFD4AF37,
                        ).withValues(
                          alpha: 0.30,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        'AGRICULTURAL RECORD',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              const Color(
                            0xFFD4AF37,
                          ).withValues(
                            alpha: 0.55,
                          ),
                          fontSize: 6.5,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Back Row
  // ==========================================================================

  Widget _buildBackRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            softWrap: true,
            style:
                const TextStyle(
              color:
                  Color(0xFFE2D7C4),
              fontSize: 10.5,
              height: 1.2,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            softWrap: true,
            style:
                const TextStyle(
              color:
                  Color(0xFFD4AF37),
              fontSize: 10.5,
              height: 1.2,
              fontWeight:
                  FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Old Paper Border
// ============================================================================

class _OldPaperBorderPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final outerPaint = Paint()
      ..color = const Color(0xFF8B7355)
          .withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerPaint = Paint()
      ..color = const Color(0xFF8B7355)
          .withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final outerRect =
        RRect.fromRectAndRadius(
      Offset.zero &
          size,
      const Radius.circular(5),
    );

    final innerRect =
        RRect.fromRectAndRadius(
      Rect.fromLTWH(
        4,
        4,
        size.width - 8,
        size.height - 8,
      ),
      const Radius.circular(3),
    );

    canvas.drawRRect(
      outerRect,
      outerPaint,
    );

    canvas.drawRRect(
      innerRect,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _OldPaperBorderPainter
        oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// Old Book Back Painter
// ============================================================================

class _OldBookBackPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFFD4AF37)
          .withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final rect =
        RRect.fromRectAndRadius(
      Rect.fromLTWH(
        4,
        4,
        size.width - 8,
        size.height - 8,
      ),
      const Radius.circular(3),
    );

    canvas.drawRRect(
      rect,
      linePaint,
    );

    // 裝飾性的上下小線，
    // 保持老書內頁的印刷感。
    final centerX = size.width / 2;

    canvas.drawLine(
      Offset(centerX - 25, 8),
      Offset(centerX - 7, 8),
      linePaint,
    );

    canvas.drawLine(
      Offset(centerX + 7, 8),
      Offset(centerX + 25, 8),
      linePaint,
    );

    canvas.drawLine(
      Offset(centerX - 25, size.height - 8),
      Offset(centerX - 7, size.height - 8),
      linePaint,
    );

    canvas.drawLine(
      Offset(centerX + 7, size.height - 8),
      Offset(centerX + 25, size.height - 8),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _OldBookBackPainter
        oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// Rice Stalk Painter
// ============================================================================

class _SingleStalkPainter
    extends CustomPainter {
  final VarietyVisualTraits traits;

  _SingleStalkPainter(this.traits);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final baseX =
        size.width * 0.5;
    final baseY =
        size.height * 0.9;

    final stalkHeight =
        size.height * 0.7;

    final stemColor =
        traits.stemColor;

    // ------------------------------------------------------------------------
    // Stem
    // ------------------------------------------------------------------------

    final stemPaint = Paint()
      ..color = stemColor
      ..strokeWidth = 2.6
      ..strokeCap =
          StrokeCap.round
      ..style =
          PaintingStyle.stroke;

    final stemPath = Path();

    stemPath.moveTo(
      baseX,
      baseY,
    );

    final tipX =
        baseX + size.width * 0.2;

    final tipY =
        baseY -
        stalkHeight +
        size.height * 0.2;

    stemPath.cubicTo(
      baseX,
      baseY -
          stalkHeight * 0.5,
      baseX +
          size.width * 0.3,
      baseY -
          stalkHeight * 0.8,
      tipX,
      tipY,
    );

    canvas.drawPath(
      stemPath,
      stemPaint,
    );

    // ------------------------------------------------------------------------
    // Leaves
    // ------------------------------------------------------------------------

    _drawLeaf(
      canvas,
      baseX + 2,
      baseY -
          stalkHeight * 0.3,
      true,
      stemColor,
    );

    _drawLeaf(
      canvas,
      baseX + 4,
      baseY -
          stalkHeight * 0.6,
      false,
      stemColor,
    );

    // ------------------------------------------------------------------------
    // Grains
    // ------------------------------------------------------------------------

    final grainPaint = Paint()
      ..color =
          traits.ripeGrainColor
      ..style =
          PaintingStyle.fill;

    const grainCount = 6;

    for (int i = 0;
        i < grainCount;
        i++) {
      final t =
          i / grainCount;

      final grainX =
          tipX +
          sin(t * pi) * 12 +
          (i.isEven ? 2 : -2);

      final grainY =
          tipY +
          t * 25 +
          (i.isEven ? 1 : -1);

      final radius =
          3.5 *
          traits.grainSize;

      canvas.save();

      canvas.translate(
        grainX,
        grainY,
      );

      canvas.rotate(
        0.2 + t * 0.5,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width:
              radius *
              traits.grainRoundness,
          height: radius,
        ),
        grainPaint,
      );

      canvas.restore();
    }
  }

  // --------------------------------------------------------------------------
  // Leaf
  // --------------------------------------------------------------------------

  void _drawLeaf(
    Canvas canvas,
    double x,
    double y,
    bool isLeft,
    Color color,
  ) {
    final leafPaint = Paint()
      ..color = color.withValues(
        alpha: 0.9,
      )
      ..strokeWidth = 2.2
      ..strokeCap =
          StrokeCap.round
      ..style =
          PaintingStyle.stroke;

    final dir =
        isLeft ? -1.0 : 1.0;

    final leafPath = Path();

    leafPath.moveTo(
      x,
      y,
    );

    leafPath.quadraticBezierTo(
      x + dir * 15,
      y - 10,
      x + dir * 25,
      y + 5,
    );

    canvas.drawPath(
      leafPath,
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _SingleStalkPainter
        oldDelegate,
  ) {
    return oldDelegate.traits !=
        traits;
  }
}
