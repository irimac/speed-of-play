import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/ui/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders settings section headers', (tester) async {
    await tester.pumpWidget(_buildSettingsApp());

    expect(find.text('Session'), findsOneWidget);
    expect(find.text('Display'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Timing'), 300);
    expect(find.text('Timing'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Advanced'), 300);
    expect(find.text('Advanced'), findsOneWidget);
  });

  testWidgets('number stepper increments and decrements within bounds',
      (tester) async {
    final preset = SessionPreset.defaults().copyWith(rounds: 2);
    await tester.pumpWidget(_buildSettingsApp(preset: preset));

    expect(_valueText(tester, 'settings-rounds-value'), '2');

    await tester.tap(find.byKey(const ValueKey('settings-rounds-inc')));
    await tester.pump();
    expect(_valueText(tester, 'settings-rounds-value'), '3');

    await tester.tap(find.byKey(const ValueKey('settings-rounds-dec')));
    await tester.pump();
    expect(_valueText(tester, 'settings-rounds-value'), '2');

    await tester.tap(find.byKey(const ValueKey('settings-rounds-dec')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-rounds-dec')));
    await tester.pump();
    expect(_valueText(tester, 'settings-rounds-value'), '1');
  });

  testWidgets('countdown switch toggles countdown seconds row', (tester) async {
    await tester.pumpWidget(_buildSettingsApp());

    await tester.scrollUntilVisible(find.text('Timing'), 300);
    expect(find.text('Countdown seconds'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('settings-countdown-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-countdown-toggle')));
    await tester.pump();
    expect(find.text('Countdown seconds'), findsNothing);
  });

  testWidgets('save action pops back to host', (tester) async {
    await tester.pumpWidget(_buildHostApp());

    await tester.tap(find.byKey(const ValueKey('open-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);
  });

  testWidgets('save and close button pops back to host', (tester) async {
    await tester.pumpWidget(_buildHostApp());

    await tester.tap(find.byKey(const ValueKey('open-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Save & Close'), 300);
    expect(find.text('Save & Close'), findsOneWidget);

    await tester.tap(find.text('Save & Close'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);
  });
}

Widget _buildSettingsApp({SessionPreset? preset}) {
  return MaterialApp(
    home: SettingsScreen(
      preset: preset ?? SessionPreset.defaults(),
      onPresetChanged: (_) {},
    ),
  );
}

Widget _buildHostApp() {
  return MaterialApp(
    home: _SettingsHost(
      preset: SessionPreset.defaults(),
    ),
  );
}

class _SettingsHost extends StatelessWidget {
  const _SettingsHost({required this.preset});

  final SessionPreset preset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const ValueKey('open-settings'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  preset: preset,
                  onPresetChanged: (_) {},
                ),
              ),
            );
          },
          child: const Text('Open Settings'),
        ),
      ),
    );
  }
}

String _valueText(WidgetTester tester, String key) {
  final valueFinder = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(Text),
  );
  return tester.widget<Text>(valueFinder).data ?? '';
}
