import 'rice_variety.dart';
import 'weather_metrics.dart';

enum GrowthStage { fallow, seedling, tillering, heading, ripening, harvested, dead }

enum TaiwanRegion { north, south }

enum DayPhase { morning, afternoon, evening, night }

enum WeatherCondition { clear, cloudy, rainy, stormy }

class FieldState {
  GrowthStage growthStage;
  WeatherMetrics weatherMetrics;
  RiceVariety? currentVariety;
  
  // Continuous lighting parameter (-90 to +90 degrees)
  double sunElevation;

  // New biological continuous metrics
  double vitality; // 0.0 to 1.0
  double accumulatedBiomass; // Represents overall growth (e.g., 0.0 to 100.0)
  double waterStressLevel; // 0.0 = perfect, > 1.0 = lethal
  double temperatureStressLevel; // 0.0 = perfect, > 1.0 = lethal

  FieldState({
    this.growthStage = GrowthStage.fallow,
    this.weatherMetrics = const WeatherMetrics(
      temperature: 25.0,
      humidity: 60.0,
      windSpeed: 0.0,
      windDirection: 0.0,
      cloudCoverPercentage: 10.0,
      precipitationIntensity: 0.0,
    ),
    this.sunElevation = 45.0, // Default daytime
    this.currentVariety,
    this.vitality = 1.0,
    this.accumulatedBiomass = 0.0,
    this.waterStressLevel = 0.0,
    this.temperatureStressLevel = 0.0,
  });

  bool get isDead => vitality <= 0.0 || growthStage == GrowthStage.dead;

  // Backward compatibility getters to bridge WeatherMetrics back to simple enums
  WeatherCondition get weatherCondition {
    if (weatherMetrics.precipitationIntensity > 5.0 || weatherMetrics.windSpeed > 15.0) {
      return WeatherCondition.stormy;
    } else if (weatherMetrics.precipitationIntensity > 0.0) {
      return WeatherCondition.rainy;
    } else if (weatherMetrics.cloudCoverPercentage > 45.0) {
      return WeatherCondition.cloudy;
    }
    return WeatherCondition.clear;
  }
  
  DayPhase get dayPeriod {
    if (sunElevation > 10.0) {
      return DayPhase.afternoon; // Broad daytime
    } else if (sunElevation > 0.0) {
      return DayPhase.morning; // Actually early morning or late afternoon
    } else if (sunElevation > -10.0) {
      return DayPhase.evening; // Twilight
    } else {
      return DayPhase.night;
    }
  }

  // Developer controls helper
  set dayPeriod(DayPhase phase) {
    switch (phase) {
      case DayPhase.morning:
        sunElevation = 5.0;
        break;
      case DayPhase.afternoon:
        sunElevation = 45.0;
        break;
      case DayPhase.evening:
        sunElevation = -5.0;
        break;
      case DayPhase.night:
        sunElevation = -45.0;
        break;
    }
  }
}
