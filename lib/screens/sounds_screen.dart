import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  bool _isPlaying = false;
  String _selectedCategory = '🌧️ Rain';

  static const Map<String, String> soundImages = {
    // Rain
    'Soft Rain': 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?auto=format&fit=crop&w=300&q=80',
    'Thunderstorm': 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65?auto=format&fit=crop&w=300&q=80',
    'Heavy Rain': 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?auto=format&fit=crop&w=300&q=80',
    'Rain on Window': 'https://images.unsplash.com/photo-1438449805896-28a666819a20?auto=format&fit=crop&w=300&q=80',
    'Rain on Roof': 'https://images.unsplash.com/photo-1519692933481-e162a57d6721?auto=format&fit=crop&w=300&q=80',
    'Rain on Umbrella': 'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=300&q=80',
    'Rain on Tent': 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=300&q=80',
    'Rain on Leaves': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=300&q=80',

    // Nature
    'Ocean Waves': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=80',
    'Mountain Stream': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=300&q=80',
    'Forest Birds': 'https://images.unsplash.com/photo-1444464666168-49d633b86797?auto=format&fit=crop&w=300&q=80',
    'Campfire': 'https://images.unsplash.com/photo-1508873696983-2df515122519?auto=format&fit=crop&w=300&q=80',
    'Wind in Trees': 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=300&q=80',
    'Howling Wind': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=300&q=80',
    'Crickets': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=300&q=80',
    'Waterfall': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?auto=format&fit=crop&w=300&q=80',
    'Frogs': 'https://images.unsplash.com/photo-1550853024-fae8cd4be47f?auto=format&fit=crop&w=300&q=80',
    'Jungle Day': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?auto=format&fit=crop&w=300&q=80',
    'Water Droplets': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=300&q=80',
    'Walking in Snow': 'https://images.unsplash.com/photo-1483921020237-2ff51e5e4bfe?auto=format&fit=crop&w=300&q=80',
    'Walking on Gravel': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=300&q=80',
    'Walking on Leaves': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=80',
    'Owl Hooting': 'https://images.unsplash.com/photo-1543549790-8b5f4a028cfb?auto=format&fit=crop&w=300&q=80',

    // Places
    'Coffee Shop': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=300&q=80',
    'Library': 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=300&q=80',
    'Office Ambience': 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=300&q=80',
    'Church Interior': 'https://images.unsplash.com/photo-1548625361-18567117e335?auto=format&fit=crop&w=300&q=80',
    'Temple': 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=300&q=80',
    'Restaurant': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80',
    'Crowded Bar': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=300&q=80',
    'Night Village': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=300&q=80',
    'Supermarket': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=300&q=80',
    'Airport': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=300&q=80',

    // Transport
    'Train Ride': 'https://images.unsplash.com/photo-1474487548417-781cb71495f3?auto=format&fit=crop&w=300&q=80',
    'Inside a Train': 'https://images.unsplash.com/photo-1515165562839-978bbcf18277?auto=format&fit=crop&w=300&q=80',
    'Airplane Cabin': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=300&q=80',
    'Submarine': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=300&q=80',
    'Rowing Boat': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=300&q=80',
    'Sailing Ship': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
    'Highway Traffic': 'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?auto=format&fit=crop&w=300&q=80',
    'Busy Street': 'https://images.unsplash.com/photo-1477959858617-67f30ac72604?auto=format&fit=crop&w=300&q=80',

    // Animals
    'Cat Purring': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=300&q=80',
    'Seagulls': 'https://images.unsplash.com/photo-1498637841888-108c6b723fc2?auto=format&fit=crop&w=300&q=80',
    'Whale Song': 'https://images.unsplash.com/photo-1568430460464-5237c8b417c8?auto=format&fit=crop&w=300&q=80',
    'Wolf Howling': 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?auto=format&fit=crop&w=300&q=80',
  };

  // 75 Sound Volumes State Map
  final Map<String, double> _volumes = {
    // Rain (12)
    'Soft Rain': 0.3, 'Heavy Rain': 0.0, 'Rain on Window': 0.0, 'Rain on Roof': 0.0,
    'Rain on Umbrella': 0.0, 'Rain on Tent': 0.0, 'Thunderstorm': 0.0, 'Rain on Leaves': 0.0,
    'Urban Rain': 0.0, 'Light Drizzle': 0.0, 'Rain Cave': 0.0, 'Tropical Storm': 0.0,
    // Nature (15)
    'Ocean Waves': 0.3, 'Mountain Stream': 0.0, 'Forest Birds': 0.0, 'Campfire': 0.0,
    'Wind in Trees': 0.0, 'Crickets': 0.0, 'Waterfall': 0.0, 'Frogs': 0.0,
    'Waves on Pebbles': 0.0, 'Underwater': 0.0, 'Meadow Breeze': 0.0, 'Desert Wind': 0.0,
    'Jungle Night': 0.0, 'Leaves Rustling': 0.0, 'Mountain Echo': 0.0,
    // Places (10)
    'Coffee Shop': 0.0, 'Library': 0.0, 'Office Ambience': 0.0, 'Church Bells': 0.0,
    'Quiet Park': 0.0, 'Street Market': 0.0, 'Temple Bowl': 0.0, 'Zen Garden': 0.0,
    'Harbor': 0.0, 'Farmyard': 0.0,
    // Transport (8)
    'Train Track': 0.0, 'Airplane Cabin': 0.0, 'Driving Rain Car': 0.0, 'Boat Deck': 0.0,
    'Subway Train': 0.0, 'Bicycle Ride': 0.0, 'Sailing Ship': 0.0, 'Highway Traffic': 0.0,
    // Things (10)
    'Clock Ticking': 0.0, 'Fan Noise': 0.0, 'Keyboard Typing': 0.0, 'Washing Machine': 0.0,
    'Vinyl Crackle': 0.0, 'Boiling Kettle': 0.0, 'Bamboo Chimes': 0.0, 'Page Turning': 0.0,
    'Pendulum': 0.0, 'Wind Generator': 0.0,
    // Noise Colors (6)
    'White Noise': 0.0, 'Pink Noise': 0.0, 'Brown Noise': 0.0, 'Blue Noise': 0.0,
    'Violet Noise': 0.0, 'Grey Noise': 0.0,
    // Solfeggio (14)
    'Singing Bowls': 0.0, '432Hz Healing': 0.0, '528Hz Transformation': 0.0, '639Hz Harmonics': 0.0,
    '108Hz Theta Drone': 0.0, 'Deep Space Drone': 0.0, 'Delta Deep Sleep': 0.0, 'Alpha Focus Flow': 0.0,
    'Beta Energy Boost': 0.0, 'Gamma Insight': 0.0, '174Hz Pain Relief': 0.0, '285Hz Cellular': 0.0,
    '396Hz Liberation': 0.0, '741Hz Intuition': 0.0, '852Hz Awakening': 0.0, '963Hz Crown State': 0.0,
    'Ambient Piano': 0.0, 'Cozy Hearth': 0.0, 'Soothing Breeze': 0.0,
  };

  static const Map<String, List<(String, String, String, Color)>> soundCategories = {
    '🌧️ Rain': [
      ('🌧️', 'Soft Rain', 'Gentle Downpour', Color(0xFF42A5F5)),
      ('⛈️', 'Thunderstorm', 'Distant Low Rumble', Color(0xFF5C6BC0)),
      ('🪟', 'Rain on Window', 'Soft Drops on Glass', Color(0xFF29B6F6)),
      ('🏠', 'Rain on Roof', 'Cozy Attic Downpour', Color(0xFF0288D1)),
      ('🌂', 'Rain on Umbrella', 'Rhythmic Pitter Patter', Color(0xFF039BE5)),
      ('⛺', 'Rain on Tent', 'Wilderness Camping Rain', Color(0xFF00ACC1)),
      ('🍃', 'Rain on Leaves', 'Forest Canopy Drizzle', Color(0xFF26A69A)),
      ('🏙️', 'Urban Rain', 'City Street Rainfall', Color(0xFF78909C)),
      ('🌧️', 'Heavy Rain', 'Continuous Pouring Storm', Color(0xFF1E88E5)),
      ('🌧️', 'Light Drizzle', 'Gentle Atmospheric Mist', Color(0xFF80DEEA)),
      ('洞', 'Rain Cave', 'Echoing Cavern Drops', Color(0xFF3F51B5)),
      ('🌴', 'Tropical Storm', 'Warm Rainforest Gale', Color(0xFF00897B)),
    ],
    '🌲 Nature': [
      ('🌊', 'Ocean Waves', 'Rolling Pacific Tide', Color(0xFF26A69A)),
      ('🏞️', 'Mountain Stream', 'Flowing Crystal Creek', Color(0xFF66BB6A)),
      ('🐦', 'Forest Birds', 'Morning Canopy Chirp', Color(0xFF9CCC65)),
      ('🔥', 'Campfire', 'Warm Crackling Wood Logs', Color(0xFFFF7043)),
      ('💨', 'Wind in Trees', 'Calm Mountain Breeze', Color(0xFF78909C)),
      ('🦗', 'Crickets', 'Night Meadow Symphony', Color(0xFF8D6E63)),
      ('🌊', 'Waterfall', 'Majestic Cascade Spray', Color(0xFF00BCD4)),
      ('🐸', 'Frogs', 'Serene Marshland Night', Color(0xFF4CAF50)),
      ('🪨', 'Waves on Pebbles', 'Gentle Shoreline Shimmer', Color(0xFF80CBC4)),
      ('🤿', 'Underwater', 'Deep Ocean Submersion', Color(0xFF0277BD)),
      ('🌾', 'Meadow Breeze', 'Soft Grasslands Whispers', Color(0xFFAED581)),
      ('🏜️', 'Desert Wind', 'Solitary Dune Sweep', Color(0xFFFFB74D)),
      ('🌴', 'Jungle Night', 'Nocturnal Rainforest', Color(0xFF2E7D32)),
      ('🍂', 'Leaves Rustling', 'Autumn Footsteps', Color(0xFFD84315)),
      ('⛰️', 'Mountain Echo', 'Resonant Valley Stillness', Color(0xFF546E7A)),
    ],
    '☕ Places': [
      ('☕', 'Coffee Shop', 'Gentle Ambient Chatter', Color(0xFF8D6E63)),
      ('📚', 'Library', 'Silent Study Sanctuary', Color(0xFF5D4037)),
      ('🏢', 'Office Ambience', 'Low Productivity Hum', Color(0xFF78909C)),
      ('🔔', 'Church Bells', 'Distant Resonant Chimes', Color(0xFFFFB300)),
      ('🌳', 'Quiet Park', 'Peaceful Bench Retreat', Color(0xFF7CB342)),
      ('🛍️', 'Street Market', 'Soft Bustling Market', Color(0xFFFB8C00)),
      ('🥣', 'Temple Bowl', 'Zen Monastery Gong', Color(0xFFAB47BC)),
      ('🎍', 'Zen Garden', 'Raked Sand Fountain', Color(0xFF00ACC1)),
      ('⚓', 'Harbor', 'Gentle Boat Dock Lapping', Color(0xFF0288D1)),
      ('🚜', 'Farmyard', 'Rural Countryside', Color(0xFF8BC34A)),
    ],
    '🚆 Transport': [
      ('🚆', 'Train Track', 'Rhythmic Iron Rail Clicker', Color(0xFF546E7A)),
      ('✈️', 'Airplane Cabin', 'Soothing White Noise Cruise', Color(0xFF0288D1)),
      ('🚗', 'Driving Rain Car', 'Highway Windshield Rain', Color(0xFF455A64)),
      ('⛵', 'Boat Deck', 'Creaking Wooden Hull Waves', Color(0xFF0097A7)),
      ('🚇', 'Subway Train', 'Low Underground Metro', Color(0xFF37474F)),
      ('🚲', 'Bicycle Ride', 'Gentle Coasting Wind', Color(0xFF689F38)),
      ('⛵', 'Sailing Ship', 'Rigging Breeze & Swell', Color(0xFF00838F)),
      ('🛣️', 'Highway Traffic', 'Distant Asphalt Roll', Color(0xFF607D8B)),
    ],
    '⚙️ Things': [
      ('🕰️', 'Clock Ticking', 'Steady Rhythmic Pendulum', Color(0xFF78909C)),
      ('🌀', 'Fan Noise', 'Cooling Air Circulation', Color(0xFF00ACC1)),
      ('⌨️', 'Keyboard Typing', 'Soft Mechanical Keys', Color(0xFF546E7A)),
      ('🧺', 'Washing Machine', 'Gentle Laundry Rinsing', Color(0xFF0288D1)),
      ('📻', 'Vinyl Crackle', 'Warm Analog Nostalgia', Color(0xFF8D6E63)),
      ('🫖', 'Boiling Kettle', 'Cozy Teatime Whistle', Color(0xFFFF7043)),
      ('🎋', 'Bamboo Chimes', 'Pentatonic Wind Chimes', Color(0xFF26C6DA)),
      ('📖', 'Page Turning', 'Book Study Leaf', Color(0xFFA1887F)),
      ('⏱️', 'Pendulum', 'Hypnotic Second Beat', Color(0xFF455A64)),
      ('💨', 'Wind Generator', 'Constant Turbine Sweep', Color(0xFF90A4AE)),
    ],
    '🔊 Noise': [
      ('⚪', 'White Noise', 'Full Spectrum Flat Noise', Color(0xFFCFD8DC)),
      ('🌸', 'Pink Noise', 'Balanced Waterfall Spectrum', Color(0xFFF48FB1)),
      ('🤎', 'Brown Noise', 'Deep Low Frequency Rumble', Color(0xFF8D6E63)),
      ('🔵', 'Blue Noise', 'High Pitch Crisp Hiss', Color(0xFF64B5F6)),
      ('💜', 'Violet Noise', 'Ultra Crisp Shimmer', Color(0xFFBA68C8)),
      ('🩶', 'Grey Noise', 'Equal Perception Contour', Color(0xFF90A4AE)),
    ],
    '🔮 Solfeggio': [
      ('🧘', '432Hz Healing', 'Natural Harmony Tone', Color(0xFFAB47BC)),
      ('✨', '528Hz Transformation', 'Miracle Healing Frequency', Color(0xFF00E676)),
      ('💖', '639Hz Harmonics', 'Heart Relationship Harmony', Color(0xFFFF4081)),
      ('🧠', '108Hz Theta Drone', 'Deep Meditation State', Color(0xFF00ACC1)),
      ('💤', 'Delta Deep Sleep', 'Restful Subconscious Waves', Color(0xFF3F51B5)),
      ('⚡', 'Alpha Focus Flow', 'Peak Concentration Alpha Waves', Color(0xFFFFC107)),
      ('🔥', 'Beta Energy Boost', 'Active Consciousness', Color(0xFFFF5722)),
      ('🌌', 'Gamma Insight', 'High Cognitive Transcendence', Color(0xFF9C27B0)),
      ('🛡️', '174Hz Pain Relief', 'Physical Comfort Frequency', Color(0xFF4CAF50)),
      ('🌿', '285Hz Cellular', 'Vitality & Tissue Renewal', Color(0xFF8BC34A)),
      ('🕊️', '396Hz Liberation', 'Liberating Guilt & Fear', Color(0xFF00BCD4)),
      ('👁️', '741Hz Intuition', 'Awakening Inner Intuition', Color(0xFF7C4DFF)),
      ('✡️', '852Hz Awakening', 'Spiritual Order & Light', Color(0xFFE040FB)),
      ('👑', '963Hz Crown State', 'Divine Unity Consciousness', Color(0xFFFFD700)),
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      final cached = state.cachedVolumes;
      if (cached.isNotEmpty) {
        setState(() {
          cached.forEach((k, v) {
            if (_volumes.containsKey(k)) {
              _volumes[k] = v;
            }
          });
          _isPlaying = _volumes.values.any((v) => v > 0);
        });
      }
    });
  }

  // Group 1: Natural Environment Sounds (Popular)
  static const _popularNaturalSounds = [
    ('🌧️', 'Soft Rain', 'Gentle Downpour', Color(0xFF42A5F5)),
    ('🌊', 'Ocean Waves', 'Rolling Pacific Tide', Color(0xFF26A69A)),
    ('🌲', 'Mountain Stream', 'Flowing Crystal Creek', Color(0xFF66BB6A)),
    ('🔥', 'Cozy Hearth', 'Warm Crackling Fire', Color(0xFFFF7043)),
    ('💨', 'Soothing Breeze', 'Calm Wind Sweep', Color(0xFF78909C)),
    ('⚡', 'Thunderstorm', 'Distant Low Rumble', Color(0xFF5C6BC0)),
  ];

  // Group 2: Advanced Healing Enhancements
  static const _advancedSounds = [
    ('🔮', 'Singing Bowls', '432Hz Solfeggio Tones', Color(0xFFAB47BC)),
    ('🪐', 'Deep Space Drone', '108Hz Delta Frequency', Color(0xFF00ACC1)),
    ('🎹', 'Ambient Piano', 'Generative Calm Chords', Color(0xFF8E24AA)),
    ('🐦', 'Forest Birds', 'Morning Canopy Chirp', Color(0xFF9CCC65)),
    ('🎋', 'Bamboo Chimes', 'Pentatonic Wind Chimes', Color(0xFF26C6DA)),
  ];

  void _applyVolumes(Map<String, double> vols, AppState state) {
    setState(() {
      _volumes.forEach((k, _) {
        final v = vols[k] ?? 0.0;
        _volumes[k] = v;
        state.updateSoundTrackVolume(k, v);
      });
      _isPlaying = true;
    });
    state.saveCachedVolumes(_volumes);
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 1), () {
          if (ctx.mounted) Navigator.pop(ctx);
        });
        return CupertinoAlertDialog(
          title: const Text('Preset Applied ✓'),
          content: const Text('Playing ambient soundscape'),
        );
      },
    );
  }

  void _toggleMasterPlay(AppState state) {
    setState(() {
      _isPlaying = !_isPlaying;
      if (!_isPlaying) {
        state.stopAllAudio();
      } else {
        _volumes.forEach((name, vol) {
          if (vol > 0) {
            state.updateSoundTrackVolume(name, vol);
          }
        });
      }
    });
  }

  void _randomizeMix(AppState state) {
    final Map<String, double> newVols = {};
    _volumes.keys.forEach((key) {
      // 30% chance for track to be active
      final active = (DateTime.now().microsecondsSinceEpoch % 10) > 6;
      newVols[key] = active ? (0.2 + (DateTime.now().millisecondsSinceEpoch % 5) * 0.1) : 0.0;
    });
    _applyVolumes(newVols, state);
  }

  void _shareCurrentMix(AppState state) {
    final url = state.generateShareUrl();
    Clipboard.setData(ClipboardData(text: url));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) Navigator.pop(ctx);
        });
        return const CupertinoAlertDialog(
          title: Text('Mix Link Copied! 🔗'),
          content: Text('Share this link with friends so they can listen to your exact sound mix.'),
        );
      },
    );
  }

  void _showSavePresetDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Save Sound Preset'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'e.g. Rainy Study Night',
            style: const TextStyle(color: textPrimary),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.savePreset(controller.text.trim(), Map.from(_volumes));
                Navigator.pop(ctx);
                showCupertinoDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (ctx2) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (ctx2.mounted) Navigator.pop(ctx2);
                    });
                    return CupertinoAlertDialog(
                      title: const Text('Preset Saved ✓'),
                    );
                  },
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRenamePresetDialog(BuildContext context, String currentName, AppState state) {
    final displayName = state.getPresetDisplayName(currentName);
    final controller = TextEditingController(text: displayName);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Rename Recommended Mix'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter custom name',
            style: const TextStyle(color: textPrimary),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.renameCuratedPreset(currentName, controller.text.trim());
                Navigator.pop(ctx);
                showCupertinoDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (ctx2) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (ctx2.mounted) Navigator.pop(ctx2);
                    });
                    return CupertinoAlertDialog(
                      title: Text('Renamed to "${controller.text.trim()}" ✓'),
                    );
                  },
                );
              }
            },
            child: const Text('Save Name'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(
    (String, String, String, Color) t,
    AppState state,
  ) {
    final emoji = t.$1;
    final name = t.$2;
    final desc = t.$3;
    final color = t.$4;
    final vol = _volumes[name] ?? 0.0;
    final isActive = vol > 0 && _isPlaying;
    final imgUrl = soundImages[name];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive ? color.withOpacity(0.8) : Colors.white.withOpacity(0.08),
              width: isActive ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? color.withOpacity(0.3) : Colors.black.withOpacity(0.35),
                blurRadius: isActive ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 🖼️ High-Definition Artwork Background with Gradient Overlay
              if (imgUrl != null) ...[
                Positioned.fill(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF09141D).withOpacity(0.82),
                          const Color(0xFF050D15).withOpacity(0.94),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // 🎨 Card Content Layer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // 3D Artwork Thumbnail Badge
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive ? color : Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: imgUrl != null
                                ? Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Center(
                                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                    ),
                                  )
                                : Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? color : textPrimary,
                                        letterSpacing: -0.2,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: const EdgeInsets.only(left: 6),
                                    minSize: 0,
                                    onPressed: () => state.toggleFavoriteSound(name),
                                    child: Icon(
                                      state.isFavorite(name) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: state.isFavorite(name) ? coralAccent : textSecondary.withOpacity(0.4),
                                      size: 18,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    AnimatedSoundWave(accentColor: color),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                desc,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: textSecondary, decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                        ),

                        // Volume Badge & Switch Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: vol > 0 ? color.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: vol > 0 ? color.withOpacity(0.4) : Colors.white10,
                            ),
                          ),
                          child: Text(
                            '${(vol * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: vol > 0 ? color : textSecondary.withOpacity(0.6),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        CupertinoSwitch(
                          value: vol > 0,
                          activeColor: color,
                          onChanged: (val) {
                            final newVol = val ? 0.35 : 0.0;
                            setState(() {
                              _volumes[name] = newVol;
                              _isPlaying = true;
                            });
                            state.updateSoundTrackVolume(name, newVol);
                          },
                        ),
                      ],
                    ),

                    // Smooth Interactive Volume Slider
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: vol > 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CupertinoSlider(
                          value: vol,
                          activeColor: color,
                          onChanged: (v) {
                            setState(() {
                              _volumes[name] = v;
                              _isPlaying = true;
                            });
                            state.updateSoundTrackVolume(name, v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isClay = state.themeMode.isLight;
    final activeTextColor = isClay ? clayText : textPrimary;
    final activeSubtextColor = isClay ? claySubtext : textSecondary;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text(
                'Sounds',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xE6050D15),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  SoundMixShareModal.show(context);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.share, color: tealPrimary, size: 20),
                    SizedBox(width: 4),
                    Text('Share', style: TextStyle(color: tealPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AMBIENT SOUND MIXER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isClay ? clayAccent : tealPrimary,
                                  letterSpacing: 1.8,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                'Build Your Environment',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: activeTextColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: tealPrimary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.slider_horizontal_3, color: tealPrimary, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Layer natural sounds & healing frequencies for work, study, or sleep',
                      style: TextStyle(fontSize: 13, color: textSecondary, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 20),

                    // 🎛️ Master Control Center Bar (Apple-level Luxury Tactile UI)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF132230).withOpacity(0.95),
                            const Color(0xFF091420).withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isPlaying ? tealPrimary.withOpacity(0.45) : Colors.white.withOpacity(0.12),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isPlaying ? tealPrimary.withOpacity(0.20) : Colors.black.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ⏯️ Glowing Play / Pause Master Dial
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _toggleMasterPlay(state);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _isPlaying
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.06)],
                                      ),
                                boxShadow: _isPlaying
                                    ? [
                                        BoxShadow(
                                          color: tealPrimary.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                color: _isPlaying ? Colors.black : Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // 🏷️ Track Status & Active Counter
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (_isPlaying) ...[
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: tealPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Flexible(
                                      child: Text(
                                        _isPlaying ? 'Soundscape Active' : 'Mixer Paused',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isPlaying
                                      ? '${_volumes.values.where((v) => v > 0).length} active layers'
                                      : 'Tap play to start audio',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🔀 Shuffle Randomize Mix Button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _randomizeMix(state);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: const Icon(CupertinoIcons.shuffle, color: Colors.white70, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 📤 Share Mix Button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _shareCurrentMix(state);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: tealPrimary.withOpacity(0.14),
                                shape: BoxShape.circle,
                                border: Border.all(color: tealPrimary.withOpacity(0.35)),
                              ),
                              child: const Icon(CupertinoIcons.share, color: tealPrimary, size: 16),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 💾 Save & Pin Mix Pill Button (High Contrast & Tactile)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showSavePresetDialog(context, state);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: tealPrimary.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.bookmark_fill, color: Colors.black, size: 13),
                                  SizedBox(width: 5),
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 1-TAP CURATED PRESET MIXES
                    const Text(
                      'CURATED ONE-TAP MIXES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tealPrimary,
                        letterSpacing: 1.6,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppState.curatedPresets.entries.map((e) {
                          final displayName = state.getPresetDisplayName(e.key);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onLongPress: () => _showRenamePresetDialog(context, e.key, state),
                              child: GlassChip(
                                label: displayName,
                                onTap: () => _applyVolumes(e.value, state),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // MESSENGER-STYLE HORIZONTAL CATEGORY FILTER TRAY
                    Row(
                      children: [
                        const Icon(CupertinoIcons.square_grid_2x2_fill, color: tealPrimary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'SOUND CATEGORY TRAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 1.6,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CupertinoSlidingSegmentedControl<String>(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          thumbColor: tealPrimary,
                          groupValue: _selectedCategory,
                          onValueChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                          children: {
                            '❤️ Favorites': Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '❤️ Favorites (${state.favoriteSounds.length})',
                                style: TextStyle(
                                  color: _selectedCategory == '❤️ Favorites' ? Colors.black : textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...Map.fromEntries(
                              soundCategories.keys.map((catKey) => MapEntry(
                                    catKey,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        '$catKey (${soundCategories[catKey]?.length ?? 0})',
                                        style: TextStyle(
                                          color: _selectedCategory == catKey ? Colors.black : textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // LIST OF SOUND CARDS FOR SELECTED CATEGORY
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: Builder(
                builder: (context) {
                  List<(String, String, String, Color)> currentList = [];
                  if (_selectedCategory == '❤️ Favorites') {
                    for (final catList in soundCategories.values) {
                      for (final item in catList) {
                        if (state.isFavorite(item.$2)) {
                          currentList.add(item);
                        }
                      }
                    }
                    if (currentList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: GlassCard(
                          cornerRadius: 22,
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                const Icon(CupertinoIcons.heart, color: coralAccent, size: 40),
                                const SizedBox(height: 12),
                                const Text(
                                  'No Favorite Sounds Saved Yet',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary, decoration: TextDecoration.none),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap the ❤️ heart icon on any sound card to build your top favorites list!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.5, color: textSecondary, decoration: TextDecoration.none),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    currentList = soundCategories[_selectedCategory] ?? [];
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i >= currentList.length) return const SizedBox.shrink();
                        return _buildTrackCard(currentList[i], state);
                      },
                      childCount: currentList.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
