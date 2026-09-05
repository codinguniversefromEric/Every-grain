import 'package:geolocator/geolocator.dart';
import '../models/weather_metrics.dart';
import 'app_logger.dart';
import 'weather/adapters/weather_adapter.dart';
import 'weather/adapters/cwa_weather_adapter.dart';
import 'weather/adapters/open_meteo_weather_adapter.dart';
import 'weather/adapters/fake_weather_adapter.dart';

/// The deep module for fetching weather data.
/// It hides the complexity of picking the correct API (CWA vs Open-Meteo) 
/// or injecting fake data for testing.
class WeatherService {
  final WeatherAdapter _cwaAdapter;
  final WeatherAdapter _openMeteoAdapter;
  final FakeWeatherAdapter _fakeAdapter;

  bool _isBetaTestMode = false;
  
  static DateTime? _lastFetchTime;
  static WeatherMetrics? _cachedWeather;

  WeatherService({
    String cwaApiKey = const String.fromEnvironment('CWA_API_KEY'),
  })  : _cwaAdapter = CwaWeatherAdapter(cwaApiKey),
        _openMeteoAdapter = OpenMeteoWeatherAdapter(),
        _fakeAdapter = FakeWeatherAdapter();

  /// Toggles the beta test mode. When true, fetches will route to the FakeAdapter.
  void setBetaTestMode(bool isBeta) {
    _isBetaTestMode = isBeta;
  }

  /// Injects a forced macro event (like Typhoon) for the Developer Controls.
  void forceWeatherEvent(WeatherMetrics metrics) {
    _fakeAdapter.forceWeather(metrics);
    _cachedWeather = metrics; // Immediately apply to cache so UI updates fast.
  }

  Future<WeatherMetrics> getCurrentWeather(Position? position, {bool forceRefresh = false}) async {
    // 1. Beta Test Mode routing
    if (_isBetaTestMode) {
      final fakeWeather = await _fakeAdapter.fetchWeather(0, 0);
      _cachedWeather = fakeWeather;
      return fakeWeather;
    }

    // 2. Cache check
    if (!forceRefresh && _lastFetchTime != null && _cachedWeather != null) {
      if (DateTime.now().difference(_lastFetchTime!) < const Duration(hours: 1)) {
        AppLogger.i('Using cached weather: $_cachedWeather');
        return _cachedWeather!;
      }
    }

    try {
      WeatherMetrics newWeather;

      if (position != null) {
        // 台灣邊界判定 (粗略 Bounding Box)
        bool isInTaiwan = position.latitude >= 21.0 &&
            position.latitude <= 26.0 &&
            position.longitude >= 119.0 &&
            position.longitude <= 122.0;

        if (isInTaiwan) {
          AppLogger.i('User in Taiwan, routing to CwaAdapter');
          try {
            newWeather = await _cwaAdapter.fetchWeather(position.latitude, position.longitude);
          } catch (e) {
            AppLogger.w('CWA API failed ($e), gracefully degrading to OpenMeteoAdapter');
            newWeather = await _openMeteoAdapter.fetchWeather(position.latitude, position.longitude);
          }
        } else {
          AppLogger.i('User abroad, routing to OpenMeteoAdapter');
          newWeather = await _openMeteoAdapter.fetchWeather(position.latitude, position.longitude);
        }
      } else {
        // Fallback Miaoli coordinates
        AppLogger.i('No position, using fallback Miaoli coordinates via OpenMeteoAdapter');
        newWeather = await _openMeteoAdapter.fetchWeather(24.5602, 120.8214);
      }

      _cachedWeather = newWeather;
      _lastFetchTime = DateTime.now();
      return newWeather;
    } catch (e, stackTrace) {
      AppLogger.e('Error in getCurrentWeather, falling back', e, stackTrace);
      return _cachedWeather ?? WeatherMetrics.clearSky();
    }
  }
}
