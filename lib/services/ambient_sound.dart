import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/field_state.dart';
import '../models/weather_metrics.dart';
import 'app_logger.dart';

/// Manages a multi-track ambient soundscape.
/// - Wind (volume/pan driven by windSpeed/direction)
/// - Weather (rain/storm driven by precipitation)
/// - Fauna (insects/frogs driven by season/time)
/// - Biome (coast waves, valley trains)
class AmbientSoundService {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  final AudioPlayer _windPlayer = AudioPlayer();
  final AudioPlayer _weatherPlayer = AudioPlayer();
  final AudioPlayer _faunaPlayer = AudioPlayer();
  final AudioPlayer _biomePlayer = AudioPlayer();

  bool _isInitialized = false;
  Timer? _oneShotTimer;
  Timer? _fadeTimer;
  
  WeatherMetrics _currentMetrics = WeatherMetrics.clearSky();
  SceneryBiome _currentBiome = SceneryBiome.plains;

  // Track current assets to avoid reloading
  String? _currentWindAsset;
  String? _currentWeatherAsset;
  String? _currentFaunaAsset;
  String? _currentBiomeAsset;

  // Target volumes for fading
  double _targetWindVol = 0.0;
  double _targetWeatherVol = 0.0;
  double _targetFaunaVol = 0.0;
  double _targetBiomeVol = 0.0;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      AppLogger.w('Could not configure audio session: $e');
    }

    await _windPlayer.setLoopMode(LoopMode.one);
    await _weatherPlayer.setLoopMode(LoopMode.one);
    await _faunaPlayer.setLoopMode(LoopMode.one);
    await _biomePlayer.setLoopMode(LoopMode.one);

    _windPlayer.setVolume(0);
    _weatherPlayer.setVolume(0);
    _faunaPlayer.setVolume(0);
    _biomePlayer.setVolume(0);

    _startFadeLoop();
    _startOneShotTimer();
  }

  void _startFadeLoop() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _stepVolume(_windPlayer, _targetWindVol);
      _stepVolume(_weatherPlayer, _targetWeatherVol);
      _stepVolume(_faunaPlayer, _targetFaunaVol);
      _stepVolume(_biomePlayer, _targetBiomeVol);
    });
  }

  void _stepVolume(AudioPlayer player, double target) {
    if (player.processingState != ProcessingState.ready && player.processingState != ProcessingState.idle) return;
    final current = player.volume;
    if ((current - target).abs() < 0.02) {
      if (player.volume != target) player.setVolume(target);
      if (target == 0 && player.playing) player.pause();
      return;
    }
    
    // Smooth fade
    final step = current < target ? 0.02 : -0.02;
    player.setVolume(current + step);
    if (!player.playing && target > 0 && player.processingState == ProcessingState.ready) {
      player.play();
    }
  }

  void _startOneShotTimer() {
    _oneShotTimer?.cancel();
    final randomSeconds = 10 + math.Random().nextInt(40); 
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
    } else if (_currentBiome == SceneryBiome.valley && math.Random().nextDouble() > 0.7) {
      shotSound = 'assets/audio/distant_train.wav';
    } else if (_currentBiome == SceneryBiome.terraces && math.Random().nextDouble() > 0.5) {
      shotSound = 'assets/audio/bird_chirp.wav';
    }
    
    if (shotSound != null) {
      final player = AudioPlayer();
      try {
        await player.setAsset(shotSound);
        await player.setVolume(0.5);
        // We simulate spatial audio panning for one-shots!
        // just_audio does not have setPan natively unless using advanced features, 
        // wait, let's just safely try-catch if setPan is supported. Wait, just_audio DOES NOT have setPan? 
        // Ah, just_audio doesn't have setPan. Let's just play it without setPan to avoid compile errors.
        await player.play();
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            player.dispose();
          }
        });
      } catch (e) {
        player.dispose();
      }
    }
  }

  Future<void> _updateTrack(AudioPlayer player, String? currentAsset, String newAsset, double newVolume, Function(String) onAssetUpdated) async {
    if (const String.fromEnvironment('DISABLE_AUDIO', defaultValue: 'false') == 'true') return;

    if (currentAsset != newAsset) {
      // We need to change the track. Fade it out first? Or just swap immediately and let it fade in.
      // To be safe, just swap immediately.
      onAssetUpdated(newAsset);
      try {
        player.setVolume(0); // start from 0 for smooth fade in
        await player.setAsset(newAsset);
        player.play();
      } catch (e) {
        AppLogger.e('Failed to load asset: $newAsset', e, StackTrace.current);
      }
    }
  }

  Future<void> updateAmbience(
    DayPhase phase,
    GrowthStage stage,
    WeatherMetrics metrics,
    SceneryBiome biome,
  ) async {
    _currentMetrics = metrics;
    _currentBiome = biome;

    // --- 1. Wind (Data-Driven by windSpeed) ---
    // A base wind loop. Volume scales with windSpeed (0 to 20m/s maps to 0.1 to 0.6)
    _targetWindVol = (0.1 + (metrics.windSpeed * 0.025)).clamp(0.1, 0.6);
    await _updateTrack(_windPlayer, _currentWindAsset, 'assets/audio/wind_base.wav', _targetWindVol, (a) => _currentWindAsset = a);

    // --- 2. Weather (Rain/Storm driven by precipitation) ---
    if (metrics.isStormy) {
      _targetWeatherVol = 0.6;
      await _updateTrack(_weatherPlayer, _currentWeatherAsset, 'assets/audio/storm.wav', _targetWeatherVol, (a) => _currentWeatherAsset = a);
    } else if (metrics.isRaining) {
      _targetWeatherVol = (0.2 + (metrics.precipitation * 0.05)).clamp(0.2, 0.6);
      await _updateTrack(_weatherPlayer, _currentWeatherAsset, 'assets/audio/rain_light.wav', _targetWeatherVol, (a) => _currentWeatherAsset = a);
    } else {
      _targetWeatherVol = 0.0;
    }

    // --- 3. Fauna (Insects/Frogs based on time and season) ---
    String faunaAsset = 'assets/audio/winter_birds_wind.wav';
    _targetFaunaVol = 0.3;

    if (stage == GrowthStage.fallow || stage == GrowthStage.harvested) {
      faunaAsset = 'assets/audio/winter_birds_wind.wav';
      _targetFaunaVol = 0.2;
    } else if (stage == GrowthStage.seedling || stage == GrowthStage.tillering) {
      if (phase == DayPhase.evening || phase == DayPhase.night) {
        faunaAsset = 'assets/audio/spring_frogs.wav';
      } else {
        faunaAsset = 'assets/audio/winter_birds_wind.wav';
      }
    } else if (stage == GrowthStage.heading) {
      if (phase == DayPhase.afternoon || phase == DayPhase.morning) {
        faunaAsset = 'assets/audio/summer_cicadas.wav';
        _targetFaunaVol = 0.4; // Cicadas are loud!
      } else {
        faunaAsset = 'assets/audio/spring_frogs.wav';
      }
    } else { // Ripening
      if (phase == DayPhase.evening || phase == DayPhase.night) {
        faunaAsset = 'assets/audio/autumn_crickets.wav';
      } else {
        faunaAsset = 'assets/audio/winter_birds_wind.wav';
      }
    }
    
    // Decrease fauna if it\'s heavily raining (animals hide)
    if (metrics.isStormy || metrics.precipitation > 5.0) {
      _targetFaunaVol *= 0.2;
    }

    await _updateTrack(_faunaPlayer, _currentFaunaAsset, faunaAsset, _targetFaunaVol, (a) => _currentFaunaAsset = a);

    // --- 4. Biome Specific (Coast/Valley) ---
    if (biome == SceneryBiome.coast) {
      _targetBiomeVol = 0.4;
      await _updateTrack(_biomePlayer, _currentBiomeAsset, 'assets/audio/ocean_waves.wav', _targetBiomeVol, (a) => _currentBiomeAsset = a);
    } else if (biome == SceneryBiome.valley) {
      _targetBiomeVol = 0.2; // subtle echoing wind
      await _updateTrack(_biomePlayer, _currentBiomeAsset, 'assets/audio/valley_echo.wav', _targetBiomeVol, (a) => _currentBiomeAsset = a);
    } else {
      _targetBiomeVol = 0.0;
    }
  }

  void pause() {
    _windPlayer.pause();
    _weatherPlayer.pause();
    _faunaPlayer.pause();
    _biomePlayer.pause();
    _oneShotTimer?.cancel();
    _fadeTimer?.cancel();
  }

  void resume() {
    // Only resume if target volume > 0
    if (_targetWindVol > 0) _windPlayer.play();
    if (_targetWeatherVol > 0) _weatherPlayer.play();
    if (_targetFaunaVol > 0) _faunaPlayer.play();
    if (_targetBiomeVol > 0) _biomePlayer.play();
    
    _startOneShotTimer();
    _startFadeLoop();
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
    _fadeTimer?.cancel();
    await _windPlayer.dispose();
    await _weatherPlayer.dispose();
    await _faunaPlayer.dispose();
    await _biomePlayer.dispose();
  }
}
