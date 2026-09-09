import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  bool hasReadFirstLetter = false;
  bool hasCompletedPlanting = false;
  Set<String> unlockedVarieties = {};
  DateTime? nextPlantingAllowedAt;
  DateTime? weatherOverrideUntil;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    hasReadFirstLetter = prefs.getBool('hasReadFirstLetter') ?? false;
    hasCompletedPlanting = prefs.getBool('hasCompletedPlanting') ?? false;
    unlockedVarieties = (prefs.getStringList('unlockedVarieties') ?? []).toSet();
    
    final nextPlantingStr = prefs.getString('nextPlantingAllowedAt');
    if (nextPlantingStr != null) {
      nextPlantingAllowedAt = DateTime.parse(nextPlantingStr);
    }
    
    final overrideStr = prefs.getString('weatherOverrideUntil');
    if (overrideStr != null) {
      weatherOverrideUntil = DateTime.parse(overrideStr);
      if (weatherOverrideUntil!.isBefore(DateTime.now())) {
        weatherOverrideUntil = null;
        await prefs.remove('weatherOverrideUntil');
      }
    }
  }

  Future<void> setHasReadFirstLetter(bool value) async {
    hasReadFirstLetter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasReadFirstLetter', value);
  }

  Future<void> setHasCompletedPlanting(bool value) async {
    hasCompletedPlanting = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPlanting', value);
  }

  Future<void> addUnlockedVariety(String varietyId) async {
    if (!unlockedVarieties.contains(varietyId)) {
      unlockedVarieties.add(varietyId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedVarieties', unlockedVarieties.toList());
    }
  }

  Future<void> debugInjectUnlockedCards(List<String> varietyIds) async {
    for (var v in varietyIds) {
      unlockedVarieties.add(v);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlockedVarieties', unlockedVarieties.toList());
  }

  Future<void> setNextPlantingAllowedAt(DateTime? date) async {
    nextPlantingAllowedAt = date;
    final prefs = await SharedPreferences.getInstance();
    if (date != null) {
      await prefs.setString('nextPlantingAllowedAt', date.toIso8601String());
    } else {
      await prefs.remove('nextPlantingAllowedAt');
    }
  }

  Future<void> setWeatherOverrideUntil(DateTime? date) async {
    weatherOverrideUntil = date;
    final prefs = await SharedPreferences.getInstance();
    if (date != null) {
      await prefs.setString('weatherOverrideUntil', date.toIso8601String());
    } else {
      await prefs.remove('weatherOverrideUntil');
    }
  }
}
