import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Theme 1: Serenly Luxury Obsidian + Neo Minimalism Palette ────────────────
const Color tealPrimary     = Color(0xFF52B788); // Apple Fitness/Health Sage Green (#52b788)
const Color tealDark        = Color(0xFF3B8260);
const Color coralAccent     = Color(0xFFE29578); // Soft Warm Terracotta Peach (#e29578)
const Color mintAccent      = Color(0xFF74C69D); // Fresh Soft Spring Mint (#74c69d)
const Color purpleAccent    = Color(0xFFB8B8D1); // Ethereal Dusk Lavender (#b8b8d1)
const Color greenAccent     = Color(0xFF95D5B2);

// Serenly Ultra Dark Obsidian tokens
const Color serenlyBg       = Color(0xFF08090C); // Pure obsidian night (#08090c)
const Color serenlySurface  = Color(0xFF111319); // Subtle dark card surface
const Color serenlyGlass    = Color(0x1AFFFFFF); // Translucent pill fill
const Color serenlyBorder   = Color(0x1FFFFFFF); // Hairline white contour
const Color serenlyGold     = Color(0xFFE5A96E); // Warm sunset golden glow
const Color serenlyDuskBlue = Color(0xFF38BDF8); // Ocean breath cyan

const Color bgDark          = Color(0xFF08090C); // Deep Obsidian Midnight Sanctuary (#08090c)
const Color bgMid           = Color(0xFF0F1117); // Obsidian Surface Navy (#0f1117)
const Color bgSurface       = Color(0xFF141720);

const Color glassWhite      = Color(0x0CFFFFFF); // Ultra-soft 0.05 glass opacity
const Color glassBorder     = Color(0x1AFFFFFF); // Soft 0.1 border contour
const Color textPrimary     = Color(0xFFFFFFFF); // Pure Crisp White
const Color textSecondary   = Color(0xFF94A3B8); // Slate 400 Editorial Subtext

// ─── Claymorphism Soft UI Theme Palette ──────────────────────────────────────
const Color clayAccent       = Color(0xFFD4A574); // Warm Sand Clay Accent (#d4a574)
const Color clayText         = Color(0xFF5D4037); // Deep Roasted Espresso (#5d4037)
const Color claySubtext      = Color(0xFF8D6E63); // Terracotta Soil (#8d6e63)
const Color claySurface      = Color(0xFFF9F4EF); // Soft Cream Clay Surface (#f9f4ef)
const Color clayCardBg       = Color(0xFFEADBC8); // Warm Sand Card Background (#eadbc8)
const Color clayDarkCardBg   = Color(0xFFDFCCB7);

// ─── Neumorphism Soft UI Theme Palette (2019-2020 Classic) ───────────────────
const Color neuSurface       = Color(0xFFE0E5EC); // Soft Slate-Blue Off-White Surface (#e0e5ec)
const Color neuAccent        = Color(0xFF6C757D); // Soft Slate Grey Accent (#6c757d)
const Color neuText          = Color(0xFF3D3D3D); // Charcoal Dark Text (#3d3d3d)
const Color neuSubtext       = Color(0xFF888888); // Slate Subtext (#888888)
const Color neuLightShadow   = Color(0xFFFFFFFF); // Top-left soft highlight shadow
const Color neuDarkShadow    = Color(0xFFA3B1C6); // Bottom-right soft depth shadow

// ─── Material Theme ────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: tealPrimary,
      secondary: coralAccent,
      tertiary: mintAccent,
      surface: bgMid,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.8),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.6),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, height: 1.4),
        bodyMedium: TextStyle(color: textSecondary, height: 1.4),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textPrimary,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: tealPrimary,
      thumbColor: textPrimary,
      inactiveTrackColor: Colors.white.withOpacity(0.08),
      overlayColor: tealPrimary.withOpacity(0.12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.black : Colors.white60),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? tealPrimary : Colors.white10),
    ),
  );
}

const List<String> emojiFontFallbacks = [
  'Noto Color Emoji',
  'Apple Color Emoji',
  'Segoe UI Emoji',
  'sans-serif',
];

// ─── Cupertino / iOS Theme ─────────────────────────────────────────────────────
// Maps the existing dark palette to iOS Cupertino system tokens.
// Used by CupertinoApp as the top-level theme.
CupertinoThemeData buildCupertinoTheme() {
  return const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: tealPrimary,
    primaryContrastingColor: Colors.black,
    scaffoldBackgroundColor: bgDark,
    barBackgroundColor: Color(0xE6050D15), // bgDark at ~90% opacity — frosted effect
    textTheme: CupertinoTextThemeData(
      primaryColor: tealPrimary,
      textStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      navTitleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      navLargeTitleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      navActionTextStyle: TextStyle(
        color: tealPrimary,
        fontSize: 17,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      tabLabelTextStyle: TextStyle(
        color: textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      actionTextStyle: TextStyle(
        color: tealPrimary,
        fontSize: 17,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      pickerTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 21,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
      dateTimePickerTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 21,
        decoration: TextDecoration.none,
        fontFamilyFallback: emojiFontFallbacks,
      ),
    ),
  );
}
