import re

with open("lib/widgets/widget_scenery_snapshot.dart", "r", encoding="utf-8") as f:
    content = f.read()

# We completely rewrite the file
new_content = """import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../models/weather_metrics.dart';
import '../visuals/living_sky.dart';
import '../visuals/biome_scenery_layer.dart';
import 'rice_plant.dart';

class WidgetScenerySnapshot extends StatelessWidget {
  final FieldState state;
  final bool hasUnreadJournal;

  const WidgetScenerySnapshot({
    super.key, 
    required this.state, 
    this.hasUnreadJournal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Provide a mocked sun elevation for snapshot
    final sunElevation = state.isDaytime ? 45.0 : -45.0;
    
    // Provide Directionality to avoid errors since this renders outside app tree
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 800,
        height: 800,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Sky
            LivingSkyBackground(
              sunElevation: sunElevation,
              weatherMetrics: WeatherMetrics(
                temperature: 25.0,
                humidity: 70.0,
                cloudCover: state.weatherCondition == WeatherCondition.clear ? 10.0 : 80.0,
                isRaining: state.weatherCondition == WeatherCondition.rainy || state.weatherCondition == WeatherCondition.stormy,
                isStormy: state.weatherCondition == WeatherCondition.stormy,
                isCloudy: state.weatherCondition == WeatherCondition.cloudy,
              ),
            ),
            
            // Mountains
            BiomeSceneryLayer(
              isDaytime: state.isDaytime,
              weatherCondition: state.weatherCondition,
            ),
            
            // Ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200, // Thick ground for 800x800
              child: Container(
                color: const Color(0xFF2E1C15), // Dark soil
              ),
            ),
            
            // Plant
            if (state.growthStage != GrowthStage.fallow)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 400,
                  child: RicePlantLayer(
                    growthStage: state.growthStage,
                    variety: state.variety,
                  ),
                ),
              ),
              
            // Notification indicator
            if (hasUnreadJournal)
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: const Text(
                    '● 阿公有信',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
"""

with open("lib/widgets/widget_scenery_snapshot.dart", "w", encoding="utf-8") as f:
    f.write(new_content)
