import 'package:flutter/material.dart';
import '../models/field_state.dart';
import '../visuals/scenery/biome_scenery_layer.dart';

/// A debug page that lets testers preview all 12 landscape variants
/// with toggleable day phase and weather conditions.
class SceneryPreviewPage extends StatefulWidget {
  const SceneryPreviewPage({super.key});

  @override
  State<SceneryPreviewPage> createState() => _SceneryPreviewPageState();
}

class _SceneryPreviewPageState extends State<SceneryPreviewPage> {
  DayPhase _dayPhase = DayPhase.afternoon;
  LandscapeVariant? _fullscreenVariant;

  static const _variantLabels = {
    LandscapeVariant.centralPlains: 'Central Plains\n中部平原',
    LandscapeVariant.southPlains: 'South Plains\n南部平原',
    LandscapeVariant.southWetlands: 'South Wetlands\n南部濕地',
    LandscapeVariant.northHills: 'North Hills\n北部丘陵',
    LandscapeVariant.northTerraces: 'North Terraces\n北部梯田',
    LandscapeVariant.centralHills: 'Central Hills\n中部丘陵',
    LandscapeVariant.centralValley: 'Central Valley\n中部山谷',
    LandscapeVariant.eastRiftValley: 'East Rift Valley\n花東縱谷',
    LandscapeVariant.eastFoothills: 'East Foothills\n東部丘陵',
    LandscapeVariant.northEstuary: 'North Estuary\n北部河口',
    LandscapeVariant.southCoast: 'South Coast\n南部海岸',
    LandscapeVariant.eastCoast: 'East Coast\n東部海岸',
  };

  static SceneryBiome _biomeFor(LandscapeVariant v) {
    switch (v) {
      case LandscapeVariant.centralPlains:
      case LandscapeVariant.southPlains:
      case LandscapeVariant.southWetlands:
        return SceneryBiome.plains;
      case LandscapeVariant.northHills:
      case LandscapeVariant.northTerraces:
      case LandscapeVariant.centralHills:
        return SceneryBiome.terraces;
      case LandscapeVariant.centralValley:
      case LandscapeVariant.eastRiftValley:
      case LandscapeVariant.eastFoothills:
        return SceneryBiome.valley;
      case LandscapeVariant.northEstuary:
      case LandscapeVariant.southCoast:
      case LandscapeVariant.eastCoast:
        return SceneryBiome.coast;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreenVariant != null) {
      return _buildFullscreen(_fullscreenVariant!);
    }
    return _buildGrid();
  }

  Widget _buildGrid() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scenery Preview'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<DayPhase>(
            icon: Icon(_dayPhaseIcon(_dayPhase), color: Colors.white),
            onSelected: (phase) => setState(() => _dayPhase = phase),
            itemBuilder: (_) => DayPhase.values.map((p) => PopupMenuItem(
              value: p,
              child: Row(
                children: [
                  Icon(_dayPhaseIcon(p), size: 18),
                  const SizedBox(width: 8),
                  Text(p.name),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: LandscapeVariant.values.length,
        itemBuilder: (context, index) {
          final variant = LandscapeVariant.values[index];
          final biome = _biomeFor(variant);
          return GestureDetector(
            onTap: () => setState(() => _fullscreenVariant = variant),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BiomeSceneryLayer(
                    biome: biome,
                    dayPhase: _dayPhase,
                    variantOverride: variant,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        _variantLabels[variant] ?? variant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullscreen(LandscapeVariant variant) {
    final biome = _biomeFor(variant);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BiomeSceneryLayer(
            biome: biome,
            dayPhase: _dayPhase,
            variantOverride: variant,
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => setState(() => _fullscreenVariant = null),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _variantLabels[variant] ?? variant.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black.withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: DayPhase.values.map((phase) {
                    final isSelected = phase == _dayPhase;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_dayPhaseIcon(phase), size: 16,
                              color: isSelected ? Colors.black : Colors.white70),
                            const SizedBox(width: 4),
                            Text(phase.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.black : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _dayPhase = phase),
                        selectedColor: Colors.amber,
                        backgroundColor: Colors.white12,
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Swipe left/right to navigate variants
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final index = LandscapeVariant.values.indexOf(variant);
              if (details.primaryVelocity != null && details.primaryVelocity! < -300 && index < LandscapeVariant.values.length - 1) {
                setState(() => _fullscreenVariant = LandscapeVariant.values[index + 1]);
              } else if (details.primaryVelocity != null && details.primaryVelocity! > 300 && index > 0) {
                setState(() => _fullscreenVariant = LandscapeVariant.values[index - 1]);
              }
            },
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  IconData _dayPhaseIcon(DayPhase phase) {
    switch (phase) {
      case DayPhase.morning: return Icons.wb_twilight;
      case DayPhase.afternoon: return Icons.wb_sunny;
      case DayPhase.evening: return Icons.nights_stay_outlined;
      case DayPhase.night: return Icons.dark_mode;
    }
  }
}
