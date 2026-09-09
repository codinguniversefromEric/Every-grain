import 'package:flutter/foundation.dart';
import '../../models/field_state.dart';
import '../ambient_sound.dart';

class AudioController {
  final AmbientSoundService service = AmbientSoundService();

  void updateAmbience(FieldState state, bool isTimeLapseMode) {
    if (isTimeLapseMode) {
      service.pause();
      return;
    }
    service.updateAmbience(
      state.dayPeriod,
      state.growthStage,
      state.weatherMetrics,
    );
  }

  void playHarvestSound() {
    service.playHarvestSound();
  }

  void pauseApp() {
    service.pause();
  }

  void resumeApp(FieldState? state, bool isTimeLapseMode) {
    service.resume();
    if (state != null) {
      updateAmbience(state, isTimeLapseMode);
    }
  }
}
