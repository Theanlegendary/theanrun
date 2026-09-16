import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/theme/responsive.dart';

// ─── GlassCard ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double cornerRadius;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.cornerRadius = 28,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isClay = state.themeMode.isLight;
    final spacing = Spacing.of(context);
    // Padding scales with screen size — phones get 16, tablets get 22.
    final effectivePadding = padding ?? EdgeInsets.all(spacing.lg);
    // Radius scales subtly with screen width so it doesn't look pinched on tablets.
    final effectiveRadius = cornerRadius == 28
        ? (isCompact(context) ? 22.0 : isMedium(context) ? 26.0 : 30.0)
        : cornerRadius;

    final isNeu = state.themeMode.isNeumorphic;
    if (isNeu) {
      return Container(
        margin: margin,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? neuSurface,
          borderRadius: BorderRadius.circular(effectiveRadius),
          boxShadow: const [
            BoxShadow(
              color: neuDarkShadow,
              offset: Offset(9, 9),
              blurRadius: 16,
            ),
            BoxShadow(
              color: neuLightShadow,
              offset: Offset(-9, -9),
              blurRadius: 16,
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: neuText),
          child: child,
        ),
      );
    }

    if (isClay) {
      return Container(
        margin: margin,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? clayCardBg,
          borderRadius: BorderRadius.circular(effectiveRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33B89679),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      margin: margin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF0C1924).withOpacity(0.92),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            offset: const Offset(6, 6),
            blurRadius: 18,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            offset: const Offset(-4, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── GlassPillButton (Soft & Relaxing Cloud Pill) ───────────────────────────
class GlassPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color containerColor;
  final Color contentColor;
  final double? width;

  const GlassPillButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.containerColor = tealPrimary,
    this.contentColor = Colors.black,
    this.width,
  });

  @override
  State<GlassPillButton> createState() => _GlassPillButtonState();
}

class _GlassPillButtonState extends State<GlassPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Generate soft dual-tint gradient from containerColor
    final isTeal = widget.containerColor == tealPrimary;
    final gradientColors = isTeal
        ? [const Color(0xFF64DFDF), const Color(0xFF48CAE4)]
        : [widget.containerColor.withOpacity(0.9), widget.containerColor.withOpacity(0.7)];
    // Padding scales with screen size — compact 20/11, medium 22/12, expanded 24/13
    final spacing = Spacing.of(context);
    final hPad = isCompact(context) ? 20.0 : (isMedium(context) ? 22.0 : 24.0);
    final vPad = isCompact(context) ? 11.0 : (isMedium(context) ? 12.0 : 13.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.containerColor.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.contentColor, size: 17),
                const SizedBox(width: 7),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.contentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ─── GlassChip (Soft Relaxing Floating Chip) ─────────────────────────────────
class GlassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const GlassChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.selectedColor = tealPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isClay = state.themeMode.isLight;

    if (isClay) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact(context) ? 16.0 : (isMedium(context) ? 18.0 : 20.0),
            vertical:   isCompact(context) ? 10.0 : (isMedium(context) ? 11.0 : 12.0),
          ),
          decoration: BoxDecoration(
            color: isSelected ? clayAccent : clayDarkCardBg,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x40D4A574), blurRadius: 10, offset: Offset(3, 3)),
                    BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-3, -3)),
                  ]
                : const [
                    BoxShadow(color: Color(0x20B89679), blurRadius: 6, offset: Offset(4, 4)),
                    BoxShadow(color: Colors.white, blurRadius: 6, offset: Offset(-3, -3)),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : clayText,
              fontSize: isCompact(context) ? 12.5 : 13.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ));
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact(context) ? 16.0 : (isMedium(context) ? 18.0 : 20.0),
          vertical:   isCompact(context) ? 10.0 : (isMedium(context) ? 11.0 : 12.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(26),
          border: isSelected ? Border.all(color: selectedColor.withOpacity(0.4), width: 1) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (selectedColor.computeLuminance() > 0.45 ? Colors.black : Colors.white)
                : Colors.white.withOpacity(0.9),
            fontSize: isCompact(context) ? 12.5 : 13.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    ));
  }
}

