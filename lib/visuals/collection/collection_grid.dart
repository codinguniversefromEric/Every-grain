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
        const SizedBox(height: 32), // space for close button
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75, // slightly taller for back text
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
        // Academic Attribution (Very Important)
        Padding(
          padding: const EdgeInsets.all(16.0),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, color: widget.variety.visualTraits.stemColor, size: 48),
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
      padding: const EdgeInsets.all(12.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackRow(loc.tariGrowthDays, loc.growthDaysFormat(data.growthDays)),
            _buildBackRow(loc.tariWeight, '${data.thousandGrainWeight}g'),
            _buildBackRow(loc.tariType, data.localizedGrainType(loc, widget.variety)),
            _buildBackRow(loc.tariBlast, data.localizedBlast(loc, widget.variety)),
            _buildBackRow(loc.tariParents, data.localizedParents(loc, widget.variety)),
          ],
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
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}