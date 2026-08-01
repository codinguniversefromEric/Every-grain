import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/field_state.dart';
import 'visuals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      title: 'Rice Journey Prototype',
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

class _RiceFieldScreenState extends State<RiceFieldScreen> with SingleTickerProviderStateMixin {
  late FieldState _state;
  final TextEditingController _reflectionController = TextEditingController();
  late AnimationController _breathingController;

  final Map<DayPhase, String> _backgrounds = {
    DayPhase.morning: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\bg_morning_1785565644406.jpg',
    DayPhase.afternoon: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\bg_afternoon_1785565656153.jpg',
    DayPhase.evening: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\bg_evening_1785565667703.jpg',
    DayPhase.night: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\bg_night_1785565678247.jpg',
  };

  final Map<GrowthStage, String> _plantImages = {
    GrowthStage.seedling: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\rice_seedling_1785565699665.jpg',
    GrowthStage.tillering: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\rice_tillering_1785565708389.jpg',
    GrowthStage.heading: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\rice_heading_1785565718866.jpg',
    GrowthStage.ripening: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\rice_ripening_1785565729076.jpg',
    GrowthStage.harvested: r'C:\Users\ericw\.gemini\antigravity\brain\507e0024-e752-464b-87f4-16dd05fd9798\rice_harvested_1785565737748.jpg',
  };

  @override
  void initState() {
    super.initState();
    _state = FieldState(
      growthStage: GrowthStage.seedling,
      dayPeriod: _calculateDayPhase(DateTime.now()),
      reflections: List.from(widget.initialReflections),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  DayPhase _calculateDayPhase(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return DayPhase.morning;
    if (hour >= 12 && hour < 17) return DayPhase.afternoon;
    if (hour >= 17 && hour < 20) return DayPhase.evening;
    return DayPhase.night;
  }

  Future<void> _saveReflection(String reflection) async {
    if (reflection.isEmpty) return;

    setState(() {
      _state.reflections.add(reflection);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reflections', _state.reflections);
    _reflectionController.clear();
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
  }

  void _showDeveloperControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Developer Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Growth Stage:'),
                  Slider(
                    value: _state.growthStage.index.toDouble(),
                    min: 0,
                    max: GrowthStage.values.length.toDouble() - 1,
                    divisions: GrowthStage.values.length - 1,
                    label: _state.growthStage.name,
                    onChanged: (val) {
                      setState(() {
                        _state.growthStage = GrowthStage.values[val.toInt()];
                      });
                      setModalState(() {});
                      
                      if (_state.growthStage == GrowthStage.harvested) {
                        Navigator.pop(context); 
                        _showHarvestSequence();
                      }
                    },
                  ),
                  const Text('Time of Day:'),
                  Slider(
                    value: _state.dayPeriod.index.toDouble(),
                    min: 0,
                    max: DayPhase.values.length.toDouble() - 1,
                    divisions: DayPhase.values.length - 1,
                    label: _state.dayPeriod.name,
                    onChanged: (val) {
                      setState(() {
                        _state.dayPeriod = DayPhase.values[val.toInt()];
                      });
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showHarvestSequence() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rice_bowl, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  '一株秧苗，經過時間與人的陪伴，最後成為一碗飯。',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_state.reflections.isNotEmpty) ...[
                  const Text('Your reflections during this season:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: _state.reflections.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('"$r"', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                        )).toList(),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgPath = _backgrounds[_state.dayPeriod]!;
    final plantPath = _plantImages[_state.growthStage]!;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. AI Generated Background Layer
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: Image.file(
                File(bgPath),
                key: ValueKey(bgPath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // 2. Ambient Fireflies (only at night)
          if (_state.dayPeriod == DayPhase.night)
            const Positioned.fill(child: FirefliesLayer()),
            
          // 3. Floating Memories Layer
          Positioned.fill(
            child: FloatingMemoriesLayer(reflections: _state.reflections),
          ),

          // 4. AI Generated Rice Plant Layer
          Positioned(
            bottom: 50, 
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: Tween(begin: 0.98, end: 1.01).animate(_breathingController),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1500),
                  child: ColorFiltered(
                    key: ValueKey(plantPath),
                    // Use BlendMode.multiply so the white background of the illustration becomes transparent against the background
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.multiply),
                    child: Image.file(
                      File(plantPath),
                      height: MediaQuery.of(context).size.height * 0.45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Daily Reflection Input Layer
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38),
              ),
              child: TextField(
                controller: _reflectionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '今天，有什麼值得好好珍惜？',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: _saveReflection,
              ),
            ),
          ),

          // 6. Invisible Developer Controls Trigger
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _showDeveloperControls,
              child: Container(
                width: 70,
                height: 70,
                color: Colors.transparent, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
