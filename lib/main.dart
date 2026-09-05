import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/field_state.dart';
import 'models/rice_variety.dart';
import 'services/state_manager.dart';
import 'services/widget_service.dart';
import 'theme/animation_constants.dart';
import 'visuals/living_sky.dart';
import 'visuals/cloud_layer.dart';
import 'visuals/rain_layer.dart';
import 'visuals/fireflies_layer.dart';
import 'visuals/scenery/biome_scenery_layer.dart';
import 'widgets/book_modal.dart';
import 'visuals/collection/collection_grid.dart';
import 'visuals/dragonfly_layer.dart';
import 'visuals/water_ripple_layer.dart';
import 'visuals/shooting_star_layer.dart';
import 'visuals/mist_layer.dart';
import 'visuals/wind_gust_layer.dart';
import 'visuals/egret_flock_layer.dart';

import 'widgets/widget_scenery_snapshot.dart';
import 'widgets/rice_plant.dart';
import 'widgets/developer_controls.dart';
import 'widgets/harvest_dialog.dart';
import 'widgets/bwa_bwei_dialog.dart';
import 'widgets/about_screen.dart';
import 'widgets/journal_button.dart';
import 'widgets/journal_dialog.dart';
import 'widgets/micro_simulation_overlay.dart';
import 'services/review/review_service.dart';
import 'services/review/native_review_service.dart';
import 'services/review/fake_review_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const RiceJourneyApp());
}

class RiceJourneyApp extends StatefulWidget {
  const RiceJourneyApp({super.key});

