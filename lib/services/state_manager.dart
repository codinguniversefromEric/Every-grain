import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/field_state.dart';
import '../models/rice_variety.dart';
import '../models/weather_metrics.dart';
import 'agricultural_calendar.dart';
import 'ambient_sound.dart';
import 'weather_service.dart';

import 'controllers/progress_repository.dart';
import 'controllers/audio_controller.dart';
import 'controllers/environment_controller.dart';
import 'controllers/crop_controller.dart';
import 'widget_service.dart';

class StateManager extends ChangeNotifier {
  FieldState? _state;
  bool _isLoading = true;

  late final ProgressRepository progress;
  late final AudioController audio;
  late final EnvironmentController env;
  late final CropController crop;

  StateManager() {
    progress = ProgressRepository();
    audio = AudioController();
    env = EnvironmentController(notifyListeners);
    crop = CropController(notifyListeners);
  }

  // Getters for UI compatibility
  FieldState? get state => _state;
  TaiwanRegion get region => env.region;
  DateTime get simulatedDate => crop.simulatedDate;
  int get simulatedHour => env.simulatedHour;
  bool get isLoading => _isLoading;
  bool get isHarvesting => crop.isHarvesting;
  bool get isInTaiwan => env.isInTaiwan;
  bool get isTeleported => env.isTeleported;
  bool get isTimeLapseMode => crop.isTimeLapseMode;
  AmbientSoundService get ambientSound => audio.service;
  WeatherService get weatherService => env.weatherService;
  Set<String> get unlockedVarieties => progress.unlockedVarieties;
  bool get hasReadFirstLetter => progress.hasReadFirstLetter;
  bool get hasCompletedPlanting => progress.hasCompletedPlanting;
  bool get needsPlanting {
    if (_state == null) return false;
    if (_state!.nextPlantingAllowedAt != null && DateTime.now().isBefore(_state!.nextPlantingAllowedAt!)) {
      return false;
    }
    return _state!.growthStage == GrowthStage.fallow && !hasCompletedPlanting;
  }
  bool get hasUnreadJournal => !hasReadFirstLetter || needsPlanting;


  Future<void> initializeState() async {
    _isLoading = true;
    notifyListeners();

    await progress.load();

    _state = FieldState(
      growthStage: progress.hasCompletedPlanting ? GrowthStage.seedling : GrowthStage.fallow,
      weatherMetrics: WeatherMetrics(
        temperature: 25.0, humidity: 80.0, windSpeed: 2.0, windDirection: 0.0,
        cloudCoverPercentage: 50.0, precipitationIntensity: 0.0,
      ),
      sunElevation: 45.0,
      currentVariety: null,
      currentBiome: SceneryBiome.plains,
      
    );

    await audio.service.init();
    await env.initialize(_state!, progress);
    audio.updateAmbience(_state!, crop.isTimeLapseMode);
    crop.startTimers(_state!, env, audio);

    _isLoading = false;
    notifyListeners();
  }

  void pauseApp() {
    crop.stopTimers();
    audio.pauseApp();
    WidgetService.updateWidget(_state, hasUnreadJournal: !hasReadFirstLetter);
  }

  void resumeApp() {
    crop.startTimers(_state!, env, audio);
    audio.resumeApp(_state, crop.isTimeLapseMode);
  }

  Future<void> markFirstLetterRead() async {
    await progress.setHasReadFirstLetter(true);
    notifyListeners();
  }

  Future<void> completePlanting() async {
    if (_state != null) {
      await crop.completePlanting(_state!, progress);
      notifyListeners();
    }
  }

  Future<void> resetSeason() async {
    if (_state != null) {
      await crop.resetSeason(_state!, progress);
      notifyListeners();
    }
  }

  Future<void> clearWeatherOverride() async {
    if (_state != null) {
      await env.clearWeatherOverride(_state!, progress);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  Future<void> applyWeatherOverride(WeatherMetrics overridden) async {
    if (_state != null) {
      await env.applyWeatherOverride(overridden, _state!, progress);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  void executeHarvest(VoidCallback onHarvestComplete) {
    if (_state != null) {
      crop.executeHarvest(_state!, audio, progress, onHarvestComplete);
    }
  }

  Future<void> teleportTo(double lat, double lon) async {
    if (_state == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await env.teleportTo(lat, lon, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetTeleport() async {
    if (_state == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await env.resetTeleport(_state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTimeLapse() {
    if (_state != null) {
      crop.toggleTimeLapse(_state!, env, audio);
      notifyListeners();
    }
  }

  Future<void> debugInjectUnlockedCards(List<RiceVariety> varieties) async {
    await progress.debugInjectUnlockedCards(varieties.map((v) => v.id).toList());
    notifyListeners();
  }

  void updateGrowthStage(GrowthStage stage) {
    if (_state != null) {
      crop.updateGrowthStage(stage, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  void updateDayPhase(DayPhase phase) {
    if (_state != null) {
      env.updateDayPhase(phase, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  void updateWeatherMetrics(WeatherMetrics metrics) {
    if (_state != null) {
      env.updateWeatherMetrics(metrics, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  void updateWeather(WeatherCondition weather) {
    if (_state != null) {
      env.updateWeather(weather, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }

  void simulateNextMonth() {
    if (_state != null) {
      crop.simulateNextMonth(_state!);
      notifyListeners();
    }
  }

  void toggleRegion() {
    env.toggleRegion();
    notifyListeners();
  }

  void updateHour(int hour) {
    if (_state != null) {
      env.updateHour(hour, _state!);
      audio.updateAmbience(_state!, crop.isTimeLapseMode);
      notifyListeners();
    }
  }
}
