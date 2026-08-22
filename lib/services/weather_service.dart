import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/field_state.dart';
import 'app_logger.dart';

class WeatherService {
  static const String _cwaApiKey = String.fromEnvironment('CWA_API_KEY');
  static const String _cwaBaseUrl =
      'https://opendata.cwa.gov.tw/api/v1/rest/datastore/O-A0003-001';

  static DateTime? _lastFetchTime;
  static WeatherCondition? _cachedWeather;

  static Future<WeatherCondition> getCurrentWeather(Position? position) async {
    // 1小時快取機制
    if (_lastFetchTime != null && _cachedWeather != null) {
      if (DateTime.now().difference(_lastFetchTime!) <
          const Duration(hours: 1)) {
        AppLogger.i('Using cached weather: $_cachedWeather');
        return _cachedWeather!;
      }
    }

    try {
      WeatherCondition newWeather;

      if (position != null) {
        // 台灣邊界判定 (粗略 Bounding Box)
        bool isInTaiwan =
            position.latitude >= 21.0 &&
            position.latitude <= 26.0 &&
            position.longitude >= 119.0 &&
            position.longitude <= 122.0;

        if (isInTaiwan) {
          AppLogger.i('User in Taiwan, using CWA API');
          newWeather = await _fetchCWAWeather(position);
        } else {
          AppLogger.i('User abroad, using Open-Meteo API');
          newWeather = await _fetchGlobalWeather(position);
        }
      } else {
        // 沒有定位時，預設呼叫 CWA 台北站
        newWeather = await _fetchCWAWeather(null);
      }

      _cachedWeather = newWeather;
      _lastFetchTime = DateTime.now();
      return newWeather;
    } catch (e, stackTrace) {
      // 靜默降級：任何錯誤都不中斷體驗，回傳快取或晴天
      AppLogger.e('Error in getCurrentWeather, falling back', e, stackTrace);
      return _cachedWeather ?? WeatherCondition.clear;
    }
  }

  static Future<WeatherCondition> _fetchGlobalWeather(Position position) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=weather_code',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weatherCode = data['current']['weather_code'] as int?;

      if (weatherCode != null) {
        return _mapWMOToCondition(weatherCode);
      }
    }
    throw Exception('Failed to fetch from Open-Meteo: ${response.statusCode}');
  }

  static Future<WeatherCondition> _fetchCWAWeather(Position? position) async {
    if (_cwaApiKey == 'CWA_API_KEY') {
      return WeatherCondition.clear;
    }

    final url = Uri.parse('$_cwaBaseUrl?Authorization=$_cwaApiKey&format=JSON');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stations = data['records']['Station'] as List;

      if (stations.isEmpty) return WeatherCondition.clear;

      Map<String, dynamic>? nearestStation;
      double minDistance = double.infinity;

      if (position != null) {
        for (var station in stations) {
          try {
            final coordinates = station['GeoInfo']['Coordinates'] as List;
            final wgs84 = coordinates.firstWhere(
              (c) => c['CoordinateName'] == 'WGS84',
              orElse: () => coordinates.first,
            );

            final lat = double.parse(wgs84['StationLatitude']);
            final lon = double.parse(wgs84['StationLongitude']);

            final distance = _calculateHaversineDistance(
              position.latitude,
              position.longitude,
              lat,
              lon,
            );

            if (distance < minDistance) {
              minDistance = distance;
              nearestStation = station;
            }
          } catch (e) {
            // Ignore parse error for individual stations
          }
        }
      } else {
        nearestStation = stations.firstWhere(
          (s) => s['StationName'] == '臺北',
          orElse: () => stations.first,
        );
      }

      if (nearestStation != null) {
        final weatherElement = nearestStation['WeatherElement'];
        final weatherStr = weatherElement['Weather'] as String? ?? '-99';

        if (weatherStr != '-99') {
          return _mapWeatherStringToCondition(weatherStr);
        } else {
          final precipStr =
              weatherElement['Now']?['Precipitation'] as String? ?? '0.0';
          final precip = double.tryParse(precipStr) ?? 0.0;
          if (precip > 0.0) {
            return precip > 5.0
                ? WeatherCondition.stormy
                : WeatherCondition.rainy;
          }
          return WeatherCondition.cloudy;
        }
      }
    }
    throw Exception('Failed to fetch from CWA: ${response.statusCode}');
  }

  static double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  static WeatherCondition _mapWeatherStringToCondition(String weather) {
    if (weather.contains('晴')) {
      if (weather.contains('多雲') ||
          weather.contains('陰') ||
          weather.contains('靄') ||
          weather.contains('霧')) {
        return WeatherCondition.cloudy;
      }
      return WeatherCondition.clear;
    } else if (weather.contains('雷')) {
      return WeatherCondition.stormy;
    } else if (weather.contains('雨')) {
      return WeatherCondition.rainy;
    } else if (weather.contains('陰') ||
        weather.contains('多雲') ||
        weather.contains('霧') ||
        weather.contains('靄')) {
      return WeatherCondition.cloudy;
    }
    return WeatherCondition.clear;
  }

  static WeatherCondition _mapWMOToCondition(int code) {
    // 0: Clear sky, 1: Mainly clear
    if (code == 0 || code == 1) {
      return WeatherCondition.clear;
    }
    // 2: partly cloudy, 3: overcast, 45, 48: fog
    if (code == 2 || code == 3 || code == 45 || code == 48) {
      return WeatherCondition.cloudy;
    }
    // 51-86: Drizzle, Rain, Snow, Showers
    if (code >= 51 && code <= 86) {
      return WeatherCondition.rainy;
    }
    // 95-99: Thunderstorm
    if (code >= 95 && code <= 99) {
      return WeatherCondition.stormy;
    }

    return WeatherCondition.clear;
  }
}
