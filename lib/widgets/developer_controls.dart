import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../l10n/app_localizations.dart';

class DeveloperControlsBottomSheet extends StatefulWidget {
  final GrowthStage currentGrowthStage;
  final DayPhase currentDayPhase;
  final ValueChanged<GrowthStage> onGrowthStageChanged;
  final ValueChanged<DayPhase> onDayPhaseChanged;
  final VoidCallback onHarvestSequenceTriggered;
  final VoidCallback onSimulateNextMonth;
  final WeatherCondition currentWeather;
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
    required this.currentWeather,
    required this.onWeatherChanged,
    required this.onTeleportTo,
  });

  @override
  State<DeveloperControlsBottomSheet> createState() => _DeveloperControlsBottomSheetState();
}

class _DeveloperControlsBottomSheetState extends State<DeveloperControlsBottomSheet> {
  late DayPhase _localDayPhase;
  late WeatherCondition _localWeather;

  @override
  void initState() {
    super.initState();
    _localDayPhase = widget.currentDayPhase;
    _localWeather = widget.currentWeather;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.testerControlsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(loc.testerControlsDesc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            
            // 1. Location (Taiwan)
            Text(loc.testerLocationTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(loc.testerLocationDesc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  label: Text(loc.testerLocTaipei),
                  onPressed: () => widget.onTeleportTo(25.0330, 121.5654),
                ),
                ActionChip(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  label: Text(loc.testerLocTaichung),
                  onPressed: () => widget.onTeleportTo(24.1477, 120.6736),
                ),
                ActionChip(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  label: Text(loc.testerLocKaohsiung),
                  onPressed: () => widget.onTeleportTo(22.6273, 120.2642),
                ),
                ActionChip(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  label: Text(loc.testerLocTaitung),
                  onPressed: () => widget.onTeleportTo(23.1235, 121.2064),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 2. Location (Global)
            Text(loc.testerGlobalTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  label: Text(loc.testerLocNewYork),
                  onPressed: () => widget.onTeleportTo(40.7128, -74.0060),
                ),
                ActionChip(
                  backgroundColor: Colors.pink.withValues(alpha: 0.1),
                  label: Text(loc.testerLocTokyo),
                  onPressed: () => widget.onTeleportTo(35.6762, 139.6503),
                ),
                ActionChip(
                  backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                  label: Text(loc.testerLocParis),
                  onPressed: () => widget.onTeleportTo(48.8566, 2.3522),
                ),
                ActionChip(
                  backgroundColor: Colors.lightBlue.withValues(alpha: 0.1),
                  label: Text(loc.testerLocLondon),
                  onPressed: () => widget.onTeleportTo(51.5074, -0.1278),
                ),
                ActionChip(
                  backgroundColor: Colors.teal.withValues(alpha: 0.1),
                  label: Text(loc.testerLocSydney),
                  onPressed: () => widget.onTeleportTo(-33.8688, 151.2093), // South hemisphere!
                ),
                ActionChip(
                  backgroundColor: Colors.amber.withValues(alpha: 0.1),
                  label: Text(loc.testerLocCairo),
                  onPressed: () => widget.onTeleportTo(30.0444, 31.2357), // Desert
                ),
                ActionChip(
                  backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                  label: Text(loc.testerLocRio),
                  onPressed: () => widget.onTeleportTo(-22.9068, -43.1729), // Tropical
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 2. Time
            Text(loc.testerTimeTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fast_forward),
                    label: Text(loc.testerNextMonth),
                    onPressed: () {
                      widget.onSimulateNextMonth();
                      // Update local state to match the simulation roughly (just force refresh)
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_localDayPhase == DayPhase.morning ? Icons.dark_mode : Icons.light_mode),
                    label: Text(_localDayPhase == DayPhase.morning ? loc.testerToNight : loc.testerToDay),
                    onPressed: () {
                      final newPhase = _localDayPhase == DayPhase.morning ? DayPhase.night : DayPhase.morning;
                      setState(() => _localDayPhase = newPhase);
                      widget.onDayPhaseChanged(newPhase);
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 3. Events
            Text(loc.testerEventsTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Clear'),
                  selected: _localWeather == WeatherCondition.clear,
                  onSelected: (s) {
                    if(s) { setState(() => _localWeather = WeatherCondition.clear); widget.onWeatherChanged(WeatherCondition.clear); }
                  },
                ),
                ChoiceChip(
                  label: const Text('Cloudy'),
                  selected: _localWeather == WeatherCondition.cloudy,
                  onSelected: (s) {
                    if(s) { setState(() => _localWeather = WeatherCondition.cloudy); widget.onWeatherChanged(WeatherCondition.cloudy); }
                  },
                ),
                ChoiceChip(
                  label: const Text('Rainy'),
                  selected: _localWeather == WeatherCondition.rainy,
                  onSelected: (s) {
                    if(s) { setState(() => _localWeather = WeatherCondition.rainy); widget.onWeatherChanged(WeatherCondition.rainy); }
                  },
                ),
                ChoiceChip(
                  label: const Text('Stormy'),
                  selected: _localWeather == WeatherCondition.stormy,
                  onSelected: (s) {
                    if(s) { setState(() => _localWeather = WeatherCondition.stormy); widget.onWeatherChanged(WeatherCondition.stormy); }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black87,
              ),
              icon: const Icon(Icons.rice_bowl),
              label: Text(loc.testerForceHarvest),
              onPressed: () {
                widget.onGrowthStageChanged(GrowthStage.harvested);
                Navigator.pop(context);
                widget.onHarvestSequenceTriggered();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
