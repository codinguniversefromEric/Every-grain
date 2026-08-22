import 'package:flutter_test/flutter_test.dart';
import 'package:rice_journey/services/agricultural_calendar.dart';
import 'package:rice_journey/models/field_state.dart';

void main() {
  group('AgriculturalCalendar', () {
    test('getRegionForPosition returns north when position is null', () {
      expect(
        AgriculturalCalendar.getRegionForPosition(null),
        TaiwanRegion.north,
      );
    });
  });
}
