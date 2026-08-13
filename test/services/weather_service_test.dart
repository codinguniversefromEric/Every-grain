import 'package:flutter_test/flutter_test.dart';
import 'package:rice_journey/services/weather_service.dart';
import 'package:rice_journey/models/field_state.dart';

void main() {
  group('WeatherService', () {
    test('getCurrentWeather returns clear when API key is missing (fallback)', () async {
      final weather = await WeatherService.getCurrentWeather(null);
      // In test environment, String.fromEnvironment is empty, so it defaults to clear.
      expect(weather, WeatherCondition.clear);
    });
  });
}
