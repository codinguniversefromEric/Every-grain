import 'weather_adapter.dart';
import '../../../models/weather_metrics.dart';

/// A deterministic weather adapter strictly for Developer Controls and testing.
class FakeWeatherAdapter implements WeatherAdapter {
  WeatherMetrics _forcedMetrics = WeatherMetrics.clearSky();

  /// Injects a specific macro event (like "Typhoon") into the adapter.
  void forceWeather(WeatherMetrics metrics) {
    _forcedMetrics = metrics;
  }

  @override
  Future<WeatherMetrics> fetchWeather(double latitude, double longitude) async {
    // Return the forced metrics immediately.
    return _forcedMetrics;
  }
}
