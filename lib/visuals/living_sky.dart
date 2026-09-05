import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../models/weather_metrics.dart';
import '../theme/app_colors.dart';

class LivingSkyBackground extends StatefulWidget {
  final double sunElevation;
  final WeatherMetrics weatherMetrics;

  const LivingSkyBackground({
    super.key,
    required this.sunElevation,
    required this.weatherMetrics,
  });

  @override
  State<LivingSkyBackground> createState() => _LivingSkyBackgroundState();
}

class _LivingSkyBackgroundState extends State<LivingSkyBackground>
    with SingleTickerProviderStateMixin {
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

  Color _getInterpolatedColor(double elevation, WeatherMetrics metrics, bool isTop) {
    // If it's cloudy or raining, bypass sunset colors
    bool isCloudy = metrics.isCloudy || metrics.isRaining || metrics.isStormy;

    if (isCloudy) {
      // Cloudy gradient
      final dayColor = isTop ? Colors.blueGrey.shade400 : Colors.blueGrey.shade200;
      final nightColor = isTop ? const Color(0xFF101820) : Colors.blueGrey.shade800;
      
      // Normalize elevation: -20 to +20
      final t = ((elevation + 20) / 40).clamp(0.0, 1.0);
      return Color.lerp(nightColor, dayColor, t)!;
    } else {
      // Clear gradient with sunset
      if (elevation > 20) {
        return isTop ? AppColors.skyTopAfternoon : AppColors.skyBottomAfternoon;
      } else if (elevation > 0) {
        final t = elevation / 20.0;
        final sunsetTop = AppColors.skyTopEvening;
        final sunsetBottom = AppColors.skyBottomEvening;
        final dayTop = AppColors.skyTopAfternoon;
        final dayBottom = AppColors.skyBottomAfternoon;
        return Color.lerp(isTop ? sunsetTop : sunsetBottom, isTop ? dayTop : dayBottom, t)!;
      } else if (elevation > -20) {
        final t = (elevation + 20) / 20.0;
        final nightTop = AppColors.skyTopNight;
        final nightBottom = AppColors.skyBottomNight;
        final sunsetTop = AppColors.skyTopEvening;
        final sunsetBottom = AppColors.skyBottomEvening;
        return Color.lerp(isTop ? nightTop : nightBottom, isTop ? sunsetTop : sunsetBottom, t)!;
      } else {
        return isTop ? AppColors.skyTopNight : AppColors.skyBottomNight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        // The mid-stop breathes up and down
        final breathAmount = 0.3 + _breathController.value * 0.2;
        
        final topColor = _getInterpolatedColor(widget.sunElevation, widget.weatherMetrics, true);
        final bottomColor = _getInterpolatedColor(widget.sunElevation, widget.weatherMetrics, false);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                topColor,
                Color.lerp(topColor, bottomColor, breathAmount)!,
                bottomColor,
              ],
              stops: [0.0, 0.5 + _breathController.value * 0.1, 1.0],
            ),
          ),
        );
      },
    );
  }
}
