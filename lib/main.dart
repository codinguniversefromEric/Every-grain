import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';
import 'models/field_state.dart';
import 'services/agricultural_calendar.dart';
import 'visuals.dart';
import 'widgets/custom_status_bar.dart';
import 'widgets/rice_plant.dart';
import 'widgets/developer_controls.dart';
import 'widgets/harvest_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Load saved reflections
  final prefs = await SharedPreferences.getInstance();
  final savedReflections = prefs.getStringList('reflections') ?? [];

  runApp(RiceJourneyApp(savedReflections: savedReflections));
}

class RiceJourneyApp extends StatelessWidget {
  final List<String> savedReflections;

  const RiceJourneyApp({super.key, required this.savedReflections});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '粒粒皆辛苦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: RiceFieldScreen(initialReflections: savedReflections),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RiceFieldScreen extends StatefulWidget {
  final List<String> initialReflections;

  const RiceFieldScreen({super.key, required this.initialReflections});

  @override
  State<RiceFieldScreen> createState() => _RiceFieldScreenState();
}

class _RiceFieldScreenState extends State<RiceFieldScreen> {
  late FieldState _state;
  late TaiwanRegion _region;
  late DateTime _simulatedDate;
  final TextEditingController _reflectionController = TextEditingController();
  bool _isLoading = true;

  final Battery _battery = Battery();
  int _batteryLevel = 100;
  late int _simulatedHour;
  bool _isSinking = false;

  @override
  void initState() {
    super.initState();
    _simulatedDate = DateTime.now();
    _simulatedHour = DateTime.now().hour;
    _initializeState();
  }

