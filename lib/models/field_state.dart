import 'rice_variety.dart';

enum GrowthStage { fallow, seedling, tillering, heading, ripening, harvested }

enum TaiwanRegion { north, south }

enum DayPhase { morning, afternoon, evening, night }

enum WeatherCondition { clear, cloudy, rainy, stormy }

class WeatherMetrics {
  final double precipitation; // mm/h
  final double windSpeed;     // m/s
  final int weatherCode;      // WMO code or equivalent

  const WeatherMetrics({
    this.precipitation = 0.0,
    this.windSpeed = 0.0,
    this.weatherCode = 0,
  });

  bool get isRaining => precipitation > 0.0 || _isRainCode(weatherCode);
  bool get isStormy => precipitation > 5.0 || _isStormCode(weatherCode);
  bool get isCloudy => condition == WeatherCondition.cloudy;
  
  // WMO Codes: 0=Clear, 1-3=Cloudy, 50-69=Drizzle/Rain, 80-82=Showers, 95-99=Thunderstorm
  bool _isRainCode(int code) => (code >= 50 && code <= 69) || (code >= 80 && code <= 82);
  bool _isStormCode(int code) => code >= 95;

  WeatherCondition get condition {
    if (isStormy) return WeatherCondition.stormy;
    if (isRaining) return WeatherCondition.rainy;
    if (weatherCode >= 1 && weatherCode <= 45) return WeatherCondition.cloudy;
    return WeatherCondition.clear;
  }
}

class FieldState {
  GrowthStage growthStage;
  WeatherMetrics weatherMetrics;
  RiceVariety? currentVariety;
  
  // Continuous lighting parameter (-90 to +90 degrees)
  double sunElevation;

  FieldState({
    this.growthStage = GrowthStage.fallow,
    this.weatherMetrics = const WeatherMetrics(),
    this.sunElevation = 45.0, // Default daytime
    this.currentVariety,
  });

  // Backward compatibility getters
  WeatherCondition get weatherCondition => weatherMetrics.condition;
  
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

  // Allow setting dayPeriod for developer controls
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

  // Allow setting weatherCondition for developer controls
  set weatherCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        weatherMetrics = const WeatherMetrics(weatherCode: 0, precipitation: 0);
        break;
      case WeatherCondition.cloudy:
        weatherMetrics = const WeatherMetrics(weatherCode: 3, precipitation: 0);
        break;
      case WeatherCondition.rainy:
        weatherMetrics = const WeatherMetrics(weatherCode: 61, precipitation: 2.0);
        break;
      case WeatherCondition.stormy:
        weatherMetrics = const WeatherMetrics(weatherCode: 95, precipitation: 10.0);
        break;
    }
  }
}
