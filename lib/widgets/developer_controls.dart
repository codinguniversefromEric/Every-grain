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
  final int currentBattery;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onBatteryChanged;

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
    required this.currentBattery,
    required this.onHourChanged,
    required this.onBatteryChanged,
  });

  @override
  State<DeveloperControlsBottomSheet> createState() => _DeveloperControlsBottomSheetState();
}

class _DeveloperControlsBottomSheetState extends State<DeveloperControlsBottomSheet> {
  late GrowthStage _localGrowthStage;
  late DayPhase _localDayPhase;
  late int _localHour;
  late int _localBattery;

  @override
  void initState() {
    super.initState();
    _localGrowthStage = widget.currentGrowthStage;
    _localDayPhase = widget.currentDayPhase;
    _localHour = widget.currentHour;
    _localBattery = widget.currentBattery;
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
          const SizedBox(height: 20),
          const Text('Override Battery (%):'),
          Slider(
            value: _localBattery.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '$_localBattery%',
            onChanged: (val) {
              setState(() {
                _localBattery = val.toInt();
              });
              widget.onBatteryChanged(_localBattery);
            },
          ),
        ],
      ),
    ));
  }
}