  static void setLocale(BuildContext context, Locale? newLocale) {
    _RiceJourneyAppState? state = context
        .findAncestorStateOfType<_RiceJourneyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<RiceJourneyApp> createState() => _RiceJourneyAppState();
}

class _RiceJourneyAppState extends State<RiceJourneyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('pref_locale');
    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  void setLocale(Locale? locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('pref_locale');
    } else {
      await prefs.setString('pref_locale', locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Every Grain',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', ''),
        Locale('ja', 'JP'),
      ],
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

// ⚠️ 測試期間設為 true，正式上架生產環境前請改為 false
const bool isBetaTestMode = true;

class _RiceFieldScreenState extends State<RiceFieldScreen>
    with WidgetsBindingObserver {
  late final StateManager _stateManager;
  late final ReviewService _reviewService;
  bool _showMicroSimulation = false;

  @override
  void initState() {
    super.initState();
    _stateManager = StateManager();
    _reviewService = isBetaTestMode ? FakeReviewService() : NativeReviewService();
    globalStateManager = _stateManager;
    WidgetsBinding.instance.addObserver(this);
    WidgetService.init();
    _stateManager.initializeState().then((_) {
      if (mounted) {
        WidgetService.updateWidget(
          _stateManager.state, 
          hasUnreadJournal: _stateManager.hasUnreadJournal
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stateManager.pauseApp();
      WidgetService.updateWidget(
        _stateManager.state, 
        hasUnreadJournal: _stateManager.hasUnreadJournal
      );
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
          currentWeather: _stateManager.state!.weatherCondition,
          onGrowthStageChanged: _stateManager.updateGrowthStage,
          onDayPhaseChanged: _stateManager.updateDayPhase,
          onWeatherChanged: _stateManager.updateWeather,
          currentMetrics: _stateManager.state!.weatherMetrics,
          onMetricsChanged: _stateManager.updateWeatherMetrics,
          onHarvestSequenceTriggered: _showHarvestSequence,
          onSimulateNextMonth: _stateManager.simulateNextMonth,
          onTeleportTo: (lat, lon) async {
            if (context.mounted) {
              Navigator.pop(context);
            }
            await _stateManager.teleportTo(lat, lon);
          },
          onResetLocation: () async {
            if (context.mounted) {
              Navigator.pop(context);
            }
            await _stateManager.initializeState(forceRefreshWeather: true);
          },
          isTimeLapseActive: _stateManager.isTimeLapseMode,
          onToggleTimeLapse: _stateManager.toggleTimeLapse,
          onUnlockAllCards: () async {
            await _stateManager.debugInjectUnlockedCards([
              RiceVariety.tainan11,
              RiceVariety.kaohsiung139,
              RiceVariety.tainung71,
              RiceVariety.taikeng9,
            ]);
          },
          onResetField: _stateManager.resetSeason,
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

  void _openJournal() {
    final state = _stateManager;
    showBookModal(
      context,
      title: !state.hasReadFirstLetter ? '阿公的信' : '農事日誌',
      content: JournalDialog(
          isFirstLetter: !state.hasReadFirstLetter,
          needsPlanting: state.needsPlanting,
          state: state.state,
          onStartTask: () {
            setState(() {
              _showMicroSimulation = true;
            });
          },
          onPlowDeadCrop: () {
            state.plowDeadCrop();
          },
          onPrayToEarthGod: () {
            showDialog(
              context: context,
              builder: (context) => BwaBweiDialog(stateManager: state),
            );
          },
        ),
    ).then((_) {
      if (!state.hasReadFirstLetter) {
        state.markFirstLetterRead();
      }
    });
  }

  void _executeHarvest() {
    _stateManager.executeHarvest(() async {
      _showHarvestSequence();
      
      await _reviewService.checkAndRequestReview();
    });
  }



  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _stateManager,
      builder: (context, _) {
        if (_stateManager.state == null) {
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
                  sunElevation: state.sunElevation,
                  weatherMetrics: state.weatherMetrics,
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
              if (state.dayPeriod != DayPhase.night &&
                  state.weatherCondition == WeatherCondition.clear)
                const Positioned.fill(child: EgretFlockLayer()),

              // 2. Ambient Fireflies (only at night)
              if (state.dayPeriod == DayPhase.night)
                const Positioned.fill(child: FirefliesLayer()),

              // 3. Morning/Evening Mist
              if (state.dayPeriod == DayPhase.morning ||
                  state.dayPeriod == DayPhase.evening)
                const Positioned.fill(child: MistLayer()),

              // 4. Scenery Biome Layer (Mountains, Ocean, Plains)
              Positioned.fill(
                child: BiomeSceneryLayer(
                  biome: state.currentBiome,
                  dayPhase: state.dayPeriod,
                ),
              ),

              // 5. Procedural Rice Plant Layer
              Positioned(
                bottom: -20, // Let it bleed into the bottom
                left: 0,
                right: 0,
                child: RicePlantLayer(
                  growthStage: state.growthStage,
                  variety: state.currentVariety,
                ),
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
                          opacity:
                              (0.5 +
                              0.5 * (1.0 - ((value * 2) % 1.0))), // Pulsing
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.swipeToHarvest,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 5. Dragonflies (Daylight + Warm Seasons)
              if (state.dayPeriod != DayPhase.night &&
                  (state.growthStage == GrowthStage.tillering ||
                      state.growthStage == GrowthStage.heading ||
                      state.growthStage == GrowthStage.ripening))
                const Positioned.fill(child: DragonflyLayer()),

              // 6. Water Ripples (Flooded Paddy Stages)
              if (state.growthStage == GrowthStage.fallow ||
                  state.growthStage == GrowthStage.seedling)
                const Positioned.fill(child: WaterRippleLayer()),

              // 6.5. Wind Gusts (Afternoon/Evening or Stormy)
              if (state.dayPeriod == DayPhase.afternoon ||
                  state.dayPeriod == DayPhase.evening ||
                  state.weatherCondition == WeatherCondition.stormy)
                Positioned.fill(
                  child: WindGustLayer(weather: state.weatherCondition),
                ),

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
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 50) {
                        _executeHarvest();
                      }
                    },
                    child: const SizedBox.expand(),
                  ),
                ),

              // 7. Developer Controls (Beta Test Mode or Debug Mode)
              if ((kDebugMode || isBetaTestMode) && !isTakingScreenshot)
                Positioned(
                  top: 20,
                  right: 20,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.build,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      onPressed: _showDeveloperControls,
                      tooltip: AppLocalizations.of(context)!.developerControls,
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
                      icon: Icon(
                        Icons.spa,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutScreen(
                              isInTaiwan: _stateManager.isInTaiwan,
                            ),
                          ),
                        );
                      },
                      tooltip: AppLocalizations.of(context)!.aboutUs,
                    ),
                  ),
                ),
                
              // Collection Grid Button
              if (!isTakingScreenshot)
                Positioned(
                  bottom: 20,
                  right: 80,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: Colors.white.withValues(alpha: _stateManager.unlockedVarieties.isNotEmpty ? 0.8 : 0.3),
                      ),
                      onPressed: () {
                        showBookModal(
                          context,
                          title: '台灣米護照',
                          content: CollectionGrid(
                            unlockedIds: _stateManager.unlockedVarieties,
                          ),
                        );
                      },
                      tooltip: '圖鑑 (Collection)',
                    ),
                  ),
                ),
                
              // 9. Farming Journal Button
              if (!isTakingScreenshot)
                Positioned(
                  top: (kDebugMode || isBetaTestMode) ? 80 : 20,
                  left: 20,
                  child: SafeArea(
                    child: JournalButton(
                      hasUnread: _stateManager.hasUnreadJournal,
                      onTap: _openJournal,
                    ),
                  ),
                ),

              // Reset Location Button (UX Safety)
              if (_stateManager.isTeleported)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location, color: Colors.white),
                        label: const Text(
                          "恢復真實定位",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 8,
                        ),
                        onPressed: () {
                          _stateManager.resetTeleport();
                        },
                      ),
                    ),
                  ),
                ),

              // 10. Micro Simulation Overlay
              if (_showMicroSimulation)
                Positioned.fill(
                  child: MicroSimulationOverlay(
                    onCompleted: () async {
                      setState(() {
                        _showMicroSimulation = false;
                      });
                      await _stateManager.completePlanting();
                    },
                  ),
                ),
                
              if (_stateManager.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
