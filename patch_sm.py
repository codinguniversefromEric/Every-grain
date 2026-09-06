import re

with open("lib/services/state_manager.dart", "r", encoding="utf-8") as f:
    content = f.read()

func = """  Future<void> clearWeatherOverride() async {
    if (_state != null) {
      _state!.weatherOverrideUntil = null;
      _state!.overriddenMetrics = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('weatherOverrideUntil');
      _weatherService.getCurrentWeather(_lastPosition, forceRefresh: true).then((metrics) {
        if (_state != null && _state!.overriddenMetrics == null) {
          _state!.weatherMetrics = metrics;
          _updateAmbience();
          notifyListeners();
        }
      });
      notifyListeners();
    }
  }

  Future<void> applyWeatherOverride(WeatherMetrics overridden) async {"""

content = content.replace("  Future<void> applyWeatherOverride(WeatherMetrics overridden) async {", func)

with open("lib/services/state_manager.dart", "w", encoding="utf-8") as f:
    f.write(content)
