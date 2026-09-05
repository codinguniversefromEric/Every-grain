import 'package:flutter_test/flutter_test.dart';
import 'package:rice_journey/services/weather_service.dart';
import 'package:rice_journey/models/weather_metrics.dart';

void main() {
  group('WeatherService', () {
    test(
      'getCurrentWeather returns WeatherMetrics when API key is missing (fallback)',
      () async {
        final service = WeatherService();
        final weather = await service.getCurrentWeather(null);
        expect(weather, isA<WeatherMetrics>());
        // Verify it has valid precipitation data
        expect(weather.precipitationIntensity, isA<double>());
      },
    );
  });
}
