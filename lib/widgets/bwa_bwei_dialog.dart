import 'package:flutter/material.dart';
import 'dart:math';

import '../models/weather_metrics.dart';
import '../services/state_manager.dart';

class BwaBweiDialog extends StatefulWidget {
  final StateManager stateManager;

  const BwaBweiDialog({super.key, required this.stateManager});

  @override
  State<BwaBweiDialog> createState() => _BwaBweiDialogState();
}

class _BwaBweiDialogState extends State<BwaBweiDialog> with SingleTickerProviderStateMixin {
  bool _tossed = false;
  String _resultText = "";
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tossBwei() {
    if (_tossed) return;
    setState(() {
      _tossed = true;
    });
    
    _controller.forward().then((_) {
      // 50% Sheng Bwei (Holy), 30% Laughing, 20% Yin (Negative)
      final rand = Random().nextDouble();
      setState(() {
        if (rand < 0.5) {
          _resultText = "聖筊！\n\n土地公聽到了你的祈求。\n天氣已為您修正為晴天。";
          // Override weather to clear
          widget.stateManager.applyWeatherOverride(const WeatherMetrics(
            temperature: 28,
            humidity: 50,
            windSpeed: 2,
            windDirection: 0,
            cloudCoverPercentage: 10,
            precipitationIntensity: 0,
          ));
        } else if (rand < 0.8) {
          _resultText = "笑筊。\n\n土地公笑了笑，沒有答應。\n或許大自然有它的安排吧。";
        } else {
          _resultText = "陰筊。\n\n土地公認為現在這樣最好。\n請順應天意。";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EAD5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "田邊土地公廟",
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _tossed ? _resultText : "你帶著一炷香，走到田埂邊的土地公廟，祈求風調雨順。\n\n(點擊下方擲筊)",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (!_tossed || _resultText.isEmpty)
              GestureDetector(
                onTap: _tossBwei,
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 3.0).animate(_animation),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8D6E63),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "擲筊",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5D4037),
                  side: const BorderSide(color: Color(0xFF5D4037)),
                ),
                child: const Text("離開"),
              ),
          ],
        ),
      ),
    );
  }
}
