import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rice_journey/services/variety_service.dart';
import 'package:rice_journey/models/rice_variety.dart';

void main() {
  group('VarietyService', () {
    test('returns default Taikeng9 when position is null', () {
      final variety = VarietyService.getVarietyForPosition(null);
      expect(variety, RiceVariety.taikeng9);
    });

    test('returns Kaohsiung 139 for East Taiwan', () {
      final pos = Position(
        latitude: 23.0, longitude: 121.5, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
      final variety = VarietyService.getVarietyForPosition(pos);
      expect(variety, RiceVariety.kaohsiung139);
    });

    test('returns Taikeng 9 for North Taiwan', () {
      final pos = Position(
        latitude: 25.0, longitude: 121.5, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
      final variety = VarietyService.getVarietyForPosition(pos);
      expect(variety, RiceVariety.taikeng9);
    });

    test('returns Tainung 71 for Central Taiwan', () {
      final pos = Position(
        latitude: 24.0, longitude: 120.5, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
      final variety = VarietyService.getVarietyForPosition(pos);
      expect(variety, RiceVariety.tainung71);
    });

    test('returns Tainan 11 for South Taiwan', () {
      final pos = Position(
        latitude: 22.0, longitude: 120.5, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
      final variety = VarietyService.getVarietyForPosition(pos);
      expect(variety, RiceVariety.tainan11);
    });
  });
}
