import 'package:just_audio/just_audio.dart';
import '../models/field_state.dart';
import 'app_logger.dart';

/// Manages ambient nature sounds that shift with time of day and season.
/// Wind during the day, crickets at night, water during fallow.
class AmbientSoundService {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  final AudioPlayer _ambientPlayer = AudioPlayer();
  String? _currentSound;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _ambientPlayer.setLoopMode(LoopMode.one);
    await _ambientPlayer.setVolume(0.3);
  }

  Future<void> updateAmbience(DayPhase phase, GrowthStage stage, {WeatherCondition weather = WeatherCondition.clear}) async {
    String targetSound;

    if (weather == WeatherCondition.rainy) {
      targetSound = 'assets/audio/rain.wav';
    } else if (weather == WeatherCondition.stormy) {
      targetSound = 'assets/audio/storm.wav';
    } else {
      // Fallow / Harvested (Winter/Late Autumn)
    if (stage == GrowthStage.fallow || stage == GrowthStage.harvested) {
      if (phase == DayPhase.morning || phase == DayPhase.afternoon) {
        targetSound = 'assets/audio/winter_birds_wind.wav';
      } else {
        targetSound = 'assets/audio/winter_birds_wind.wav'; // Night time is quieter but we use the same base for now
      }
    } 
    // Seedling / Tillering (Spring/Early Summer)
    else if (stage == GrowthStage.seedling || stage == GrowthStage.tillering) {
      if (phase == DayPhase.evening || phase == DayPhase.night) {
        targetSound = 'assets/audio/spring_frogs.wav';
      } else {
        targetSound = 'assets/audio/winter_birds_wind.wav'; // Wind/water during day
      }
    }
    // Heading (Summer)
    else if (stage == GrowthStage.heading) {
      if (phase == DayPhase.afternoon || phase == DayPhase.morning) {
        targetSound = 'assets/audio/summer_cicadas.wav';
      } else {
        targetSound = 'assets/audio/spring_frogs.wav'; // Frogs at night
      }
    }
    // Ripening (Autumn)
    else {
      if (phase == DayPhase.evening || phase == DayPhase.night) {
        targetSound = 'assets/audio/autumn_crickets.wav';
      } else {
        targetSound = 'assets/audio/winter_birds_wind.wav'; // Wind during day
      }
    }
    }

    if (targetSound != _currentSound) {
      _currentSound = targetSound;
      try {
        await _ambientPlayer.setAsset(targetSound);
        _ambientPlayer.play();
      } catch (e, stackTrace) {
        AppLogger.e('Failed to play ambient sound: $_currentSound', e, stackTrace);
      }
    }
  }

  void pause() {
    _ambientPlayer.pause();
  }

  void resume() {
    _ambientPlayer.play();
  }

  Future<void> playHarvestSound() async {
    final player = AudioPlayer();
    try {
      await player.setAsset('assets/audio/harvest_slice.wav');
      await player.play();
      // Dispose after playing to free resources
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e, stackTrace) {
      AppLogger.e('Failed to play harvest sound', e, stackTrace);
      player.dispose();
    }
  }

  Future<void> dispose() async {
    await _ambientPlayer.stop();
    await _ambientPlayer.dispose();
  }
}

