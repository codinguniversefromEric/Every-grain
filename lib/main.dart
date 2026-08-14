import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/field_state.dart';
import 'services/state_manager.dart';
import 'theme/app_colors.dart';
import 'theme/animation_constants.dart';
import 'theme/strings.dart';
import 'visuals/living_sky.dart';
import 'visuals/cloud_layer.dart';
import 'visuals/rain_layer.dart';
import 'visuals/fireflies_layer.dart';
import 'visuals/dragonfly_layer.dart';
import 'visuals/water_ripple_layer.dart';
import 'visuals/shooting_star_layer.dart';
import 'visuals/mist_layer.dart';
import 'visuals/wind_gust_layer.dart';
import 'visuals/egret_flock_layer.dart';

import 'widgets/rice_plant.dart';
import 'widgets/developer_controls.dart';
import 'widgets/harvest_dialog.dart';
import 'widgets/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const RiceJourneyApp());
}

class RiceJourneyApp extends StatelessWidget {
  const RiceJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RiceFieldScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RiceFieldScreen extends StatefulWidget {
  const RiceFieldScreen({super.key});

  @override
  State<RiceFieldScreen> createState() => _RiceFieldScreenState();
}

@visibleForTesting
StateManager? globalStateManager;

@visibleForTesting
bool isTakingScreenshot = false;

class _RiceFieldScreenState extends State<RiceFieldScreen> with WidgetsBindingObserver {
  late final StateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = StateManager();
    globalStateManager = _stateManager;
    WidgetsBinding.instance.addObserver(this);
    _stateManager.initializeState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stateManager.pauseApp();
    } else if (state == AppLifecycleState.resumed) {
      _stateManager.resumeApp();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateManager.dispose();
    super.dispose();
  }

  void _showDeveloperControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      builder: (context) {
        return DeveloperControlsBottomSheet(
          currentGrowthStage: _stateManager.state!.growthStage,
          currentDayPhase: _stateManager.state!.dayPeriod,
          currentHour: _stateManager.simulatedHour,
          currentBattery: _stateManager.batteryLevel,
          currentWeather: _stateManager.state!.weatherCondition,
          onGrowthStageChanged: _stateManager.updateGrowthStage,
          onDayPhaseChanged: _stateManager.updateDayPhase,
          onWeatherChanged: _stateManager.updateWeather,
          onHarvestSequenceTriggered: _showHarvestSequence,
          onSimulateNextMonth: _stateManager.simulateNextMonth,
          onToggleRegion: _stateManager.toggleRegion,
          onHourChanged: _stateManager.updateHour,
          onBatteryChanged: _stateManager.overrideBattery,
          onTeleportTo: (lat, lon) async {
            await _stateManager.teleportTo(lat, lon);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  void _showHarvestSequence() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return HarvestDialog(
          variety: _stateManager.state!.currentVariety,
          onRestart: _stateManager.resetSeason,
        );
      },
    );
  }

  void _executeHarvest() {
    _stateManager.executeHarvest(_showHarvestSequence);
  }

  Color _getSkyTopColor(DayPhase phase) {
    switch (phase) {
      case DayPhase.morning:
        return AppColors.skyTopMorning;
      case DayPhase.afternoon:
        return AppColors.skyTopAfternoon;
      case DayPhase.evening:
        return AppColors.skyTopEvening;
      case DayPhase.night:
        return AppColors.skyTopNight;
    }
  }

