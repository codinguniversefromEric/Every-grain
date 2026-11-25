import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/field_state.dart';
import '../visuals/scenery/biome_scenery_layer.dart';
import '../visuals/scenery/rainy_field_lane.dart';

/// A debug page that lets testers preview landscape variants
/// with toggleable day phase and weather conditions.
class SceneryPreviewPage extends StatefulWidget {
  const SceneryPreviewPage({super.key});

  @override
  State<SceneryPreviewPage> createState() => _SceneryPreviewPageState();
}

class _SceneryPreviewPageState extends State<SceneryPreviewPage> {
  DayPhase _dayPhase = DayPhase.afternoon;
  LandscapeVariant? _fullscreenVariant;

  static const _rainyFieldLaneTitle = '雨後的田邊';

  static const _variantLabels = {
    LandscapeVariant.centralPlains: 'Central Plains\n中部平原',
    LandscapeVariant.southPlains: 'South Plains\n南部平原',
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

  static const _landscapeReferences = {
    LandscapeVariant.centralPlains: (
      '彰化二水・八堡圳',
      'https://www.iachu.nat.gov.tw/about/WorkStationPage?a=10461&id=144',
    ),
    LandscapeVariant.southPlains: (
      '高雄大樹・鳳梨田',
      'https://www.kcg.gov.tw/News_Video_Content.aspx?n=068B982FDBB4C923&s=9E7AC85F1954DDA8',
    ),
    LandscapeVariant.northHills: (
      '台北貓空・茶園步道',
      'https://www.travel.taipei/en/media/audio-guide/details/501',
    ),
    LandscapeVariant.northTerraces: (
      '新北石門嵩山・石砌梯田',
      'https://www.ca.ntpc.gov.tw/home.jsp?id=103&parentpath=0%2C3%2C101',
    ),
    LandscapeVariant.centralHills: (
      '南投名間松柏嶺・茶園農路',
      'https://www.trimt-nsa.gov.tw/zh-tw/tour/56/',
    ),
    LandscapeVariant.centralValley: (
      '台中大甲溪・卵礫石河床',
      'https://web.wra.gov.tw/WraLib/wSite/books_63919',
    ),
    LandscapeVariant.eastRiftValley: (
      '台東池上・新開園老田區',
      'https://nchdb.boch.gov.tw/city/TAITUNG/assets/overview/culturalLandscape/20140530000007/',
    ),
    LandscapeVariant.eastFoothills: (
      '花蓮富里六十石山・金針花田',
      'https://www.erv-nsa.gov.tw/zh-tw/Attractions/Detail/58',
    ),
    LandscapeVariant.northEstuary: (
      '新北淡水・紅樹林棧道',
      'https://newtaipei.travel/zh-tw/attractions/detail/109656',
    ),
    LandscapeVariant.southCoast: (
      '屏東恆春・珊瑚礁海岸',
      'https://www.ktnp.gov.tw/News_Content2.aspx?n=85E1E406503C665B&s=AF9EF3A8785FF5A8',
    ),
    LandscapeVariant.eastCoast: (
      '花蓮清水斷崖・礫灘',
      'https://www.taroko.gov.tw/ch/sglarticle/transportation-and-trails',
    ),
  };

  static SceneryBiome _biomeFor(LandscapeVariant v) {
    switch (v) {
      case LandscapeVariant.centralPlains:
      case LandscapeVariant.southPlains:
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
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 275,
          childAspectRatio: 1.0,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: LandscapeVariant.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildRainyFieldLanePreview(context);
          final variant = LandscapeVariant.values[index - 1];
          return GestureDetector(
            onTap: () => setState(() => _fullscreenVariant = variant),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildLandscape(variant),
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

  Widget _buildRainyFieldLanePreview(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: _rainyFieldLaneTitle,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: const Text(_rainyFieldLaneTitle),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    tooltip: '畫面對照',
                    icon: const Icon(Icons.compare_outlined),
                    onPressed: () => _openComparison(),
                  ),
                ],
              ),
              body: const RainyFieldLane(interactive: true),
              bottomNavigationBar: const SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    '點天空切換細雨，點稻田驚起白鷺鷥。\n'
                    '點屋子開關燈，輕觸或滑過水圳看漣漪。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          )),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const RainyFieldLane(),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(_rainyFieldLaneTitle,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscape(LandscapeVariant variant, {bool interactive = false}) {
    final sky = switch (_dayPhase) {
      DayPhase.morning => const [Color(0xFFA6B9C5), Color(0xFFDFE3D5)],
      DayPhase.afternoon => const [Color(0xFF9EADB9), Color(0xFFD8DFDD)],
      DayPhase.evening => const [Color(0xFF737A8C), Color(0xFFCCAC96)],
      DayPhase.night => const [Color(0xFF171F30), Color(0xFF344759)],
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: sky,
        ),
      ),
      child: BiomeSceneryLayer(
        biome: _biomeFor(variant),
        dayPhase: _dayPhase,
        variantOverride: variant,
        interactive: interactive,
      ),
    );
  }

  void _openComparison([LandscapeVariant? variant]) {
    const directory = 'assets/scenery_references';
    const sheets = [
      'plains_and_maokong.jpg',
      'terraces_and_valleys.jpg',
      'foothills_and_coasts.jpg',
    ];
    const quadrants = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ];
    // The lower-left tile of the first sheet belonged to the retired Qigu scene.
    final variantIndex = variant?.index;
    final index = variantIndex == null || variantIndex < 2
        ? variantIndex
        : variantIndex + 1;
    final asset = index == null
        ? '$directory/rainy_field_lane.jpg'
        : '$directory/${sheets[index ~/ quadrants.length]}';
    final alignment = index == null ? null : quadrants[index % quadrants.length];
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _SceneryComparisonPage(
        title: variant == null ? _rainyFieldLaneTitle : _landscapeReferences[variant]!.$1,
        asset: asset,
        alignment: alignment,
        scene: variant == null ? const RainyFieldLane() : _buildLandscape(variant),
      ),
    ));
  }

  Widget _buildFullscreen(LandscapeVariant variant) {
    final (place, source) = _landscapeReferences[variant]!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildLandscape(variant, interactive: true),
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
                      tooltip: '返回場景總覽',
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => setState(() => _fullscreenVariant = null),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _variantLabels[variant] ?? variant.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(place,
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '畫面對照',
                      icon: const Icon(Icons.compare_outlined, color: Colors.white),
                      onPressed: () => _openComparison(variant),
                    ),
                    IconButton(
                      tooltip: '開啟地景參考',
                      icon: const Icon(Icons.open_in_new, color: Colors.white70),
                      onPressed: () async {
                        final opened = await launchUrl(
                          Uri.parse(source),
                          mode: LaunchMode.externalApplication,
                        );
                        if (!opened && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('無法開啟地景參考')),
                          );
                        }
                      },
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: DayPhase.values.map((phase) {
                    final isSelected = phase == _dayPhase;
                    return ChoiceChip(
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

class _SceneryComparisonPage extends StatelessWidget {
  const _SceneryComparisonPage({
    required this.title,
    required this.asset,
    required this.alignment,
    required this.scene,
  });

  final String title;
  final String asset;
  final Alignment? alignment;
  final Widget scene;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const SizedBox(
        width: 280,
        height: 210,
        child: Center(
          child: Text('參考圖無法顯示', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
    final crop = alignment;
    return Scaffold(
      backgroundColor: const Color(0xFF171C1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171C1B),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 650;
              return Flex(
                direction: sideBySide ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    child: _panel(
                      '構圖參考圖（生成）',
                      FittedBox(
                        fit: BoxFit.contain,
                        child: crop == null
                            ? image
                            : ClipRect(
                                child: Align(
                                  alignment: crop,
                                  widthFactor: 0.5,
                                  heightFactor: 0.5,
                                  child: image,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: sideBySide ? 12 : 0,
                    height: sideBySide ? 0 : 12,
                  ),
                  Expanded(child: _panel('程式繪製', scene)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _panel(String caption, Widget content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(caption, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        Flexible(
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(color: Colors.black, child: content),
            ),
          ),
        ),
      ],
    );
  }
}
