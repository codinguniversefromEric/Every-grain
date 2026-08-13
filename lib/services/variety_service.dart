import 'package:geolocator/geolocator.dart';
import '../models/rice_variety.dart';

class VarietyService {
  /// Determines the local rice variety based on GPS coordinates.
  static RiceVariety getVarietyForPosition(Position? position) {
    if (position == null) {
      // Default to Taikeng 9 (North) if no GPS
      return RiceVariety.taikeng9;
    }

    final lat = position.latitude;
    final lon = position.longitude;

    // East (Hualien/Taitung) - East of Central Mountain Range
    // Roughly longitude > 121.0 and latitude < 24.5
    if (lon > 121.0 && lat < 24.5) {
      return RiceVariety.kaohsiung139;
    }

    // North (Taipei/New Taipei/Taoyuan/Hsinchu/Yilan)
    if (lat >= 24.5) {
      return RiceVariety.taikeng9;
    }

    // Central (Taichung/Changhua/Nantou/Yunlin)
    if (lat >= 23.5 && lat < 24.5) {
      return RiceVariety.tainung71;
    }

    // South (Chiayi/Tainan/Kaohsiung/Pingtung)
    return RiceVariety.tainan11;
  }
}
