import 'rice_variety.dart';

enum GrowthStage { fallow, seedling, tillering, heading, ripening, harvested }

enum TaiwanRegion { north, south }

enum DayPhase { morning, afternoon, evening, night }

enum WeatherCondition { clear, cloudy, rainy, stormy }

class FieldState {
  GrowthStage growthStage;
  DayPhase dayPeriod;
  WeatherCondition weatherCondition;
  RiceVariety? currentVariety;

  FieldState({
    this.growthStage = GrowthStage.fallow,
    this.dayPeriod = DayPhase.morning,
    this.weatherCondition = WeatherCondition.clear,
    this.currentVariety,
  });
}
