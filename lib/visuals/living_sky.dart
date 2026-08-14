import 'package:flutter/material.dart';
import '../models/field_state.dart';

class LivingSkyBackground extends StatefulWidget {
  final Color topColor;
  final Color bottomColor;
  final WeatherCondition weather;
  const LivingSkyBackground({super.key, required this.topColor, required this.bottomColor, this.weather = WeatherCondition.clear});

  @override
  State<LivingSkyBackground> createState() => _LivingSkyBackgroundState();
}

class _LivingSkyBackgroundState extends State<LivingSkyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        // The mid-stop breathes up and down
        final breathAmount = 0.3 + _breathController.value * 0.2;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _adjustColorForWeather(widget.topColor, widget.weather),
                _adjustColorForWeather(Color.lerp(widget.topColor, widget.bottomColor, breathAmount)!, widget.weather),
                _adjustColorForWeather(widget.bottomColor, widget.weather),
              ],
              stops: [0.0, 0.5 + _breathController.value * 0.1, 1.0],
            ),
          ),
        );
      },
    );
  }

  Color _adjustColorForWeather(Color color, WeatherCondition weather) {
    if (weather == WeatherCondition.clear) return color;
    
    // Convert to HSL to desaturate and darken
    final hsl = HSLColor.fromColor(color);
    double lightness = hsl.lightness;
    double saturation = hsl.saturation;
    
    if (weather == WeatherCondition.cloudy) {
      lightness = (lightness * 0.8).clamp(0.0, 1.0);
      saturation = (saturation * 0.7).clamp(0.0, 1.0);
    } else if (weather == WeatherCondition.rainy) {
      lightness = (lightness * 0.6).clamp(0.0, 1.0);
      saturation = (saturation * 0.5).clamp(0.0, 1.0);
    } else if (weather == WeatherCondition.stormy) {
      lightness = (lightness * 0.4).clamp(0.0, 1.0);
      saturation = (saturation * 0.3).clamp(0.0, 1.0);
    }
    
    return hsl.withLightness(lightness).withSaturation(saturation).toColor();
  }
}

