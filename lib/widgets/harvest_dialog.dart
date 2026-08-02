import 'package:flutter/material.dart';

class HarvestDialog extends StatelessWidget {
  final List<String> reflections;

  const HarvestDialog({super.key, required this.reflections});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rice_bowl, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              '一株秧苗，經過時間與人的陪伴，最後成為一碗飯。',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (reflections.isNotEmpty) ...[
              const Text('Your reflections during this season:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: reflections.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('"$r"', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                    )).toList(),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
