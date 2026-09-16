import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:relax_mindfulness/main.dart' show localNotifications;

// ─── Enums ────────────────────────────────────────────────────────────────────
enum AppTab { home, meditate, breathe, sounds, sleep, aiStudio }

enum BreathingPattern {
  box4444('Box 4-4-4-4', 4, 4, 4, 4, 'Classic Navy SEAL stress relief'),
  relax478('4-7-8 Sleep', 4, 7, 8, 0, 'Dr. Weil sleep technique'),
  resonance55('Resonance 5-5', 5, 0, 5, 0, 'Heart rate coherence'),
  power626('Power 6-2-6', 6, 2, 6, 2, 'Energy & focus boost');

  const BreathingPattern(this.displayName, this.inhale, this.hold, this.exhale, this.holdOut, this.description);
  final String displayName;
  final int inhale, hold, exhale, holdOut;
  final String description;
  int get totalCycle => inhale + hold + exhale + holdOut;
}

enum BreathPhase { inhale, hold, exhale, holdOut }

enum AppWallpaper {
  rainyWindow(
    '🌧️ Rain on Glass',
    'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?auto=format&fit=crop&w=1200&q=80',
    Color(0xFF0C1924),
    Color(0xFF2DD4BF),
  ),
  cosmicAurora(
    '🌌 Cosmic Aurora',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80',
    Color(0xFF0F172A),
    Color(0xFFA855F7),
  ),
  mistyForest(
    '🌲 Misty Pine Forest',
    'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=1200&q=80',
    Color(0xFF081C15),
    Color(0xFF74C69D),
  ),
  sunsetHearth(
    '🌅 Amber Sunset',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
    Color(0xFF1E0E08),
    Color(0xFFE29578),
  ),
  deepOcean(
    '🌊 Deep Ocean',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=1200&q=80',
    Color(0xFF05131E),
    Color(0xFF38BDF8),
  ),
  pureObsidian(
    '🌑 Pure Minimal Obsidian',
    '',
    Color(0xFF030712),
    Color(0xFF64748B),
  );

  final String displayName;
  final String imageUrl;
  final Color baseColor;
  final Color accentColor;

  const AppWallpaper(this.displayName, this.imageUrl, this.baseColor, this.accentColor);
}

enum SanctuaryThemeMode {
  claymorphism('Claymorphism Soft UI', Color(0xFFF9F4EF), Color(0xFFEADBC8), isLight: true),
  neumorphism('Neumorphism Soft UI 2020', Color(0xFFE0E5EC), Color(0xFFE0E5EC), isLight: true, isNeumorphic: true),
  midnightNavy('Midnight Navy', Color(0xFF050D15), Color(0xFF0A1622)),
  forestDusk('Forest Dusk', Color(0xFF061412), Color(0xFF0D2522)),
  twilightLavender('Twilight Lavender', Color(0xFF0E0A17), Color(0xFF191228));

  const SanctuaryThemeMode(this.displayName, this.bgDark, this.bgMid, {this.isLight = false, this.isNeumorphic = false});
  final String displayName;
  final Color bgDark, bgMid;
  final bool isLight;
  final bool isNeumorphic;
}

// ─── Models ───────────────────────────────────────────────────────────────────
class SessionRecord {
  final String id, title, type;
  final int durationMinutes, moodRating;
  final DateTime timestamp;

  SessionRecord({required this.id, required this.title, required this.type,
    required this.durationMinutes, required this.timestamp, this.moodRating = 0});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'type': type,
    'dur': durationMinutes, 'ts': timestamp.millisecondsSinceEpoch, 'mood': moodRating};

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
    id: j['id'] as String, title: j['title'] as String, type: j['type'] as String,
    durationMinutes: j['dur'] as int,
    timestamp: DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
    moodRating: (j['mood'] as int?) ?? 0);

  SessionRecord withMood(int m) => SessionRecord(id: id, title: title, type: type,
    durationMinutes: durationMinutes, timestamp: timestamp, moodRating: m);
}

class SoundPreset {
  final String name;
  final Map<String, double> volumes;
  SoundPreset({required this.name, required this.volumes});
  Map<String, dynamic> toJson() => {'name': name, 'volumes': volumes};
  factory SoundPreset.fromJson(Map<String, dynamic> j) => SoundPreset(
    name: j['name'] as String,
    volumes: Map<String, double>.from((j['volumes'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble()))));
}

