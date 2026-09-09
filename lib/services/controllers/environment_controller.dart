import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/field_state.dart';
import '../../models/weather_metrics.dart';
import '../agricultural_calendar.dart';
import '../solar_calculator.dart';
import '../variety_service.dart';
import '../weather_service.dart';
import 'progress_repository.dart';

class EnvironmentController {
  final VoidCallback notifyListeners;
  final WeatherService weatherService = WeatherService();

  TaiwanRegion region = TaiwanRegion.north;
  bool isInTaiwan = true;
  bool isTeleported = false;
  Position? lastPosition;
  int simulatedHour = DateTime.now().hour;

  EnvironmentController(this.notifyListeners);

  Future<void> initialize(FieldState state, ProgressRepository progressRepo) async {
    // 1. Initial Position (Fallback to Taipei)
    Position? position = await AgriculturalCalendar.getPosition();
    lastPosition = position;
    if (position != null) {
      isInTaiwan = position.latitude >= 21.0 && position.latitude <= 26.0 &&
          position.longitude >= 119.0 && position.longitude <= 122.0;
      region = AgriculturalCalendar.getRegionForPosition(position);
    } else {
      isInTaiwan = true;
      region = TaiwanRegion.north;
    }

    state.currentVariety = VarietyService.getVarietyForPosition(position);
    state.currentBiome = VarietyService.getBiomeForPosition(position);
    if (position != null) {
      state.sunElevation = SolarCalculator.getSunElevation(
          position.latitude, position.longitude, DateTime.now());
    } else {
      state.sunElevation = 45.0; // fallback daytime
    }
    
    // 2. Initial Weather
    if (progressRepo.weatherOverrideUntil != null) {
      // Keep existing override
    } else {
      state.weatherMetrics = await weatherService.getCurrentWeather(position);
    }
  }

  Future<void> teleportTo(double lat, double lon, FieldState state) async {
    isTeleported = true;
    final mockPos = Position(
      latitude: lat, longitude: lon, timestamp: DateTime.now(),
      accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0,
      speedAccuracy: 0.0, altitudeAccuracy: 0.0, headingAccuracy: 0.0,
    );

    isInTaiwan = lat >= 21.0 && lat <= 26.0 && lon >= 119.0 && lon <= 122.0;
    region = AgriculturalCalendar.getRegionForPosition(mockPos);
    
    final metrics = await weatherService.getCurrentWeather(mockPos, forceRefresh: true);
    state.weatherMetrics = metrics;
    state.currentVariety = VarietyService.getVarietyForPosition(mockPos);
    state.currentBiome = VarietyService.getBiomeForPosition(mockPos);
    state.sunElevation = SolarCalculator.getSunElevation(lat, lon, DateTime.now());
    lastPosition = mockPos;
  }

  Future<void> resetTeleport(FieldState state) async {
    isTeleported = false;
    Position? position = await AgriculturalCalendar.getPosition();
    lastPosition = position;
    if (position != null) {
      isInTaiwan = position.latitude >= 21.0 && position.latitude <= 26.0 &&
          position.longitude >= 119.0 && position.longitude <= 122.0;
      region = AgriculturalCalendar.getRegionForPosition(position);
      final metrics = await weatherService.getCurrentWeather(position, forceRefresh: true);
      state.weatherMetrics = metrics;
      state.currentVariety = VarietyService.getVarietyForPosition(position);
      state.currentBiome = VarietyService.getBiomeForPosition(position);
      state.sunElevation = SolarCalculator.getSunElevation(position.latitude, position.longitude, DateTime.now());
    }
  }

  void updateDayPhase(DayPhase phase, FieldState state) {
    state.dayPeriod = phase;
  }

  void updateHour(int hour, FieldState state) {
    simulatedHour = hour;
    state.sunElevation = hour > 6 && hour < 18 ? 45.0 : -45.0; 
    if (hour == 17 || hour == 18) state.sunElevation = 0.0;
    if (hour == 5 || hour == 6) state.sunElevation = 0.0;
  }

  void toggleRegion() {
    region = region == TaiwanRegion.north ? TaiwanRegion.south : TaiwanRegion.north;
  }

  Future<void> applyWeatherOverride(WeatherMetrics overridden, FieldState state, ProgressRepository progressRepo) async {
    final overrideUntil = DateTime.now().add(const Duration(hours: 3));
    state.weatherOverrideUntil = overrideUntil;
    state.overriddenMetrics = overridden;
    state.weatherMetrics = overridden;
    await progressRepo.setWeatherOverrideUntil(overrideUntil);
  }

  Future<void> clearWeatherOverride(FieldState state, ProgressRepository progressRepo) async {
    state.weatherOverrideUntil = null;
    state.overriddenMetrics = null;
    await progressRepo.setWeatherOverrideUntil(null);
    final metrics = await weatherService.getCurrentWeather(lastPosition, forceRefresh: true);
    if (state.overriddenMetrics == null) {
      state.weatherMetrics = metrics;
      notifyListeners();
    }
  }

  void updateWeather(WeatherCondition weather, FieldState state) {
    double rain = 0.0, wind = 0.0, cloud = 0.0;
    switch (weather) {
      case WeatherCondition.clear: cloud = 10.0; break;
      case WeatherCondition.cloudy: cloud = 60.0; break;
      case WeatherCondition.rainy: rain = 2.0; cloud = 80.0; break;
      case WeatherCondition.stormy: rain = 10.0; wind = 20.0; cloud = 100.0; break;
    }
    final old = state.weatherMetrics;
    state.weatherMetrics = WeatherMetrics(
      temperature: old.temperature,
      humidity: old.humidity,
      windDirection: old.windDirection,
      windSpeed: wind > 0 ? wind : old.windSpeed,
      cloudCoverPercentage: cloud,
      precipitationIntensity: rain,
    );
  }

  void updateWeatherMetrics(WeatherMetrics metrics, FieldState state) {
    state.weatherMetrics = metrics;
  }
}
