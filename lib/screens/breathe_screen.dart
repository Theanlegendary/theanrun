import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});
  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> with TickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late AnimationController _pulseCtrl;
  Timer? _timer;

  bool _isRunning = false;
  int _totalMins = 5;
  int _remainingSec = 300;
  int _cycleTick = 0;

  BreathPhase _phase = BreathPhase.inhale;
  int _phaseSecLeft = 4;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _remainingSec = _totalMins * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orbCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startStop() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      _orbCtrl.stop();
      setState(() => _isRunning = false);
    } else {
      setState(() { _isRunning = true; _cycleTick = 0; });
      _runCycle();
    }
  }

  void _reset() {
    _timer?.cancel();
    _orbCtrl.stop();
    final pattern = context.read<AppState>().pattern;
    setState(() {
      _isRunning = false;
      _remainingSec = _totalMins * 60;
      _cycleTick = 0;
      _phase = BreathPhase.inhale;
      _phaseSecLeft = pattern.inhale;
    });
  }

  void _runCycle() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isRunning) { t.cancel(); return; }

      final pattern = context.read<AppState>().pattern;
      final cycle = pattern.totalCycle;

      setState(() {
        _remainingSec = (_remainingSec - 1).clamp(0, _totalMins * 60);
        _cycleTick = (_cycleTick + 1) % cycle;

        int elapsed = 0;
        final phases = [
          (BreathPhase.inhale, pattern.inhale),
          (BreathPhase.hold, pattern.hold),
          (BreathPhase.exhale, pattern.exhale),
          (BreathPhase.holdOut, pattern.holdOut),
        ].where((p) => p.$2 > 0).toList();

        for (final p in phases) {
          if (_cycleTick < elapsed + p.$2) {
            final oldPhase = _phase;
            _phase = p.$1;
            final posInPhase = _cycleTick - elapsed;
            _phaseSecLeft = p.$2 - posInPhase;
            if (oldPhase != _phase || posInPhase == 0) {
              // Strong tactile cue on phase switch
              if (_phase == BreathPhase.inhale) {
                HapticFeedback.mediumImpact();
              } else if (_phase == BreathPhase.hold) {
                HapticFeedback.heavyImpact();
              } else if (_phase == BreathPhase.exhale) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.lightImpact();
              }
              _updateOrb(p.$2);
            } else {
              // Subtle pacing tick per second
              if (_phase == BreathPhase.inhale) {
                HapticFeedback.lightImpact();
              } else if (_phase == BreathPhase.exhale) {
                HapticFeedback.selectionClick();
              }
            }
            break;
          }
          elapsed += p.$2;
        }
      });

      if (_remainingSec <= 0) {
        t.cancel();
        if (!mounted) return; // BUG FIX: widget may be gone when timer fires
        setState(() => _isRunning = false);
        HapticFeedback.heavyImpact();
        context.read<AppState>().recordSession(
            '${context.read<AppState>().pattern.displayName} Session', 'Breathing', _totalMins);
      }
    });
  }

  void _updateOrb(int durationSec) {
    if (durationSec > 0) {
      _orbCtrl.duration = Duration(seconds: durationSec);
    }
    switch (_phase) {
      case BreathPhase.inhale:
        _orbCtrl.forward(from: 0.0);
        break;
      case BreathPhase.hold:
        _orbCtrl.value = 1.0;
        break;
      case BreathPhase.exhale:
        _orbCtrl.reverse(from: 1.0);
        break;
      case BreathPhase.holdOut:
        _orbCtrl.value = 0.0;
        break;
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case BreathPhase.inhale: return mintAccent;
      case BreathPhase.hold: return tealPrimary;
      case BreathPhase.exhale: return coralAccent;
      case BreathPhase.holdOut: return const Color(0xFFFFB74D);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case BreathPhase.inhale: return 'INHALE';
      case BreathPhase.hold: return 'HOLD';
      case BreathPhase.exhale: return 'EXHALE';
      case BreathPhase.holdOut: return 'PAUSE';
    }
  }

  String get _phaseInstruction {
    switch (_phase) {
      case BreathPhase.inhale: return 'Breathe in peace gently';
      case BreathPhase.hold: return 'Rest softly in stillness';
      case BreathPhase.exhale: return 'Slowly release all tension';
      case BreathPhase.holdOut: return 'Pause before the next breath';
    }
  }

  void _showPatternPicker(BuildContext context, AppState state) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Breathing Technique'),
        message: const Text('Select your breathing pattern'),
        actions: BreathingPattern.values.map((p) => CupertinoActionSheetAction(
          child: Column(
            children: [
              Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(p.description, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
            ],
          ),
          onPressed: () { 
            state.setPattern(p); 
            _reset(); 
            Navigator.of(ctx).pop(); 
          },
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: false, 
          child: const Text('Cancel'), 
          onPressed: () => Navigator.of(ctx).pop()
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final mins = _remainingSec ~/ 60;
    final secs = _remainingSec % 60;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Breathe', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xE6061118),
        border: Border.all(color: Colors.transparent),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.list_bullet, color: tealPrimary),
          onPressed: () => _showPatternPicker(context, state),
        ),
      ),
      child: Stack(
        children: [
          
          // Background Soft Radial Ambient Glow
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  return Container(
                    width: 320 + (40 * _pulseCtrl.value),
                    height: 320 + (40 * _pulseCtrl.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _phaseColor.withOpacity(0.18 * _pulseCtrl.value),
                          _phaseColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // ── Clean Header (Unboxed) ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Breath Sanctuary',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.pattern.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Text(
                          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Technique Selector Pills (Floating Unboxed)
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<BreathingPattern>(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      thumbColor: tealPrimary,
                      groupValue: state.pattern,
                      children: {
                        for (final p in BreathingPattern.values)
                          p: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              p.displayName,
                              style: TextStyle(
                                color: state.pattern == p ? Colors.black : Colors.white,
                                fontSize: 13,
                                fontWeight: state.pattern == p ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                      },
                      onValueChanged: (pattern) {
                        if (pattern != null) {
                          state.setPattern(pattern);
                          _reset();
                        }
                      },
                    ),
                  ),

                  const Spacer(),

                  // ── Hero Glowing 3D Breathing Lotus Orb (GPU Isolated) ──
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_orbCtrl, _pulseCtrl]),
                      builder: (context, _) {
                        final scale = 0.72 + (0.28 * _orbCtrl.value);
                        final orbSize = 250.0 * scale;

                        return Container(
                          width: orbSize,
                          height: orbSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _phaseColor.withOpacity(0.9),
                                _phaseColor.withOpacity(0.5),
                                _phaseColor.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _phaseColor.withOpacity(0.4 * _pulseCtrl.value),
                                blurRadius: 40 * scale,
                                spreadRadius: 10 * scale,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _phaseLabel,
                                  style: TextStyle(
                                    fontSize: 24 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_phaseSecLeft s',
                                  style: TextStyle(
                                    fontSize: 32 * scale,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    _phaseInstruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // Duration Selector Chips (Floating Unboxed)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [3, 5, 10, 15, 20].map((m) {
                        final isSelected = _totalMins == m;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GlassChip(
                            label: '$m min',
                            isSelected: isSelected,
                            selectedColor: coralAccent,
                            onTap: () {
                              setState(() {
                                _totalMins = m;
                                _reset();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Soft Controls Row (Start/Pause, Reset) ────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _reset,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(CupertinoIcons.refresh, color: Colors.white70, size: 22),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Hero Play/Pause Soft Cloud Pill
                      GestureDetector(
                        onTap: _startStop,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isRunning
                                  ? [coralAccent, const Color(0xFFFF8A65)]
                                  : [tealPrimary, const Color(0xFF48CAE4)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRunning ? coralAccent : tealPrimary).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                            color: Colors.black,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (ctx) => CupertinoAlertDialog(
                              title: const Text('Focus Mode'),
                              content: const Text('Focus mode active — breathe gently'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(CupertinoIcons.leaf_arrow_circlepath, color: Colors.white70, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