// ─── AnimatedSoundWave ────────────────────────────────────────────────────────
class AnimatedSoundWave extends StatefulWidget {
  final Color accentColor;
  // Optional 0..1 — bar amplitude scales with this (e.g. the master volume
  // or the dominant track's volume). Falls back to a constant envelope
  // when null.
  final double? amplitude;
  const AnimatedSoundWave({super.key, required this.accentColor, this.amplitude});

  @override
  State<AnimatedSoundWave> createState() => _AnimatedSoundWaveState();
}

class _AnimatedSoundWaveState extends State<AnimatedSoundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final amp = (widget.amplitude ?? 0.7).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * pi;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [1.0, 1.8, 0.6].asMap().entries.map((e) {
            // Amplitude is now driven by the actual track volume, so a quiet
            // mix shows small bars and a loud mix shows tall ones.
            final h = 3 + 12 * amp * (0.5 + 0.5 * sin(t + e.key * 1.2)) * e.value;
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── StreakBadge ──────────────────────────────────────────────────────────────
class StreakBadge extends StatelessWidget {
  final int streakCount;
  const StreakBadge({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFFB74D)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$streakCount day${streakCount == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── MoodCheckInDialog — iOS Bottom Sheet style ───────────────────────────────
// Shows as a Cupertino-native bottom pull-up sheet with haptic feedback.
class MoodCheckInDialog extends StatefulWidget {
  final void Function(int) onMoodSelected;
  final VoidCallback onSkip;

  const MoodCheckInDialog({
    super.key,
    required this.onMoodSelected,
    required this.onSkip,
  });

  @override
  State<MoodCheckInDialog> createState() => _MoodCheckInDialogState();
}

class _MoodCheckInDialogState extends State<MoodCheckInDialog>
    with SingleTickerProviderStateMixin {
  int? _selected;
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  static const _emojis = ['😔', '😕', '😐', '🙂', '😊'];
  static const _labels = ['Rough', 'Okay', 'Neutral', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black.withOpacity(0.65),
          child: SlideTransition(
            position: _slide,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    cornerRadius: 28,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // iOS-style drag handle
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How Do You Feel?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rate your session experience',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final rating = i + 1;
                            final isSelected = _selected == rating;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selected = rating);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? tealPrimary.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? tealPrimary : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _emojis[i],
                                        style: TextStyle(fontSize: isSelected ? 24 : 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _labels[i],
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? tealPrimary : Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        // iOS-style action row
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: widget.onSkip,
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                color: _selected != null ? tealPrimary : tealPrimary.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: _selected != null ? () {
                                  HapticFeedback.heavyImpact();
                                  widget.onMoodSelected(_selected!);
                                } : null,
                                child: Text(
                                  _selected != null ? 'Save Rating ✓' : 'Select Mood',
                                  style: TextStyle(
                                    color: _selected != null ? Colors.black : Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GuidedPlayerOverlay (Serenly Screen 3 Immersive Ocean Breath Player) ──────
class GuidedPlayerOverlay extends StatefulWidget {
  const GuidedPlayerOverlay({super.key});

  @override
  State<GuidedPlayerOverlay> createState() => _GuidedPlayerOverlayState();
}

class _GuidedPlayerOverlayState extends State<GuidedPlayerOverlay> {
  double _dragValue = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isGuidedPlaying) return const SizedBox.shrink();

        final totalSec = state.guidedTotalSec > 0 ? state.guidedTotalSec : 2700;
        final elapsedSec = (totalSec - state.guidedRemainingSec).clamp(0, totalSec);
        final title = state.currentGuidedTitle ?? 'Ocean Breath';

        final elapsedMins = elapsedSec ~/ 60;
        final elapsedRemainderSecs = elapsedSec % 60;
        final totalMins = totalSec ~/ 60;
        final totalRemainderSecs = totalSec % 60;

        final elapsedStr = '${elapsedMins.toString()}:${elapsedRemainderSecs.toString().padLeft(2, '0')}';
        final totalStr = '${totalMins.toString()}:${totalRemainderSecs.toString().padLeft(2, '0')}';

        // Center Countdown / Duration String
        final remainingMins = state.guidedRemainingSec ~/ 60;
        final remainingSecs = state.guidedRemainingSec % 60;
        final centerTimerStr = '${remainingMins.toString()}:${remainingSecs.toString().padLeft(2, '0')}';

        final progress = totalSec > 0 ? (elapsedSec / totalSec).clamp(0.0, 1.0) : 0.0;
        final effectiveProgress = _isDragging ? _dragValue : progress;

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 🌊 1. Full-Bleed Atmospheric Dusk Ocean Wallpaper
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF08090C)),
                ),
              ),

              // Smooth Dark Gradient Vignette
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.35, 0.70, 1.0],
                    ),
                  ),
                ),
              ),

              // 📱 2. Clean Serenly Player Interface
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    children: [
                      // Top Row: Circular Back `<` & More `...`
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.14),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => state.stopGuidedSession(completed: false),
                              child: const Icon(
                                CupertinoIcons.chevron_left,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.14),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (ctx) => CupertinoActionSheet(
                                    title: Text(title),
                                    actions: [
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          state.extendGuidedSession(10);
                                        },
                                        child: const Text('Extend +10 Minutes ⏱️'),
                                      ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          state.toggleGuidedLoop();
                                        },
                                        child: Text(state.isGuidedLooping ? 'Disable Loop ♾️' : 'Enable Loop ♾️'),
                                      ),
                                      CupertinoActionSheetAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          state.stopGuidedSession(completed: true);
                                        },
                                        child: const Text('End & Complete Session'),
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
                              child: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Title & Subtitles
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Breathe with the rhythm of the waves.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calm Sounds • 45 min',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      // ⏱️ Giant Central Digital Countdown Timer (Screen 3)
                      Text(
                        centerTimerStr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),

                      const Spacer(),

                      // ⏯️ Minimalist Playback Controls (15s Rewind, Play/Pause, 15s Forward)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 15s Rewind
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              state.restartGuidedSession(5);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.gobackward_15,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '15',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 48),

                          // Large Minimal Play / Pause Toggle
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              state.toggleGuidedPlayPause();
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                state.isGuidedPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                color: Colors.black87,
                                size: 30,
                              ),
                            ),
                          ),

                          const SizedBox(width: 48),

                          // 15s Forward
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              state.extendGuidedSession(5);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.goforward_15,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '15',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 38),

                      // ── Progress Scrubber with Floating Tooltip (Screen 3) ──
                      Column(
                        children: [
                          // Floating Tooltip Bubble showing current timestamp
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final sliderWidth = constraints.maxWidth;
                              final bubbleOffset = (sliderWidth * effectiveProgress).clamp(18.0, sliderWidth - 18.0);

                              return Stack(
                                children: [
                                  SizedBox(height: 30, width: sliderWidth),
                                  Positioned(
                                    left: bubbleOffset - 22,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        elapsedStr,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Custom Clean Slider
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withOpacity(0.2),
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withOpacity(0.1),
                            ),
                            child: Slider(
                              value: effectiveProgress,
                              onChanged: (v) {
                                setState(() {
                                  _isDragging = true;
                                  _dragValue = v;
                                });
                              },
                              onChangeEnd: (v) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                            ),
                          ),

                          // Elapsed vs Total Timestamps
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  elapsedStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.55),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  totalStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.55),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── SanctuaryMiniPlayer (Floating Bottom Mini-Player with Equalizer Waveform) ──
// ─── SanctuaryMiniPlayer (Floating Bottom Mini-Player with Equalizer & Close Button) ──
class SanctuaryMiniPlayer extends StatelessWidget {
  const SanctuaryMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isAnyAudioPlaying) return const SizedBox.shrink();

        final activeCount = (state.isGuidedPlaying ? 1 : 0) + state.activeAmbientTracks.length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF10202E).withOpacity(0.98),
                  const Color(0xFF07121C).withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: tealPrimary.withOpacity(0.55), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: tealPrimary.withOpacity(0.3),
                  blurRadius: 22,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🎵 Tap to open Playing List Modal
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showCupertinoModalPopup(
                        context: context,
                        builder: (_) => const ActivePlayingListModal(),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [tealPrimary.withOpacity(0.3), tealPrimary.withOpacity(0.15)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: tealPrimary.withOpacity(0.4)),
                          ),
                          child: AnimatedSoundWave(
                            accentColor: tealPrimary,
                            amplitude: state.isGuidedPlaying
                                ? state.guidanceGuidedAmplitude
                                : state.activeMixAmplitude,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'NOW PLAYING ($activeCount)',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: tealPrimary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(CupertinoIcons.chevron_up, color: tealPrimary, size: 11),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.activePlayingLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ⏯️ Pause / Play Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (state.isGuidedPlaying) {
                      state.pauseGuidedSession();
                    } else {
                      state.stopAllAudio();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [tealPrimary, mintAccent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: tealPrimary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.pause_fill,
                          color: Colors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Pause All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ✕ Close & Dismiss Button (Stops All Audio & Hides Mini Player)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    state.stopAllAudio();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: coralAccent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: coralAccent.withOpacity(0.4), width: 1.2),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: coralAccent,
                        size: 16,
                      ),
                    ),
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

