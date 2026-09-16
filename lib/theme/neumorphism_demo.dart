import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';

// ─── Twilight Lavender Dark Neumorphic Soft UI Showcase ──────────────────────
class NeumorphismDemoScreen extends StatefulWidget {
  const NeumorphismDemoScreen({super.key});

  @override
  State<NeumorphismDemoScreen> createState() => _NeumorphismDemoScreenState();
}

class _NeumorphismDemoScreenState extends State<NeumorphismDemoScreen> {
  // Twilight Lavender Dark Neumorphic Tokens
  static const Color _neuDarkSurface = Color(0xFF0D1826);
  static const Color _neuLavender = Color(0xFFC7D2FE);
  static const Color _neuLavenderGlow = Color(0xFFA5B4FC);
  static const Color _neuTextPrimary = Color(0xFFF1F5F9);
  static const Color _neuTextSecondary = Color(0xFF94A3B8);
  static const Color _neuDarkShadow = Color(0xFF04080F);
  static const Color _neuLightGlow = Color(0x1FC7D2FE);

  bool _isButtonPressed = false;
  bool _isSwitchOn = true;
  double _sliderValue = 0.75;
  int _selectedChip = 1; // Default to Sleep (Moon)

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSwitchOn = prefs.getBool('neu_switch_on') ?? true;
      _sliderValue = prefs.getDouble('neu_slider_val') ?? 0.75;
      _selectedChip = prefs.getInt('neu_chip_idx') ?? 1;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final wallpaper = state.wallpaper;

