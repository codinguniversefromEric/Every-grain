import '../../utils/variety_l10n_extension.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/rice_variety.dart';
import '../../l10n/app_localizations.dart';

class CollectionGrid extends StatelessWidget {
  final Set<String> unlockedIds;
  
  const CollectionGrid({super.key, required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final allVarieties = RiceVariety.allVarieties;

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 24.0,
              childAspectRatio: 0.6, // Taller cards to give text more breathing room
            ),
            itemCount: allVarieties.length,
            itemBuilder: (context, index) {
              final variety = allVarieties[index];
              final isUnlocked = unlockedIds.contains(variety.id);
              return _CollectionCard(
                variety: variety,
                isUnlocked: isUnlocked,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              loc.collectionHintText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
        // Academic Attribution (Very Important)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            loc.collectionSourceText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final RiceVariety variety;
  final bool isUnlocked;

  const _CollectionCard({required this.variety, required this.isUnlocked});

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2), // Faint frosted look
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.eco,
            color: Colors.white.withValues(alpha: 0.15), // Faint silhouette
            size: 32,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBackVisible = angle > pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBackVisible
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EAD5), // Old paper color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 200,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _SingleStalkPainter(widget.variety.visualTraits),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.variety.localizedName(loc),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    final loc = AppLocalizations.of(context)!;
    final data = widget.variety.tariData;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723), // Dark wood/leather
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Gold border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // More outer padding
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 200, // Slightly wider before scaling down
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackRow(loc.tariGrowthDays, loc.growthDaysFormat(data.growthDays)),
            const SizedBox(height: 8),
            _buildBackRow(loc.tariWeight, '${data.thousandGrainWeight}g'),
            const SizedBox(height: 8),
            _buildBackRow(loc.tariType, data.localizedGrainType(loc, widget.variety)),
            const SizedBox(height: 8),
            _buildBackRow(loc.tariBlast, data.localizedBlast(loc, widget.variety)),
            const SizedBox(height: 8),
            _buildBackRow(loc.tariParents, data.localizedParents(loc, widget.variety)),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFD4AF37), // Gold text
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleStalkPainter extends CustomPainter {
  final VarietyVisualTraits traits;

  _SingleStalkPainter(this.traits);

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.9;
    final stalkHeight = size.height * 0.7;

    final stemColor = traits.stemColor;
    
    // 1. Draw stem
    final stemPaint = Paint()
      ..color = stemColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(baseX, baseY);
    
    // Curve slightly to the right, droop down
    final tipX = baseX + size.width * 0.2;
    final tipY = baseY - stalkHeight + size.height * 0.2;
    
    stemPath.cubicTo(
      baseX, baseY - stalkHeight * 0.5,
      baseX + size.width * 0.3, baseY - stalkHeight * 0.8,
      tipX, tipY
    );
    canvas.drawPath(stemPath, stemPaint);

    // 2. Draw a couple of leaves
    _drawLeaf(canvas, baseX + 2, baseY - stalkHeight * 0.3, true, stemColor);
    _drawLeaf(canvas, baseX + 4, baseY - stalkHeight * 0.6, false, stemColor);

    // 3. Draw grains
    final grainPaint = Paint()
      ..color = traits.ripeGrainColor
      ..style = PaintingStyle.fill;
      
    final grainCount = 6;
    for (int i = 0; i < grainCount; i++) {
      final t = i / grainCount;
      final grainX = tipX + sin(t * pi) * 12 + (i % 2 == 0 ? 2 : -2);
      final grainY = tipY + t * 25 + (i % 2 == 0 ? 1 : -1);
      
      final radius = 3.5 * traits.grainSize;
      
      canvas.save();
      canvas.translate(grainX, grainY);
      // rotate grain slightly
      canvas.rotate(0.2 + t * 0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * traits.grainRoundness,
          height: radius,
        ),
        grainPaint,
      );
      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, bool isLeft, Color color) {
    final leafPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dir = isLeft ? -1.0 : 1.0;
    final leafPath = Path();
    leafPath.moveTo(x, y);
    leafPath.quadraticBezierTo(
      x + dir * 15, y - 10,
      x + dir * 25, y + 5,
    );
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleStalkPainter oldDelegate) {
    return oldDelegate.traits != traits;
  }
}