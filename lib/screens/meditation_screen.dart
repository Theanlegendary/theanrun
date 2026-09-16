import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  String _selectedCategory = 'All';

  static const _sessions = [
    ('🌸', 'Gentle Relief & Comfort', '15', 'Comfort', 'Soft wind chimes and gentle rain to soothe your heart & mind'),
    ('🌿', 'Soft Body Rest & Ease', '18', 'Comfort', 'Warm ocean waves to help your body feel completely weightless and safe'),
    ('🌅', 'Peaceful Morning Awakening', '10', 'Morning', 'Gentle morning birds and soft warmth to welcome a brand new day'),
    ('🕊️', 'Quiet Mind Sanctuary', '8', 'Morning', 'A soft quiet space to rest your thoughts without any pressure'),
    ('🌙', 'Cozy Bedtime Slumber', '20', 'Sleep', 'Gentle bedtime lullaby to help you drift off into sweet, easy sleep'),
    ('✨', 'Healing Crystal Chimes', '35', 'Sleep', 'Deep peaceful harmonic chimes for uninterrupted night rest'),
    ('💗', 'Warm Heart Comfort', '15', 'Healing', 'Feel safe, loved, and held in a soft, gentle sanctuary of warmth'),
    ('🌄', 'Peaceful Haven Journey', '25', 'Focus', 'Drift along a quiet forest stream into your own peaceful safe place'),
    ('🔮', 'Gentle Breeze Rest', '30', 'Healing', 'Soft whispering pine trees to wash away heavy thoughts effortless'),
    ('🐈', 'Loving Warmth & Peace', '15', 'Healing', 'Cozy companion warmth and soft purrs to bring peace to your day'),
    ('🌊', 'Ocean Horizon Slumber', '25', 'Sleep', 'Lapping tide under moonlight for effortless deep sleep'),
    ('🧘', 'Chakra Solfeggio Alignment', '30', 'Healing', 'Harmonic 432Hz crystal frequencies to align energy'),
    ('🌲', 'Pine Forest Bathing', '20', 'Comfort', 'Walk among whispering pines and fresh mountain air'),
    ('⚡', 'Release Anxious Tension', '12', 'Comfort', 'Soft breath guidance to melt muscle tightness and anxiety'),
  ];

  static const _colorPairs = [
    [Color(0xFF162534), tealPrimary],
    [Color(0xFF162830), mintAccent],
    [Color(0xFF261C30), purpleAccent],
    [Color(0xFF1E2830), tealDark],
    [Color(0xFF2D201A), coralAccent],
    [Color(0xFF181C30), tealPrimary],
    [Color(0xFF1A2930), mintAccent],
    [Color(0xFF241A30), purpleAccent],
    [Color(0xFF2A1E26), coralAccent],
    [Color(0xFF1B2830), tealPrimary],
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _sessions
        : _sessions.where((s) => s.$4 == _selectedCategory).toList();

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header ─────────────────────────────────────────────────────
                  CupertinoSliverNavigationBar(
                    largeTitle: const Text(
                      'Meditate',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xE60A1A12),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                        width: 0.5,
                      ),
                    ),
                    trailing: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tealPrimary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        color: tealPrimary,
                        size: 20,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search by how you feel — curated practices for your emotional state',
                            style: TextStyle(fontSize: 13, color: textSecondary),
                          ),
                          const SizedBox(height: 20),

                          // Daily Featured Card (Pixel-Perfect Match to Screenshot)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.35),
                                          Colors.black.withOpacity(0.85),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // 64x64 Rounded Artwork Badge
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.4),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(
                                                'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'DAILY GUIDED JOURNEY',
                                                  style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: tealPrimary,
                                                    letterSpacing: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                const Text(
                                                  'Calm Mountain Horizon',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    const Icon(CupertinoIcons.time, size: 13, color: Colors.white70),
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      '10 Min • Deep Relaxation',
                                                      style: TextStyle(fontSize: 12, color: Colors.white70),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Consumer<AppState>(
                                            builder: (ctx, state, _) {
                                              final isThisPlaying = state.isGuidedPlaying && state.currentGuidedTitle == 'Calm Mountain Horizon';
                                              return CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  HapticFeedback.lightImpact();
                                                  if (isThisPlaying) {
                                                    state.pauseGuidedSession();
                                                  } else {
                                                    state.playGuidedSession('Calm Mountain Horizon', 10);
                                                  }
                                                },
                                                child: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.4),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                                  ),
                                                  child: Icon(
                                                    isThisPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),

                                      Row(
                                        children: [
                                          Consumer<AppState>(
                                            builder: (ctx, state, _) {
                                              final isThisPlaying = state.isGuidedPlaying && state.currentGuidedTitle == 'Calm Mountain Horizon';
                                              return GlassPillButton(
                                                text: isThisPlaying ? 'Pause Session' : 'Begin Session',
                                                icon: isThisPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                                containerColor: isThisPlaying ? coralAccent : tealPrimary,
                                                contentColor: Colors.black,
                                                onTap: () {
                                                  HapticFeedback.mediumImpact();
                                                  if (isThisPlaying) {
                                                    state.pauseGuidedSession();
                                                  } else {
                                                    state.playGuidedSession('Calm Mountain Horizon', 10);
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                          const Spacer(),
                                          const AnimatedSoundWave(accentColor: tealPrimary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // EMOTIONAL INTENT FILTER CHIPS
                          const Text(
                            'BROWSE BY EMOTIONAL INTENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: tealPrimary,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: CupertinoSlidingSegmentedControl<String>(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                thumbColor: tealPrimary.withOpacity(0.3),
                                groupValue: _selectedCategory,
                                onValueChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedCategory = value);
                                  }
                                },
                                children: {
                                  'All': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All ✨', style: TextStyle(color: Colors.white))),
                                  'Comfort': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Comfort', style: TextStyle(color: Colors.white))),
                                  'Morning': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Morning', style: TextStyle(color: Colors.white))),
                                  'Sleep': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Sleep', style: TextStyle(color: Colors.white))),
                                  'Focus': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Focus', style: TextStyle(color: Colors.white))),
                                  'Healing': const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Healing', style: TextStyle(color: Colors.white))),
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ── Session List Filtered by Mood Intent ───────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = filtered[i];
                          final colors = _colorPairs[i % _colorPairs.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CupertinoContextMenu(
                              actions: [
                                CupertinoContextMenuAction(
                                  child: const Text('Play'),
                                  trailingIcon: CupertinoIcons.play_fill,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Provider.of<AppState>(context, listen: false).playGuidedSession(s.$2, int.tryParse(s.$3) ?? 10);
                                  },
                                ),
                                CupertinoContextMenuAction(
                                  child: const Text('Favorite'),
                                  trailingIcon: CupertinoIcons.heart_fill,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoContextMenuAction(
                                  child: const Text('Share'),
                                  trailingIcon: CupertinoIcons.share,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                              child: Material( // Wrap in Material so cards can still have shadows/gestures properly inside context menu if needed
                                color: Colors.transparent,
                                child: _SessionCard(
                                  emoji: s.$1,
                                  title: s.$2,
                                  duration: s.$3,
                                  category: s.$4,
                                  description: s.$5,
                                  accentColor: colors[1],
                                  bgColor: colors[0],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String emoji, title, duration, category, description;
  final Color accentColor, bgColor;

  static const Map<String, String> sessionImages = {
    'Gentle Relief & Comfort': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
    'Soft Body Rest & Ease': 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80',
    'Peaceful Morning Awakening': 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80',
    'Quiet Mind Sanctuary': 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
    'Cozy Bedtime Slumber': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
    'Healing Crystal Chimes': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=400&q=80',
    'Warm Heart Comfort': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    'Peaceful Haven Journey': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
    'Gentle Breeze Rest': 'https://images.unsplash.com/photo-1528319725582-ddc096101511?auto=format&fit=crop&w=400&q=80',
    'Loving Warmth & Peace': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=400&q=80',
  };

  const _SessionCard({
    required this.emoji,
    required this.title,
    required this.duration,
    required this.category,
    required this.description,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = sessionImages[title];

    return Consumer<AppState>(
      builder: (ctx, state, _) {
        final isPlayingThis = state.isGuidedPlaying && state.currentGuidedTitle == title;

        return GestureDetector(
          onTap: () {
            if (isPlayingThis) {
              state.pauseGuidedSession();
            } else {
              state.playGuidedSession(title, int.tryParse(duration) ?? 10);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isPlayingThis ? accentColor.withOpacity(0.9) : Colors.white.withOpacity(0.08),
                    width: isPlayingThis ? 1.8 : 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPlayingThis ? accentColor.withOpacity(0.35) : Colors.black.withOpacity(0.35),
                      blurRadius: isPlayingThis ? 18 : 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 🖼️ High-Definition Artwork Background
                    if (imgUrl != null) ...[
                      Positioned.fill(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const SizedBox.shrink(),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(isPlayingThis ? 0.22 : 0.12),
                                const Color(0xFF0A141D).withOpacity(0.88),
                                const Color(0xFF050D15).withOpacity(0.96),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // 🎨 Card Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 🖼️ Tall TikTok Portrait Artwork Thumbnail Container (100x135)
                          Container(
                            width: 100,
                            height: 135,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPlayingThis ? accentColor : Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(isPlayingThis ? 0.5 : 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: imgUrl != null
                                  ? Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Center(
                                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                                      ),
                                    )
                                  : Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isPlayingThis ? accentColor : textPrimary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [accentColor.withOpacity(0.3), accentColor.withOpacity(0.15)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: accentColor.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.time, size: 14, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$duration min • Guided Session',
                                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                                    ),
                                    if (isPlayingThis) ...[
                                      const SizedBox(width: 8),
                                      AnimatedSoundWave(accentColor: accentColor),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isPlayingThis
                                              ? [coralAccent, const Color(0xFFF43F5E)]
                                              : [accentColor, accentColor.withOpacity(0.85)],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isPlayingThis ? coralAccent : accentColor).withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isPlayingThis ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                            size: 13,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isPlayingThis ? 'Pause' : 'Begin',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

