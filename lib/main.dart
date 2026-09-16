import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/screens/home_screen.dart';
import 'package:relax_mindfulness/screens/onboarding_screen.dart';
import 'package:relax_mindfulness/screens/meditation_screen.dart';
import 'package:relax_mindfulness/screens/breathe_screen.dart';
import 'package:relax_mindfulness/screens/sounds_screen.dart';
import 'package:relax_mindfulness/screens/sleep_screen.dart';
import 'package:relax_mindfulness/screens/mindfulness_screen.dart';
import 'package:relax_mindfulness/screens/ai_studio_screen.dart';
import 'package:relax_mindfulness/screens/premium_screen.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

import 'dart:ui' show PlatformDispatcher;

final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Boundaries to eliminate unhandled crash states
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Global FlutterError caught: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Global Async Error caught: $error');
    return true; // Handled safely without freezing the app
  };

  // Initialize timezone for local notifications
  tz.initializeTimeZones();

  // Initialize Local Notifications (iOS specific for Cupertino feel)
  if (!kIsWeb) {
    try {
      const DarwinInitializationSettings initSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        iOS: initSettingsDarwin,
      );
      await localNotifications.initialize(initSettings);
    } catch (e) {
      debugPrint("Notifications init error: $e");
    }
  }

  // Initialize RevenueCat on supported native platforms if a real key is provided
  const revenueCatKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
  if (!kIsWeb && (Platform.isIOS || Platform.isMacOS) && revenueCatKey.isNotEmpty && !revenueCatKey.contains('your_revenuecat_key')) {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(revenueCatKey));
    } catch (e) {
      debugPrint("RevenueCat init error: $e");
    }
  }

  // Lock to portrait mode for a clean app experience
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Make status bar transparent for edge-to-edge iOS design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  final appState = AppState();
  await appState.init();

  if (kIsWeb) {
    try {
      appState.parseAndApplyMixFromUri(Uri.base);
    } catch (e) {
      debugPrint("Deep link parsing error: $e");
    }
  }

  // ── GPU & Image Cache tuning for maximum FPS ──
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200 MB
  PaintingBinding.instance.imageCache.maximumSize = 200;

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const SanctuaryApp(),
    ),
  );
}

// ─── Root App — CupertinoApp for full native iOS feel ─────────────────────────
class SanctuaryApp extends StatelessWidget {
  const SanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Sanctuary – Relax & Meditate',
      debugShowCheckedModeBanner: false,
      theme: buildCupertinoTheme(),
      builder: (context, child) {
        // Protect layout against RenderFlex yellow/black overflows on large accessibility fonts
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.28,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      // ── iOS Bouncing Scroll Physics globally ──
      scrollBehavior: const _IOSScrollBehavior(),
      home: const AppShell(),
    );
  }
}

// ── Global iOS Bouncing Scroll Behavior ──────────────────────────────────────
class _IOSScrollBehavior extends ScrollBehavior {
  const _IOSScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) =>
      child; // No scrollbars — pure native iOS feel

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

