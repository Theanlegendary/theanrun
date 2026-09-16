import 'package:flutter/material.dart';

// ─── Claymorphism Design Tokens ──────────────────────────────────────────────
class ClayTheme {
  static const Color accent    = Color(0xFFD4A574); // Warm Amber Gold (#d4a574)
  static const Color text      = Color(0xFF5D4037); // Deep Warm Terracotta (#5d4037)
  static const Color subtext   = Color(0xFF8D6E63); // Soft Warm Clay Subtext (#8d6e63)
  static const Color background= Color(0xFFF5EBE0); // Soft Creamy Clay Surface
  static const Color cardBg    = Color(0xFFFAF3EC); // Inflated Clay Card Background
}

// ─── 1. Claymorphism Card Container Widget ────────────────────────────────────
class ClayCard extends StatelessWidget {
  final Widget child;
  final double cornerRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.cornerRadius = 28,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          color: ClayTheme.cardBg,
          borderRadius: BorderRadius.circular(cornerRadius),
          // Inflated 3D Claymorphism Soft Shadow Combination:
          boxShadow: [
            // Dark outer bottom-right shadow
            BoxShadow(
              color: const Color(0xFFD3C5B5).withOpacity(0.7),
              offset: const Offset(8, 8),
              blurRadius: 16,
              spreadRadius: 1,
            ),
            // Light inner top-left highlight
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─── 2. Claymorphism Button Widget ────────────────────────────────────────────
class ClayButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;

  const ClayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = ClayTheme.accent,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Puffy 3D Clay Button Outer Shadow
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    offset: const Offset(6, 6),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
