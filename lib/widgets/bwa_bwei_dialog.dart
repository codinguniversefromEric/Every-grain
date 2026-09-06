import 'package:flutter/material.dart';
import 'dart:math';

import '../models/weather_metrics.dart';
import '../services/state_manager.dart';
import '../l10n/app_localizations.dart';

class BwaBweiDialog extends StatefulWidget {
  final StateManager stateManager;

  const BwaBweiDialog({super.key, required this.stateManager});

  @override
  State<BwaBweiDialog> createState() => _BwaBweiDialogState();
}

class _BwaBweiDialogState extends State<BwaBweiDialog> with SingleTickerProviderStateMixin {
  bool _tossed = false;
  String _resultText = "";
  late AppLocalizations loc;
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
          _resultText = loc.bwaResultHoly;
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
          _resultText = loc.bwaResultLaughing;
        } else {
          _resultText = loc.bwaResultNegative;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
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
            Text(
              loc.bwaTitle,
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _tossed ? _resultText : loc.bwaDesc,
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
                    child: Center(
                      child: Text(
                        loc.bwaButton,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
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
                child: Text(loc.bwaClose),
              ),
          ],
        ),
      ),
    );
  }
}
