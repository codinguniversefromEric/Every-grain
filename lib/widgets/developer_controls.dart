import 'package:flutter/material.dart';
import '../models/field_state.dart';

class DeveloperControlsBottomSheet extends StatefulWidget {
  final GrowthStage currentGrowthStage;
  final DayPhase currentDayPhase;
  final ValueChanged<GrowthStage> onGrowthStageChanged;
  final ValueChanged<DayPhase> onDayPhaseChanged;
  final VoidCallback onHarvestSequenceTriggered;
  final VoidCallback onSimulateNextMonth;
  final VoidCallback onToggleRegion;
  final int currentHour;
  final WeatherCondition currentWeather;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<WeatherCondition> onWeatherChanged;
  final void Function(double lat, double lon) onTeleportTo;

  const DeveloperControlsBottomSheet({
    super.key,
    required this.currentGrowthStage,
    required this.currentDayPhase,
    required this.onGrowthStageChanged,
    required this.onDayPhaseChanged,
    required this.onHarvestSequenceTriggered,
    required this.onSimulateNextMonth,
    required this.onToggleRegion,
    required this.currentHour,
    required this.currentWeather,
    required this.onHourChanged,
    required this.onWeatherChanged,
    required this.onTeleportTo,
  });

  @override
  State<DeveloperControlsBottomSheet> createState() => _DeveloperControlsBottomSheetState();
}

class _DeveloperControlsBottomSheetState extends State<DeveloperControlsBottomSheet> {
  late GrowthStage _localGrowthStage;
  late DayPhase _localDayPhase;
  late int _localHour;
  late WeatherCondition _localWeather;

  @override
  void initState() {
    super.initState();
    _localGrowthStage = widget.currentGrowthStage;
    _localDayPhase = widget.currentDayPhase;
    _localHour = widget.currentHour;
    _localWeather = widget.currentWeather;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Developer Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onSimulateNextMonth,
            child: const Text('Simulate Next Month (+1 month)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.onToggleRegion,
            child: const Text('Toggle North/South Region'),
          ),
          const SizedBox(height: 20),
          const Text('Teleport (Test GPS Weather):', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('📍 台北信義區'),
                onPressed: () => widget.onTeleportTo(25.0330, 121.5654),
              ),
              ActionChip(
                label: const Text('📍 高雄西子灣'),
                onPressed: () => widget.onTeleportTo(22.6273, 120.2642),
              ),
              ActionChip(
                label: const Text('📍 阿里山/玉山'),
                onPressed: () => widget.onTeleportTo(23.4889, 120.9513),
              ),
              ActionChip(
                label: const Text('📍 澎湖吉貝'),
                onPressed: () => widget.onTeleportTo(23.7417, 119.5960),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Manual Growth Stage Override:'),
          Slider(
            value: _localGrowthStage.index.toDouble(),
            min: 0,
            max: GrowthStage.values.length.toDouble() - 1,
            divisions: GrowthStage.values.length - 1,
            label: _localGrowthStage.name,
            onChanged: (val) {
              final newStage = GrowthStage.values[val.toInt()];
              setState(() {
                _localGrowthStage = newStage;
              });
              widget.onGrowthStageChanged(newStage);
              
              if (newStage == GrowthStage.harvested) {
                Navigator.pop(context); 
                widget.onHarvestSequenceTriggered();
              }
            },
          ),
          const Text('Time of Day:'),
          Slider(
            value: _localDayPhase.index.toDouble(),
            min: 0,
            max: DayPhase.values.length.toDouble() - 1,
            divisions: DayPhase.values.length - 1,
            label: _localDayPhase.name,
            onChanged: (val) {
              final newPhase = DayPhase.values[val.toInt()];
              setState(() {
                _localDayPhase = newPhase;
              });
              widget.onDayPhaseChanged(newPhase);
            },
          ),
          const SizedBox(height: 20),
          const Text('Weather:'),
          Slider(
            value: _localWeather.index.toDouble(),
            min: 0,
            max: WeatherCondition.values.length.toDouble() - 1,
            divisions: WeatherCondition.values.length - 1,
            label: _localWeather.name,
            onChanged: (val) {
              final newWeather = WeatherCondition.values[val.toInt()];
              setState(() {
                _localWeather = newWeather;
              });
              widget.onWeatherChanged(newWeather);
            },
          ),
          const SizedBox(height: 20),
          const Text('Override Hour (0-23):'),
          Slider(
            value: _localHour.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            label: '$_localHour:00',
            onChanged: (val) {
              setState(() {
                _localHour = val.toInt();
              });
              widget.onHourChanged(_localHour);
            },
          ),
        ],
      ),
    ));
  }
}
