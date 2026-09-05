import '../../../models/weather_metrics.dart';

/// The deep module seam for weather data. 
/// Adapters implement this to fetch real or simulated weather data and
/// map it to the unified [WeatherMetrics] domain model.
abstract class WeatherAdapter {
  /// Fetches weather data for a given GPS coordinate.
  Future<WeatherMetrics> fetchWeather(double latitude, double longitude);
}
