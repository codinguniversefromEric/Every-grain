import 'package:just_audio/just_audio.dart';
import '../models/field_state.dart';

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

  Future<void> updateAmbience(DayPhase phase, GrowthStage stage) async {
    String targetSound;

    if (stage == GrowthStage.fallow) {
      targetSound = 'assets/audio/water.wav';
    } else if (phase == DayPhase.night) {
      targetSound = 'assets/audio/crickets.wav';
    } else if (phase == DayPhase.evening) {
      targetSound = 'assets/audio/evening_wind.wav';
    } else {
      targetSound = 'assets/audio/wind.wav';
    }

    if (targetSound != _currentSound) {
      _currentSound = targetSound;
      try {
        await _ambientPlayer.setAsset(targetSound);
        _ambientPlayer.play();
      } catch (e) {
        // Silently handle missing audio files
      }
    }
  }

  void pause() {
    _ambientPlayer.pause();
  }

  void resume() {
    _ambientPlayer.play();
  }

  Future<void> dispose() async {
    await _ambientPlayer.stop();
    await _ambientPlayer.dispose();
  }
}

