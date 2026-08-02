import 'package:audioplayers/audioplayers.dart';
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
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setVolume(0.3);
  }

  Future<void> updateAmbience(DayPhase phase, GrowthStage stage) async {
    String targetSound;

    if (stage == GrowthStage.fallow) {
      targetSound = 'audio/water.mp3';
    } else if (phase == DayPhase.night) {
      targetSound = 'audio/crickets.mp3';
    } else if (phase == DayPhase.evening) {
      targetSound = 'audio/evening_wind.mp3';
    } else {
      targetSound = 'audio/wind.mp3';
    }

    if (targetSound != _currentSound) {
      _currentSound = targetSound;
      try {
        await _ambientPlayer.stop();
        await _ambientPlayer.play(AssetSource(targetSound));
      } catch (e) {
        // Silently handle missing audio files
      }
    }
  }

  Future<void> dispose() async {
    await _ambientPlayer.stop();
    await _ambientPlayer.dispose();
  }
}
