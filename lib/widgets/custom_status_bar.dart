import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomStatusBar extends StatefulWidget {
  const CustomStatusBar({super.key});

  @override
  State<CustomStatusBar> createState() => _CustomStatusBarState();
}

class _CustomStatusBarState extends State<CustomStatusBar> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initBattery();
    
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    } catch (e) {
      // Handle battery reading error silently
    }

    // Listen for battery changes
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format time (e.g. 14:30)
    final timeString = '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
    
    // Format date (e.g. 8月2日)
    final dateString = '${_currentTime.month}月${_currentTime.day}日';

    // Warm, paper-like color for the rustic feel
    final rusticColor = const Color(0xFFFFF8E7).withValues(alpha: 0.9);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Date
            Text(
              dateString,
              style: GoogleFonts.zcoolKuaiLe(
                color: rusticColor,
                fontSize: 18,
                shadows: [const Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
            
            // Center: Time
            Text(
              timeString,
              style: GoogleFonts.caveat(
                color: rusticColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                shadows: [const Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
            
            // Right: Battery (體力 XX%)
            Text(
              '體力 $_batteryLevel%',
              style: GoogleFonts.zcoolKuaiLe(
                color: rusticColor,
                fontSize: 18,
                shadows: [const Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
