import 'dart:math' as math;

class SolarCalculator {
  /// Calculates the sun's elevation angle (in degrees) for a given location and time.
  /// 
  /// Positive values mean the sun is above the horizon (day).
  /// Negative values mean the sun is below the horizon (night).
  /// Values around 0 (e.g., -6 to 6) indicate twilight/sunrise/sunset.
  static double getSunElevation(double lat, double lon, DateTime time) {
    // 1. Calculate day of the year (1-365)
    final startOfYear = DateTime(time.year, 1, 1);
    final dayOfYear = time.difference(startOfYear).inDays + 1;

    // 2. Fractional year in radians
    final gamma = (2 * math.pi / 365) * (dayOfYear - 1 + (time.hour - 12) / 24);

    // 3. Estimate solar declination angle (in radians)
    // Formula from NOAA Solar Calculator
    final decl = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);

    // 4. Equation of time (in minutes)
    final eqTime = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));

    // 5. True solar time (in minutes)
    final timeOffset = eqTime + (4 * lon) - (time.timeZoneOffset.inMinutes);
    final tst = time.hour * 60 + time.minute + time.second / 60 + timeOffset;

    // 6. Solar hour angle (in degrees, then radians)
    final haDeg = (tst / 4) - 180;
    final ha = haDeg * math.pi / 180;

    final latRad = lat * math.pi / 180;

    // 7. Zenith angle (in radians)
    final cosZenith = math.sin(latRad) * math.sin(decl) +
        math.cos(latRad) * math.cos(decl) * math.cos(ha);
    
    // Clamp to valid range to avoid floating point errors in acos
    final clampedCosZenith = cosZenith.clamp(-1.0, 1.0);
    final zenithAngle = math.acos(clampedCosZenith);

    // 8. Elevation angle = 90 - Zenith
    final elevation = (math.pi / 2) - zenithAngle;
    
    return elevation * 180 / math.pi; // Return in degrees
  }
}
