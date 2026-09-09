import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/field_state.dart';
import '../agricultural_calendar.dart';
import '../solar_calculator.dart';
import '../simulation/crop_simulation_engine.dart';
import 'progress_repository.dart';
import 'audio_controller.dart';
import 'environment_controller.dart';

class CropController {
  final VoidCallback notifyListeners;
  
  DateTime simulatedDate = DateTime.now();
  DateTime timeLapseClock = DateTime.now();
  DateTime lastTickTime = DateTime.now();
  
  Timer? _simulationTimer;
  Timer? _timeLapseTimer;
  bool isTimeLapseMode = false;
  bool isHarvesting = false;

  CropController(this.notifyListeners);

  void startTimers(FieldState state, EnvironmentController env, AudioController audio) {
    if (isTimeLapseMode) {
      _startTimeLapseTimer(state, env, audio);
    } else {
      _startSimulationTimer(state, env, audio);
    }
  }

  void stopTimers() {
    _simulationTimer?.cancel();
    _timeLapseTimer?.cancel();
  }

  void _startSimulationTimer(FieldState state, EnvironmentController env, AudioController audio) {
    _simulationTimer?.cancel();
    lastTickTime = DateTime.now();
    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (isTimeLapseMode) return;
      final now = DateTime.now();
      
      // Update biology using engine
      if (state.currentVariety != null) {
        CropSimulationEngine.tickSimulation(
          state, 
          state.weatherMetrics, 
          state.currentVariety!, 
          now.difference(lastTickTime)
        );
      }
      
      // Update sun
      state.sunElevation = SolarCalculator.getSunElevation(
        env.lastPosition?.latitude ?? 23.5, 
        env.lastPosition?.longitude ?? 121.0, 
        now
      );

      // Periodically refresh weather
      if (now.minute % 30 == 0) {
        if (state.weatherOverrideUntil != null && now.isAfter(state.weatherOverrideUntil!)) {
          state.weatherOverrideUntil = null;
          state.overriddenMetrics = null;
        }
        if (state.weatherOverrideUntil == null) {
          state.weatherMetrics = await env.weatherService.getCurrentWeather(env.lastPosition);
        }
      }
      
      lastTickTime = now;
      audio.updateAmbience(state, isTimeLapseMode);
      notifyListeners();
    });
  }

  void _startTimeLapseTimer(FieldState state, EnvironmentController env, AudioController audio) {
    _timeLapseTimer?.cancel();
    _timeLapseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isTimeLapseMode) return;
      
      timeLapseClock = timeLapseClock.add(const Duration(minutes: 30));
      env.simulatedHour = timeLapseClock.hour;
      
      // Update sun
      state.sunElevation = SolarCalculator.getSunElevation(
        env.lastPosition?.latitude ?? 23.5, 
        env.lastPosition?.longitude ?? 121.0, 
        timeLapseClock
      );
      
      if (state.currentVariety != null) {
        CropSimulationEngine.tickSimulation(
          state, 
          state.weatherMetrics, 
          state.currentVariety!, 
          const Duration(minutes: 30)
        );
      }
      
      audio.updateAmbience(state, isTimeLapseMode);
      notifyListeners();
    });
  }

  void toggleTimeLapse(FieldState state, EnvironmentController env, AudioController audio) {
    isTimeLapseMode = !isTimeLapseMode;
    if (isTimeLapseMode) {
      timeLapseClock = DateTime.now();
      _simulationTimer?.cancel();
      _startTimeLapseTimer(state, env, audio);
    } else {
      _timeLapseTimer?.cancel();
      _startSimulationTimer(state, env, audio);
    }
  }

  void updateGrowthStage(GrowthStage stage, FieldState state) {
    state.growthStage = stage;
    if (stage == GrowthStage.seedling) state.accumulatedBiomass = 5.0;
    if (stage == GrowthStage.tillering) state.accumulatedBiomass = 30.0;
    if (stage == GrowthStage.heading) state.accumulatedBiomass = 60.0;
    if (stage == GrowthStage.ripening) state.accumulatedBiomass = 90.0;
    if (stage == GrowthStage.dead) state.vitality = 0.0;
  }

  void simulateNextMonth(FieldState state) {
    simulatedDate = DateTime(simulatedDate.year, simulatedDate.month + 1, simulatedDate.day);
    state.accumulatedBiomass += 20.0;
    if (state.accumulatedBiomass >= 100.0) state.accumulatedBiomass = 100.0;
    
    if (state.accumulatedBiomass >= 100.0) {
      state.growthStage = GrowthStage.ripening;
    } else if (state.accumulatedBiomass > 60.0) {
      state.growthStage = GrowthStage.heading;
    } else if (state.accumulatedBiomass > 30.0) {
      state.growthStage = GrowthStage.tillering;
    }
  }

  Future<void> executeHarvest(FieldState state, AudioController audio, ProgressRepository progressRepo, VoidCallback onHarvestComplete) async {
    if (isHarvesting) return;
    isHarvesting = true;
    notifyListeners();

    audio.playHarvestSound();
    state.growthStage = GrowthStage.harvested;
    if (state.currentVariety != null) {
      await progressRepo.addUnlockedVariety(state.currentVariety!.id);
    }
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    onHarvestComplete();
    isHarvesting = false;
    notifyListeners();
  }

  Future<void> completePlanting(FieldState state, ProgressRepository progressRepo) async {
    state.growthStage = GrowthStage.seedling;
    state.vitality = 1.0;
    state.accumulatedBiomass = 5.0;
    state.temperatureStressLevel = 0.0;
    state.waterStressLevel = 0.0;
    state.nextPlantingAllowedAt = null;
    await progressRepo.setHasCompletedPlanting(true);
    await progressRepo.setNextPlantingAllowedAt(null);
  }

  Future<void> resetSeason(FieldState state, ProgressRepository progressRepo) async {
    state.growthStage = GrowthStage.fallow;
    state.vitality = 1.0;
    state.accumulatedBiomass = 0.0;
    state.temperatureStressLevel = 0.0;
    state.waterStressLevel = 0.0;
    
    final nextTerm = AgriculturalCalendar.getNextSolarTermDate(DateTime.now());
    state.nextPlantingAllowedAt = nextTerm;
    await progressRepo.setNextPlantingAllowedAt(nextTerm);
    await progressRepo.setHasCompletedPlanting(false);
  }
}