  Future<void> _initializeState() async {
    _region = await AgriculturalCalendar.determineRegion();
    
    try {
      _batteryLevel = await _battery.batteryLevel;
    } catch (e) {
      _batteryLevel = 100;
    }

    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (mounted) {
        final level = await _battery.batteryLevel;
        setState(() {
          _batteryLevel = level;
        });
      }
    });
    
    if (!mounted) return;
    
    setState(() {
      _state = FieldState(
        growthStage: AgriculturalCalendar.getStageForDate(_simulatedDate, _region),
        dayPeriod: _calculateDayPhase(_simulatedHour),
        reflections: List.from(widget.initialReflections),
      );
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  DayPhase _calculateDayPhase(int hour) {
    if (hour >= 5 && hour < 12) return DayPhase.morning;
    if (hour >= 12 && hour < 17) return DayPhase.afternoon;
    if (hour >= 17 && hour < 20) return DayPhase.evening;
    return DayPhase.night;
  }

  Future<void> _saveReflection(String reflection) async {
    if (reflection.isEmpty) return;

    FocusScope.of(context).unfocus();
    _reflectionController.clear();

    setState(() {
      _isSinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _state.reflections.add(reflection);
      _isSinking = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reflections', _state.reflections);
  }

  Future<void> _clearReflections() async {
    setState(() {
      _state.reflections.clear();
      _state.growthStage = GrowthStage.fallow;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reflections');
  }

  void _showDeveloperControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      builder: (context) {
        return DeveloperControlsBottomSheet(
          currentGrowthStage: _state.growthStage,
          currentDayPhase: _state.dayPeriod,
          onGrowthStageChanged: (stage) => setState(() => _state.growthStage = stage),
          onDayPhaseChanged: (phase) => setState(() => _state.dayPeriod = phase),
          onHarvestSequenceTriggered: _showHarvestSequence,
          onSimulateNextMonth: () {
            setState(() {
              _simulatedDate = DateTime(_simulatedDate.year, _simulatedDate.month + 1, _simulatedDate.day);
              _state.growthStage = AgriculturalCalendar.getStageForDate(_simulatedDate, _region);
            });
          },
          onToggleRegion: () {
            setState(() {
              _region = _region == TaiwanRegion.north ? TaiwanRegion.south : TaiwanRegion.north;
              _state.growthStage = AgriculturalCalendar.getStageForDate(_simulatedDate, _region);
            });
          },
          currentHour: _simulatedHour,
          currentBattery: _batteryLevel,
          onHourChanged: (hour) {
            setState(() {
              _simulatedHour = hour;
              _state.dayPeriod = _calculateDayPhase(hour);
            });
          },
          onBatteryChanged: (battery) {
            setState(() {
              _batteryLevel = battery;
            });
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
          reflections: _state.reflections,
          onRestart: _clearReflections,
        );
      },
    );
  }

  Color _getBackgroundColor(DayPhase phase) {
    switch (phase) {
      case DayPhase.morning:
        return const Color(0xFF87CEEB); // Sky blue
      case DayPhase.afternoon:
        return const Color(0xFF4682B4); // Steel blue
      case DayPhase.evening:
        return const Color(0xFFFF7F50); // Coral/Sunset
      case DayPhase.night:
        return const Color(0xFF191970); // Midnight blue
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final promptText = AgriculturalCalendar.getPromptForStage(_state.growthStage);
    final seasonText = AgriculturalCalendar.getSeasonText(_simulatedDate, _region);

    bool inputDisabled = false;
    String? disableReason;

    if (_batteryLevel < 20) {
      inputDisabled = true;
      disableReason = '體力透支，農夫該休息了';
    } else if (_simulatedHour >= 22 || _simulatedHour < 4) {
      inputDisabled = true;
      disableReason = '萬物皆休，明日請早';
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. Dynamic Simple Background Layer
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              color: _getBackgroundColor(_state.dayPeriod),
            ),
          ),

          // 2. Ambient Fireflies (only at night)
          if (_state.dayPeriod == DayPhase.night)
            const Positioned.fill(child: FirefliesLayer()),
            
          // 3. Floating Memories Layer (Buried until harvest)
          Positioned.fill(
            child: FloatingMemoriesLayer(
              reflections: (_state.growthStage == GrowthStage.harvested || _state.growthStage == GrowthStage.ripening)
                  ? _state.reflections
                  : [],
            ),
          ),

          // 4. Procedural Rice Plant Layer
          Positioned(
            bottom: 50, 
            left: 0,
            right: 0,
            child: RicePlantLayer(growthStage: _state.growthStage),
          ),
          
          // 4.5. Custom Rustic Status Bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomStatusBar(),
          ),

          // 5. Agricultural Season Text Overlay
          Positioned(
            top: 60,
            left: 24,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '粒粒皆辛苦',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seasonText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  if (_region == TaiwanRegion.south)
                    Text(
                      '南部地區作息',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      '中北部地區作息',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 5.5 Sinking Seed Animation Layer
          if (_isSinking)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                // Starts at 150 from bottom, drops to -50
                double bottomPos = 150 - (value * 200);
                // Fades out in the last 30% of the animation
                double opacity = value < 0.7 ? 1.0 : (1.0 - value) * 3.33;
                
                return Positioned(
                  bottom: bottomPos,
                  left: 0, 
                  right: 0,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: const Center(
                      child: Icon(Icons.spa, color: Color(0xFFD4AF37), size: 36), // Golden seed
                    ),
                  ),
                );
              },
            ),

          // 6. Daily Reflection Input Layer
          _KeyboardInputLayer(
            controller: _reflectionController,
            promptText: promptText,
            onSubmitted: _saveReflection,
            isDisabled: inputDisabled,
            disabledReason: disableReason,
          ),

          // 7. Subtle Developer Controls Trigger
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white.withValues(alpha: 0.2)),
                onPressed: _showDeveloperControls,
                tooltip: 'Developer Controls',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardInputLayer extends StatelessWidget {
  final TextEditingController controller;
  final String promptText;
  final Function(String) onSubmitted;
  final bool isDisabled;
  final String? disabledReason;

  const _KeyboardInputLayer({
    required this.controller,
    required this.promptText,
    required this.onSubmitted,
    this.isDisabled = false,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      left: 20,
      right: 20,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.black.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDisabled ? Colors.red.withValues(alpha: 0.3) : Colors.white38),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(color: isDisabled ? Colors.grey : Colors.white),
              enabled: !isDisabled,
              decoration: InputDecoration(
                hintText: isDisabled ? (disabledReason ?? '無法輸入') : promptText,
                hintStyle: TextStyle(
                  color: isDisabled ? Colors.red.withValues(alpha: 0.5) : Colors.white70,
                  fontSize: 14,
                  fontWeight: isDisabled ? FontWeight.bold : FontWeight.normal,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ),
      ),
    );
  }
}
