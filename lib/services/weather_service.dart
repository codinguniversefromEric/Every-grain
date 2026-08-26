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
  static WeatherMetrics? _cachedWeather;

  static Future<WeatherMetrics> getCurrentWeather(Position? position, {bool forceRefresh = false}) async {
    // 1小時快取機制
    if (!forceRefresh && _lastFetchTime != null && _cachedWeather != null) {
      if (DateTime.now().difference(_lastFetchTime!) <
          const Duration(hours: 1)) {
        AppLogger.i('Using cached weather: $_cachedWeather');
        return _cachedWeather!;
      }
    }

    try {
      WeatherMetrics newWeather;

      if (position != null) {
        // 台灣邊界判定 (粗略 Bounding Box)
        bool isInTaiwan =
            position.latitude >= 21.0 &&
            position.latitude <= 26.0 &&
            position.longitude >= 119.0 &&
            position.longitude <= 122.0;

        if (isInTaiwan) {
          AppLogger.i('User in Taiwan, using CWA API');
          try {
            newWeather = await _fetchCWAWeather(position);
          } catch (e) {
            AppLogger.w('CWA API failed ($e), gracefully degrading to Open-Meteo');
            newWeather = await _fetchGlobalWeather(position);
          }
        } else {
          AppLogger.i('User abroad, using Open-Meteo API');
          newWeather = await _fetchGlobalWeather(position);
        }
      } else {
        // 沒有定位時，預設呼叫 CWA 苗栗縣站
        try {
          newWeather = await _fetchCWAWeather(null);
        } catch (e) {
          AppLogger.w('CWA API failed for default location ($e), gracefully degrading to Open-Meteo (Miaoli coordinates)');
          // Provide Miaoli coordinates for fallback
          final fallbackPos = Position(
            latitude: 24.5602,
            longitude: 120.8214,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
          newWeather = await _fetchGlobalWeather(fallbackPos);
        }
      }

      _cachedWeather = newWeather;
      _lastFetchTime = DateTime.now();
      return newWeather;
    } catch (e, stackTrace) {
      // 靜默降級：任何錯誤都不中斷體驗，回傳快取或晴天
      AppLogger.e('Error in getCurrentWeather, falling back', e, stackTrace);
      return _cachedWeather ?? const WeatherMetrics();
    }
  }

  static Future<WeatherMetrics> _fetchGlobalWeather(Position position) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=weather_code,wind_speed_10m,precipitation',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current'];
      
      final weatherCode = current['weather_code'] as int? ?? 0;
      final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
      final precipitation = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
      
      return WeatherMetrics(
        weatherCode: weatherCode,
        windSpeed: windSpeed,
        precipitation: precipitation,
      );
    }
    throw Exception('Failed to fetch from Open-Meteo: ${response.statusCode}');
  }

  static Future<WeatherMetrics> _fetchCWAWeather(Position? position) async {
    if (_cwaApiKey.isEmpty || _cwaApiKey == 'CWA_API_KEY') {
      throw Exception('CWA API key is missing or not configured');
    }

    final url = Uri.parse('$_cwaBaseUrl?Authorization=$_cwaApiKey&format=JSON');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stations = data['records']['Station'] as List;

      if (stations.isEmpty) return const WeatherMetrics();

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

            final lat = double.parse(wgs84['StationLatitude'].toString());
            final lon = double.parse(wgs84['StationLongitude'].toString());

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
          (s) => s['GeoInfo']?['CountyName'] == '苗栗縣',
          orElse: () => stations.firstWhere(
            (s) => s['StationName'] == '苗栗',
            orElse: () => stations.first,
          ),
        );
      }

      if (nearestStation != null) {
        final weatherElement = nearestStation['WeatherElement'];
        final weatherStr = weatherElement['Weather'] as String? ?? '-99';
        final windStr = weatherElement['WindSpeed']?.toString() ?? '0.0';
        final windSpeed = double.tryParse(windStr) ?? 0.0;
        final precipStr = weatherElement['Now']?['Precipitation']?.toString() ?? '0.0';
        
        double precip = double.tryParse(precipStr) ?? 0.0;
        if (precip < 0) precip = 0.0; // handle -99.0

        int code = 0;
        if (weatherStr != '-99') {
          final condition = _mapWeatherStringToCondition(weatherStr);
          code = _conditionToWMO(condition);
        } else {
          final condition = precip > 0.0
                ? (precip > 5.0 ? WeatherCondition.stormy : WeatherCondition.rainy)
                : WeatherCondition.cloudy;
          code = _conditionToWMO(condition);
        }

        return WeatherMetrics(
          precipitation: precip,
          windSpeed: windSpeed,
          weatherCode: code,
        );
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
    if (weather.contains('雷')) {
      return WeatherCondition.stormy;
    } else if (weather.contains('雨')) {
      return WeatherCondition.rainy;
    } else if (weather.contains('陰') ||
        weather.contains('多雲') ||
        weather.contains('霧') ||
        weather.contains('靄')) {
      return WeatherCondition.cloudy;
    } else if (weather.contains('晴')) {
      return WeatherCondition.clear;
    }
    return WeatherCondition.clear;
  }

  static WeatherCondition _mapWMOToCondition(int code) {
    if (code == 0 || code == 1) return WeatherCondition.clear;
    if (code == 2 || code == 3 || code == 45 || code == 48) return WeatherCondition.cloudy;
    if (code >= 51 && code <= 86) return WeatherCondition.rainy;
    if (code >= 95 && code <= 99) return WeatherCondition.stormy;
    return WeatherCondition.clear;
  }
  
  static int _conditionToWMO(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear: return 0;
      case WeatherCondition.cloudy: return 3;
      case WeatherCondition.rainy: return 61;
      case WeatherCondition.stormy: return 95;
    }
  }
}
