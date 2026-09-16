import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:relax_mindfulness/main.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'streak': 3,
      'theme_mode': 'midnightNavy',
    });
  });

  testWidgets('Test 1: App initializes and renders HomeScreen with Serenly navigation', (WidgetTester tester) async {
    final appState = AppState();
    await appState.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const SanctuaryApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Tab scaffold & items
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Breathe'), findsOneWidget);
    expect(find.text('Sounds'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
  });

  testWidgets('Test 2: Tab switching between screens works smoothly', (WidgetTester tester) async {
    final appState = AppState();
    await appState.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const SanctuaryApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Switch to Discover
    appState.setTab(AppTab.meditate);
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.tab, AppTab.meditate);

    // Switch to Breathe
    appState.setTab(AppTab.breathe);
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.tab, AppTab.breathe);

    // Switch to Sounds
    appState.setTab(AppTab.sounds);
    await tester.pump(const Duration(milliseconds: 300));
    expect(appState.tab, AppTab.sounds);
  });

  testWidgets('Test 3: Sound mixer & volume state calculations', (WidgetTester tester) async {
    final appState = AppState();
    await appState.init();

    // Set volumes
    await appState.updateSoundTrackVolume('Soft Rain', 0.6);
    expect(appState.getTrackVolume('Soft Rain'), 0.6);
    expect(appState.isAnyAudioPlaying, true);

    // Stop all audio
    await appState.stopAllAudio();
    expect(appState.isAnyAudioPlaying, false);
  });

  testWidgets('Test 4: Sleep auto-fade timer start and cancel', (WidgetTester tester) async {
    final appState = AppState();
    await appState.init();

    appState.startSleepTimer(15);
    expect(appState.isSleepTimerRunning, true);
    expect(appState.sleepTimerRemainingSec, 15 * 60);

    appState.cancelSleepTimer();
    expect(appState.isSleepTimerRunning, false);
    expect(appState.sleepTimerRemainingSec, null);
  });

  testWidgets('Test 5: Onboarding gate and Skip button works as expected', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': false});
    final appState = AppState();
    await appState.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const SanctuaryApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Master Your Mind\nwith Ease'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Skip to complete onboarding
    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(appState.onboardingDone, true);
  });
}
