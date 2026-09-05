import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'weather_adapter.dart';
import '../../../models/weather_metrics.dart';

class CwaWeatherAdapter implements WeatherAdapter {
  final String _apiKey;
  static const String _cwaBaseUrl =
      'https://opendata.cwa.gov.tw/api/v1/rest/datastore/O-A0001-001';

  CwaWeatherAdapter(this._apiKey);

  @override
  Future<WeatherMetrics> fetchWeather(double latitude, double longitude) async {
    if (_apiKey.isEmpty || _apiKey == 'CWA_API_KEY') {
      throw Exception('CWA API key is missing or not configured');
    }

    final url = Uri.parse('$_cwaBaseUrl?Authorization=$_apiKey&format=JSON');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stations = data['records']['Station'] as List;

      if (stations.isEmpty) throw Exception('No stations returned from CWA');

      Map<String, dynamic>? nearestStation;
      double minDistance = double.infinity;

      for (var station in stations) {
        try {
          final coordinates = station['GeoInfo']['Coordinates'] as List;
          final wgs84 = coordinates.firstWhere(
            (c) => c['CoordinateName'] == 'WGS84',
            orElse: () => coordinates.first,
          );

          final lat = double.parse(wgs84['StationLatitude'].toString());
          final lon = double.parse(wgs84['StationLongitude'].toString());

          final distance = _calculateHaversineDistance(latitude, longitude, lat, lon);
          if (distance < minDistance) {
            minDistance = distance;
            nearestStation = station;
          }
        } catch (e) {
          // Ignore parse errors for individual stations
        }
      }

      if (nearestStation != null) {
        final weatherElement = nearestStation['WeatherElement'];
        final tempStr = (weatherElement['AirTemperature'] ?? weatherElement['TEMP'])?.toString() ?? '25.0';
        final humStr = (weatherElement['RelativeHumidity'] ?? weatherElement['HUMD'])?.toString() ?? '60.0';
        final windStr = (weatherElement['WindSpeed'] ?? weatherElement['WDSD'])?.toString() ?? '0.0';
        final windDirStr = (weatherElement['WindDirection'] ?? weatherElement['WDIR'])?.toString() ?? '0.0';
        
        // Precipitation could be in Now/Precipitation or just H_24R or HOUR_24
        String precipStr = '0.0';
        if (weatherElement['Now'] != null && weatherElement['Now']['Precipitation'] != null) {
          precipStr = weatherElement['Now']['Precipitation'].toString();
        } else if (weatherElement['HOUR_24'] != null) {
          precipStr = weatherElement['HOUR_24'].toString();
        } else if (weatherElement['H_24R'] != null) {
          precipStr = weatherElement['H_24R'].toString();
        }

        final temp = double.tryParse(tempStr) ?? 25.0;
        double hum = double.tryParse(humStr) ?? 60.0;
        // HUMD in O-A0001 is often 0~1 range, so check if it's <= 1.0 (except 0)
        if (hum > 0 && hum <= 1.0) hum *= 100.0;

        final windSpeed = double.tryParse(windStr) ?? 0.0;
        final windDir = double.tryParse(windDirStr) ?? 0.0;
        double precip = double.tryParse(precipStr) ?? 0.0;
        
        if (precip < 0) precip = 0.0; // handle -99.0 missing values
        
        // Approximate cloud cover from weather text or just infer from rain
        double cloudCover = 10.0;
        final weatherStr = weatherElement['Weather'] as String? ?? '';
        if (weatherStr.contains('陰') || precip > 0) cloudCover = 90.0;
        else if (weatherStr.contains('多雲')) cloudCover = 50.0;

        return WeatherMetrics(
          temperature: temp == -99.0 ? 25.0 : temp,
          humidity: hum == -99.0 ? 60.0 : hum,
          windSpeed: windSpeed == -99.0 ? 0.0 : windSpeed,
          windDirection: windDir == -99.0 ? 0.0 : windDir,
          cloudCoverPercentage: cloudCover,
          precipitationIntensity: precip,
        );
      }
    }
    throw Exception('Failed to fetch from CWA: ${response.statusCode}');
  }

  static double _calculateHaversineDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const double r = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
