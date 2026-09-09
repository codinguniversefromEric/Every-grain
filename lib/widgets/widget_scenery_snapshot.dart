import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../models/weather_metrics.dart';
import '../visuals/living_sky.dart';
import '../visuals/scenery/biome_scenery_layer.dart';
import '../l10n/app_localizations.dart';
import 'rice_plant.dart';

class WidgetScenerySnapshot extends StatelessWidget {
  final FieldState state;
  final bool hasUnreadJournal;
  final AppLocalizations loc;

  const WidgetScenerySnapshot({
    super.key, 
    required this.state, 
    required this.loc,
    this.hasUnreadJournal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Provide a mocked sun elevation for snapshot
    final sunElevation = state.dayPeriod != DayPhase.night ? 45.0 : -45.0;
    
    // Provide Directionality to avoid errors since this renders outside app tree
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 400,
        height: 400,
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
                windSpeed: state.weatherCondition == WeatherCondition.stormy ? 20.0 : 5.0,
                windDirection: 0.0,
                cloudCoverPercentage: state.weatherCondition == WeatherCondition.clear ? 10.0 : 80.0,
                precipitationIntensity: (state.weatherCondition == WeatherCondition.rainy || state.weatherCondition == WeatherCondition.stormy) ? 10.0 : 0.0,
              ),
            ),
            
            // Mountains
            BiomeSceneryLayer(
              biome: state.currentBiome,
              dayPhase: state.dayPeriod,
            ),
            
            // Ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100, // Thick ground
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
                  height: 200,
                  child: RicePlantLayer(
                    growthStage: state.growthStage,
                    variety: state.currentVariety,
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
                  child: Text(
                    loc.grandpaHasLetterBadge,
                    style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
