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
    final savedLang = prefs.getString('pref_locale');
    final systemLang = PlatformDispatcher.instance.locale.languageCode;
    String langCode = savedLang ?? systemLang;
    
    // Ensure the resolved language is supported by our app, otherwise fallback to English
    if (!AppLocalizations.supportedLocales.map((l) => l.languageCode).contains(langCode)) {
      langCode = 'en';
    }
    
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
        debugPrint('🍚 Updating widget...');
        
        // 修正 Storage Leak：使用固定檔名，不再每次產生新檔案。
        // Swift 端已經有 UUID() cache busting 機制，不需要靠檔名來破壞快取。
        final String uniqueKey = 'scenery_image_file';
        
        final String path = await HomeWidget.renderFlutterWidget(
          WidgetScenerySnapshot(
            state: state,
            hasUnreadJournal: hasUnreadJournal,
            loc: loc,
          ),
          logicalSize: const Size(400, 400),
          key: uniqueKey,
        );
        
        debugPrint('🍚 image rendered at: $path');
        
        // 由於檔名變了，我們必須告訴 Swift 新的路徑在哪裡
        // Swift 那邊依然是讀取 'scenery_image' 這個鍵值，但內容變成了最新產生的絕對路徑
        await HomeWidget.saveWidgetData<String>('scenery_image', path);
        
      } catch (e) {
        debugPrint('Failed to render widget snapshot: $e');
      }
    }

    // Trigger update for both platforms
    debugPrint('🍚 calling HomeWidget.updateWidget');
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
