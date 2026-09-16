import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─── Twinkling Starry Night Background ─────────────────────────────────────────
class StarrySkyPainter extends CustomPainter {
  final double animationValue;
  StarrySkyPainter({this.animationValue = 1.0});

  static final List<_Star> _stars = List.generate(45, (i) {
    final rand = math.Random(i * 137);
    return _Star(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: rand.nextDouble() * 2.2 + 0.8,
      baseOpacity: rand.nextDouble() * 0.5 + 0.35,
      blinkSpeed: rand.nextDouble() * 2 + 1,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(
          (s.baseOpacity * (0.6 + 0.4 * math.sin(animationValue * math.pi * 2 * s.blinkSpeed))).clamp(0.1, 0.95),
        );
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarrySkyPainter oldDelegate) => true;
}

class _Star {
  final double x, y, size, baseOpacity, blinkSpeed;
  _Star({required this.x, required this.y, required this.size, required this.baseOpacity, required this.blinkSpeed});
}

// ─── 1. Glowing Crescent Moon with Hanging Lantern (Screen 1) ─────────────────
class CrescentMoonLanternIllustration extends StatelessWidget {
  const CrescentMoonLanternIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Moon Glow
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.35),
                  blurRadius: 45,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          // Custom Painted Crescent Moon & Hanging Lantern
          CustomPaint(
            size: const Size(200, 220),
            painter: _MoonLanternPainter(),
          ),
        ],
      ),
    );
  }
}

class _MoonLanternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.42, size.height * 0.46);
    final radius = size.width * 0.38;

    // 🌙 Crescent Moon
    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, math.pi * 1.5)
      ..arcToPoint(
        Offset(center.dx - radius * 0.7, center.dy - radius * 0.7),
        radius: Radius.circular(radius * 0.8),
        clockwise: false,
      );

    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFFFF176),
          Color(0xFFFFD54F),
          Color(0xFFFFB300),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(moonPath, moonPaint);

    // Inner subtle shadow rim
    final moonRimPaint = Paint()
      ..color = const Color(0xFFFF8F00).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(moonPath, moonRimPaint);

    // 🏮 Lantern Hanging String
    final stringStart = Offset(center.dx + radius * 0.65, center.dy - radius * 0.3);
    final lanternTop = Offset(center.dx + radius * 0.65, center.dy + radius * 0.2);

    final linePaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(stringStart, lanternTop, linePaint);

    // 🏮 Hanging Lantern Body
    final lanternRect = Rect.fromCenter(
      center: Offset(lanternTop.dx, lanternTop.dy + 22),
      width: 26,
      height: 38,
    );

    // Lantern Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(lanternRect, glowPaint);

    // Lantern Glass
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
      ).createShader(lanternRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(lanternRect, const Radius.circular(5)), glassPaint);

    // Lantern Metal Frame (Top & Bottom Caps)
    final framePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    // Top Cap
    final topCapPath = Path()
      ..moveTo(lanternRect.left - 3, lanternRect.top)
      ..lineTo(lanternRect.right + 3, lanternRect.top)
      ..lineTo(lanternRect.center.dx, lanternRect.top - 6)
      ..close();
    canvas.drawPath(topCapPath, framePaint);

    // Bottom Cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lanternRect.left - 2, lanternRect.bottom - 2, lanternRect.width + 4, 5),
        const Radius.circular(2),
      ),
      framePaint,
    );

    // Vertical Frame Bars
    final barPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(lanternRect.left + 5, lanternRect.top), Offset(lanternRect.left + 5, lanternRect.bottom), barPaint);
    canvas.drawLine(Offset(lanternRect.right - 5, lanternRect.top), Offset(lanternRect.right - 5, lanternRect.bottom), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 2. Meditating Journey Persona on Warm Glowing Cushion (Screen 2) ─────────
class JourneyMeditationIllustration extends StatelessWidget {
  const JourneyMeditationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Clock/Moon floating badge in top right
          Positioned(
            top: 6,
            right: 24,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF8E1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.clock_fill, size: 16, color: Color(0xFFF59E0B)),
            ),
          ),

          // Big Glowing Golden Floor Beanbag / Cushion
          Positioned(
            bottom: 10,
            child: Container(
              width: 220,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE082),
                    Color(0xFFFFCA28),
                    Color(0xFFFFB300),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // Meditating Character with Laptop
          Positioned(
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Head
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFCCBC),
                  ),
                ),
                const SizedBox(height: 2),
                // Shirt
                Container(
                  width: 44,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Laptop & Crossed Legs
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DD0E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.laptop_mac, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // Legs
                Container(
                  width: 58,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. Glowing Sleeping Sun with Night Mask (Screen 3) ────────────────────────
class SleepingSunIllustration extends StatelessWidget {
  const SleepingSunIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing Ray Burst Behind
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.5),
                  blurRadius: 36,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Sun Core with Radiating Spikes
          CustomPaint(
            size: const Size(140, 140),
            painter: _SleepingSunPainter(),
          ),
        ],
      ),
    );
  }
}

class _SleepingSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 42.0;

    // Radiating Sun Spikes / Petals
    final rayPaint = Paint()
      ..color = const Color(0xFFFFCA28)
      ..style = PaintingStyle.fill;

    const numRays = 12;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * math.pi) / numRays;
      final x1 = center.dx + (radius + 2) * math.cos(angle - 0.18);
      final y1 = center.dy + (radius + 2) * math.sin(angle - 0.18);
      final x2 = center.dx + (radius + 14) * math.cos(angle);
      final y2 = center.dy + (radius + 14) * math.sin(angle);
      final x3 = center.dx + (radius + 2) * math.cos(angle + 0.18);
      final y3 = center.dy + (radius + 2) * math.sin(angle + 0.18);

      final path = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(x3, y3)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // Sun Face Center
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF59D), Color(0xFFFFD54F), Color(0xFFFFB300)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sunPaint);

    // Sleeping Eye Mask (Navy Obsidian)
    final maskRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 6),
      width: 54,
      height: 24,
    );
    final maskPaint = Paint()
      ..color = const Color(0xFF1E1B4B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(maskRect, const Radius.circular(12)), maskPaint);

    // Mask Strap
    final strapPaint = Paint()
      ..color = const Color(0xFF1E1B4B)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(maskRect.left, maskRect.center.dy), Offset(center.dx - radius, maskRect.center.dy), strapPaint);
    canvas.drawLine(Offset(maskRect.right, maskRect.center.dy), Offset(center.dx + radius, maskRect.center.dy), strapPaint);

    // Little Cute Sleep Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(center.dx - 8, center.dy + 15)
      ..quadraticBezierTo(center.dx, center.dy + 22, center.dx + 8, center.dy + 15);
    canvas.drawPath(smilePath, smilePaint);

    // Rosy Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF8A80).withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 14), 4, cheekPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 14), 4, cheekPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
