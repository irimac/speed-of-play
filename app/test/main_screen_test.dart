import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/ui/history_screen.dart';
import 'package:speed_of_play/ui/main_screen.dart';
import 'package:speed_of_play/ui/session_screen.dart';
import 'package:speed_of_play/ui/settings_screen.dart';

void main() {
  testWidgets('main screen renders primary and secondary actions',
      (tester) async {
    await tester.pumpWidget(_buildApp());

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('play navigates to session route', (tester) async {
    await tester.pumpWidget(_buildApp());

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Session Screen'), findsOneWidget);
  });

  testWidgets('settings opens settings screen', (tester) async {
    await tester.pumpWidget(_buildApp());

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}

Widget _buildApp() {
  return MaterialApp(
    home: MainScreen(
      preset: SessionPreset.defaults(),
      onPresetChanged: (_) {},
    ),
    onGenerateRoute: (settings) {
      if (settings.name == SessionScreen.routeName) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Session Screen')),
          ),
        );
      }
      if (settings.name == HistoryScreen.routeName) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('History Screen')),
          ),
        );
      }
      return null;
    },
  );
}