  Color _getSkyBottomColor(DayPhase phase) {
    switch (phase) {
      case DayPhase.morning:
        return AppColors.skyBottomMorning;
      case DayPhase.afternoon:
        return AppColors.skyBottomAfternoon;
      case DayPhase.evening:
        return AppColors.skyBottomEvening;
      case DayPhase.night:
        return AppColors.skyBottomNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _stateManager,
      builder: (context, _) {
        if (_stateManager.isLoading || _stateManager.state == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = _stateManager.state!;
        final isHarvesting = _stateManager.isHarvesting;

        return Scaffold(
          resizeToAvoidBottomInset: false, 
          body: Stack(
            children: [
              // 1. Living Sky Background
              Positioned.fill(
                child: LivingSkyBackground(
                  topColor: _getSkyTopColor(state.dayPeriod),
                  bottomColor: _getSkyBottomColor(state.dayPeriod),
                  weather: state.weatherCondition,
                ),
              ),

              // 1.3. Shooting Stars (Night only, behind clouds)
              if (state.dayPeriod == DayPhase.night)
                const Positioned.fill(child: ShootingStarLayer()),

              // 1.5. Drifting Clouds
              Positioned.fill(
                child: CloudLayer(
                  isNight: state.dayPeriod == DayPhase.night,
                  weather: state.weatherCondition,
                ),
              ),

              // 1.6. Rain Layer
              Positioned.fill(
                child: RainLayer(weather: state.weatherCondition),
              ),

              // 1.8. Egrets (Daylight only)
              if (state.dayPeriod != DayPhase.night && state.weatherCondition == WeatherCondition.clear)
                const Positioned.fill(child: EgretFlockLayer()),

              // 2. Ambient Fireflies (only at night)
              if (state.dayPeriod == DayPhase.night)
                const Positioned.fill(child: FirefliesLayer()),

              // 3. Morning/Evening Mist
              if (state.dayPeriod == DayPhase.morning || state.dayPeriod == DayPhase.evening)
                const Positioned.fill(child: MistLayer()),

              // 4. Procedural Rice Plant Layer
              Positioned(
                bottom: 50, 
                left: 0,
                right: 0,
                child: RicePlantLayer(growthStage: state.growthStage, variety: state.currentVariety),
              ),

              // 4.5. Swipe Hint Overlay
              if (state.growthStage == GrowthStage.ripening && !isHarvesting)
                Positioned(
                  bottom: 250,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: AnimationConstants.harvestSequence,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: (0.5 + 0.5 * (1.0 - ((value * 2) % 1.0))), // Pulsing
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.swipeToHarvest, style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                              SizedBox(width: 8),
                              Icon(Icons.keyboard_double_arrow_right, color: Colors.white),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 5. Dragonflies (Daylight + Warm Seasons)
              if (state.dayPeriod != DayPhase.night && 
                 (state.growthStage == GrowthStage.tillering || state.growthStage == GrowthStage.heading || state.growthStage == GrowthStage.ripening))
                const Positioned.fill(child: DragonflyLayer()),

              // 6. Water Ripples (Flooded Paddy Stages)
              if (state.growthStage == GrowthStage.fallow || state.growthStage == GrowthStage.seedling)
                const Positioned.fill(child: WaterRippleLayer()),

              // 6.5. Wind Gusts (Afternoon/Evening or Stormy)
              if (state.dayPeriod == DayPhase.afternoon || state.dayPeriod == DayPhase.evening || state.weatherCondition == WeatherCondition.stormy)
                Positioned.fill(child: WindGustLayer(weather: state.weatherCondition)),

              // 6.6. Full-screen Swipe to Harvest Detector
              if (state.growthStage == GrowthStage.ripening && !isHarvesting)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 10) {
                        _executeHarvest();
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
                        _executeHarvest();
                      }
                    },
                    child: const SizedBox.expand(),
                  ),
                ),
                
              // 7. Hidden Developer Controls (Only in Debug Mode)
              if (kDebugMode && !isTakingScreenshot)
                Positioned(
                  top: 20,
                  right: 20,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.build, color: Colors.white.withValues(alpha: 0.2)),
                      onPressed: _showDeveloperControls,
                      tooltip: AppStrings.developerControls,
                    ),
                  ),
                ),

              // 8. Low-profile About/Tip Jar Button
              if (!isTakingScreenshot)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.spa, color: Colors.white.withValues(alpha: 0.3)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      },
                      tooltip: AppStrings.aboutAndDonate,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
