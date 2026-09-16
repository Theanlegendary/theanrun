import 'package:flutter/material.dart';
import 'app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Responsive Design System
///
/// One-file, no-dependency helper layer for the Relax Mindfulness app. All
/// screens should use these tokens instead of hardcoded sizes so the app
/// stays consistent across:
///   - iPhone SE (320 logical px) → iPad Pro 12.9" (1024 logical px)
///   - portrait & landscape
///   - default & large text-scale settings
///   - bottom nav + floating mini-player safe areas
///
/// Three principles:
///   1. Spacing is proportional to the screen width, not fixed.
///   2. Type scale respects user's accessibility text setting.
///   3. SafeArea is the responsibility of the layout, not the screen.
/// ─────────────────────────────────────────────────────────────────────────────

// ─── Breakpoints ──────────────────────────────────────────────────────────────
// Matches Material 3 window size classes.
enum ScreenSize { compact, medium, expanded }

ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 600) return ScreenSize.compact;   // phones portrait
  if (w < 900) return ScreenSize.medium;    // phones landscape, small tablets
  return ScreenSize.expanded;               // tablets, desktop
}

bool isCompact(BuildContext c)  => screenSizeOf(c) == ScreenSize.compact;
bool isMedium(BuildContext c)   => screenSizeOf(c) == ScreenSize.medium;
bool isExpanded(BuildContext c) => screenSizeOf(c) == ScreenSize.expanded;

bool isLandscape(BuildContext c) =>
    MediaQuery.sizeOf(c).width > MediaQuery.sizeOf(c).height;

// ─── Spacing tokens (the only spacing values you should ever use) ─────────────
// Scales with screen width so phones get tight, tablets get airy.
class Spacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  const Spacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  static const compact = Spacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32);
  static const medium  = Spacing(xs: 6, sm: 10, md: 16, lg: 22, xl: 32, xxl: 44);
  static const expanded = Spacing(xs: 8, sm: 12, md: 20, lg: 28, xl: 40, xxl: 56);

  static Spacing of(BuildContext context) {
    switch (screenSizeOf(context)) {
      case ScreenSize.medium:   return medium;
      case ScreenSize.expanded: return expanded;
      case ScreenSize.compact:  return compact;
    }
  }

  // Convenient EdgeInsets helpers
  static EdgeInsets allMd(BuildContext c) =>
      EdgeInsets.all(of(c).md);
  static EdgeInsets screenPadding(BuildContext c) =>
      EdgeInsets.symmetric(horizontal: of(c).lg);
  static EdgeInsets cardPadding(BuildContext c) =>
      EdgeInsets.all(of(c).lg);
}

// ─── Typography that respects user accessibility ───────────────────────────────
// Use these instead of raw fontSize values in screens.
class AppText {
  // Headlines
  static TextStyle? displayLarge(BuildContext c)  => Theme.of(c).textTheme.displayLarge?.copyWith(fontSize: _scaled(c, 32));
  static TextStyle? displayMedium(BuildContext c) => Theme.of(c).textTheme.displayMedium?.copyWith(fontSize: _scaled(c, 28));
  static TextStyle? headlineLarge(BuildContext c) => Theme.of(c).textTheme.headlineLarge?.copyWith(fontSize: _scaled(c, 26));
  static TextStyle? headlineMedium(BuildContext c)=> Theme.of(c).textTheme.headlineMedium?.copyWith(fontSize: _scaled(c, 22));
  static TextStyle? titleLarge(BuildContext c)    => Theme.of(c).textTheme.titleLarge?.copyWith(fontSize: _scaled(c, 18));

  // Body
  static TextStyle? bodyLarge(BuildContext c)  => Theme.of(c).textTheme.bodyLarge?.copyWith(fontSize: _scaled(c, 15));
  static TextStyle? bodyMedium(BuildContext c) => Theme.of(c).textTheme.bodyMedium?.copyWith(fontSize: _scaled(c, 13));
  static TextStyle? labelLarge(BuildContext c) => Theme.of(c).textTheme.labelLarge?.copyWith(fontSize: _scaled(c, 13));

  // Section eyebrow labels (small caps-ish letter-spaced labels)
  static TextStyle eyebrow(BuildContext c) => TextStyle(
        fontSize: _scaled(c, 11),
        fontWeight: FontWeight.bold,
        color: tealPrimary,
        letterSpacing: 1.6,
      );