// ─── 🎧 ActivePlayingListModal (Soundscape Mixer & Active Tracks Sheet) ───────
class ActivePlayingListModal extends StatelessWidget {
  const ActivePlayingListModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final activeAmbient = state.activeAmbientTracks;
        final hasGuided = state.isGuidedPlaying;
        final totalCount = (hasGuided ? 1 : 0) + activeAmbient.length;

        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF101B27),
                Color(0xFF070E15),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: tealPrimary.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Notch Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENTLY PLAYING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tealPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Active Soundscapes ($totalCount)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.chevron_down, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Active Items List
              Expanded(
                child: totalCount == 0
                    ? Center(
                        child: Text(
                          'No soundscape tracks currently playing',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // 🧘 Guided Meditation Track (if playing)
                          if (hasGuided && state.currentGuidedTitle != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tealPrimary.withOpacity(0.18),
                                    const Color(0xFF0C1722).withOpacity(0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: tealPrimary.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: tealPrimary.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.self_improvement_rounded, color: tealPrimary, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'GUIDED MEDITATION',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: tealPrimary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          state.currentGuidedTitle!,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Stop Guided Track
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      state.stopGuidedSession(completed: false);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: coralAccent.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(CupertinoIcons.xmark, color: coralAccent, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // 🌧️ Ambient Sound Tracks with Real-time Volume Sliders
                          ...activeAmbient.entries.map((entry) {
                            final name = entry.key;
                            final volume = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.06),
                                    const Color(0xFF09141F).withOpacity(0.9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: mintAccent.withOpacity(0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(CupertinoIcons.waveform, color: mintAccent, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Volume: ${(volume * 100).toInt()}%',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Remove / Mute this track
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          state.setTrackVolume(name, 0.0);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(CupertinoIcons.xmark, color: Colors.white70, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Volume Slider
                                  CupertinoSlider(
                                    value: volume,
                                    activeColor: tealPrimary,
                                    onChanged: (v) {
                                      state.setTrackVolume(name, v);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
              ),

              const SizedBox(height: 12),

              // ── Quick Action Buttons: Save & Pin + Zen Screen ──
              if (activeAmbient.isNotEmpty) ...[
                Row(
                  children: [
                    // 💾 Save & Pin Mix to Home
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final textCtrl = TextEditingController(
                            text: 'My ${activeAmbient.keys.first} Mix',
                          );
                          showCupertinoDialog(
                            context: context,
                            builder: (dialogCtx) => CupertinoAlertDialog(
                              title: const Text('Save & Pin Mix ✨'),
                              content: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  children: [
                                    const Text('Give your custom sound blend a name to pin it to your Home Screen:'),
                                    const SizedBox(height: 12),
                                    CupertinoTextField(
                                      controller: textCtrl,
                                      placeholder: 'e.g. Rainy Cabin Hearth',
                                      autofocus: true,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(dialogCtx),
                                ),
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: const Text('Save & Pin'),
                                  onPressed: () {
                                    final name = textCtrl.text.trim().isEmpty
                                        ? 'Custom Sanctuary Mix'
                                        : textCtrl.text.trim();
                                    state.savePreset(name, Map.from(activeAmbient));
                                    Navigator.pop(dialogCtx);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: tealPrimary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.bookmark_fill, color: Colors.black, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Save & Pin Mix 💾',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ⛶ Zen Fullscreen Mode
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          ZenFullscreenModal.show(context);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA855F7), Color(0xFF6D28D9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.fullscreen, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Zen Screen ⛶',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // 🛑 Stop All Audio & Dismiss Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  state.stopAllAudio();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE29578), Color(0xFFF43F5E)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: coralAccent.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.stop_fill, color: Colors.black, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Stop All Soundscapes & Clear ✕',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
      },
    );
  }
}

// ─── 🌌 Zen Fullscreen Screen Saver Modal ──────────────────────────────────────
class ZenFullscreenModal extends StatefulWidget {
  const ZenFullscreenModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ZenMode',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const ZenFullscreenModal(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  State<ZenFullscreenModal> createState() => _ZenFullscreenModalState();
}

class _ZenFullscreenModalState extends State<ZenFullscreenModal>
    with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  String _timeStr = '';
  late AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    setState(() {
      _timeStr = '$h:$m';
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeCount = state.activeAmbientTracks.length;
    final trackNames = state.activeAmbientTracks.keys.join(' + ');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌧️ Atmospheric Rain Droplets Wallpaper
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Dark Radial Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0.4),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          // Central Breathing Halo
          Center(
            child: AnimatedBuilder(
              animation: _breatheCtrl,
              builder: (context, _) {
                final scale = 1.0 + (_breatheCtrl.value * 0.25);
                final opacity = 0.2 + (_breatheCtrl.value * 0.3);
                return Container(
                  width: 260 * scale,
                  height: 260 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2DD4BF).withOpacity(opacity),
                        const Color(0xFFA855F7).withOpacity(opacity * 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Exit & Fullscreen Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.moon_stars_fill,
                                color: Color(0xFFA855F7), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'ZEN SCREEN',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill,
                            color: Colors.white60, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  // Center: Glowing Clock & Inhale/Exhale Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeStr,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(color: Color(0xFF2DD4BF), blurRadius: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _breatheCtrl,
                        builder: (context, _) {
                          final isInhaling =
                              _breatheCtrl.status == AnimationStatus.forward;
                          return Text(
                            isInhaling ? 'Inhale Peace...' : 'Exhale Tension...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: 2.0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Bottom: Now Playing Soundscape & Controls
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('CURRENT SOUNDSCAPE',
                                  style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2DD4BF),
                                      letterSpacing: 1.4)),
                              const SizedBox(height: 2),
                              Text(
                                activeCount > 0
                                    ? trackNames
                                    : (state.currentGuidedTitle ??
                                        'Tranquil Silence'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              state.isPlayingAny
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_fill,
                              color: Colors.white),
                          onPressed: () {
                            if (state.isPlayingAny) {
                              state.stopAllAudio();
                            } else {
                              state.updateSoundTrackVolume('Soft Rain', 0.6);
                            }
                          },
                        ),
                      ],
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
}

// ─── 🚀 Viral Sound Mix Share Modal & Social Card Export ──────────────────────
class SoundMixShareModal extends StatelessWidget {
  const SoundMixShareModal({super.key});

  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => const SoundMixShareModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeTracks = state.activeAmbientTracks.entries.toList();
    final shareUrl = state.generateShareUrl();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1017),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Your Soundscape 🌿',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Send your custom mix to friends or post to Stories',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white60, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🖼️ Viral Aesthetic Snapshot Card (Instagram / TikTok ready)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF161B26),
                    const Color(0xFF0B0E14),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: tealPrimary.withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: tealPrimary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.sparkles, color: tealPrimary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SANCTUARY AMBIENT MIX',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: tealPrimary,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${activeTracks.length} Layers',
                          style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (activeTracks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Play some sounds to create your unique mix!',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...activeTracks.map((entry) {
                      final pct = (entry.value * 100).round();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: entry.value,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(tealPrimary),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      Navigator.pop(context);
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          Future.delayed(const Duration(seconds: 2), () {
                            if (ctx.mounted) Navigator.pop(ctx);
                          });
                          return const CupertinoAlertDialog(
                            title: Text('Link Copied! 🔗'),
                            content: Text('Your soundscape mix link is copied to clipboard. Share it with anyone!'),
                          );
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.link, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Copy Link',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: tealPrimary,
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Clipboard.setData(ClipboardData(text: 'Listen to my relaxing sound mix on Sanctuary: $shareUrl'));
                      Navigator.pop(context);
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          Future.delayed(const Duration(seconds: 2), () {
                            if (ctx.mounted) Navigator.pop(ctx);
                          });
                          return const CupertinoAlertDialog(
                            title: Text('Shared to Story 🌟'),
                            content: Text('Invite text copied. Open Instagram, WhatsApp, or TikTok to paste & share.'),
                          );
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.share_up, size: 16, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Share to Friends',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 🏆 Viral Streak Milestone Card Modal (Share to Instagram/WhatsApp) ───────
class ViralStreakShareModal extends StatelessWidget {
  const ViralStreakShareModal({super.key});

  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => const ViralStreakShareModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    const inviteUrl = 'https://theanlegendary.github.io/allinone/?ref=streak';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1017),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Milestone Badge 🏆',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Inspire friends & gift them 1 month of calm',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white60, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🖼️ Luxury Obsidian Achievement Story Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E2433),
                    Color(0xFF0C0E14),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF9500), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'DAILY MINDFULNESS HABIT',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF9500),
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          state.currentStreakTitle ?? 'Mindful Habit',
                          style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Streak Big Number
                  Text(
                    '${state.streak}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Day Streak Completed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('${state.totalMinutes}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Minutes Calm', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55))),
                          ],
                        ),
                        Container(width: 1, height: 24, color: Colors.white12),
                        Column(
                          children: [
                            Text('${state.totalSessions}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Sessions', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.sparkles, color: tealPrimary, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        'sanctuary.app • Beat stress in 60s',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Viral Action Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: const Color(0xFF1C2230),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(const ClipboardData(text: inviteUrl));
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          Future.delayed(const Duration(seconds: 2), () {
                            if (ctx.mounted) Navigator.pop(ctx);
                          });
                          return const CupertinoAlertDialog(
                            title: Text('Invite Link Copied 📋'),
                            content: Text('Gift link copied. Friends get 1 month of full access.'),
                          );
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.link, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Gift a Friend',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: const Color(0xFFFF9500),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Clipboard.setData(ClipboardData(
                        text: '🔥 I just reached a ${state.streak}-day mindfulness streak on Sanctuary! Try it free: $inviteUrl',
                      ));
                      Navigator.pop(context);
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          Future.delayed(const Duration(seconds: 2), () {
                            if (ctx.mounted) Navigator.pop(ctx);
                          });
                          return const CupertinoAlertDialog(
                            title: Text('Streak Card Copied 🌟'),
                            content: Text('Open Instagram or WhatsApp to share your achievement with friends!'),
                          );
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.share_up, size: 16, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Share Story',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ⚡ 60-Second SOS Panic/Stress Reset Card ───────────────────────────────────
class QuickPanicResetCard extends StatelessWidget {
  const QuickPanicResetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1528),
            const Color(0xFF0E0B16),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF9D4EDD).withOpacity(0.35), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF9D4EDD).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF9D4EDD).withOpacity(0.4), width: 1),
            ),
            child: const Icon(CupertinoIcons.bolt_fill, color: Color(0xFFD8B4FE), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Immediate Calm SOS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '1-Min 4-7-8 Breath + Soothing Rain',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.heavyImpact();
              final state = context.read<AppState>();
              state.startPanicResetCombo();
              state.setTab(AppTab.breathe);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9D4EDD),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x669D4EDD), blurRadius: 10),
                ],
              ),
              child: const Text(
                'Reset ⚡',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

