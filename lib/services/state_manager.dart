import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/field_state.dart';
import '../models/rice_variety.dart';
import '../models/weather_metrics.dart';
import 'agricultural_calendar.dart';
import 'ambient_sound.dart';
import 'weather_service.dart';
import 'variety_service.dart';
import 'solar_calculator.dart';
import 'simulation/crop_simulation_engine.dart';

class StateManager extends ChangeNotifier {
  FieldState? _state;
  TaiwanRegion _region = TaiwanRegion.north;
  DateTime _simulatedDate = DateTime.now();
  int _simulatedHour = DateTime.now().hour;
  bool _isLoading = true;
  bool _isHarvesting = false;
  bool _isInTaiwan = true;
  Position? _lastPosition;
  Timer? _simulationTimer;
  Timer? _timeLapseTimer;
  bool _isTimeLapseMode = false;
  DateTime _timeLapseClock = DateTime.now();
  DateTime _lastTickTime = DateTime.now();

  bool _hasReadFirstLetter = false;
  bool _hasCompletedPlanting = false;

  final AmbientSoundService _ambientSound = AmbientSoundService();
  final WeatherService _weatherService = WeatherService();

  // New storage for unlocked varieties (Phase 3)
  Set<String> _unlockedVarieties = {};

  FieldState? get state => _state;
  TaiwanRegion get region => _region;
  DateTime get simulatedDate => _simulatedDate;
  int get simulatedHour => _simulatedHour;
  bool get isLoading => _isLoading;
  bool get isHarvesting => _isHarvesting;
  bool get isInTaiwan => _isInTaiwan;
  bool get isTimeLapseMode => _isTimeLapseMode;
  AmbientSoundService get ambientSound => _ambientSound;
  WeatherService get weatherService => _weatherService;
  Set<String> get unlockedVarieties => _unlockedVarieties;

  bool get hasReadFirstLetter => _hasReadFirstLetter;
  bool get hasCompletedPlanting => _hasCompletedPlanting;

  bool get needsPlanting {
    if (_state == null) return false;
    
    // Check solar term rest period
    if (_state!.nextPlantingAllowedAt != null && 
        DateTime.now().isBefore(_state!.nextPlantingAllowedAt!)) {
      return false;
    }

    return _state!.growthStage == GrowthStage.fallow && !_hasCompletedPlanting;
  }

  bool get hasUnreadJournal {
    return !_hasReadFirstLetter || needsPlanting;
  }

  StateManager();

  Future<void> initializeState({bool forceRefreshWeather = false}) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _hasReadFirstLetter = prefs.getBool('hasReadFirstLetter') ?? false;
    _hasCompletedPlanting = prefs.getBool('hasCompletedPlanting') ?? false;
    
    List<String> savedVarieties = prefs.getStringList('unlockedVarieties') ?? [];
    _unlockedVarieties = savedVarieties.toSet();

    DateTime? savedPlantingRest;
    final nextPlantStr = prefs.getString('nextPlantingAllowedAt');
    if (nextPlantStr != null) {
      savedPlantingRest = DateTime.tryParse(nextPlantStr);
    }

    DateTime? savedOverrideUntil;
    final overrideStr = prefs.getString('weatherOverrideUntil');
    if (overrideStr != null) {
      savedOverrideUntil = DateTime.tryParse(overrideStr);
    }

    Position? position = await AgriculturalCalendar.getPosition();
    _lastPosition = position;

    if (position != null) {
      _isInTaiwan =
          position.latitude >= 21.0 &&
          position.latitude <= 26.0 &&
          position.longitude >= 119.0 &&
          position.longitude <= 122.0;
    } else {
      _isInTaiwan = true; 
    }

    _region = AgriculturalCalendar.getRegionForPosition(position);
    final weatherMetrics = await _weatherService.getCurrentWeather(position, forceRefresh: forceRefreshWeather);
    final variety = VarietyService.getVarietyForPosition(position);

    _state = FieldState(
      growthStage: _hasCompletedPlanting ? GrowthStage.seedling : GrowthStage.fallow,
      weatherMetrics: weatherMetrics,
      currentVariety: variety,
    );
    _state!.nextPlantingAllowedAt = savedPlantingRest;
    
    // Resume weather override if still active
    if (savedOverrideUntil != null && DateTime.now().isBefore(savedOverrideUntil)) {
      _state!.weatherOverrideUntil = savedOverrideUntil;
      // We don't have the exact overriddenMetrics saved natively right now.
      // A full implementation would persist the exact JSON of WeatherMetrics.
      // For now, we mock a clear sky if override is active upon restart, or just clear the flag.
      _state!.overriddenMetrics = const WeatherMetrics(
        temperature: 28, humidity: 50, windSpeed: 2, windDirection: 0, cloudCoverPercentage: 10, precipitationIntensity: 0
      );
      _state!.weatherMetrics = _state!.overriddenMetrics!;
    }
    