// ─── AppShell — CupertinoTabScaffold with synced AppState ─────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final CupertinoTabController _tabController;

  // Tab order matches AppTab enum values we expose in the tab bar
  static const _tabOrder = [
    AppTab.home,
    AppTab.meditate,
    AppTab.breathe,
    AppTab.sounds,
    AppTab.sleep,
    AppTab.aiStudio,
  ];

  int _appTabToIndex(AppTab tab) => _tabOrder.indexOf(tab).clamp(0, _tabOrder.length - 1);
  AppTab _indexToAppTab(int index) => _tabOrder[index.clamp(0, _tabOrder.length - 1)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = CupertinoTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Thermal & battery optimization: pause high-power UI animations on screen sleep
    if (lifecycleState == AppLifecycleState.paused || lifecycleState == AppLifecycleState.hidden) {
      context.read<AppState>().setBackgroundMode(true);
    } else if (lifecycleState == AppLifecycleState.resumed) {
      context.read<AppState>().setBackgroundMode(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // ── Onboarding gate ──
        if (!state.onboardingDone) {
          // Wrap in Material for onboarding screen compatibility
          return Material(
            color: bgDark,
            child: const OnboardingScreen(),
          );
        }

        // ── Sync CupertinoTabController → AppState ──
        final expectedIndex = _appTabToIndex(state.tab);
        if (_tabController.index != expectedIndex) {
          // Avoid setState loop — just set index directly
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _tabController.index != expectedIndex) {
              _tabController.index = expectedIndex;
            }
          });
        }

        return Stack(
          children: [
            // 🖼️ App-Wide Global Living Atmospheric Wallpaper Stack
            if (state.wallpaper.imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  state.wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      state.wallpaper.baseColor.withOpacity(0.78),
                      state.wallpaper.baseColor.withOpacity(0.94),
                      state.wallpaper.baseColor,
                    ],
                  ),
                ),
              ),
            ),

            // ── 🍎 Authentic Apple iOS Inspired Footer Tab Bar ──────────────
            CupertinoTabScaffold(
              backgroundColor: Colors.transparent,
              controller: _tabController,
              tabBar: CupertinoTabBar(
                onTap: (index) {
                  HapticFeedback.selectionClick();
                  state.setTab(_indexToAppTab(index));
                },
                backgroundColor: const Color(0xF00D0F16), // Serenly Obsidian frosted glass
                border: const Border(
                  top: BorderSide(color: Color(0x2EFFFFFF), width: 0.8), // Clear top boundary
                ),
                activeColor: const Color(0xFFFFFFFF), // Pure bright active white
                inactiveColor: const Color(0xFFA0AEC0), // High-contrast clear silver/slate
                iconSize: 23,
                currentIndex: _appTabToIndex(state.tab),
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore_rounded),
                    label: 'Discover',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.air_outlined),
                    activeIcon: Icon(Icons.air_rounded),
                    label: 'Breathe',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.graphic_eq_outlined),
                    activeIcon: Icon(Icons.graphic_eq_rounded),
                    label: 'Sounds',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.nightlight_outlined),
                    activeIcon: Icon(Icons.nightlight_round),
                    label: 'Sleep',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.auto_awesome_outlined),
                    activeIcon: const Icon(Icons.auto_awesome_rounded),
                    label: state.isPremium ? 'Premium' : 'AI',
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                final tab = _indexToAppTab(index);
                return CupertinoTabView(
                  builder: (ctx) => RepaintBoundary(
                    child: _buildScreen(tab, ctx),
                  ),
                );
              },
            ),

            // ── 🎵 Floating Mini Player ───────────────────────────────────
            if (state.isAnyAudioPlaying)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 83, // Above CupertinoTabBar (49px) + safe area
                child: SanctuaryMiniPlayer(),
              ),

            // ── 😊 Mood Check-In Dialog ───────────────────────────────────
            if (state.showMoodDialog)
              MoodCheckInDialog(
                onMoodSelected: (rating) => state.submitMood(rating),
                onSkip: () => state.dismissMood(),
              ),

            // ── 🎧 Full-Screen Guided Player ──────────────────────────────
            if (state.isGuidedPlaying)
              const GuidedPlayerOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildScreen(AppTab tab, BuildContext context) {
    switch (tab) {
      case AppTab.home:
        return const HomeScreen();
      case AppTab.meditate:
        return const MeditationScreen();
      case AppTab.breathe:
        return const BreatheScreen();
      case AppTab.sounds:
        return const SoundsScreen();
      case AppTab.sleep:
        return const SleepScreen();
      case AppTab.aiStudio:
        return const AiStudioScreen();
      default:
        return const HomeScreen();
    }
  }
}

// ─── Premium Crown Tab Icon ────────────────────────────────────────────────────
class _PremiumTabIcon extends StatelessWidget {
  final bool isPremium;
  final bool isActive;
  const _PremiumTabIcon({required this.isPremium, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [const BoxShadow(color: Color(0x80FFB300), blurRadius: 8)]
              : [],
        ),
        child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 16),
      );
    }
    return Icon(
      CupertinoIcons.sparkles,
      size: 22,
      color: isActive ? tealPrimary : const Color(0xFF4A6070),
    );
  }
}