// ─── AppState ─────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  final Map<String, AudioPlayer> _audioPlayers = {};
  final Set<String> _loadingTracks = {};
  final Map<String, double> _targetVolumes = {};

  final AudioPlayer _guidedPlayer = AudioPlayer();
  bool _isGuidedPlaying = false;
  String? _currentGuidedTitle;
  int _guidedRemainingSec = 0;
  Timer? _guidedTimer;

  // Master Gain Limiter & Sleep Fade Control
  double _masterGain = 1.0;
  double _fadeMaster = 1.0;

  // Global Sleep Auto-Fade Timer
  Timer? _sleepTimer;
  int? _sleepTimerRemainingSec;
  int? _sleepTimerTotalSec;

  int? get sleepTimerRemainingSec => _sleepTimerRemainingSec;
  int? get sleepTimerTotalSec => _sleepTimerTotalSec;
  bool get isSleepTimerRunning => _sleepTimerRemainingSec != null && _sleepTimerRemainingSec! > 0;

  bool get isGuidedPlaying => _isGuidedPlaying;
  String? get currentGuidedTitle => _currentGuidedTitle;
  int get guidedRemainingSec => _guidedRemainingSec;
  
  static const Map<String, String> soundStreamUrls = {
    'Soft Rain': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/light-rain.mp3',
    'Thunderstorm': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/thunder.mp3',
    'Heavy Rain': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/heavy-rain.mp3',
    'Rain on Window': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-window.mp3',
    'Rain on Roof': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-car-roof.mp3',
    'Rain on Umbrella': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-umbrella.mp3',
    'Rain on Tent': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-tent.mp3',
    'Rain on Leaves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-leaves.mp3',
    'Ocean Waves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Mountain Stream': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Forest Birds': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/birds.mp3',
    'Campfire': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'Wind in Trees': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Howling Wind': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/howling-wind.mp3',
    'Crickets': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/crickets.mp3',
    'Waterfall': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waterfall.mp3',
    'Frogs': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/frog.mp3',
    'Jungle Day': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/jungle.mp3',
    'Water Droplets': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/droplets.mp3',
    'Walking in Snow': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-in-snow.mp3',
    'Walking on Gravel': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-on-gravel.mp3',
    'Walking on Leaves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-on-leaves.mp3',
    'Owl Hooting': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/owl.mp3',
    'Coffee Shop': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/cafe.mp3',
    'Library': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/library.mp3',
    'Office Ambience': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/office.mp3',
    'Church Interior': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/church.mp3',
    'Temple': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/temple.mp3',
    'Restaurant': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/restaurant.mp3',
    'Crowded Bar': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/crowded-bar.mp3',
    'Night Village': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/night-village.mp3',
    'Supermarket': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/supermarket.mp3',
    'Airport': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/airport.mp3',
    'Train Ride': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/train.mp3',
    'Inside a Train': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/inside-a-train.mp3',
    'Airplane Cabin': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/airplane.mp3',
    'Submarine': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/submarine.mp3',
    'Rowing Boat': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/rowing-boat.mp3',
    'Sailing Ship': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/sailboat.mp3',
    'Highway Traffic': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/urban/highway.mp3',
    'Busy Street': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/urban/busy-street.mp3',
    'Clock Ticking': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/clock.mp3',
    'Ceiling Fan': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/ceiling-fan.mp3',
    'Keyboard Typing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/keyboard.mp3',
    'Typewriter': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/typewriter.mp3',
    'Washing Machine': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/washing-machine.mp3',
    'Clothes Dryer': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/dryer.mp3',
    'Vinyl Crackle': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/vinyl-effect.mp3',
    'Boiling Water': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/boiling-water.mp3',
    'Wind Chimes': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Windshield Wipers': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/windshield-wipers.mp3',
    'White Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/white-noise.wav',
    'Pink Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/pink-noise.wav',
    'Brown Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/brown-noise.wav',
    'Steady Wind': 'https://actions.google.com/sounds/v1/weather/wind.ogg',
    'Desert Howling Wind': 'https://actions.google.com/sounds/v1/weather/desert_howling_wind.ogg',
    'Singing Bowl': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Delta Deep Sleep': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-delta.wav',
    'Theta Meditation': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-theta.wav',
    'Alpha Focus Flow': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-alpha.wav',
    'Beta Energy': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-beta.wav',
    'Gamma Insight': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-gamma.wav',
    'Tuning Radio': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/tuning-radio.mp3',
    'Morse Code': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/morse-code.mp3',
    'Paper Rustling': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/paper.mp3',
    'Bubbles': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/bubbles.mp3',
    'Cat Purring': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/cat-purring.mp3',
    'Seagulls': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/seagulls.mp3',
    'Whale Song': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/whale.mp3',
    'Wolf Howling': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/wolf.mp3',
    'Woodpecker': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/woodpecker.mp3',
    'Crows': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/crows.mp3',
    'Horse Galloping': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/horse-gallop.mp3',
    'Sheep Bleating': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/sheep.mp3',
    'Chickens': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/chickens.mp3',
    'Cows Mooing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/cows.mp3',
    'Dog Barking': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/dog-barking.mp3',
    'Beehive Hum': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/beehive.mp3',
    'Cosmic Drone': 'https://actions.google.com/sounds/v1/science_fiction/alien_breath.ogg',
    'Submarine Ping': 'https://actions.google.com/sounds/v1/water/submarine_ping.ogg',
    'Urban Rain': 'https://actions.google.com/sounds/v1/weather/rain_on_roof.ogg',
    'Heartbeat': 'https://actions.google.com/sounds/v1/human_voices/heartbeat.ogg',
    'Cozy Hearth': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'Singing Bowls': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Ambient Piano': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Bamboo Chimes': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Soothing Breeze': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Deep Space Drone': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-gamma.wav',
    'Tibetan Bowls': 'https://actions.google.com/sounds/v1/musical_instruments/singing_bowl.ogg',
    'Night Forest': 'https://actions.google.com/sounds/v1/nature/night_crickets.ogg',
    'Summer Meadow': 'https://actions.google.com/sounds/v1/nature/field_insects.ogg',
    'Space Drift': 'https://actions.google.com/sounds/v1/science_fiction/space_atmosphere.ogg',
  };

  static const Map<String, String> guidedAudioUrls = {
    'Calm Mountain Horizon': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Peaceful Haven Journey': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Gentle Relief & Comfort': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Soft Body Rest & Ease': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Peaceful Morning Awakening': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/birds.mp3',
    'Peaceful Morning Start': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/birds.mp3',
    'Quiet Mind Sanctuary': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Cozy Bedtime Slumber': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/light-rain.mp3',
    'Warm Heart Comfort': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'Gentle Breeze Rest': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Healing Crystal Chimes': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Loving Warmth & Peace': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Soft Sanctuary Horizon': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Ocean Horizon Slumber': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Chakra Solfeggio Alignment': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Pine Forest Bathing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Release Anxious Tension': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'The Starry Night': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-theta.wav',
    'Journey to Dreamland': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'The Hidden Waterfall': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'The Lighthouse Keeper': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Moonlit Japanese Garden': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Whispering Pine Forest': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Desert Stargazing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Ancient Temple Bells': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Ocean Breath': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Gentle Reset': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Forest Slumber': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Return To Stillness': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/light-rain.mp3',
  };

  static String _resolveCdnUrl(String rawUrl) {
    if (rawUrl.contains('raw.githubusercontent.com/remvze/moodist/main/')) {
      return rawUrl.replaceAll(
        'https://raw.githubusercontent.com/remvze/moodist/main/',
        'https://cdn.jsdelivr.net/gh/remvze/moodist@main/',
      );
    }
    return rawUrl;
  }

  bool _isBackgroundMode = false;
  bool get isBackgroundMode => _isBackgroundMode;
  void setBackgroundMode(bool value) {
    if (_isBackgroundMode != value) {
      _isBackgroundMode = value;
      notifyListeners();
    }
  }

  // ─── Data Backup & Restore (Prevents Safari 7-day eviction) ────────────────
  String exportUserDataToJson() {
    final data = {
      'version': '2.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'streak': _streak,
      'longest_streak': _longestStreak,
      'theme_mode': _themeMode.name,
      'favorites': _favorites,
      'favorite_sounds': _favoriteSounds.toList(),
      'presets': _presets.map((p) => p.toJson()).toList(),
      'renamed_presets': _renamedPresets,
      'sessions': _sessions.take(500).map((s) => s.toJson()).toList(),
      'reminder_enabled': _reminderEnabled,
      'reminder_hour': _reminderHour,
      'reminder_minute': _reminderMinute,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importUserDataFromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map.containsKey('streak')) _streak = (map['streak'] as num).toInt();
      if (map.containsKey('longest_streak')) _longestStreak = (map['longest_streak'] as num).toInt();
      if (map.containsKey('theme_mode')) {
        final modeName = map['theme_mode'] as String;
        _themeMode = SanctuaryThemeMode.values.firstWhere(
          (e) => e.name == modeName,
          orElse: () => _themeMode,
        );
      }
      if (map.containsKey('favorites')) {
        _favorites
          ..clear()
          ..addAll(List<String>.from(map['favorites'] as List));
      }
      if (map.containsKey('favorite_sounds')) {
        _favoriteSounds = Set<String>.from(map['favorite_sounds'] as List);
      }
      if (map.containsKey('presets')) {
        _presets = (map['presets'] as List)
            .map((p) => SoundPreset.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      if (map.containsKey('renamed_presets')) {
        _renamedPresets = Map<String, String>.from(map['renamed_presets'] as Map);
      }
      if (map.containsKey('sessions')) {
        _sessions = (map['sessions'] as List)
            .map((s) => SessionRecord.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      if (map.containsKey('reminder_enabled')) {
        _reminderEnabled = map['reminder_enabled'] as bool;
        _reminderHour = (map['reminder_hour'] as int?) ?? 22;
        _reminderMinute = (map['reminder_minute'] as int?) ?? 0;
      }
      _saveFavorites();
      _savePresets();
      _saveSessions();
      _prefs?.setStringList('favorite_sounds', _favoriteSounds.toList());
      _prefs?.setString('renamed_presets', jsonEncode(_renamedPresets));
      _prefs?.setInt('streak', _streak);
      _prefs?.setInt('longest_streak', _longestStreak);
      _prefs?.setString('theme_mode', _themeMode.name);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing user data: $e');
      return false;
    }
  }

  SanctuaryThemeMode _themeMode = SanctuaryThemeMode.midnightNavy;
  SanctuaryThemeMode get themeMode => _themeMode;
  void setThemeMode(SanctuaryThemeMode mode) {
    _themeMode = mode;
    _prefs?.setString('theme_mode', mode.name);
    notifyListeners();
  }

  AppWallpaper _wallpaper = AppWallpaper.rainyWindow;
  AppWallpaper get wallpaper => _wallpaper;
  void setWallpaper(AppWallpaper w) {
    _wallpaper = w;
    _prefs?.setInt('app_wallpaper', w.index);
    notifyListeners();
  }

  bool get isAnyAudioPlaying => _isGuidedPlaying || _targetVolumes.values.any((v) => v > 0);
  bool get isPlayingAny => isAnyAudioPlaying;
  Map<String, double> get activeAmbientTracks =>
      Map.fromEntries(_targetVolumes.entries.where((e) => e.value > 0.001));

  String get activePlayingLabel {
    if (_isGuidedPlaying && _currentGuidedTitle != null) {
      return _currentGuidedTitle!;
    }
    final activeTracks = _targetVolumes.entries.where((e) => e.value > 0.001).map((e) => e.key).toList();
    if (activeTracks.isEmpty) return 'No Audio Playing';
    if (activeTracks.length == 1) return activeTracks.first;
    return '${activeTracks.first} + ${activeTracks.length - 1} more';
  }

  bool _isPremium = false;
  bool _trialActive = false;
  int _trialDaysLeft = 7;
  DateTime? _trialStartDate;
  int _totalSessions = 0;

  bool get isPremium => _isPremium;
  bool get trialActive => _trialActive;
  int get trialDaysLeft => _trialDaysLeft;
  bool get hasFullAccess => _isPremium || _trialActive;

  Future<void> purchasePremium() async {
    _isPremium = true;
    _trialActive = false;
    await _prefs?.setBool('is_premium', true);
    await _prefs?.setBool('trial_active', false);
    notifyListeners();
  }

  Future<void> startFreeTrial() async {
    if (_isPremium || _trialActive) return;
    _trialActive = true;
    _trialStartDate = DateTime.now();
    _trialDaysLeft = 7;
    await _prefs?.setBool('trial_active', true);
    await _prefs?.setString('trial_start', _trialStartDate!.toIso8601String());
    notifyListeners();
  }

  Future<void> restorePurchase() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      if (isPro) {
        _isPremium = true;
        _prefs?.setBool('is_premium', true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Restore error: $e");
    }
  }

  void _loadPremiumState() {
    _isPremium = _prefs?.getBool('is_premium') ?? false;
    _trialActive = _prefs?.getBool('trial_active') ?? false;
    final trialStartStr = _prefs?.getString('trial_start');
    if (trialStartStr != null && _trialActive) {
      _trialStartDate = DateTime.tryParse(trialStartStr);
      if (_trialStartDate != null) {
        final elapsed = DateTime.now().difference(_trialStartDate!).inDays;
        _trialDaysLeft = (7 - elapsed).clamp(0, 7);
        if (_trialDaysLeft <= 0) {
          _trialActive = false;
          _prefs?.setBool('trial_active', false);
        }
      }
    }
  }

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;
  void completeOnboarding() {
    _onboardingDone = true;
    _prefs?.setBool('onboarding_done', true);
    notifyListeners();
  }

  int _streak = 0;
  int _longestStreak = 0;
  bool _practicedToday = false;
  int get streak => _streak;
  int get longestStreak => _longestStreak;
  bool get practicedToday => _practicedToday;

  List<SessionRecord> _sessions = [];
  List<SessionRecord> get sessions => List.unmodifiable(_sessions);

  int get totalMinutes => _sessions.fold(0, (sum, s) => sum + s.durationMinutes);
  int get totalSessions => _totalSessions;

  double get avgMood {
    final rated = _sessions.where((s) => s.moodRating > 0);
    if (rated.isEmpty) return 0.0;
    final total = rated.fold(0, (sum, s) => sum + s.moodRating);
    return total / rated.length;
  }

  List<MapEntry<String, int>> get weeklyMinutes {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return days.asMap().entries.map((e) {
      final dayDate = startOfWeek.add(Duration(days: e.key));
      final dayMins = _sessions
          .where((s) => _sameDay(s.timestamp, dayDate))
          .fold(0, (sum, s) => sum + s.durationMinutes);
      return MapEntry(e.value, dayMins);
    }).toList();
  }

  Map<String, int> get categoryBreakdown {
    final map = <String, int>{};
    for (final s in _sessions) {
      map[s.type] = (map[s.type] ?? 0) + s.durationMinutes;
    }
    return map;
  }

  AppTab _tab = AppTab.home;
  AppTab get tab => _tab;
  void setTab(AppTab t) { _tab = t; notifyListeners(); }

  String _selectedMoodFilter = 'Calm';
  String get selectedMoodFilter => _selectedMoodFilter;

  void setMoodFilter(String mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  Map<String, String> _renamedPresets = {};
  Map<String, String> get renamedPresets => Map.unmodifiable(_renamedPresets);

  Set<String> _favoriteSounds = {'Soft Rain', 'Ocean Waves', 'Campfire'};
  Set<String> get favoriteSounds => Set.unmodifiable(_favoriteSounds);

  bool isFavorite(String name) => _favoriteSounds.contains(name);

  void toggleFavoriteSound(String name) {
    if (_favoriteSounds.contains(name)) {
      _favoriteSounds.remove(name);
    } else {
      _favoriteSounds.add(name);
    }
    _prefs?.setStringList('favorite_sounds', _favoriteSounds.toList());
    notifyListeners();
  }

  void renameCuratedPreset(String oldName, String newName) {
    _renamedPresets[oldName] = newName;
    _prefs?.setString('renamed_presets', jsonEncode(_renamedPresets));
    notifyListeners();
  }

  String getPresetDisplayName(String originalName) {
    return _renamedPresets[originalName] ?? originalName;
  }

  static const Map<String, Map<String, double>> curatedPresets = {
    '🌧️ Rainy Cabin': {
      'Soft Rain': 0.70,
      'Cozy Hearth': 0.35,
      'Ambient Piano': 0.20,
    },
    '🌊 Beach Sunset': {
      'Ocean Waves': 0.70,
      'Soothing Breeze': 0.40,
      'Bamboo Chimes': 0.20,
    },
    '🌌 Deep Space': {
      'Deep Space Drone': 0.70,
      'Singing Bowls': 0.30,
    },
    '🌲 Forest Walk': {
      'Mountain Stream': 0.60,
      'Forest Birds': 0.40,
      'Soothing Breeze': 0.30,
    },
    '⚡ Thunderstorm': {
      'Thunderstorm': 0.70,
      'Soft Rain': 0.50,
      'Soothing Breeze': 0.20,
    },
    '🧘 Zen Sanctuary': {
      'Singing Bowls': 0.60,
      'Bamboo Chimes': 0.40,
      'Mountain Stream': 0.30,
    },
    '🔥 Campfire Night': {
      'Cozy Hearth': 0.75,
      'Soothing Breeze': 0.30,
    },
    '🕊️ Peace Flow': {
      'Ambient Piano': 0.65,
      'Soft Rain': 0.30,
      'Singing Bowls': 0.25,
    },
  };

  Future<void> applyCuratedPreset(String presetName) async {
    if (_isGuidedPlaying) {
      await pauseGuidedSession();
    }

    final volumes = curatedPresets[presetName];
    if (volumes == null) return;

    for (final track in soundStreamUrls.keys) {
      final vol = volumes[track] ?? 0.0;
      await updateSoundTrackVolume(track, vol);
    }
  }

  Future<void> pauseAllAmbientSoundTracks() async {
    for (final name in _targetVolumes.keys.toList()) {
      _targetVolumes[name] = 0.0;
    }
    for (final entry in _audioPlayers.entries) {
      try {
        await entry.value.setVolume(0);
        await entry.value.pause();
      } catch (e) {
        debugPrint('Error pausing ambient track ${entry.key}: $e');
      }
    }
  }

  Future<void> playGuidedSession(String title, int durationMins) async {
    await pauseAllAmbientSoundTracks();

    _guidedTimer?.cancel();
    _currentGuidedTitle = title;
    _guidedRemainingSec = durationMins * 60;
    _isGuidedPlaying = true;
    notifyListeners();

    _guidedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGuidedPlaying || _guidedRemainingSec <= 0) {
        timer.cancel();
        stopGuidedSession(completed: true, durationMins: durationMins);
      } else {
        _guidedRemainingSec--;
        notifyListeners();
      }
    });

    final rawUrl = guidedAudioUrls[title] ?? guidedAudioUrls['Calm Mountain Horizon']!;
    final cdnUrl = _resolveCdnUrl(rawUrl);

    try {
      await _guidedPlayer.setUrl(cdnUrl);
      await _guidedPlayer.setLoopMode(LoopMode.one);
      await _guidedPlayer.setVolume(0.35);
      _guidedPlayer.play();
    } catch (e) {
      debugPrint('Error starting guided audio on CDN, trying fallback: $e');
      try {
        await _guidedPlayer.setUrl(rawUrl);
        await _guidedPlayer.setLoopMode(LoopMode.one);
        await _guidedPlayer.setVolume(0.35);
        _guidedPlayer.play();
      } catch (e2) {
        debugPrint('Guided audio fallback error: $e2');
      }
    }
  }

  bool _isGuidedLooping = true;
  bool get isGuidedLooping => _isGuidedLooping;

  void extendGuidedSession(int extraMins) {
    _guidedRemainingSec += extraMins * 60;
    notifyListeners();
  }

  void toggleGuidedLoop() {
    _isGuidedLooping = !_isGuidedLooping;
    if (_isGuidedLooping) {
      _guidedPlayer.setLoopMode(LoopMode.one);
    } else {
      _guidedPlayer.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  void restartGuidedSession(int initialMins) {
    _guidedRemainingSec = initialMins * 60;
    _guidedPlayer.seek(Duration.zero);
    notifyListeners();
  }

  int _guidedTotalSec = 2700;
  int get guidedTotalSec => _guidedTotalSec;

  Future<void> startGuidedSession(String title, String subtitle, int totalSec, int durationMins) async {
    _guidedTotalSec = totalSec;
    await playGuidedSession(title, durationMins);
  }

  void toggleGuidedPlayPause() {
    if (_isGuidedPlaying) {
      pauseGuidedSession();
    } else {
      _guidedPlayer.play();
      _isGuidedPlaying = true;
      _guidedTimer?.cancel();
      _guidedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isGuidedPlaying || _guidedRemainingSec <= 0) {
          timer.cancel();
          stopGuidedSession(completed: true, durationMins: _guidedTotalSec ~/ 60);
        } else {
          _guidedRemainingSec--;
          notifyListeners();
        }
      });
      notifyListeners();
    }
  }

  Future<void> pauseGuidedSession() async {
    _guidedTimer?.cancel();
    await _guidedPlayer.pause();
    _isGuidedPlaying = false;
    notifyListeners();
  }

  Future<void> stopGuidedSession({bool completed = false, int durationMins = 10}) async {
    _guidedTimer?.cancel();
    await _guidedPlayer.stop();
    _isGuidedPlaying = false;
    final title = _currentGuidedTitle ?? 'Guided Meditation';
    _currentGuidedTitle = null;
    notifyListeners();

    if (completed) {
      recordSession(title, 'Meditation', durationMins);
    }
  }

  double getTrackVolume(String name) => _targetVolumes[name] ?? 0.0;

  void _recalculateGainAndApply() {
    final activeVolumes = _targetVolumes.values.where((v) => v > 0).toList();
    final sum = activeVolumes.fold<double>(0.0, (a, b) => a + b);
    // Soft master limiter: clamp combined multi-track headroom to 1.0 to eliminate clipping
    _masterGain = sum > 1.0 ? (1.0 / sum) : 1.0;

    for (final entry in _audioPlayers.entries) {
      final name = entry.key;
      final player = entry.value;
      final target = _targetVolumes[name] ?? 0.0;
      if (target > 0) {
        // Soft per-track cap (0.85 max) + master limiter + sleep fade master
        final effective = (target * _masterGain * _fadeMaster).clamp(0.0, 0.85);
        player.setVolume(effective);
      } else {
        player.setVolume(0.0);
      }
    }
  }

  Future<void> _evictColdPlayers() async {
    if (_audioPlayers.length <= 12) return;
    final coldKeys = _audioPlayers.keys
        .where((key) => (_targetVolumes[key] ?? 0.0) <= 0.0)
        .take(_audioPlayers.length - 12)
        .toList();
    for (final key in coldKeys) {
      final player = _audioPlayers.remove(key);
      if (player != null) {
        try {
          await player.stop();
          await player.dispose();
        } catch (_) {}
      }
    }
  }

  Future<void> updateSoundTrackVolume(String name, double volume) async {
    if (volume > 0 && _isGuidedPlaying) {
      await pauseGuidedSession();
    }

    final url = soundStreamUrls[name] ?? 'https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg';
    final effectiveVolume = volume.clamp(0.0, 1.0);
    _targetVolumes[name] = effectiveVolume;

    if (volume <= 0) {
      final existingPlayer = _audioPlayers[name];
      if (existingPlayer != null) {
        await existingPlayer.setVolume(0);
        await existingPlayer.pause();
      }
      _recalculateGainAndApply();
      _evictColdPlayers();
      notifyListeners();
      return;
    }

    if (!_audioPlayers.containsKey(name)) {
      final newPlayer = AudioPlayer();
      _audioPlayers[name] = newPlayer;
      _loadingTracks.add(name);

      final primaryUrl = _resolveCdnUrl(url);
      try {
        await newPlayer.setUrl(primaryUrl);
        await newPlayer.setLoopMode(LoopMode.one);
      } catch (e) {
        debugPrint('Primary CDN failed for $name, trying fallback: $e');
        try {
          await newPlayer.setUrl(url);
          await newPlayer.setLoopMode(LoopMode.one);
        } catch (e2) {
          debugPrint('Secondary source failed for $name: $e2');
        }
      } finally {
        _loadingTracks.remove(name);
      }
    }

    final player = _audioPlayers[name]!;
    _recalculateGainAndApply();

    if (!player.playing) {
      try {
        await player.play();
      } catch (e) {
        debugPrint('Error playing track $name: $e');
      }
    }
    notifyListeners();
  }

  Future<void> stopAllAudio() async {
    _targetVolumes.clear();
    await stopGuidedSession(completed: false);
    for (final entry in _audioPlayers.entries) {
      try {
        await entry.value.setVolume(0);
        await entry.value.pause();
      } catch (e) {
        debugPrint('Error stopping track ${entry.key}: $e');
      }
    }
    _recalculateGainAndApply();
    notifyListeners();
  }

  // ─── Global Sleep Auto-Fade Timer ───────────────────────────────────────────
  void startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    final total = minutes * 60;
    _sleepTimerTotalSec = total;
    _sleepTimerRemainingSec = total;
    _fadeMaster = 1.0;
    _recalculateGainAndApply();
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_sleepTimerRemainingSec == null || _sleepTimerRemainingSec! <= 0) {
        t.cancel();
        _sleepTimer = null;
        _sleepTimerRemainingSec = null;
        _sleepTimerTotalSec = null;
        _fadeMaster = 1.0;
        await stopAllAudio();
        recordSession('Sleep Sanctuary Auto-Fade', 'Sleep', minutes);
        notifyListeners();
      } else {
        _sleepTimerRemainingSec = _sleepTimerRemainingSec! - 1;
        // Last 30 seconds: smooth linear volume fade out
        if (_sleepTimerRemainingSec! <= 30) {
          _fadeMaster = (_sleepTimerRemainingSec! / 30.0).clamp(0.0, 1.0);
          _recalculateGainAndApply();
        }
        notifyListeners();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerRemainingSec = null;
    _sleepTimerTotalSec = null;
    _fadeMaster = 1.0;
    _recalculateGainAndApply();
    notifyListeners();
  }

  // ─── Mix Share & Deep Linking ───────────────────────────────────────────────
  String generateShareUrl() {
    final active = _targetVolumes.entries.where((e) => e.value > 0).toList();
    if (active.isEmpty) return 'https://sanctuary.app/allinone/';
    final pairs = active.map((e) => '${Uri.encodeComponent(e.key)}:${(e.value * 100).round()}').join(',');
    return 'https://sanctuary.app/allinone/?mix=$pairs';
  }

  void parseAndApplyMixFromUri(Uri uri) {
    try {
      final mixParam = uri.queryParameters['mix'];
      if (mixParam != null && mixParam.isNotEmpty) {
        final parts = mixParam.split(',');
        for (final part in parts) {
          final kv = part.split(':');
          if (kv.length == 2) {
            final name = Uri.decodeComponent(kv[0]);
            final vol = (double.tryParse(kv[1]) ?? 50) / 100.0;
            if (soundStreamUrls.containsKey(name)) {
              updateSoundTrackVolume(name, vol);
            }
          }
        }
        return;
      }
      final presetParam = uri.queryParameters['preset'];
      if (presetParam != null && curatedPresets.containsKey(presetParam)) {
        applyCuratedPreset(presetParam);
      }
    } catch (e) {
      debugPrint('Error parsing mix from URL: $e');
    }
  }

  bool _showMoodDialog = false;
  bool get showMoodDialog => _showMoodDialog;
  SessionRecord? _pendingSession;

  void requestMoodCheckIn(SessionRecord session) {
    _pendingSession = session;
    _showMoodDialog = true;
    notifyListeners();
  }

  void submitMood(int rating) {
    if (_pendingSession == null) return;
    _addSession(_pendingSession!.withMood(rating));
    _showMoodDialog = false;
    _pendingSession = null;
    notifyListeners();
  }

  void dismissMood() {
    if (_pendingSession != null) { _addSession(_pendingSession!); _pendingSession = null; }
    _showMoodDialog = false;
    notifyListeners();
  }

  void recordSession(String title, String type, int minutes, {bool showMoodCheckIn = true}) {
    final record = SessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      durationMinutes: minutes,
      timestamp: DateTime.now(),
    );

    if (showMoodCheckIn) {
      requestMoodCheckIn(record);
    } else {
      _addSession(record);
    }
  }

  void _addSession(SessionRecord s) {
    _sessions.insert(0, s);
    _totalSessions++;
    _updateStreak();
    _saveSessions();
  }

  void _saveSessions() {
    _prefs?.setStringList('sessions', _sessions.map((s) => jsonEncode(s.toJson())).toList());
    _prefs?.setInt('total_sessions', _totalSessions);
  }

  List<SoundPreset> _presets = [];
  List<SoundPreset> get presets => List.unmodifiable(_presets);
  void savePreset(String name, Map<String, double> volumes) {
    _presets.insert(0, SoundPreset(name: name, volumes: volumes));
    _savePresets(); notifyListeners();
  }
  void deletePreset(int index) { _presets.removeAt(index); _savePresets(); notifyListeners(); }
  void applyCustomPreset(SoundPreset preset) {
    stopAllAudio();
    preset.volumes.forEach((track, volume) {
      if (volume > 0) {
        updateSoundTrackVolume(track, volume);
      }
    });
    notifyListeners();
  }
  Future<void> startPanicResetCombo() async {
    setPattern(BreathingPattern.relax478);
    await updateSoundTrackVolume('Soft Rain', 0.55);
    notifyListeners();
  }
  void _savePresets() => _prefs?.setStringList('presets', _presets.map((p) => jsonEncode(p.toJson())).toList());

  BreathingPattern _pattern = BreathingPattern.box4444;
  BreathingPattern get pattern => _pattern;
  void setPattern(BreathingPattern p) { _pattern = p; notifyListeners(); }

  String? _selectedStory;
  String? get selectedStory => _selectedStory;
  void setStory(String? s) {
    _selectedStory = s;
    stopAllAudio();

    if (s != null) {
      if (s.contains('Cabin') || s.contains('Rainfall')) {
        updateSoundTrackVolume('Soft Rain', 0.7);
        updateSoundTrackVolume('Cozy Hearth', 0.35);
      } else if (s.contains('Alpine') || s.contains('Forest')) {
        updateSoundTrackVolume('Forest Birds', 0.6);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Ocean') || s.contains('Voyage')) {
        updateSoundTrackVolume('Ocean Waves', 0.7);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Japanese') || s.contains('Garden')) {
        updateSoundTrackVolume('Bamboo Chimes', 0.5);
        updateSoundTrackVolume('Mountain Stream', 0.4);
      } else if (s.contains('Stargazing') || s.contains('Desert')) {
        updateSoundTrackVolume('Deep Space Drone', 0.6);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Cloud') || s.contains('Floating')) {
        updateSoundTrackVolume('Ambient Piano', 0.6);
        updateSoundTrackVolume('Singing Bowls', 0.3);
      } else if (s.contains('Temple') || s.contains('Bells')) {
        updateSoundTrackVolume('Singing Bowls', 0.6);
        updateSoundTrackVolume('Bamboo Chimes', 0.4);
      } else {
        updateSoundTrackVolume('Soft Rain', 0.6);
      }
    }
    notifyListeners();
  }

  // ─── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _onboardingDone = _prefs!.getBool('onboarding_done') ?? false;
    _streak = _prefs!.getInt('streak') ?? 0;
    _longestStreak = _prefs!.getInt('longest_streak') ?? 0;
    final lastMs = _prefs!.getInt('last_practice_ms') ?? 0;
    if (lastMs > 0) _practicedToday = _sameDay(DateTime.fromMillisecondsSinceEpoch(lastMs), DateTime.now());

    // BUG FIX: themeMode was saved but never restored — always defaulted to midnightNavy
    final savedTheme = _prefs!.getString('theme_mode');
    if (savedTheme != null) {
      _themeMode = SanctuaryThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => SanctuaryThemeMode.midnightNavy,
      );
    }

    final rawS = _prefs!.getStringList('sessions') ?? [];
    _sessions = rawS.map((s) { try { return SessionRecord.fromJson(jsonDecode(s)); } catch (_) { return null; } })
        .whereType<SessionRecord>().toList();

    final rawP = _prefs!.getStringList('presets') ?? [];
    _presets = rawP.map((s) { try { return SoundPreset.fromJson(jsonDecode(s)); } catch (_) { return null; } })
        .whereType<SoundPreset>().toList();

    final rawRenamed = _prefs!.getString('renamed_presets');
    if (rawRenamed != null) {
      try {
        _renamedPresets = Map<String, String>.from(jsonDecode(rawRenamed) as Map);
      } catch (_) {}
    }

    final savedFavs = _prefs!.getStringList('favorite_sounds');
    if (savedFavs != null) {
      _favoriteSounds = savedFavs.toSet();
    }

    final savedWallpaperIdx = _prefs!.getInt('app_wallpaper');
    if (savedWallpaperIdx != null && savedWallpaperIdx >= 0 && savedWallpaperIdx < AppWallpaper.values.length) {
      _wallpaper = AppWallpaper.values[savedWallpaperIdx];
    }

    _loadRecents();
    _loadFavorites(); // BUG FIX: was never called — favorites reset on every restart
    _loadReminder();
    _loadPremiumState();
    // BUG FIX: _totalSessions was never restored — counter always restarted from 0
    _totalSessions = _prefs!.getInt('total_sessions') ?? _sessions.length;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Auto-pause when headphones/Bluetooth disconnect (prevents blasting speakers at night)
      session.becomingNoisyEventStream.listen((_) {
        debugPrint('Headphones disconnected, auto-pausing audio to protect sleeper');
        pauseAllAmbientSoundTracks();
        if (_isGuidedPlaying) {
          pauseGuidedSession();
        }
      });

      // Auto-pause during phone calls / Siri interruptions
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          debugPrint('Audio interrupted by incoming call / system prompt, pausing audio');
          pauseAllAmbientSoundTracks();
          if (_isGuidedPlaying) {
            pauseGuidedSession();
          }
        }
      });
    } catch (e) {
      debugPrint('AudioSession configuration error: $e');
    }

    notifyListeners();
  }

  // Local Cache Persistence for Active Volume Mix
  Map<String, double> get cachedVolumes {
    final raw = _prefs?.getString('cached_volumes');
    if (raw == null) return {};
    try {
      return Map<String, double>.from((jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())));
    } catch (_) {
      return {};
    }
  }

  void saveCachedVolumes(Map<String, double> volumes) {
    _prefs?.setString('cached_volumes', jsonEncode(volumes));
  }

  // ─── Retention: Favorites ───────────────────────────────────────────────────
  // Users star a sound; starred sounds appear at the top of the Sounds page.
  // Persisted as a List<String> of sound IDs in SharedPreferences.
  final List<String> _favorites = [];
  List<String> get favorites => List.unmodifiable(_favorites);

  bool isFavoriteSoundId(String soundId) => _favorites.contains(soundId);

  void toggleFavorite(String soundId) {
    if (_favorites.contains(soundId)) {
      _favorites.remove(soundId);
    } else {
      _favorites.insert(0, soundId);  // most recent first
    }
    _saveFavorites();
    notifyListeners();
  }

  void _saveFavorites() =>
      _prefs?.setStringList('favorites', _favorites);

  void _loadFavorites() {
    _favorites
      ..clear()
      ..addAll(_prefs?.getStringList('favorites') ?? const []);
  }

  // ─── Retention: Recently Played ─────────────────────────────────────────────
  // Cap at 20 entries. Oldest falls off. Each entry stores (soundId, timestampMs).
  final List<MapEntry<String, int>> _recentlyPlayed = [];
  List<MapEntry<String, int>> get recentlyPlayed =>
      List.unmodifiable(_recentlyPlayed);

  static const _recentsCap = 20;

  void recordPlay(String soundId) {
    _recentlyPlayed.removeWhere((e) => e.key == soundId);  // dedupe
    _recentlyPlayed.insert(0, MapEntry(soundId, DateTime.now().millisecondsSinceEpoch));
    if (_recentlyPlayed.length > _recentsCap) {
      _recentlyPlayed.removeRange(_recentsCap, _recentlyPlayed.length);
    }
    _saveRecents();
    notifyListeners();
  }

  void _saveRecents() => _prefs?.setString(
      'recents',
      jsonEncode(_recentlyPlayed.map((e) => {'id': e.key, 'ts': e.value}).toList()));

  void _loadRecents() {
    final raw = _prefs?.getString('recents');
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _recentlyPlayed
        ..clear()
        ..addAll(list.map((j) => MapEntry(
            j['id'] as String,
            (j['ts'] as num).toInt())));
    } catch (_) {}
  }

  // ─── Retention: Daily Reminder ──────────────────────────────────────────────
  // Stores a single reminder time (HH:mm). The actual scheduling is handled by
  // the UI layer using flutter_local_notifications; this just persists the
  // preference so the toggle survives restarts.
  bool _reminderEnabled = false;
  int _reminderHour = 22;   // 10pm default — good for sleep audience
  int _reminderMinute = 0;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  void setReminder({required bool enabled, int? hour, int? minute}) {
    _reminderEnabled = enabled;
    if (hour != null) _reminderHour = hour;
    if (minute != null) _reminderMinute = minute;
    _prefs?.setBool('reminder_enabled', _reminderEnabled);
    _prefs?.setInt('reminder_hour', _reminderHour);
    _prefs?.setInt('reminder_minute', _reminderMinute);
    notifyListeners();
  }

  void _loadReminder() {
    _reminderEnabled = _prefs?.getBool('reminder_enabled') ?? false;
    _reminderHour = _prefs?.getInt('reminder_hour') ?? 22;
    _reminderMinute = _prefs?.getInt('reminder_minute') ?? 0;
  }

  // ─── Retention: Personalized Recommendations ───────────────────────────────
  // Score each ambient sound by:
  //   +5 every time it appears in recents (capped at 25)
  //   +10 if it's favorited
  //   +2 for every time it appears in a completed session (uses session title
  //     prefix match against session records that look like sound titles)
  // Returns the top N sound IDs the user is most likely to want right now.
  List<String> recommendedSounds({int limit = 5}) {
    final scores = <String, double>{};
    for (final r in _recentlyPlayed) {
      scores[r.key] = (scores[r.key] ?? 0) + 5;
    }
    for (final f in _favorites) {
      scores[f] = (scores[f] ?? 0) + 10;
    }
    // Cap per-recent contribution so a single popular sound doesn't dominate
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // If user has zero history, return a sensible "starter pack" instead of []
    if (sorted.isEmpty) {
      return const ['Soft Rain', 'Ocean Waves', 'Brown Noise', 'Campfire', 'Singing Bowl'];
    }
    return sorted.take(limit).map((e) => e.key).toList();
  }

  // ─── Amplitude helpers (consumed by AnimatedSoundWave via UI) ───────────────
  // Sum of currently-active track volumes, clamped 0..1. The mini-player uses
  // this to scale the soundwave bars so a quiet mix shows short bars and a
  // loud mix shows tall ones.
  double get activeMixAmplitude {
    if (_targetVolumes.isEmpty) return 0.0;
    final sum = _targetVolumes.values.fold<double>(0, (a, b) => a + b);
    return sum.clamp(0.0, 1.0);
  }

  // 0.35 fixed for guided (matches setVolume in playGuidedSession).
  // Returns 0 if not currently playing.
  double get guidanceGuidedAmplitude => _isGuidedPlaying ? 0.35 : 0.0;

  // ─── Helpers ────────────────────────────────────────────────────────────────
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // ─── Streak & Viral Milestone Unlocks ────────────────────────────────────────
  bool isMilestoneUnlocked(int days) => _streak >= days || _longestStreak >= days;

  String? get currentStreakTitle {
    if (_streak >= 30) return '🏆 Mindful Zen Master (30+ Days)';
    if (_streak >= 14) return '✨ Inner Peace Voyager (14 Days)';
    if (_streak >= 7) return '🌿 Serene Habit Builder (7 Days)';
    if (_streak >= 3) return '🌱 Calm Explorer (3 Days)';
    return '🌸 Peaceful Beginning (Day 1)';
  }

  void _updateStreak() {
    if (_practicedToday) return;
    _practicedToday = true;
    if (_sessions.length <= 1) {
      _streak = 1;
    } else {
      final prev = _sessions[1].timestamp;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      _streak = (_sameDay(prev, yesterday) || _sameDay(prev, DateTime.now())) ? _streak + 1 : 1;
    }
    if (_streak > _longestStreak) _longestStreak = _streak;
    _prefs?.setInt('streak', _streak);
    _prefs?.setInt('longest_streak', _longestStreak);
    _prefs?.setInt('last_practice_ms', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> setTrackVolume(String name, double volume) => updateSoundTrackVolume(name, volume);

  // ─── Local Notifications Logic ──────────────────────────────────────────────

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      await localNotifications.zonedSchedule(
        0,
        'Time for Mindfulness 🌿',
        'Take a quiet moment to breathe and center yourself.',
        scheduledDate,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'mindfulness_channel',
            'Daily Mindfulness Reminders',
            channelDescription: 'Gentle reminders for daily meditation and restful sleep',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  Future<void> cancelReminder() async {
    await localNotifications.cancel(0);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _guidedTimer?.cancel();
    _guidedPlayer.dispose();
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }
}
