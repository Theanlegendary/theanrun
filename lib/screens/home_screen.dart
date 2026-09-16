import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/theme/neumorphism_demo.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning, Welcome 🌸';
    if (h < 17) return 'Good Afternoon, Soft Rest 🌿';
    return 'Good Evening, Rest Easy 🌙';
  }

  static const _featured = [
    {
      'title': 'Morning Clarity',
      'desc': '10 Min • Quiet Awareness',
      'icon': Icons.wb_sunny_rounded,
      'type': 'Meditation',
      'mins': 10,
      'color': tealPrimary
    },
    {
      'title': 'Box Breath Reset',
      'desc': '5 Min • Stress Relief',
      'icon': Icons.air_rounded,
      'type': 'Breathing',
      'mins': 5,
      'color': mintAccent
    },
    {
      'title': 'Deep Ocean Sleep',
      'desc': '30 Min • Restorative Slumber',
      'icon': Icons.nightlight_round,
      'type': 'Sleep',
      'mins': 30,
      'color': coralAccent
    },
    {
      'title': '432Hz Sound Bath',
      'desc': '20 Min • Solfeggio Tones',
      'icon': CupertinoIcons.waveform,
      'type': 'Sounds',
      'mins': 20,
      'color': purpleAccent
    },
    {
      'title': 'Evening Gratitude',
      'desc': '15 Min • Mindful Presence',
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'type': 'Meditation',
      'mins': 15,
      'color': mintAccent
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = _featured[DateTime.now().weekday % _featured.length];
    final IconData featuredIcon = today['icon'] as IconData;
    final Color featuredColor = today['color'] as Color;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final isClay = state.themeMode.isLight;
        final activeTextColor = isClay ? clayText : textPrimary;
        final activeSubtextColor = isClay ? claySubtext : textSecondary;

        return CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      CupertinoSliverNavigationBar(
                        backgroundColor: Colors.transparent,
                        border: null,
                        largeTitle: Text(
                          _greeting(),
                          style: TextStyle(
                            color: activeTextColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🖼️ Atmospheric Living Background Switcher
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 32,
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (ctx) => CupertinoActionSheet(
                                      title: const Text('Atmospheric Background 🖼️'),
                                      message: const Text('Change the ambient living backdrop across all pages:'),
                                      actions: AppWallpaper.values.map((w) {
                                        final isCurrent = state.wallpaper == w;
                                        return CupertinoActionSheetAction(
                                          onPressed: () {
                                            state.setWallpaper(w);
                                            Navigator.pop(ctx);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(w.displayName),
                                              if (isCurrent) ...[
                                                const SizedBox(width: 8),
                                                const Icon(CupertinoIcons.checkmark_alt, color: tealPrimary, size: 16),
                                              ],
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      cancelButton: CupertinoActionSheetAction(
                                        isDefaultAction: true,
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color: textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isClay ? clayCardBg : Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 32,
                                onPressed: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (ctx) => CupertinoActionSheet(
                                      title: const Text('Data Backup & Restore 💾'),
                                      message: const Text('Prevent data loss across browsers and devices.'),
                                      actions: [
                                        CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            final json = state.exportUserDataToJson();
                                            Clipboard.setData(ClipboardData(text: json));
                                            showCupertinoDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (dCtx) {
                                                Future.delayed(const Duration(seconds: 2), () {
                                                  if (dCtx.mounted) Navigator.pop(dCtx);
                                                });
                                                return const CupertinoAlertDialog(
                                                  title: Text('Backup Copied ✓'),
                                                  content: Text('Your streak, presets, and favorites JSON data has been copied to your clipboard.'),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text('Export / Backup to Clipboard'),
                                        ),
                                        CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            final controller = TextEditingController();
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (dCtx) => CupertinoAlertDialog(
                                                title: const Text('Restore Data'),
                                                content: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CupertinoTextField(
                                                    controller: controller,
                                                    placeholder: 'Paste your backup JSON here...',
                                                    maxLines: 4,
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoDialogAction(
                                                    child: const Text('Cancel'),
                                                    onPressed: () => Navigator.pop(dCtx),
                                                  ),
                                                  CupertinoDialogAction(
                                                    isDefaultAction: true,
                                                    child: const Text('Restore'),
                                                    onPressed: () {
                                                      final success = state.importUserDataFromJson(controller.text.trim());
                                                      Navigator.pop(dCtx);
                                                      showCupertinoDialog(
                                                        context: context,
                                                        barrierDismissible: true,
                                                        builder: (resCtx) {
                                                          Future.delayed(const Duration(seconds: 2), () {
                                                            if (resCtx.mounted) Navigator.pop(resCtx);
                                                          });
                                                          return CupertinoAlertDialog(
                                                            title: Text(success ? 'Restored Successfully ✓' : 'Restore Failed'),
                                                            content: Text(success ? 'All your presets and streak history have been restored.' : 'Invalid JSON format. Please verify and try again.'),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: const Text('Import / Restore from JSON'),
                                        ),
                                        CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            final feedbackCtrl = TextEditingController();
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (fCtx) => CupertinoAlertDialog(
                                                title: const Text('Feedback & Sound Requests 💌'),
                                                content: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CupertinoTextField(
                                                    controller: feedbackCtrl,
                                                    placeholder: 'Describe a feature or sound you would love...',
                                                    maxLines: 3,
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoDialogAction(
                                                    child: const Text('Cancel'),
                                                    onPressed: () => Navigator.pop(fCtx),
                                                  ),
                                                  CupertinoDialogAction(
                                                    isDefaultAction: true,
                                                    child: const Text('Submit'),
                                                    onPressed: () {
                                                      Navigator.pop(fCtx);
                                                      showCupertinoDialog(
                                                        context: context,
                                                        barrierDismissible: true,
                                                        builder: (sCtx) {
                                                          Future.delayed(const Duration(seconds: 2), () {
                                                            if (sCtx.mounted) Navigator.pop(sCtx);
                                                          });
                                                          return const CupertinoAlertDialog(
                                                            title: Text('Thank You! 🌿'),
                                                            content: Text('Your feedback has been received and helps us improve Sanctuary.'),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: const Text('Send Feedback / Sound Request 💌'),
                                        ),
                                        CupertinoActionSheetAction(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            await state.restorePurchase();
                                            if (context.mounted) {
                                              showCupertinoDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (rCtx) {
                                                  Future.delayed(const Duration(seconds: 2), () {
                                                    if (rCtx.mounted) Navigator.pop(rCtx);
                                                  });
                                                  return const CupertinoAlertDialog(
                                                    title: Text('Purchases Restored ✓'),
                                                    content: Text('Your Apple ID subscriptions and unlocked soundscapes have been verified.'),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: const Text('Restore Purchases (Apple ID) 🔄'),
                                        ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        isDefaultAction: true,
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  CupertinoIcons.arrow_down_doc_fill,
                                  color: isClay ? clayText : textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (state.streak > 0) StreakBadge(streakCount: state.streak),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── Serenly Top Avatar & Greeting Header ──
                            const _SerenlyUserHeader(),
                            const SizedBox(height: 20),

                            // ── Serenly Hero Banner: "Return To Stillness" ──
                            const _SerenlyHeroReturnToStillness(),
                            const SizedBox(height: 18),

                            // ── Serenly Special Holiday Offer Strip ──
                            const _SerenlyHolidayOfferCard(),
                            const SizedBox(height: 18),

                            // ── ⚡ 1-Tap SOS Panic / Stress Reset Utility Card ──
                            const QuickPanicResetCard(),
                            const SizedBox(height: 26),

                            // ── Serenly "Popular" Horizontal Photo Cards Carousel ──
                            const _SerenlyPopularSection(),
                            const SizedBox(height: 28),

                            // ── Section Title: Today's Dailies ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Today's Dailies",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── 1. The Main Breathing Element: Large Organic Breathing Orb ──
                            const _HeroOrganicBreathingSection(),
                            const SizedBox(height: 32),

                            // ── Hairline Divider ──
                            Divider(
                              color: Colors.white.withOpacity(0.12),
                              thickness: 0.5,
                              height: 1,
                            ),
                            const SizedBox(height: 28),

                            // ── 2. Emotional State & Quick Duration Selector ──
                            const _EmotionalDurationSelector(),
                            const SizedBox(height: 28),

                            // ── Hairline Divider ──
                            Divider(
                              color: Colors.white.withOpacity(0.12),
                              thickness: 0.5,
                              height: 1,
                            ),
                            const SizedBox(height: 28),

                            // ── 3. Tonight: Quiet Your Mind Before Sleep ──
                            const _TonightSlumberCard(),
                            const SizedBox(height: 24),

                            // ── 4. Pinned Sound Mixes (If any saved) ──
                            if (state.presets.isNotEmpty) ...[
                              const _PinnedMixesSection(),
                              const SizedBox(height: 24),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }

// ── Serenly User Header ───────────────────────────────────────────────────────
class _SerenlyUserHeader extends StatelessWidget {
  const _SerenlyUserHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left User Avatar + Greeting
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ViralStreakShareModal.show(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.4), width: 1.5),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good evening, Tamara',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right Action Pills: Viral Streak Share + Bell
        Row(
          children: [
            // 🔥 Viral Streak Share Pill
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 36,
              onPressed: () {
                HapticFeedback.mediumImpact();
                ViralStreakShareModal.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.4), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF9500), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${state.streak}d',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Frosted Bell Icon Button
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E212B).withOpacity(0.8),
                border: Border.all(color: Colors.white.withOpacity(0.14), width: 0.8),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  showCupertinoDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Notifications 🔔'),
                      content: const Text('Your daily evening wind-down reminder is set for 9:30 PM.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.bell,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Serenly Hero Banner: Return To Stillness ──────────────────────────────────
class _SerenlyHeroReturnToStillness extends StatelessWidget {
  const _SerenlyHeroReturnToStillness();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1000&q=80',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark dusk gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.92),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Return To Stillness',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gentle sleep stories and calming meditations to guide you into restful nights.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                // Tag Pill
                Text(
                  'Deep Sleep • 45 min',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Play Pill Button
                Consumer<AppState>(
                  builder: (context, state, _) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        state.startGuidedSession(
                          'Ocean Breath',
                          'Breathe with the rhythm of the waves. Calm Sounds • 45 min',
                          2700,
                          45,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.play_fill, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Serenly Holiday Offer Strip ───────────────────────────────────────────────
class _SerenlyHolidayOfferCard extends StatelessWidget {
  const _SerenlyHolidayOfferCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        state.setTab(AppTab.aiStudio);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF13151D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.sparkles,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Special Holiday Offer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gift Serenly: Save 25% until December 31.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Serenly "Popular" Section ─────────────────────────────────────────────────
class _SerenlyPopularSection extends StatelessWidget {
  const _SerenlyPopularSection();

  static const _popularCards = [
    {
      'title': 'Ocean Breath',
      'tag': 'Calm Sounds',
      'mins': 45,
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Gentle Reset',
      'tag': 'Stress Relief',
      'mins': 15,
      'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Forest Slumber',
      'tag': 'Deep Sleep',
      'mins': 30,
      'image': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _popularCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = _popularCards[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  state.startGuidedSession(
                    item['title'] as String,
                    'Breathe with the rhythm of the waves. ${item['tag']} • ${item['mins']} min',
                    (item['mins'] as int) * 60,
                    item['mins'] as int,
                  );
                },
                child: Container(
                  width: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: DecorationImage(
                      image: NetworkImage(item['image'] as String),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.75),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),

                      // Category Tag Pill at Top Left
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.6),
                          ),
                          child: Text(
                            item['tag'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Card Title at Bottom Left
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 1. The Main Breathing Element: Large Organic Breathing Orb ────────────────
class _HeroOrganicBreathingSection extends StatefulWidget {
  const _HeroOrganicBreathingSection();

  @override
  State<_HeroOrganicBreathingSection> createState() => _HeroOrganicBreathingSectionState();
}

class _HeroOrganicBreathingSectionState extends State<_HeroOrganicBreathingSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _phase = 'Breathe in';
  int _secondsInPhase = 4;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _startBreathingLoop();
  }

  void _startBreathingLoop() {
    _runInhale();
  }

  void _runInhale() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = 'Breathe in';
      _secondsInPhase = 4;
    });
    _animController.duration = const Duration(seconds: 4);
    _animController.forward(from: 0.0);

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsInPhase > 1) {
        HapticFeedback.lightImpact();
        setState(() => _secondsInPhase--);
      } else {
        timer.cancel();
        _runHold();
      }
    });
  }

  void _runHold() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _phase = 'Hold gently';
      _secondsInPhase = 4;
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsInPhase > 1) {
        setState(() => _secondsInPhase--);
      } else {
        timer.cancel();
        _runRelease();
      }
    });
  }

  void _runRelease() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = 'Let it go';
      _secondsInPhase = 6;
    });
    _animController.duration = const Duration(seconds: 6);
    _animController.reverse(from: 1.0);

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsInPhase > 1) {
        HapticFeedback.selectionClick();
        setState(() => _secondsInPhase--);
      } else {
        timer.cancel();
        _runInhale();
      }
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      children: [
        const SizedBox(height: 10),
        // ── Big Organic Breathing Orb with Soft Radial Glow ──
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Soft Radial Background Glow
                  Container(
                    width: 250 * _scaleAnimation.value,
                    height: 250 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2DD4BF).withOpacity(0.16 * _scaleAnimation.value),
                          const Color(0xFF0F766E).withOpacity(0.06 * _scaleAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Outer Subtle Aura Ring
                  Container(
                    width: 215 * _scaleAnimation.value,
                    height: 215 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2DD4BF).withOpacity(0.22),
                        width: 1.2,
                      ),
                    ),
                  ),

                  // Center Solid Organic Breathing Circle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      state.startPanicResetCombo();
                    },
                    child: Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF132F34).withOpacity(0.92),
                            const Color(0xFF071719).withOpacity(0.96),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF2DD4BF).withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '◯',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2DD4BF),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'BREATHE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '4 · 4 · 6',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2DD4BF),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_phase · $_secondsInPhase s',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.75),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 26),

        // ── Tactile Action Pill Button ──
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            state.startPanicResetCombo();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.spa_rounded, color: Colors.black, size: 16),
                SizedBox(width: 8),
                Text(
                  'Start Reset',
                  style: TextStyle(
                    fontSize: 15,
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
    );
  }
}

// ── 2. Emotional State & Quick Duration Selector ─────────────────────────────
class _EmotionalDurationSelector extends StatelessWidget {
  const _EmotionalDurationSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You seem a little tense today.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.92),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let’s make the next minute lighter.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 18),

        // ── 3 Duration Options (60 sec · Reset | 3 min · Calm | 10 min · Deep Rest) ──
        Row(
          children: [
            Expanded(
              child: _DurationPill(
                duration: '60 sec',
                label: 'Reset',
                color: const Color(0xFF2DD4BF),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  state.startPanicResetCombo();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DurationPill(
                duration: '3 min',
                label: 'Calm',
                color: const Color(0xFF38BDF8),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  state.playGuidedSession('Quiet Mind Sanctuary', 3);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DurationPill(
                duration: '10 min',
                label: 'Deep Rest',
                color: const Color(0xFFA78BFA),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  state.playGuidedSession('Peaceful Haven Journey', 10);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ── Emotional Feelings Check-In ──
        Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _MoodFeelingChip(
              emoji: '😣',
              label: 'Overwhelmed',
              isSelected: state.selectedMoodFilter == 'Stressed',
              onTap: () {
                HapticFeedback.lightImpact();
                state.setMoodFilter('Stressed');
                state.startPanicResetCombo();
              },
            ),
            const SizedBox(width: 8),
            _MoodFeelingChip(
              emoji: '😐',
              label: 'Neutral',
              isSelected: state.selectedMoodFilter == 'Calm',
              onTap: () {
                HapticFeedback.lightImpact();
                state.setMoodFilter('Calm');
                state.playGuidedSession('Gentle Relief & Comfort', 5);
              },
            ),
            const SizedBox(width: 8),
            _MoodFeelingChip(
              emoji: '🙂',
              label: 'Grounded',
              isSelected: state.selectedMoodFilter == 'Focus',
              onTap: () {
                HapticFeedback.lightImpact();
                state.setMoodFilter('Focus');
                state.playGuidedSession('Peaceful Morning Awakening', 10);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ── Duration Pill Widget ─────────────────────────────────────────────────────
class _DurationPill extends StatelessWidget {
  final String duration;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DurationPill({
    required this.duration,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Column(
          children: [
            Text(
              duration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mood Feeling Chip Widget ─────────────────────────────────────────────────
class _MoodFeelingChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodFeelingChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.2) : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.5) : Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 3. Tonight Slumber Card ──────────────────────────────────────────────────
class _TonightSlumberCard extends StatelessWidget {
  const _TonightSlumberCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        state.setTab(AppTab.sleep);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF131B2A).withOpacity(0.9),
              const Color(0xFF0A0F1A).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFA78BFA).withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA78BFA).withOpacity(0.16),
                border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.35)),
              ),
              child: const Icon(
                CupertinoIcons.moon_stars_fill,
                color: Color(0xFFA78BFA),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TONIGHT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFA78BFA),
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Quiet your mind before sleep',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(
                CupertinoIcons.arrow_right,
                color: Colors.white70,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 4. Pinned Mixes Section ──────────────────────────────────────────────────
class _PinnedMixesSection extends StatelessWidget {
  const _PinnedMixesSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(CupertinoIcons.bookmark_fill, color: mintAccent, size: 13),
            const SizedBox(width: 6),
            const Text(
              'YOUR PINNED SOUND MIXES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: mintAccent,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: state.presets.asMap().entries.map((entry) {
              final index = entry.key;
              final preset = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2DD4BF).withOpacity(0.18),
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          state.applyCustomPreset(preset);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.play_circle_fill, color: mintAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              preset.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          state.deletePreset(index);
                        },
                        child: const Icon(CupertinoIcons.xmark, color: Colors.white54, size: 13),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Synesthetic Sensory Practice Action Card ──────────────────────────────────
class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sensorySound;
  final String bgImage;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sensorySound,
    required this.bgImage,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.color.withOpacity(0.42),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 🖼️ High-Res Atmospheric Sensory Background Texture
                Positioned.fill(
                  child: Image.network(
                    widget.bgImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                // Frosted Glass Dark Vignette
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.color.withOpacity(0.35),
                          const Color(0xFF07111B).withOpacity(0.86),
                          const Color(0xFF040A10).withOpacity(0.96),
                        ],
                      ),
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.color.withOpacity(0.55),
                                widget.color.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(widget.icon, color: Colors.white, size: 21),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.sensorySound,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: widget.color.withOpacity(0.95),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Soft Stat Metric Item (Frameless) ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Soft Muted Data Visualization Chart ──────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final List<MapEntry<String, int>> weeklyData;
  const _WeeklyBarChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox();
    final maxY = weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final today = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][DateTime.now().weekday - 1];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 10 ? 30 : maxY * 1.3,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= weeklyData.length) return const SizedBox();
                final isToday = weeklyData[idx].key == today;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weeklyData[idx].key,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday ? coralAccent : textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.04),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklyData.asMap().entries.map((e) {
          final isToday = e.value.key == today;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                width: 14,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [coralAccent.withOpacity(0.7), coralAccent]
                      : [tealPrimary.withOpacity(0.2), tealPrimary.withOpacity(0.5)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SpotifyAmbientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String imageUrl;
  final Color color;
  final VoidCallback onTap;

  const _SpotifyAmbientCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imageUrl,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
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
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: color.withOpacity(0.2)),
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
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            width: 115,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            duration,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 0. Daily Affirmation Banner ──────────────────────────────────────────────
class _DailyAffirmationBanner extends StatefulWidget {
  const _DailyAffirmationBanner();

  @override
  State<_DailyAffirmationBanner> createState() => _DailyAffirmationBannerState();
}

class _DailyAffirmationBannerState extends State<_DailyAffirmationBanner> {
  int _quoteIndex = 0;

  static const List<Map<String, String>> _quotes = [
    {
      'quote': '“In the midst of movement and chaos, keep stillness inside of you.”',
      'author': 'Deepak Chopra',
    },
    {
      'quote': '“Peace comes from within. Do not seek it without.”',
      'author': 'Buddha',
    },
    {
      'quote': '“Breath is the finest gift of nature. Be grateful for this marvelous gift.”',
      'author': 'Amit Ray',
    },
    {
      'quote': '“Quiet the mind, and the soul will speak.”',
      'author': 'Ma Jaya Sati Bhagavati',
    },
    {
      'quote': '“Rest is not idleness, but a restorative sanctuary for your spirit.”',
      'author': 'Sanctuary Mind',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = _quotes[_quoteIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tealPrimary.withOpacity(0.18),
            const Color(0xFFA855F7).withOpacity(0.08),
            const Color(0xFF07121B).withOpacity(0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tealPrimary.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: tealPrimary.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tealPrimary.withOpacity(0.35),
                  tealPrimary.withOpacity(0.15),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: tealPrimary.withOpacity(0.5), width: 1),
            ),
            child: const Icon(CupertinoIcons.quote_bubble_fill, color: tealPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current['quote']!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '— ${current['author']!}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: tealPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Share Quote to Instagram / WhatsApp
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(
                text: '🌸 Daily Calm Thought:\n${current['quote']}\n— ${current['author']}\n\nFind your stillness on Sanctuary: https://theanlegendary.github.io/allinone/?quote=daily',
              ));
              showCupertinoDialog(
                context: context,
                barrierDismissible: true,
                builder: (ctx) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (ctx.mounted) Navigator.pop(ctx);
                  });
                  return const CupertinoAlertDialog(
                    title: Text('Quote Copied 🌟'),
                    content: Text('Daily calm quote copied. Paste to your Instagram Story or WhatsApp status!'),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.share_up, color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 6),
          // Refresh Quote
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _quoteIndex = (_quoteIndex + 1) % _quotes.length;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.refresh, color: Colors.white70, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2b. Dynamic Mood Intent Recommendations ────────────────────────────────
class _DynamicMoodRecommendations extends StatelessWidget {
  const _DynamicMoodRecommendations();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final mood = state.selectedMoodFilter;

        final Map<String, List<Map<String, dynamic>>> moodData = {
          'Calm': [
            {'title': 'Peaceful Haven Journey', 'desc': '15 min • Soft River Stream', 'type': 'Guided', 'icon': CupertinoIcons.leaf_arrow_circlepath, 'color': tealPrimary, 'action': () => state.playGuidedSession('Peaceful Haven Journey', 15)},
            {'title': 'Resonance 5-5 Coherence', 'desc': '5 min • Heart Coherence', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': mintAccent, 'action': () => state.setTab(AppTab.breathe)},
            {'title': '432Hz Healing Chimes', 'desc': '20 min • Solfeggio Tones', 'type': 'Sounds', 'icon': CupertinoIcons.waveform, 'color': purpleAccent, 'action': () => state.playGuidedSession('Healing Crystal Chimes', 20)},
          ],
          'Stressed': [
            {'title': 'Deep Stress Release', 'desc': '12 min • Body Tension Melt', 'type': 'Guided', 'icon': Icons.self_improvement_rounded, 'color': coralAccent, 'action': () => state.playGuidedSession('Gentle Relief & Comfort', 12)},
            {'title': 'Box Breathing 4-4-4-4', 'desc': '4 min • Calm Nervous System', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': tealPrimary, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Cozy Rainfall Cabin', 'desc': 'Soft Downpour & Hearth', 'type': 'Sounds', 'icon': Icons.thunderstorm_rounded, 'color': mintAccent, 'action': () => state.applyCuratedPreset('🌧️ Rainy Cabin')},
          ],
          'Sleepy': [
            {'title': 'Midnight Alpine Forest', 'desc': '25 min • Sleep Story', 'type': 'Sleep', 'icon': Icons.bedtime_rounded, 'color': purpleAccent, 'action': () => state.setTab(AppTab.sleep)},
            {'title': '4-7-8 Sleep Breath', 'desc': '7 min • Dr. Weil Method', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': coralAccent, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Cosmic Deep Space Waves', 'desc': 'Delta Wave Slumber', 'type': 'Sounds', 'icon': Icons.nights_stay_rounded, 'color': tealPrimary, 'action': () => state.applyCuratedPreset('🌌 Deep Space')},
          ],
          'Focus': [
            {'title': 'Morning Clarity & Focus', 'desc': '10 min • Crisp Awareness', 'type': 'Guided', 'icon': Icons.wb_sunny_rounded, 'color': mintAccent, 'action': () => state.playGuidedSession('Peaceful Morning Start', 10)},
            {'title': 'Power 6-2-6 Breath', 'desc': '5 min • Clean Mental Energy', 'type': 'Breathe', 'icon': Icons.bolt_rounded, 'color': tealPrimary, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Alpine Forest Stream', 'desc': 'Focus Soundscape', 'type': 'Sounds', 'icon': Icons.forest_rounded, 'color': purpleAccent, 'action': () => state.applyCuratedPreset('🌲 Forest Walk')},
          ],
          'Anxiety': [
            {'title': 'Warm Heart Comfort', 'desc': '15 min • Gentle Relief', 'type': 'Guided', 'icon': CupertinoIcons.heart_fill, 'color': coralAccent, 'action': () => state.playGuidedSession('Warm Heart Comfort', 15)},
            {'title': 'Quiet Mind Sanctuary', 'desc': '12 min • Silent Center', 'type': 'Guided', 'icon': CupertinoIcons.leaf_arrow_circlepath, 'color': tealPrimary, 'action': () => state.playGuidedSession('Quiet Mind Sanctuary', 12)},
            {'title': 'Singing Bowls 432Hz', 'desc': 'Harmonic Healing', 'type': 'Sounds', 'icon': CupertinoIcons.waveform, 'color': mintAccent, 'action': () => state.playGuidedSession('Healing Crystal Chimes', 20)},
          ],
          'Nature': [
            {'title': 'Forest Bathing Journey', 'desc': '20 min • Woodland Sanctuary', 'type': 'Guided', 'icon': Icons.park_rounded, 'color': mintAccent, 'action': () => state.playGuidedSession('Peaceful Haven Journey', 20)},
            {'title': 'Mountain Stream Flow', 'desc': 'Nature Soundscape', 'type': 'Sounds', 'icon': Icons.water_drop_rounded, 'color': tealPrimary, 'action': () => state.applyCuratedPreset('🌲 Forest Walk')},
            {'title': 'Starlit Ocean Voyage', 'desc': '30 min • Bedtime Story', 'type': 'Sleep', 'icon': Icons.tsunami_rounded, 'color': purpleAccent, 'action': () => state.setTab(AppTab.sleep)},
          ],
        };

        final recs = moodData[mood] ?? moodData['Calm']!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.sparkles, color: tealPrimary, size: 15),
                const SizedBox(width: 6),
                Text(
                  'CURATED FOR YOUR "$mood" MOOD',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: tealPrimary,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Column(
              children: recs.map((item) {
                final Color color = item['color'] as Color;
                final VoidCallback onTap = item['action'] as VoidCallback;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.16),
                            const Color(0xFF0C1620).withOpacity(0.85),
                            const Color(0xFF050D15).withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.35),
                                  color.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.withOpacity(0.45), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(item['icon'] as IconData, color: color, size: 23),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.85)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(CupertinoIcons.play_fill, color: Colors.black, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'Begin',
                                  style: TextStyle(
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
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ── 2c. Embedded Instant 1-Minute Calm Breathing Widget ──────────────────────
class _HomeQuickBreathWidget extends StatefulWidget {
  const _HomeQuickBreathWidget();

  @override
  State<_HomeQuickBreathWidget> createState() => _HomeQuickBreathWidgetState();
}

class _HomeQuickBreathWidgetState extends State<_HomeQuickBreathWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _isActive = false;
  String _phaseLabel = 'Tap to start 1-min calm breath';
  int _secondsLeft = 60;
  dynamic _timer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isActive) {
      _stopBreathing();
    } else {
      _startBreathing();
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _secondsLeft = 60;
      _phaseLabel = 'Inhale deeply...';
    });
    _animCtrl.repeat(reverse: true);

    _timer?.cancel();
    _timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _stopBreathing();
      } else {
        setState(() {
          _secondsLeft--;
          final cycleSec = _secondsLeft % 8;
          if (cycleSec >= 4) {
            _phaseLabel = 'Exhale softly...';
          } else {
            _phaseLabel = 'Inhale deeply...';
          }
        });
      }
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _animCtrl.stop();
    _animCtrl.reset();
    if (mounted) {
      setState(() {
        _isActive = false;
        _phaseLabel = 'Tap to start 1-min calm breath';
        _secondsLeft = 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C2226),
            Color(0xFF091720),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mintAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Glowing Breathing Circle
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) {
              final scale = _isActive ? 0.75 + (0.35 * _animCtrl.value) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        mintAccent.withOpacity(0.8),
                        tealPrimary.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mintAccent.withOpacity(_isActive ? 0.6 : 0.2),
                        blurRadius: _isActive ? 20 : 8,
                        spreadRadius: _isActive ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isActive ? Icons.air_rounded : CupertinoIcons.leaf_arrow_circlepath,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'INSTANT 1-MIN CALM',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: mintAccent,
                        letterSpacing: 1.4,
                      ),
                    ),
                    if (_isActive) ...[
                      const Spacer(),
                      Text(
                        '00:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _phaseLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: _toggleBreathing,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isActive ? coralAccent : mintAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isActive ? coralAccent : mintAccent).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                _isActive ? 'Stop' : 'Start',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 🆘 Instant Stress SOS Widget (1-Tap Emergency Panic & Stress Relief) ─────
class _InstantStressSOSWidget extends StatefulWidget {
  const _InstantStressSOSWidget();

  @override
  State<_InstantStressSOSWidget> createState() => _InstantStressSOSWidgetState();
}

class _InstantStressSOSWidgetState extends State<_InstantStressSOSWidget> {
  bool _isSOSActive = false;
  int _secondsLeft = 60;
  Timer? _timer;

  void _triggerSOS(AppState state) {
    if (_isSOSActive) {
      _timer?.cancel();
      setState(() => _isSOSActive = false);
      state.stopAllAudio();
      return;
    }

    setState(() {
      _isSOSActive = true;
      _secondsLeft = 60;
    });

    // Start soothing Soft Rain + 4-7-8 Relaxing Breathing Combo
    state.startPanicResetCombo();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _isSOSActive = false);
        state.recordSession('60s Emergency Stress SOS', 'Breathing', 1);
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Session Complete'),
            content: const Text('✨ Stress SOS Complete. Take a deep breath. You are safe. 🌿'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Close'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        );
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            coralAccent.withOpacity(0.18),
            const Color(0xFFA855F7).withOpacity(0.09),
            const Color(0xFF07111B).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: coralAccent.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: coralAccent.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: coralAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🆘', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY STRESS RESET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: coralAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      _isSOSActive
                          ? 'Releasing tension... ($_secondsLeft s)'
                          : 'Feeling Overwhelmed or Anxious?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _isSOSActive
                ? 'Follow your breath. Inhale slowly... release all tension.'
                : 'Tap below for an instant 60-second calm audio & breathing reset.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _triggerSOS(state),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSOSActive
                      ? [coralAccent, const Color(0xFFD946EF)]
                      : [tealPrimary, mintAccent],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isSOSActive ? coralAccent : tealPrimary).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSOSActive ? Icons.pause_circle_filled_rounded : CupertinoIcons.heart_fill,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isSOSActive ? 'Stop SOS Session ($_secondsLeft s)' : '1-Tap Emergency Stress Relief 🌿',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 📊 Stress Reduction Meter Widget ─────────────────────────────────────────
class _StressReductionMeter extends StatelessWidget {
  const _StressReductionMeter();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final minutesToday = state.weeklyMinutes.isNotEmpty
        ? state.weeklyMinutes.last.value
        : 0;

    final score = (50 + (minutesToday * 3)).clamp(50, 98);
    final statusText = score >= 85 ? 'Serene & Calm 🌿' : score >= 70 ? 'Balanced 🧘' : 'Rest Needed 😴';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2DD4BF).withOpacity(0.16),
            const Color(0xFF0C1620).withOpacity(0.85),
            const Color(0xFF060E15).withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DAILY CALM INDEX',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: mintAccent, letterSpacing: 1.4)),
                    Text(statusText,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(mintAccent),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$minutesToday minutes practiced today · Stress level reduced',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 🌧️ Atmospheric Frosted Mood Chip (Tactile + Halo Glow) ───────────────────
class _AtmosphericMoodChip extends StatefulWidget {
  final String emoji;
  final String title;
  final String moodKey;
  final Color auraColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AtmosphericMoodChip({
    required this.emoji,
    required this.title,
    required this.moodKey,
    required this.auraColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AtmosphericMoodChip> createState() => _AtmosphericMoodChipState();
}

class _AtmosphericMoodChipState extends State<_AtmosphericMoodChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isSelected
                  ? [
                      widget.auraColor.withOpacity(0.95),
                      widget.auraColor.withOpacity(0.75),
                    ]
                  : [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.04),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white.withOpacity(0.65)
                  : Colors.white.withOpacity(0.18),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.auraColor.withOpacity(0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.black.withOpacity(0.2)
                      : widget.auraColor.withOpacity(0.24),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isSelected
                      ? (widget.auraColor.computeLuminance() > 0.45
                          ? Colors.black
                          : Colors.white)
                      : Colors.white.withOpacity(0.95),
                  fontSize: 13,
                  fontWeight:
                      widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 🔮 Coming Soon / Next Month Roadmap Section ──────────────────────────────
class _ComingSoonRoadmapSection extends StatelessWidget {
  const _ComingSoonRoadmapSection();

  static const _upcomingDrops = [
    (
      '🚆 Tokyo Sleeper Train in Rain',
      '8D Spatial Audio • Heavy downpour & rhythmic rails',
      'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=400&q=80',
      Color(0xFF38BDF8),
    ),
    (
      '🏔️ Nordic Blizzard Fireplace',
      '8D Spatial Audio • Roaring hearth & howling snowstorm',
      'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=400&q=80',
      Color(0xFFE29578),
    ),
    (
      '🌊 Bioluminescent Ocean (528Hz)',
      'Healing Frequency • Deep submarine pad resonance',
      'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=400&q=80',
      Color(0xFF2DD4BF),
    ),
    (
      '🌅 Time-of-Day Adaptive Aura',
      'Living Interface • Sunrise Amber to Cosmic Indigo',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      Color(0xFFFFB74D),
    ),
    (
      '📖 The Starlit Observatory',
      'Sleep Journey • Narrated deep galaxy bedtime tale',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
      Color(0xFFA855F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.sparkles,
                  color: Color(0xFFA855F7), size: 14),
            ),
            const SizedBox(width: 8),
            const Text(
              'COMING IN NEXT MONTH DROP',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA855F7),
                letterSpacing: 1.6,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
              ),
              child: const Text(
                'ROADMAP ✨',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _upcomingDrops.map((drop) {
              final title = drop.$1;
              final subtitle = drop.$2;
              final imgUrl = drop.$3;
              final accentColor = drop.$4;

              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 14),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: accentColor.withOpacity(0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    // Dark Glass Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              const Color(0xFF07111B).withOpacity(0.88),
                              const Color(0xFF040A10).withOpacity(0.96),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: accentColor.withOpacity(0.5)),
                                ),
                                child: Text(
                                  '🔒 COMING SOON',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Icon(CupertinoIcons.lock_fill,
                                  color: Colors.white60, size: 13),
                            ],
                          ),
                          const SizedBox(height: 38),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              showCupertinoDialog(
                                context: context,
                                builder: (ctx) => CupertinoAlertDialog(
                                  title: Text('$title ✨'),
                                  content: const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '🔔 You\'re on the VIP list!\n\nThis will unlock automatically in Next Month\'s Sanctuary content update at no extra charge.',
                                    ),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Awesome 🌿'),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.bell_fill,
                                        color: Colors.white, size: 11),
                                    SizedBox(width: 5),
                                    Text(
                                      'Notify Me',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
