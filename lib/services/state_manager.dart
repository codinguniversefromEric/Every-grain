import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/field_state.dart';
import 'agricultural_calendar.dart';
import 'ambient_sound.dart';
import 'weather_service.dart';
import 'variety_service.dart';

class StateManager extends ChangeNotifier {
  FieldState? _state;
  TaiwanRegion _region = TaiwanRegion.north;
  DateTime _simulatedDate = DateTime.now();
  int _simulatedHour = DateTime.now().hour;
  bool _isLoading = true;
  bool _isHarvesting = false;

  final AmbientSoundService _ambientSound = AmbientSoundService();

  FieldState? get state => _state;
  TaiwanRegion get region => _region;
  DateTime get simulatedDate => _simulatedDate;
  int get simulatedHour => _simulatedHour;
  bool get isLoading => _isLoading;
  bool get isHarvesting => _isHarvesting;
  AmbientSoundService get ambientSound => _ambientSound;

  StateManager();

  Future<void> initializeState() async {
    _isLoading = true;
    notifyListeners();

    final position = await AgriculturalCalendar.getPosition();
    _region = AgriculturalCalendar.getRegionForPosition(position);
    final weather = await WeatherService.getCurrentWeather(position);
    final variety = VarietyService.getVarietyForPosition(position);
    
    _state = FieldState(
      growthStage: AgriculturalCalendar.getStageForDate(_simulatedDate, _region),
      dayPeriod: _calculateDayPhase(_simulatedHour),
      weatherCondition: weather,
      currentVariety: variety,
    );
    _isLoading = false;
    notifyListeners();

    await _ambientSound.init();
    _updateAmbience();
  }

  void pauseApp() => _ambientSound.pause();
  void resumeApp() => _ambientSound.resume();
  
  @override
  void dispose() {
    _ambientSound.dispose();
    super.dispose();
  }

  DayPhase _calculateDayPhase(int hour) {
    if (hour >= 5 && hour < 12) return DayPhase.morning;
    if (hour >= 12 && hour < 17) return DayPhase.afternoon;
    if (hour >= 17 && hour < 20) return DayPhase.evening;
    return DayPhase.night;
  }

  void _updateAmbience() {
    if (_state != null) {
      _ambientSound.updateAmbience(_state!.dayPeriod, _state!.growthStage, weather: _state!.weatherCondition);
    }
  }

  Future<void> resetSeason() async {
    _isLoading = true;
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
      _simulatedDate = DateTime(_simulatedDate.year, _simulatedDate.month + 1, _simulatedDate.day);
      _state!.growthStage = AgriculturalCalendar.getStageForDate(_simulatedDate, _region);
      notifyListeners();
    }
  }

  void toggleRegion() {
    if (_state != null) {
      _region = _region == TaiwanRegion.north ? TaiwanRegion.south : TaiwanRegion.north;
      _state!.growthStage = AgriculturalCalendar.getStageForDate(_simulatedDate, _region);
      notifyListeners();
    }
  }

  void updateHour(int hour) {
    if (_state != null) {
      _simulatedHour = hour;
      _state!.dayPeriod = _calculateDayPhase(hour);
      _updateAmbience();
      notifyListeners();
    }
  }

  Future<void> teleportTo(double lat, double lon) async {
    if (_state == null) return;
    
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
    
    _region = AgriculturalCalendar.getRegionForPosition(mockPos);
    final weather = await WeatherService.getCurrentWeather(mockPos);
    final variety = VarietyService.getVarietyForPosition(mockPos);
    
    _state!.growthStage = AgriculturalCalendar.getStageForDate(_simulatedDate, _region);
    _state!.weatherCondition = weather;
    _state!.currentVariety = variety;
    
    _updateAmbience();
    notifyListeners();
  }
}
