import 'package:home_widget/home_widget.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field_state.dart';
import '../widgets/widget_scenery_snapshot.dart';
import '../l10n/app_localizations.dart';

class WidgetService {
  static const String appGroupId = 'group.com.chia.riceJourney';
  static const String androidWidgetName = 'RiceWidgetProvider';
  static const String iosWidgetName = 'RiceWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidget(FieldState? state, {bool hasUnreadJournal = false}) async {
    if (state == null) return;

    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('pref_locale') ?? 'zh';
    final loc = lookupAppLocalizations(Locale(langCode));

    // Convert enum values to simple strings for the widget to display
    String stageText = _getStageText(state.growthStage, loc);
    String weatherText = _getWeatherText(state.weatherCondition, loc);
    
    await HomeWidget.saveWidgetData<String>('growth_stage', stageText);
    await HomeWidget.saveWidgetData<String>('weather', weatherText);
    await HomeWidget.saveWidgetData<bool>('has_unread_journal', hasUnreadJournal);

    // Render snapshot
    if (const String.fromEnvironment('DISABLE_HOME_WIDGET', defaultValue: 'false') != 'true') {
      try {
        await HomeWidget.renderFlutterWidget(
          WidgetScenerySnapshot(
            state: state,
            hasUnreadJournal: hasUnreadJournal,
            loc: loc,
          ),
          logicalSize: const Size(400, 400),
          key: 'scenery_image',
        );
      } catch (e) {
        debugPrint('Failed to render widget snapshot: $e');
      }
    }

    // Trigger update for both platforms
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iosWidgetName,
    );
  }

  static String _getStageText(GrowthStage stage, AppLocalizations loc) {
    switch (stage) {
      case GrowthStage.fallow: return loc.widgetStageFallow;
      case GrowthStage.seedling: return loc.widgetStageSeedling;
      case GrowthStage.tillering: return loc.widgetStageTillering;
      case GrowthStage.heading: return loc.widgetStageHeading;
      case GrowthStage.ripening: return loc.widgetStageRipening;
      case GrowthStage.harvested: return loc.widgetStageHarvested;
      case GrowthStage.dead: return loc.widgetStageDead;
    }
  }

  static String _getWeatherText(WeatherCondition condition, AppLocalizations loc) {
    switch (condition) {
      case WeatherCondition.clear: return loc.widgetWeatherClear;
      case WeatherCondition.cloudy: return loc.widgetWeatherCloudy;
      case WeatherCondition.rainy: return loc.widgetWeatherRainy;
      case WeatherCondition.stormy: return loc.widgetWeatherStormy;
    }
  }
}