  // Multiply the base size by the user's text scale, but cap so a user with
  // 200% scale doesn't break layouts.
  static double _scaled(BuildContext c, double base) {
    final scale = MediaQuery.textScalerOf(c).scale(1.0);
    final clamped = scale.clamp(1.0, 1.4);
    return base * clamped;
  }
}

// ─── Layout helpers ────────────────────────────────────────────────────────────

/// Wraps a child with the standard screen padding + handles safe area + nav bar
/// + floating mini-player offsets. Use this as the outer wrapper of any screen
/// body so you never have to remember to add bottom padding for the nav.
class ScreenScaffold extends StatelessWidget {
  final Widget child;
  final Widget? floatingHeader;       // optional sticky-feel header above scroll content
  final bool addMiniPlayerPadding;    // default true; set false on screens that have their own overlay
  final bool addNavBarPadding;        // default true
  final Color? backgroundColor;
  final EdgeInsets? extraPadding;

  const ScreenScaffold({
    super.key,
    required this.child,
    this.floatingHeader,
    this.addMiniPlayerPadding = true,
    this.addNavBarPadding = true,
    this.backgroundColor,
    this.extraPadding,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    const navBarHeight = 68.0;
    const miniPlayerSpace = 68.0 + 14.0;  // player height + gap

    final bottomInset = (addNavBarPadding ? navBarHeight : 0.0) +
        (addMiniPlayerPadding ? miniPlayerSpace : 0.0);

    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: media.padding.top,
            bottom: bottomInset,
          ).add(extraPadding ?? EdgeInsets.zero),
          child: Column(
            children: [
              if (floatingHeader != null) floatingHeader!,
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard horizontal screen padding that scales with screen width.
class ScreenPadding extends StatelessWidget {
  final Widget child;
  final double? horizontalOverride;
  const ScreenPadding({super.key, required this.child, this.horizontalOverride});

  @override
  Widget build(BuildContext context) {
    final pad = Spacing.of(context).lg;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalOverride ?? pad),
      child: child,
    );
  }
}

/// Adaptive grid: phones get 2 cols, tablets get 3-4. Use for sound lists,
/// session cards, etc.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.spacing = 12,
  });

  int _columnsFor(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    if (w >= 1100) return 4;
    if (w >= 700)  return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _columnsFor(context),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

/// Constrains content max-width on tablets so lines don't stretch absurdly.
class ContentMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentMaxWidth({super.key, required this.child, this.maxWidth = 680});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Hide on phones, show on tablets (or vice versa). Useful for tablet-only
/// detail panes, or for collapsing ornament on small screens.
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool showOnCompact;
  final bool showOnMedium;
  final bool showOnExpanded;
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.showOnCompact = true,
    this.showOnMedium = true,
    this.showOnExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    final visible = switch (size) {
      ScreenSize.compact  => showOnCompact,
      ScreenSize.medium   => showOnMedium,
      ScreenSize.expanded => showOnExpanded,
    };
    return visible ? child : const SizedBox.shrink();
  }
}

/// Hide keyboard-aware content under the IME. Wrap any TextField in this so
/// scrolling content stays visible while typing.
class KeyboardSafe extends StatelessWidget {
  final Widget child;
  const KeyboardSafe({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
    );
  }
}

/// Adaptive SizedBox that uses the spacing tokens. Drop-in replacement for
/// `SizedBox(height: 16)`.
class Gap extends StatelessWidget {
  final double size;
  final Axis axis;
  const Gap(this.size, {super.key, this.axis = Axis.vertical});
  const Gap.xs(this.size, {super.key})   : axis = Axis.vertical;
  const Gap.sm(this.size, {super.key})   : axis = Axis.vertical;
  const Gap.md(this.size, {super.key})   : axis = Axis.vertical;
  const Gap.lg(this.size, {super.key})   : axis = Axis.vertical;
  const Gap.xl(this.size, {super.key})   : axis = Axis.vertical;
  const Gap.h(this.size, {super.key})    : axis = Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  axis == Axis.horizontal ? size : null,
      height: axis == Axis.vertical   ? size : null,
    );
  }
}