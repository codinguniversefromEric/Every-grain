import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/rice_variety.dart';

class CollectionGrid extends StatelessWidget {
  final Set<String> unlockedIds;
  
  const CollectionGrid({super.key, required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    final allVarieties = RiceVariety.allVarieties;

    return Column(
      children: [
        const SizedBox(height: 32), // space for close button
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
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
            '學術數據授權 / 資料來源：\n農業部農業試驗所 (TARI) - 水稻品種資訊系統',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 10,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, color: widget.variety.visualTraits.stemColor, size: 36),
          const SizedBox(height: 12),
          Text(
            widget.variety.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackRow('日數', '${data.growthDays}天'),
          _buildBackRow('千粒重', '${data.thousandGrainWeight}g'),
          _buildBackRow('型態', data.grainType),
          _buildBackRow('稻熱病', data.blastResistance),
          _buildBackRow('親本', data.crossParents),
        ],
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
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
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
