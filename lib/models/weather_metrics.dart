class WeatherMetrics {
  /// Temperature in degrees Celsius.
  final double temperature;

  /// Relative humidity as a percentage (0.0 to 100.0).
  final double humidity;

  /// Wind speed in meters per second.
  final double windSpeed;

  /// Wind direction in degrees (0-360).
  final double windDirection;

  /// Cloud cover percentage (0.0 to 100.0).
  final double cloudCoverPercentage;

  /// Precipitation intensity (e.g., mm/h).
  final double precipitationIntensity;

  const WeatherMetrics({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCoverPercentage,
    required this.precipitationIntensity,
  });

  /// Factory for a default/fallback state
  factory WeatherMetrics.clearSky() {
    return const WeatherMetrics(
      temperature: 25.0,
      humidity: 60.0,
      windSpeed: 2.0,
      windDirection: 0.0,
      cloudCoverPercentage: 10.0,
      precipitationIntensity: 0.0,
    );
  }

  /// Factory for extreme weather testing
  factory WeatherMetrics.typhoon() {
    return const WeatherMetrics(
      temperature: 22.0,
      humidity: 98.0,
      windSpeed: 35.0,
      windDirection: 45.0,
      cloudCoverPercentage: 100.0,
      precipitationIntensity: 50.0,
    );
  }

  // --- Convenience getters for UI and audio layers ---

  /// Alias for precipitationIntensity, used by ambient sound layer.
  double get precipitation => precipitationIntensity;

  /// True when precipitation is above zero.
  bool get isRaining => precipitationIntensity > 0.0;

  /// True for severe weather (heavy rain + strong wind).
  bool get isStormy => precipitationIntensity > 5.0 || windSpeed > 15.0;

  /// True when cloud cover is significant.
  bool get isCloudy => cloudCoverPercentage > 45.0;

  @override
  String toString() {
    return 'WeatherMetrics(temp: $temperature, hum: $humidity, wind: $windSpeed, clouds: $cloudCoverPercentage, rain: $precipitationIntensity)';
  }
}
