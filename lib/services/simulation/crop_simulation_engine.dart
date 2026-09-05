import 'dart:math';
import '../../models/field_state.dart';
import '../../models/rice_variety.dart';
import '../../models/weather_metrics.dart';
import '../app_logger.dart';

/// The core biological simulation engine.
/// It integrates weather over time to calculate the plant's health,
/// biomass accumulation, and eventual death or growth stage progression.
class CropSimulationEngine {
  
  /// Calculates the new FieldState based on elapsed time and environmental factors.
  /// [currentState]: The state of the field prior to this tick.
  /// [weather]: The current weather metrics (assumed constant over this timeDelta for the sake of the tick).
  /// [variety]: The genetic traits of the planted rice.
  /// [timeDelta]: How much time has passed since the last calculation.
  static FieldState tickSimulation(
    FieldState currentState,
    WeatherMetrics weather,
    RiceVariety variety,
    Duration timeDelta,
  ) {
    if (currentState.isDead || currentState.growthStage == GrowthStage.fallow || currentState.growthStage == GrowthStage.harvested) {
      // No biological changes if dead or not growing
      return currentState;
    }

    // Convert time delta to hours for standard biological rates
    final hours = timeDelta.inSeconds / 3600.0;
    if (hours <= 0) return currentState;

    final genetics = variety.geneticTraits;
    
    // 1. Calculate Stresses
    double newWaterStress = currentState.waterStressLevel;
    double newTempStress = currentState.temperatureStressLevel;
    
    // Water stress from flooding
    if (weather.precipitationIntensity > genetics.maxFloodTolerance) {
      // Accumulate stress linearly based on how much it exceeds tolerance
      double excessRain = weather.precipitationIntensity - genetics.maxFloodTolerance;
      newWaterStress += (excessRain * 0.05) * hours;
    } else {
      // Recover slowly if rain is fine
      newWaterStress -= 0.1 * hours;
    }

    // Water stress from drought (extreme low humidity/rain)
    if (weather.precipitationIntensity == 0 && weather.humidity < 40.0) {
      // Accumulate drought stress
      double droughtFactor = (40.0 - weather.humidity) / genetics.droughtResistance;
      newWaterStress += droughtFactor * hours;
    }

    // Temperature stress
    if (weather.temperature < genetics.minOptimalTemp) {
      double cold = genetics.minOptimalTemp - weather.temperature;
      newTempStress += (cold * 0.02) * hours;
    } else if (weather.temperature > genetics.maxOptimalTemp) {
      double heat = weather.temperature - genetics.maxOptimalTemp;
      newTempStress += (heat * 0.02) * hours;
    } else {
      newTempStress -= 0.1 * hours; // Recover
    }

    // Clamp stresses
    newWaterStress = max(0.0, min(2.0, newWaterStress)); // > 1.0 is lethal
    newTempStress = max(0.0, min(2.0, newTempStress));
    
    // 2. Update Vitality
    double newVitality = currentState.vitality;
    
    if (newWaterStress > 1.0 || newTempStress > 1.0) {
      // Extreme stress drops vitality
      double totalLethalStress = max(0.0, newWaterStress - 1.0) + max(0.0, newTempStress - 1.0);
      newVitality -= totalLethalStress * 0.1 * hours;
    } else {
      // Recover vitality slowly in good conditions
      newVitality += 0.05 * hours;
    }
    
    newVitality = max(0.0, min(1.0, newVitality));

    // 3. Accumulate Biomass (Growth)
    double newBiomass = currentState.accumulatedBiomass;
    if (newVitality > 0.0) {
      // Growth is scaled by vitality and good temperature
      double tempEfficiency = 1.0;
      if (weather.temperature >= genetics.minOptimalTemp && weather.temperature <= genetics.maxOptimalTemp) {
        tempEfficiency = 1.2; // Optimal growth
      } else {
        tempEfficiency = 0.5; // Stunted growth
      }
      
      // Add biomass (Assuming 100.0 is fully mature, roughly taking ~2000 hours of good growth)
      double growthRate = 0.05; // Base growth per hour
      newBiomass += growthRate * tempEfficiency * newVitality * hours;
    }
    
    newBiomass = min(100.0, newBiomass);

    // 4. Determine Growth Stage
    GrowthStage newStage = currentState.growthStage;
    if (newVitality <= 0.0) {
      newStage = GrowthStage.dead;
      AppLogger.w('Crop has died due to environmental stress.');
    } else if (newBiomass < 10.0) {
      newStage = GrowthStage.seedling;
    } else if (newBiomass < 40.0) {
      newStage = GrowthStage.tillering;
    } else if (newBiomass < 70.0) {
      newStage = GrowthStage.heading;
    } else {
      newStage = GrowthStage.ripening;
    }

    currentState.waterStressLevel = newWaterStress;
    currentState.temperatureStressLevel = newTempStress;
    currentState.vitality = newVitality;
    currentState.accumulatedBiomass = newBiomass;
    currentState.growthStage = newStage;
    
    return currentState;
  }
}
