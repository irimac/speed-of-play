import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/services/history_repository.dart';
import 'package:speed_of_play/services/storage.dart';
import 'package:speed_of_play/ui/end_screen.dart';
import 'package:speed_of_play/ui/history_screen.dart';
import 'package:speed_of_play/ui/main_screen.dart';

void main() {
  testWidgets('summary screen renders key stats', (tester) async {
    final result = _buildResult();
    await tester.pumpWidget(_buildApp(result));

    expect(find.text('Session Summary'), findsOneWidget);
    expect(find.text('Rounds Completed'), findsOneWidget);
    expect(find.text('Total Time'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('Save to History'), findsOneWidget);
    expect(find.text('Back to Main'), findsOneWidget);
  });

  testWidgets('save to history navigates to history screen', (tester) async {
    final repo = _FakeHistoryRepository();
    await tester.pumpWidget(_buildApp(_buildResult(), repo: repo));

    final saveFinder = find.text('Save to History');
    await tester.ensureVisible(saveFinder);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();

    expect(repo.saved, isNotNull);
    expect(find.text('History Screen'), findsOneWidget);
  });

  testWidgets('back to main navigates to main screen', (tester) async {
    await tester.pumpWidget(_buildApp(_buildResult()));

    final backFinder = find.text('Back to Main');
    await tester.ensureVisible(backFinder);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();

    expect(find.text('Main Screen'), findsOneWidget);
  });
}

Widget _buildApp(SessionResult result, {SessionHistoryRepository? repo}) {
  return Provider<SessionHistoryRepository>.value(
    value: repo ?? _FakeHistoryRepository(),
    child: MaterialApp(
      home: EndScreen(result: result),
      onGenerateRoute: (settings) {
        if (settings.name == HistoryScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('History Screen')),
            ),
          );
        }
        if (settings.name == MainScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Main Screen')),
            ),
          );
        }
        return null;
      },
    ),
  );
}

SessionResult _buildResult() {
  return SessionResult(
    completedAt: DateTime(2025, 1, 5, 12, 30),
    presetSnapshot: SessionPreset.defaults(),
    roundsCompleted: 3,
    perRoundDurationsSec: const [60, 60, 60],
    totalElapsedSec: 180,
    stimuli: const [],
  );
}

class _FakeHistoryRepository extends SessionHistoryRepository {
  _FakeHistoryRepository() : super(LocalFileStorage());

  SessionResult? saved;

  @override
  Future<void> saveResult(SessionResult result) async {
    saved = result;
  }
}
