enum GrowthStage {
  seedling,
  tillering,
  heading,
  ripening,
  harvested,
}

enum DayPhase {
  morning,
  afternoon,
  evening,
  night,
}

class FieldState {
  GrowthStage growthStage;
  DayPhase dayPeriod;
  List<String> reflections;

  FieldState({
    this.growthStage = GrowthStage.seedling,
    this.dayPeriod = DayPhase.morning,
    this.reflections = const [],
  });
}
