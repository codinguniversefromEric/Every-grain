import 'package:geolocator/geolocator.dart';
import '../models/field_state.dart';

class AgriculturalCalendar {
  // Approximate latitude separating North/South Taiwan farming patterns (around Taichung/Changhua)
  static const double _northSouthDividerLat = 24.0;

  static Future<Position?> getPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  static TaiwanRegion getRegionForPosition(Position? position) {
    if (position == null) return TaiwanRegion.north;
    return position.latitude >= _northSouthDividerLat
        ? TaiwanRegion.north
        : TaiwanRegion.south;
  }

  static GrowthStage getStageForDate(DateTime date, TaiwanRegion region) {
    final month = date.month;

    if (region == TaiwanRegion.south) {
      // Southern Taiwan Calendar
      switch (month) {
        case 1:
        case 2:
          return GrowthStage.seedling;
        case 3:
        case 4:
          return GrowthStage.tillering;
        case 5:
          return GrowthStage.heading;
        case 6:
          return GrowthStage.ripening; // Harvest in June
        case 7:
          return GrowthStage.seedling; // 2nd crop starts
        case 8:
        case 9:
          return GrowthStage.tillering;
        case 10:
          return GrowthStage.heading;
        case 11:
          return GrowthStage.ripening; // Harvest in Nov
        case 12:
          return GrowthStage.fallow; // Rest
        default:
          return GrowthStage.fallow;
      }
    } else {
      // Northern/Central Taiwan Calendar
      switch (month) {
        case 1:
        case 2:
          return GrowthStage.fallow; // Rest
        case 3:
          return GrowthStage.seedling;
        case 4:
        case 5:
          return GrowthStage.tillering;
        case 6:
          return GrowthStage.heading;
        case 7:
          return GrowthStage.ripening; // Harvest in July
        case 8:
          return GrowthStage.seedling; // 2nd crop starts
        case 9:
        case 10:
          return GrowthStage.tillering;
        case 11:
          return GrowthStage.heading;
        case 12:
          return GrowthStage.ripening; // Harvest in Dec
        default:
          return GrowthStage.fallow;
      }
    }
  }

  static String getSeasonText(DateTime date, TaiwanRegion region) {
    final month = date.month;
    bool isFirstCrop = false;
    bool isFallow = false;

    if (region == TaiwanRegion.south) {
      if (month >= 1 && month <= 6) {
        isFirstCrop = true;
      } else if (month >= 7 && month <= 11) {
        isFirstCrop = false;
      } else {
        isFallow = true;
      }
    } else {
      if (month >= 3 && month <= 7) {
        isFirstCrop = true;
      } else if (month >= 8 && month <= 12) {
        isFirstCrop = false;
      } else {
        isFallow = true;
      }
    }

    if (isFallow) return "休耕期 (Winter Fallow)";
    return isFirstCrop ? "一期作 (First Crop)" : "二期作 (Second Crop)";
  }

  static String getPromptForStage(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seedling:
        return '春天播種：有什麼新的開始值得期待？';
      case GrowthStage.tillering:
        return '成長分蘖：今天付出了什麼努力？';
      case GrowthStage.heading:
        return '抽穗孕育：什麼事情正在開花結果？';
      case GrowthStage.ripening:
      case GrowthStage.harvested:
        return '豐收成熟：今天，有什麼值得好好感謝？';
      case GrowthStage.fallow:
        return '冬日休耕：讓心沉澱，今天好好休息了嗎？';
    }
  }
}
