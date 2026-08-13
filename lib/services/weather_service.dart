import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/field_state.dart';
import 'app_logger.dart';

class WeatherService {
  static const String _cwaApiKey = String.fromEnvironment('CWA_API_KEY');
  // O-A0003-001 is the CWA Real-time Station Observation Data
  static const String _cwaBaseUrl = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/O-A0003-001';

  static Future<WeatherCondition> getCurrentWeather(Position? position) async {
    if (_cwaApiKey == 'CWA_API_KEY') {
      return WeatherCondition.clear;
    }

    try {
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
              final wgs84 = coordinates.firstWhere((c) => c['CoordinateName'] == 'WGS84', orElse: () => coordinates.first);
              
              final lat = double.parse(wgs84['StationLatitude']);
              final lon = double.parse(wgs84['StationLongitude']);
              
              final distance = _calculateHaversineDistance(
                position.latitude, position.longitude, lat, lon
              );
              
              if (distance < minDistance) {
                minDistance = distance;
                nearestStation = station;
              }
            } catch (e, stackTrace) {
              AppLogger.e('Error parsing weather station', e, stackTrace);
            }
          }
        } else {
          // If no GPS, fallback to Taipei station (466920) or just the first one
          nearestStation = stations.firstWhere((s) => s['StationName'] == '臺北', orElse: () => stations.first);
        }

        if (nearestStation != null) {
          final weatherElement = nearestStation['WeatherElement'];
          final weatherStr = weatherElement['Weather'] as String? ?? '-99';
          
          if (weatherStr != '-99') {
            return _mapWeatherStringToCondition(weatherStr);
          } else {
            // Fallback: Check precipitation if Weather string is missing (-99)
            final precipStr = weatherElement['Now']?['Precipitation'] as String? ?? '0.0';
            final precip = double.tryParse(precipStr) ?? 0.0;
            if (precip > 0.0) {
              return precip > 5.0 ? WeatherCondition.stormy : WeatherCondition.rainy;
            }
            return WeatherCondition.cloudy; // Default fallback if no rain but unknown weather
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching weather', e, stackTrace);
    }
    
    return WeatherCondition.clear;
  }

  static double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  static WeatherCondition _mapWeatherStringToCondition(String weather) {
    if (weather.contains('晴')) {
      if (weather.contains('多雲') || weather.contains('陰') || weather.contains('靄') || weather.contains('霧')) {
        return WeatherCondition.cloudy; // 晴時多雲, 晴有靄
      }
      return WeatherCondition.clear; // 晴
    } else if (weather.contains('雷')) {
      return WeatherCondition.stormy; // 雷雨
    } else if (weather.contains('雨')) {
      return WeatherCondition.rainy; // 陰有雨, 多雲短暫雨
    } else if (weather.contains('陰') || weather.contains('多雲') || weather.contains('霧') || weather.contains('靄')) {
      return WeatherCondition.cloudy;
    }
    
    return WeatherCondition.clear;
  }
}
