import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/theme/neumorphism_demo.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  Timer? _sleepTimer;
  int? _remainingSec;
  int? _totalSec;
  bool _isRunning = false;
  Duration _selectedDuration = const Duration(minutes: 30);

  static const _playlists = [
    (
      'Ocean Waves',
      '45 min',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
      purpleAccent
    ),
    (
      'Campfire',
      '35 min',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      coralAccent
    ),
    (
      'Night Forest',
      '40 min',
      'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=400&q=80',
      tealPrimary
    ),
    (
      'Heavy Rain',
      '30 min',
      'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
      mintAccent
    ),
    (
      'Thunderstorm',
      '45 min',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
      purpleAccent
    ),
  ];

  static const _quickMixerTracks = [
    ('Ocean', CupertinoIcons.waveform, 'Ocean Waves', purpleAccent),
    ('Rain', CupertinoIcons.cloud_rain_fill, 'Soft Rain', mintAccent),
    ('Wind', CupertinoIcons.wind, 'Soothing Breeze', tealPrimary),
    ('Thunder', CupertinoIcons.bolt_fill, 'Thunderstorm', coralAccent),
    ('Nature', CupertinoIcons.leaf_arrow_circlepath, 'Mountain Stream', Colors.greenAccent),
  ];

  void _startTimer(int minutes) {
    context.read<AppState>().startSleepTimer(minutes);
  }

  void _cancelTimer() {
    context.read<AppState>().cancelSleepTimer();
  }

  void _showTimerPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        // BUG FIX: Use StatefulBuilder so setState is scoped to modal, not parent widget
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: 300,
              color: const Color(0xE6050D15),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CupertinoButton(
                          child: const Text('Done', style: TextStyle(color: purpleAccent)),
                          onPressed: () {
                            _startTimer(_selectedDuration.inMinutes);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.hm,
                        initialTimerDuration: _selectedDuration,
                        onTimerDurationChanged: (Duration newDuration) {
                          setModalState(() => _selectedDuration = newDuration);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Sleep', style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xE6050D15),
                  border: null,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ───────────────
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Good Evening ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text('🌙', style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Sleep Sanctuary',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Everything you need for a perfect night\'s rest ♡',
                                    style: TextStyle(fontSize: 13, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(CupertinoIcons.bell, color: Colors.white, size: 22),
                                  Positioned(
                                    top: 11,
                                    right: 12,
                                    child: CircleAvatar(
                                      radius: 3.5,
                                      backgroundColor: purpleAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Timer Row
                        GlassCard(
                          cornerRadius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.timer, color: purpleAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.isSleepTimerRunning && state.sleepTimerRemainingSec != null
                                        ? 'Timer: ${(state.sleepTimerRemainingSec! ~/ 60).toString().padLeft(2, '0')}:${(state.sleepTimerRemainingSec! % 60).toString().padLeft(2, '0')}'
                                        : 'Set Sleep Auto-Fade Timer',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: state.isSleepTimerRunning ? _cancelTimer : _showTimerPicker,
                                child: Text(
                                  state.isSleepTimerRunning ? 'Cancel' : 'Set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: state.isSleepTimerRunning ? coralAccent : purpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Tonight's Journey Hero Card (Ocean Sleep) ───────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: purpleAccent.withOpacity(0.35), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: purpleAccent.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
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
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.88),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: purpleAccent.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: purpleAccent.withOpacity(0.5)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(CupertinoIcons.star_fill, color: purpleAccent, size: 12),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Tonight\'s Journey',
                                                  style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () => state.playGuidedSession('Cozy Bedtime Slumber', 45),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.4),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                                              ),
                                              child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 26),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ocean Sleep',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Deep Relaxation',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Row(
                                            children: [
                                              Icon(CupertinoIcons.time, size: 13, color: Colors.white60),
                                              SizedBox(width: 4),
                                              Text(
                                                '45 min • 🎵 Ocean + Rain',
                                                style: TextStyle(fontSize: 11.5, color: Colors.white60),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          GlassPillButton(
                                            text: 'Begin Sleep',
                                            icon: CupertinoIcons.play_fill,
                                            containerColor: purpleAccent,
                                            contentColor: Colors.white,
                                            onTap: () => state.playGuidedSession('Cozy Bedtime Slumber', 45),
                                          ),
                                          const Spacer(),
                                          const AnimatedSoundWave(accentColor: purpleAccent),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Continue Listening Card ───────────────────────────
                        const Row(
                          children: [
                            Icon(CupertinoIcons.time, color: purpleAccent, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Continue Listening',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        GlassCard(
                          cornerRadius: 22,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=200&q=80',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rain on Window',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      '31 min remaining',
                                      style: TextStyle(fontSize: 11.5, color: Colors.white60),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: const LinearProgressIndicator(
                                              value: 0.68,
                                              backgroundColor: Colors.white10,
                                              valueColor: AlwaysStoppedAnimation<Color>(purpleAccent),
                                              minHeight: 4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '68%',
                                          style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              GlassPillButton(
                                text: 'Resume',
                                icon: CupertinoIcons.play_fill,
                                containerColor: purpleAccent.withOpacity(0.3),
                                contentColor: Colors.white,
                                onTap: () => state.applyCuratedPreset('🌧️ Rainy Cabin'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Wind Down Playlist (Horizontal 120x120 Carousel) ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.sparkles, color: purpleAccent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Wind Down Playlist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'See All >',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: purpleAccent.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _playlists.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => state.applyCuratedPreset('🌧️ Rainy Cabin'),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: item.$4.withOpacity(0.3)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: item.$4.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Image.network(
                                                  item.$3,
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
                                                        Colors.transparent,
                                                        Colors.black.withOpacity(0.7),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          item.$1,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.$2,
                                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Sleep Sounds Mixer (Quick Touch Buttons) ───────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.slider_horizontal_3, color: purpleAccent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Sleep Sounds Mixer',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => state.setTab(AppTab.sounds),
                              child: Text(
                                'Customize >',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: purpleAccent.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        GlassCard(
                          cornerRadius: 24,
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _quickMixerTracks.map((t) {
                              final label = t.$1;
                              final icon = t.$2;
                              final trackName = t.$3;
                              final color = t.$4;
                              final vol = state.getTrackVolume(trackName);
                              final isActive = vol > 0;

                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  state.updateSoundTrackVolume(trackName, isActive ? 0.0 : 0.6);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isActive ? color : Colors.white.withOpacity(0.15),
                                          width: 1.5,
                                        ),
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: color.withOpacity(0.4),
                                                  blurRadius: 12,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isActive ? color : Colors.white60,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                                        color: isActive ? color : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 44,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: vol.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── 5. SLEEP STORIES SECTION ──
                        const Text(
                          'Sleep Stories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Filter Pill Bar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: purpleAccent.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'All',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: const Center(
                                    child: Text(
                                      'My Stories',
                                      style: TextStyle(fontSize: 12.5, color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: const Center(
                                    child: Text(
                                      'Downloaded',
                                      style: TextStyle(fontSize: 12.5, color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        CupertinoListSection.insetGrouped(
                          backgroundColor: Colors.transparent,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          children: [
                            _buildSleepStoryTile(
                              title: 'The Starry Night',
                              narrator: 'Emma Wallace',
                              duration: '35 min',
                              imageUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('The Starry Night', 35),
                            ),
                            _buildSleepStoryTile(
                              title: 'Journey to Dreamland',
                              narrator: 'James Harrington',
                              duration: '42 min',
                              imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('Journey to Dreamland', 42),
                            ),
                            _buildSleepStoryTile(
                              title: 'The Hidden Waterfall',
                              narrator: 'Luna Harmony',
                              duration: '38 min',
                              imageUrl: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('The Hidden Waterfall', 38),
                            ),
                            _buildSleepStoryTile(
                              title: 'The Lighthouse Keeper',
                              narrator: 'Oliver M.',
                              duration: '40 min',
                              imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('The Lighthouse Keeper', 40),
                            ),
                            _buildSleepStoryTile(
                              title: 'Moonlit Japanese Garden',
                              narrator: 'Mei Lin',
                              duration: '35 min',
                              imageUrl: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('Moonlit Japanese Garden', 35),
                            ),
                            _buildSleepStoryTile(
                              title: 'Whispering Pine Forest',
                              narrator: 'Julian Ross',
                              duration: '28 min',
                              imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('Whispering Pine Forest', 28),
                            ),
                            _buildSleepStoryTile(
                              title: 'Desert Stargazing',
                              narrator: 'Kai Thompson',
                              duration: '32 min',
                              imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('Desert Stargazing', 32),
                            ),
                            _buildSleepStoryTile(
                              title: 'Ancient Temple Bells',
                              narrator: 'Ravi Sharma',
                              duration: '45 min',
                              imageUrl: 'https://images.unsplash.com/photo-1528319725582-ddc096101511?auto=format&fit=crop&w=400&q=80',
                              onTap: () => state.playGuidedSession('Ancient Temple Bells', 45),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── 6. TWILIGHT SOFT UI SHOWCASE CARD ──
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => const NeumorphismDemoScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1826).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFC7D2FE).withOpacity(0.35), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 8),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF162338),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFC7D2FE).withOpacity(0.2),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.moon_stars_fill,
                                      color: Color(0xFFC7D2FE),
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Twilight Soft UI Controls 🌙',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Tactile haptic dials, mood orb & living wallpaper',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(CupertinoIcons.chevron_right, color: Color(0xFFC7D2FE), size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSleepStoryTile({
    required String title,
    required String narrator,
    required String duration,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      leadingSize: 60,
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            narrator,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            duration,
            style: TextStyle(
              fontSize: 11.5,
              color: purpleAccent.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: const Icon(
          CupertinoIcons.cloud_download,
          color: Colors.white70,
          size: 16,
        ),
      ),
    );
  }
}
