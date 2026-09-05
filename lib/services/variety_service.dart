import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/rice_variety.dart';
import '../models/field_state.dart';

class VarietyService {
  /// Determines the local rice variety based on GPS coordinates.
  static RiceVariety getVarietyForPosition(Position? position) {
    if (position == null) {
      // Default to Taikeng 9 (North) if no GPS
      return RiceVariety.taikeng9;
    }

    final lat = position.latitude;
    final lon = position.longitude;
    final rand = Random().nextDouble();

    // 5% chance to get the legendary Tainung 67 anywhere in Taiwan
    if (rand < 0.05) {
      return RiceVariety.tainung67;
    }

    // East (Hualien/Taitung) - East of Central Mountain Range
    if (lon > 121.0 && lat < 24.5) {
      return RiceVariety.kaohsiung139;
    }

    // North (Taipei/New Taipei/Taoyuan/Hsinchu/Yilan)
    if (lat >= 24.8) {
      return RiceVariety.taoyuan3;
    }
    if (lat >= 24.5 && lon > 121.5) {
      return RiceVariety.koshihikari; // Yilan
    }
    if (lat >= 24.5) {
      return RiceVariety.taikeng9; // Greater Taipei / Hsinchu
    }

    // Central (Taichung/Changhua/Nantou/Yunlin)
    if (lat >= 23.8) {
      return rand < 0.5 ? RiceVariety.taichungSen10 : RiceVariety.tainung71;
    }

    // South (Chiayi/Tainan/Kaohsiung/Pingtung)
    if (lat >= 23.0) {
      return RiceVariety.tainan11;
    }
    
    // Deep South (Kaohsiung/Pingtung)
    return RiceVariety.kaohsiung147;
  }

  static SceneryBiome getBiomeForPosition(Position? position) {
    if (position == null) return SceneryBiome.terraces;

    final lat = position.latitude;
    final lon = position.longitude;

    // East (Yilan/Hualien coast)
    if ((lat >= 24.5 && lon > 121.5) || (lat < 24.5 && lon > 121.3)) {
      return SceneryBiome.coast;
    }
    
    // East Rift Valley (Taitung/Inland Hualien)
    if (lon > 121.0 && lat < 24.5) {
      return SceneryBiome.valley;
    }

    // North (Terraces)
    if (lat >= 24.8) {
      return SceneryBiome.terraces;
    }

    // Default to Plains (West coast / Central / South)
    return SceneryBiome.plains;
  }
}
