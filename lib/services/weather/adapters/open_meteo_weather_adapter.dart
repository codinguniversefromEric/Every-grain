import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_adapter.dart';
import '../../../models/weather_metrics.dart';

class OpenMeteoWeatherAdapter implements WeatherAdapter {
  @override
  Future<WeatherMetrics> fetchWeather(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,precipitation,cloud_cover,wind_speed_10m,wind_direction_10m',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current'];

      return WeatherMetrics(
        temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 25.0,
        humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 60.0,
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
        windDirection: (current['wind_direction_10m'] as num?)?.toDouble() ?? 0.0,
        cloudCoverPercentage: (current['cloud_cover'] as num?)?.toDouble() ?? 0.0,
        precipitationIntensity: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      );
    }
    throw Exception('Failed to fetch from Open-Meteo: ${response.statusCode}');
  }
}
