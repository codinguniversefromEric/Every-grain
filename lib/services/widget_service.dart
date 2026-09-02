import 'package:home_widget/home_widget.dart';
import '../models/field_state.dart';
import '../widgets/widget_scenery_snapshot.dart';

class WidgetService {
  static const String appGroupId = 'group.com.chia.riceJourney';
  static const String androidWidgetName = 'RiceWidgetProvider';
  static const String iosWidgetName = 'RiceWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidget(FieldState? state, {bool hasUnreadJournal = false}) async {
    if (state == null) return;

    // Convert enum values to simple strings for the widget to display
    String stageText = _getStageText(state.growthStage);
    String weatherText = _getWeatherText(state.weatherCondition);
    
    await HomeWidget.saveWidgetData<String>('growth_stage', stageText);
    await HomeWidget.saveWidgetData<String>('weather', weatherText);
    await HomeWidget.saveWidgetData<bool>('has_unread_journal', hasUnreadJournal);

    // Render snapshot
    try {
      await HomeWidget.renderFlutterWidget(
        WidgetScenerySnapshot(
          state: state,
          hasUnreadJournal: hasUnreadJournal,
        ),
        logicalSize: const Size(400, 400),
        key: 'scenery_image',
      );
    } catch (e) {
      debugPrint('Failed to render widget snapshot: $e');
    }

    // Trigger update for both platforms
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iosWidgetName,
    );
  }

  static String _getStageText(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.fallow: return '休耕中';
      case GrowthStage.seedling: return '秧苗期';
      case GrowthStage.tillering: return '分蘖期';
      case GrowthStage.heading: return '抽穗期';
      case GrowthStage.ripening: return '成熟期';
      case GrowthStage.harvested: return '已收割';
    }
  }

  static String _getWeatherText(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear: return '晴朗';
      case WeatherCondition.cloudy: return '多雲';
      case WeatherCondition.rainy: return '有雨';
      case WeatherCondition.stormy: return '雷雨';
    }
  }
}
