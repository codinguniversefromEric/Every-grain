import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/field_state.dart';
import 'agricultural_calendar.dart';
import 'ambient_sound.dart';
import 'weather_service.dart';
import 'variety_service.dart';
import 'solar_calculator.dart';

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

  bool _hasReadFirstLetter = false;
  bool _hasCompletedPlanting = false;

  final AmbientSoundService _ambientSound = AmbientSoundService();

  FieldState? get state => _state;
  TaiwanRegion get region => _region;
  DateTime get simulatedDate => _simulatedDate;
  int get simulatedHour => _simulatedHour;
  bool get isLoading => _isLoading;
  bool get isHarvesting => _isHarvesting;
  bool get isInTaiwan => _isInTaiwan;
  bool get isTimeLapseMode => _isTimeLapseMode;
  AmbientSoundService get ambientSound => _ambientSound;

  bool get hasReadFirstLetter => _hasReadFirstLetter;
  bool get hasCompletedPlanting => _hasCompletedPlanting;

  bool get needsPlanting {
    if (_state == null) return false;
    return _state!.growthStage == GrowthStage.seedling && !_hasCompletedPlanting;
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

    Position? position = await AgriculturalCalendar.getPosition();
    _lastPosition = position;

    if (position != null) {
      _isInTaiwan =
          position.latitude >= 21.0 &&
          position.latitude <= 26.0 &&
          position.longitude >= 119.0 &&
          position.longitude <= 122.0;
    } else {
      _isInTaiwan = true; // default to CWA
    }

    _region = AgriculturalCalendar.getRegionForPosition(position);
    final weatherMetrics = await WeatherService.getCurrentWeather(position, forceRefresh: forceRefreshWeather);
    final variety = VarietyService.getVarietyForPosition(position);

    GrowthStage initialStage = AgriculturalCalendar.getStageForDate(
      _simulatedDate,
      _region,
    );

    if (initialStage == GrowthStage.fallow && _hasCompletedPlanting) {
      _hasCompletedPlanting = false;
      prefs.setBool('hasCompletedPlanting', false);
    }

    _state = FieldState(
      growthStage: initialStage,
      weatherMetrics: weatherMetrics,
      currentVariety: variety,
    );
    
    final pos = _lastPosition ?? Position(
        latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
    _state!.sunElevation = SolarCalculator.getSunElevation(pos.latitude, pos.longitude, DateTime.now());

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
    _simulationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_state != null) {
        final pos = _lastPosition ?? Position(
            latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
        
        _state!.sunElevation = SolarCalculator.getSunElevation(
          pos.latitude, 
          pos.longitude, 
          DateTime.now()
        );
        _updateAmbience();
        notifyListeners();
      }
    });
  }

  void toggleTimeLapse() {
    _isTimeLapseMode = !_isTimeLapseMode;
    if (_isTimeLapseMode) {
      _simulationTimer?.cancel();
      _timeLapseClock = DateTime.now();
      _timeLapseTimer?.cancel();
      _timeLapseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_state != null) {
          // Advance clock by 6 mins every 100ms (1 real sec = 1 virtual hour)
          _timeLapseClock = _timeLapseClock.add(const Duration(minutes: 6));
          final pos = _lastPosition ?? Position(
              latitude: 24.5602, longitude: 120.8214, timestamp: DateTime.now(),
              accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
          
          _state!.sunElevation = SolarCalculator.getSunElevation(
            pos.latitude, 
            pos.longitude, 
            _timeLapseClock
          );
          _updateAmbience();
          notifyListeners();
        }
      });
    } else {
      _timeLapseTimer?.cancel();
      _startSimulationTimer();
    }
    notifyListeners();
  }



  void _updateAmbience() {
    if (_state != null) {
      _ambientSound.updateAmbience(
        _state!.dayPeriod,
        _state!.growthStage,
        _state!.weatherMetrics,
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
    notifyListeners();
  }

  Future<void> resetSeason() async {
    _isLoading = true;
    _hasCompletedPlanting = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPlanting', false);
    
    if (_state != null) {
      _state!.growthStage = GrowthStage.fallow;
    }
    notifyListeners();
    await initializeState();
  }

  void executeHarvest(VoidCallback onHarvestComplete) async {
    if (_isHarvesting || _state == null) return;
    _isHarvesting = true;
    notifyListeners();

    _ambientSound.playHarvestSound();

    _state!.growthStage = GrowthStage.harvested;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    onHarvestComplete();
    _isHarvesting = false;
    notifyListeners();
  }

  // Developer Control Methods
  void updateGrowthStage(GrowthStage stage) {
    if (_state != null) {
      _state!.growthStage = stage;
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

  void updateWeather(WeatherCondition weather) {
    if (_state != null) {
      _state!.weatherCondition = weather;
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
      _state!.growthStage = AgriculturalCalendar.getStageForDate(
        _simulatedDate,
        _region,
      );
      notifyListeners();
    }
  }

  void toggleRegion() {
    if (_state != null) {
      _region = _region == TaiwanRegion.north
          ? TaiwanRegion.south
          : TaiwanRegion.north;
      _state!.growthStage = AgriculturalCalendar.getStageForDate(
        _simulatedDate,
        _region,
      );
      notifyListeners();
    }
  }

  void updateHour(int hour) {
    if (_state != null) {
      _simulatedHour = hour;
      // Using arbitrary logic for developer control hour overriding
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
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      _isInTaiwan = lat >= 21.0 && lat <= 26.0 && lon >= 119.0 && lon <= 122.0;

      _region = AgriculturalCalendar.getRegionForPosition(mockPos);
      final weatherMetrics = await WeatherService.getCurrentWeather(mockPos, forceRefresh: true);
      final variety = VarietyService.getVarietyForPosition(mockPos);

      _state!.growthStage = AgriculturalCalendar.getStageForDate(
        _simulatedDate,
        _region,
      );
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
