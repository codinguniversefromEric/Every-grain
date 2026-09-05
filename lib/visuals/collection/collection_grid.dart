import 'package:flutter/material.dart';
import '../../models/rice_variety.dart';

class CollectionGrid extends StatelessWidget {
  final Set<String> unlockedIds;
  
  const CollectionGrid({super.key, required this.unlockedIds});

  @override
  Widget build(BuildContext context) {

    // Currently we have 4 varieties defined. Let's pad it to 9 slots for the 九宮格.
    // In a full app, we'd have 9 actual varieties defined.
    final allVarieties = [
      RiceVariety.tainan11,
      RiceVariety.kaohsiung139,
      RiceVariety.tainung71,
      RiceVariety.taikeng9,
      // For demonstration of the 9-grid, duplicating to show locked slots
      // In production, these would be 5 other real varieties.
      ...List.generate(5, (index) => RiceVariety(
        id: 'unknown_$index',
        name: '未知品種',
        description: '',
        funFact: '',
        visualTraits: RiceVariety.tainan11.visualTraits,
        geneticTraits: RiceVariety.tainan11.geneticTraits,
      )),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        if (index >= allVarieties.length) return const SizedBox();
        
        final variety = allVarieties[index];
        final isUnlocked = unlockedIds.contains(variety.id);

        return _buildGridCell(variety, isUnlocked);
      },
    );
  }

  Widget _buildGridCell(RiceVariety variety, bool isUnlocked) {
    if (isUnlocked) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: variety.visualTraits.stemColor, size: 32),
            const SizedBox(height: 8),
            Text(
              variety.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    } else {
      // Locked state: Frosted glass silhouette per GEMINI.md aesthetic rules
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
  }
}
