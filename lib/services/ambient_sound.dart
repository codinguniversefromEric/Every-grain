import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import '../models/field_state.dart';
import '../models/weather_metrics.dart';
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
  
  Timer? _oneShotTimer;
  WeatherMetrics _currentMetrics = WeatherMetrics.clearSky();

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _ambientPlayer.setLoopMode(LoopMode.one);
    await _ambientPlayer.setVolume(0.3);
    _startOneShotTimer();
  }

  void _startOneShotTimer() {
    _oneShotTimer?.cancel();
    final randomSeconds = 15 + math.Random().nextInt(75); // 15 to 90 seconds
    _oneShotTimer = Timer(Duration(seconds: randomSeconds), () {
      _playOneShot();
      _startOneShotTimer();
    });
  }

  Future<void> _playOneShot() async {
    String? shotSound;
    if (_currentMetrics.isStormy) {
      shotSound = 'assets/audio/distant_thunder.wav';
    } else if (_currentMetrics.isRaining) {
      shotSound = 'assets/audio/water_drip.wav';
    }
    
    if (shotSound != null) {
      final player = AudioPlayer();
      try {
        await player.setAsset(shotSound);
        await player.setVolume(0.5);
        await player.play();
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            player.dispose();
          }
        });
      } catch (e) {
        // Silently fail if mock assets don't exist yet
        player.dispose();
      }
    }
  }

  Future<void> updateAmbience(
    DayPhase phase,
    GrowthStage stage,
    WeatherMetrics metrics,
  ) async {
    _currentMetrics = metrics;
    String targetSound;
    double targetVolume = 0.3;

    if (metrics.isStormy) {
      targetSound = 'assets/audio/storm.wav';
      targetVolume = 0.6;
    } else if (metrics.isRaining) {
      targetSound = 'assets/audio/rain.wav';
      // Scale volume based on precipitation (2mm/h -> 0.3, 10mm/h -> 0.6)
      targetVolume = (0.3 + (metrics.precipitation * 0.05)).clamp(0.2, 0.6);
    } else {
      // Scale wind volume based on wind speed
      targetVolume = (0.2 + (metrics.windSpeed * 0.02)).clamp(0.1, 0.4);

      // Fallow / Harvested (Winter/Late Autumn)
      if (stage == GrowthStage.fallow || stage == GrowthStage.harvested) {
        targetSound = 'assets/audio/winter_birds_wind.wav';
      }
      // Seedling / Tillering (Spring/Early Summer)
      else if (stage == GrowthStage.seedling || stage == GrowthStage.tillering) {
        if (phase == DayPhase.evening || phase == DayPhase.night) {
          targetSound = 'assets/audio/spring_frogs.wav';
        } else {
          targetSound = 'assets/audio/winter_birds_wind.wav';
        }
      }
      // Heading (Summer)
      else if (stage == GrowthStage.heading) {
        if (phase == DayPhase.afternoon || phase == DayPhase.morning) {
          targetSound = 'assets/audio/summer_cicadas.wav';
        } else {
          targetSound = 'assets/audio/spring_frogs.wav';
        }
      }
      // Ripening (Autumn)
      else {
        if (phase == DayPhase.evening || phase == DayPhase.night) {
          targetSound = 'assets/audio/autumn_crickets.wav';
        } else {
          targetSound = 'assets/audio/winter_birds_wind.wav';
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
    
    _ambientPlayer.setVolume(targetVolume);
  }

  void pause() {
    _ambientPlayer.pause();
    _oneShotTimer?.cancel();
  }

  void resume() {
    _ambientPlayer.play();
    _startOneShotTimer();
  }

  Future<void> playHarvestSound() async {
    final player = AudioPlayer();
    try {
      await player.setAsset('assets/audio/harvest_slice.wav');
      await player.play();
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
    _oneShotTimer?.cancel();
    await _ambientPlayer.stop();
    await _ambientPlayer.dispose();
  }
}