    final pos = _lastPosition ?? Position(
        latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
    _state!.sunElevation = SolarCalculator.getSunElevation(pos.latitude, pos.longitude, DateTime.now());

    _lastTickTime = DateTime.now();
    _timeLapseClock = DateTime.now();
    _isLoading = false;
    notifyListeners();

    _startSimulationTimer();

    await _ambientSound.init();
    _updateAmbience();
  }

  void pauseApp() => _ambientSound.pause();
  void resumeApp() => _ambientSound.resume();

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _timeLapseTimer?.cancel();
    _ambientSound.dispose();
    super.dispose();
  }

  void _startSimulationTimer() {
    if (_isTimeLapseMode) return;
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_state != null && _state!.currentVariety != null) {
        final now = DateTime.now();
        final delta = now.difference(_lastTickTime);
        _lastTickTime = now;

        if (_state!.weatherOverrideUntil != null && now.isAfter(_state!.weatherOverrideUntil!)) {
          _state!.weatherOverrideUntil = null;
          _state!.overriddenMetrics = null;
          _weatherService.getCurrentWeather(_lastPosition, forceRefresh: true).then((metrics) {
            if (_state != null && _state!.overriddenMetrics == null) {
              _state!.weatherMetrics = metrics;
            }
          });
        }

        _state = CropSimulationEngine.tickSimulation(
          _state!,
          _state!.weatherMetrics,
          _state!.currentVariety!,
          delta, // real time delta
        );

        final pos = _lastPosition ?? Position(
            latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
        
        _state!.sunElevation = SolarCalculator.getSunElevation(pos.latitude, pos.longitude, now);
        _updateAmbience();
        notifyListeners();
      }
    });
  }

  void toggleTimeLapse() {
    _isTimeLapseMode = !_isTimeLapseMode;
    if (_isTimeLapseMode) {
      _simulationTimer?.cancel();
      _timeLapseTimer?.cancel();
      _lastTickTime = DateTime.now();
      _timeLapseClock = DateTime.now();
      
      _timeLapseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_state != null && _state!.currentVariety != null) {
          // Advance clock by 6 mins every 100ms
          final virtualDelta = const Duration(minutes: 6);
          _timeLapseClock = _timeLapseClock.add(virtualDelta);
          
          _state = CropSimulationEngine.tickSimulation(
            _state!,
            _state!.weatherMetrics,
            _state!.currentVariety!,
            virtualDelta, // send virtual delta to engine
          );

          final pos = _lastPosition ?? Position(
              latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
              accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
          
          _state!.sunElevation = SolarCalculator.getSunElevation(pos.latitude, pos.longitude, _timeLapseClock);
          _updateAmbience();
          notifyListeners();
        }
      });
    } else {
      _timeLapseTimer?.cancel();
      _lastTickTime = DateTime.now();
      _startSimulationTimer();
    }
    notifyListeners();
  }

  void _updateAmbience() {
    if (_state != null) {
      _ambientSound.updateAmbience(
        _state!.dayPeriod,
        _state!.growthStage,
        _state!.weatherMetrics, // Use the new WeatherMetrics
      );
    }
  }

  Future<void> markFirstLetterRead() async {
    _hasReadFirstLetter = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasReadFirstLetter', true);
    notifyListeners();
  }

  Future<void> completePlanting() async {
    _hasCompletedPlanting = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPlanting', true);
    if (_state != null) {
      _state!.growthStage = GrowthStage.seedling;
      _state!.vitality = 1.0;
      _state!.accumulatedBiomass = 5.0; // Initial start
    }
    notifyListeners();
  }

  Future<void> resetSeason() async {
    _isLoading = true;
    _hasCompletedPlanting = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPlanting', false);
    
    if (_state != null) {
      _state!.growthStage = GrowthStage.fallow;
      _state!.vitality = 100.0;
      _state!.accumulatedBiomass = 0.0;
      _state!.temperatureStressLevel = 0.0;
      _state!.waterStressLevel = 0.0;
      _state!.nextPlantingAllowedAt = null;
    }
    notifyListeners();
    await initializeState();
  }

  Future<void> plowDeadCrop() async {
    _hasCompletedPlanting = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPlanting', false);

    if (_state != null) {
      _state!.growthStage = GrowthStage.fallow;
      _state!.vitality = 100.0;
      _state!.accumulatedBiomass = 0.0;
      _state!.temperatureStressLevel = 0.0;
      _state!.waterStressLevel = 0.0;
      // Impose solar term restriction
      _state!.nextPlantingAllowedAt = AgriculturalCalendar.getNextSolarTermDate(DateTime.now());
      await prefs.setString('nextPlantingAllowedAt', _state!.nextPlantingAllowedAt!.toIso8601String());
    }
    notifyListeners();
  }

  Future<void> applyWeatherOverride(WeatherMetrics overridden) async {
    if (_state != null) {
      final overrideUntil = DateTime.now().add(const Duration(hours: 3));
      _state!.weatherOverrideUntil = overrideUntil;
      _state!.overriddenMetrics = overridden;
      _state!.weatherMetrics = overridden;
      _updateAmbience();
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weatherOverrideUntil', overrideUntil.toIso8601String());
    }
  }

  void executeHarvest(VoidCallback onHarvestComplete) async {
    if (_isHarvesting || _state == null) return;
    _isHarvesting = true;
    notifyListeners();

    _ambientSound.playHarvestSound();

    _state!.growthStage = GrowthStage.harvested;
    if (_state!.currentVariety != null) {
      _unlockVariety(_state!.currentVariety!.id);
    }
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    onHarvestComplete();
    _isHarvesting = false;
    notifyListeners();
  }
  
  Future<void> _unlockVariety(String varietyId) async {
    if (!_unlockedVarieties.contains(varietyId)) {
      _unlockedVarieties.add(varietyId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedVarieties', _unlockedVarieties.toList());
      notifyListeners();
    }
  }

  // Phase 3: Developer mock for collection
  Future<void> debugInjectUnlockedCards(List<RiceVariety> varieties) async {
    for (var v in varieties) {
      _unlockedVarieties.add(v.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlockedVarieties', _unlockedVarieties.toList());
    notifyListeners();
  }

  // Developer Control Methods
  void updateGrowthStage(GrowthStage stage) {
    if (_state != null) {
      _state!.growthStage = stage;
      // adjust biological markers
      if (stage == GrowthStage.seedling) _state!.accumulatedBiomass = 5.0;
      if (stage == GrowthStage.tillering) _state!.accumulatedBiomass = 30.0;
      if (stage == GrowthStage.heading) _state!.accumulatedBiomass = 60.0;
      if (stage == GrowthStage.ripening) _state!.accumulatedBiomass = 90.0;
      if (stage == GrowthStage.dead) _state!.vitality = 0.0;
      _updateAmbience();
      notifyListeners();
    }
  }

  void updateDayPhase(DayPhase phase) {
    if (_state != null) {
      _state!.dayPeriod = phase;
      _updateAmbience();
      notifyListeners();
    }
  }

  void updateWeatherMetrics(WeatherMetrics metrics) {
    if (_state != null) {
      _state!.weatherMetrics = metrics;
      _updateAmbience();
      notifyListeners();
    }
  }

  void updateWeather(WeatherCondition weather) {
    if (_state != null) {
      double rain = 0.0, wind = 0.0, cloud = 0.0;
      switch (weather) {
        case WeatherCondition.clear: cloud = 10.0; break;
        case WeatherCondition.cloudy: cloud = 60.0; break;
        case WeatherCondition.rainy: rain = 2.0; cloud = 80.0; break;
        case WeatherCondition.stormy: rain = 10.0; wind = 20.0; cloud = 100.0; break;
      }
      final old = _state!.weatherMetrics;
      _state!.weatherMetrics = WeatherMetrics(
        temperature: old.temperature,
        humidity: old.humidity,
        windDirection: old.windDirection,
        windSpeed: wind > 0 ? wind : old.windSpeed,
        cloudCoverPercentage: cloud,
        precipitationIntensity: rain,
      );
      _updateAmbience();
      notifyListeners();
    }
  }

  void simulateNextMonth() {
    if (_state != null) {
      _simulatedDate = DateTime(
        _simulatedDate.year,
        _simulatedDate.month + 1,
        _simulatedDate.day,
      );
      // Fast forward biomass heavily
      _state!.accumulatedBiomass += 20.0;
      if (_state!.accumulatedBiomass >= 100.0) _state!.accumulatedBiomass = 100.0;
      notifyListeners();
    }
  }

  void toggleRegion() {
    if (_state != null) {
      _region = _region == TaiwanRegion.north
          ? TaiwanRegion.south
          : TaiwanRegion.north;
      notifyListeners();
    }
  }

  void updateHour(int hour) {
    if (_state != null) {
      _simulatedHour = hour;
      _state!.sunElevation = hour > 6 && hour < 18 ? 45.0 : -45.0; 
      if (hour == 17 || hour == 18) _state!.sunElevation = 0.0;
      if (hour == 5 || hour == 6) _state!.sunElevation = 0.0;
      _updateAmbience();
      notifyListeners();
    }
  }

  Future<void> teleportTo(double lat, double lon) async {
    if (_state == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final mockPos = Position(
        latitude: lat, longitude: lon, timestamp: DateTime.now(),
        accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0,
        speedAccuracy: 0.0, altitudeAccuracy: 0.0, headingAccuracy: 0.0,
      );

      _isInTaiwan = lat >= 21.0 && lat <= 26.0 && lon >= 119.0 && lon <= 122.0;
      _region = AgriculturalCalendar.getRegionForPosition(mockPos);
      
      final weatherMetrics = await _weatherService.getCurrentWeather(mockPos, forceRefresh: true);
      final variety = VarietyService.getVarietyForPosition(mockPos);

      _state!.weatherMetrics = weatherMetrics;
      _state!.currentVariety = variety;
      _state!.sunElevation = SolarCalculator.getSunElevation(lat, lon, DateTime.now());
      _lastPosition = mockPos;

      _updateAmbience();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