        return Scaffold(
          backgroundColor: _neuDarkSurface,
          body: Stack(
            children: [
              // 🖼️ Dynamic Living Wallpaper Background
              if (wallpaper.imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    wallpaper.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Dark Atmospheric Vignette Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _neuDarkSurface.withOpacity(0.85),
                        _neuDarkSurface.withOpacity(0.95),
                        _neuDarkSurface,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _neuDarkSurface,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: _neuDarkShadow, offset: Offset(4, 4), blurRadius: 8),
                                BoxShadow(color: _neuLightGlow, offset: Offset(-3, -3), blurRadius: 6),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.back, color: _neuTextPrimary, size: 20),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Twilight Soft UI 🌙',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _neuTextPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Dark Neumorphic Tactile Controls',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _neuTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 🖼️ Wallpaper Switcher
                          Container(
                            decoration: BoxDecoration(
                              color: _neuDarkSurface,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: _neuDarkShadow, offset: Offset(4, 4), blurRadius: 8),
                                BoxShadow(color: _neuLightGlow, offset: Offset(-3, -3), blurRadius: 6),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.photo_on_rectangle, color: _neuLavender, size: 18),
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
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Component Showcase
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Hero Moonlight Orb
                            _buildNeuCard(
                              child: Column(
                                children: [
                                  // Glowing Lavender Moon Capsule
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: _neuDarkSurface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        const BoxShadow(
                                          color: _neuDarkShadow,
                                          offset: Offset(8, 8),
                                          blurRadius: 16,
                                        ),
                                        const BoxShadow(
                                          color: _neuLightGlow,
                                          offset: Offset(-8, -8),
                                          blurRadius: 16,
                                        ),
                                        BoxShadow(
                                          color: _neuLavender.withOpacity(0.18),
                                          blurRadius: 28,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF162338),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _neuLavender.withOpacity(0.3),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            CupertinoIcons.moon_stars_fill,
                                            color: _neuLavender,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Twilight Lavender Soft UI',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _neuTextPrimary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Dual-shadow extruded surfaces • Tactile depth • Auto-saved local state',
                                    style: TextStyle(fontSize: 12, color: _neuTextSecondary, height: 1.4),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 2. Tactile Buttons (Extruded vs Inset)
                            _buildNeuCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(CupertinoIcons.hand_draw_fill, color: _neuLavender, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        '1. Physical Tactile Button',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: _neuTextPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Press and hold to physically recess the button inward (Inset depth):',
                                    style: TextStyle(fontSize: 12, color: _neuTextSecondary),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTapDown: (_) {
                                      HapticFeedback.lightImpact();
                                      setState(() => _isButtonPressed = true);
                                    },
                                    onTapUp: (_) => setState(() => _isButtonPressed = false),
                                    onTapCancel: () => setState(() => _isButtonPressed = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: _isButtonPressed
                                            ? const Color(0xFF0A121E)
                                            : _neuDarkSurface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _isButtonPressed
                                              ? _neuLavender.withOpacity(0.4)
                                              : _neuLavender.withOpacity(0.12),
                                          width: 1,
                                        ),
                                        boxShadow: _isButtonPressed
                                            ? [
                                                BoxShadow(
                                                  color: _neuDarkShadow.withOpacity(0.9),
                                                  offset: const Offset(3, 3),
                                                  blurRadius: 6,
                                                  spreadRadius: -1,
                                                ),
                                              ]
                                            : const [
                                                BoxShadow(
                                                  color: _neuDarkShadow,
                                                  offset: Offset(6, 6),
                                                  blurRadius: 14,
                                                ),
                                                BoxShadow(
                                                  color: _neuLightGlow,
                                                  offset: Offset(-5, -5),
                                                  blurRadius: 12,
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _isButtonPressed
                                                  ? CupertinoIcons.moon_fill
                                                  : CupertinoIcons.sparkles,
                                              color: _neuLavender,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isButtonPressed
                                                  ? 'INSET (PRESSED INTO SCREEN)'
                                                  : 'EXTRUDED SOFT UI BUTTON',
                                              style: TextStyle(
                                                color: _isButtonPressed ? _neuLavender : _neuTextPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Soft UI Toggle Switch
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tactile Haptic Switch',
                                            style: TextStyle(
                                              color: _neuTextPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          Text(
                                            'Auto-saved to local memory',
                                            style: TextStyle(
                                              color: _neuTextSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          final nextVal = !_isSwitchOn;
                                          setState(() => _isSwitchOn = nextVal);
                                          _saveSetting('neu_switch_on', nextVal);
                                        },
                                        child: Container(
                                          width: 58,
                                          height: 32,
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: _neuDarkSurface,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: const [
                                              BoxShadow(color: _neuDarkShadow, offset: Offset(3, 3), blurRadius: 6),
                                              BoxShadow(color: _neuLightGlow, offset: Offset(-3, -3), blurRadius: 6),
                                            ],
                                          ),
                                          child: AnimatedAlign(
                                            duration: const Duration(milliseconds: 200),
                                            alignment: _isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: _isSwitchOn ? _neuLavender : const Color(0xFF1E293B),
                                                shape: BoxShape.circle,
                                                boxShadow: _isSwitchOn
                                                    ? [
                                                        BoxShadow(
                                                          color: _neuLavenderGlow.withOpacity(0.5),
                                                          blurRadius: 10,
                                                        ),
                                                      ]
                                                    : const [
                                                        BoxShadow(
                                                          color: _neuDarkShadow,
                                                          offset: Offset(2, 2),
                                                          blurRadius: 4,
                                                        ),
                                                      ],
                                              ),
                                              child: Icon(
                                                _isSwitchOn ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
                                                size: 13,
                                                color: _isSwitchOn ? Colors.black : _neuTextSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 3. Soft Chips & Volume Slider
                            _buildNeuCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(CupertinoIcons.slider_horizontal_3, color: _neuLavender, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        '2. Mood Selector & Volume Slider',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: _neuTextPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _buildChip(0, '😌 Calm'),
                                      const SizedBox(width: 8),
                                      _buildChip(1, '🌙 Sleep'),
                                      const SizedBox(width: 8),
                                      _buildChip(2, '🧠 Focus'),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Master Ambient Level',
                                        style: TextStyle(
                                          color: _neuTextPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${(_sliderValue * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: _neuLavender,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: _neuLavender,
                                      inactiveTrackColor: const Color(0xFF1E293B),
                                      thumbColor: _neuLavender,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                                      overlayColor: _neuLavender.withOpacity(0.18),
                                    ),
                                    child: Slider(
                                      value: _sliderValue,
                                      onChanged: (v) {
                                        setState(() => _sliderValue = v);
                                        _saveSetting('neu_slider_val', v);
                                      },
                                    ),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(int index, String label) {
    final isSelected = _selectedChip == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedChip = index);
          _saveSetting('neu_chip_idx', index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : _neuDarkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _neuLavender.withOpacity(0.6) : Colors.white.withOpacity(0.06),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _neuLavender.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(color: _neuDarkShadow, offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: _neuLightGlow, offset: Offset(-3, -3), blurRadius: 6),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? _neuLavender : _neuTextSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeuCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _neuDarkSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        boxShadow: const [
          BoxShadow(color: _neuDarkShadow, offset: Offset(8, 8), blurRadius: 18),
          BoxShadow(color: _neuLightGlow, offset: Offset(-6, -6), blurRadius: 16),
        ],
      ),
      child: child,
    );
  }
}
