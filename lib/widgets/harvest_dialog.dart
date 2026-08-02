import 'package:flutter/material.dart';

class HarvestDialog extends StatelessWidget {
  final List<String> reflections;
  final VoidCallback onRestart;

  const HarvestDialog({super.key, required this.reflections, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2214), // Dark earthy brown
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Golden border
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rice_bowl, size: 60, color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                const Text(
                  '一株秧苗，經過時間與人的陪伴\n最後成為一碗飯。',
                  style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (reflections.isNotEmpty) ...[
                  const Text('— 你的秋收回顧 —', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: reflections.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            r, 
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text('這季沒有留下隻字片語，\n但也是一種平靜。', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRestart();
                  },
                  child: const Text('重新播種 (Start New Season)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
