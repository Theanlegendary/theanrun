import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/main.dart';
import 'package:relax_mindfulness/providers/app_state.dart';

void main() {
  testWidgets('Sanctuary app smoke test', (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const SanctuaryApp(),
      ),
    );

    expect(find.byType(SanctuaryApp), findsOneWidget);
  });
}
