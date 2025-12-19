import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/services/history_repository.dart';
import 'package:speed_of_play/services/storage.dart';
import 'package:speed_of_play/ui/history_screen.dart';
import 'package:speed_of_play/ui/main_screen.dart';

void main() {
  testWidgets('history screen renders list rows', (tester) async {
    final repo = _FakeHistoryRepository([_sampleResult()]);
    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('2025-01-05 09:45'), findsOneWidget);
    expect(find.textContaining('Rounds: 3/5'), findsOneWidget);
    expect(find.textContaining('Total: 03:00'), findsOneWidget);
    expect(find.textContaining('Palette:'), findsOneWidget);
  });

  testWidgets('history screen empty state renders', (tester) async {
    final repo = _FakeHistoryRepository(const []);
    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    expect(find.text('No sessions yet.'), findsOneWidget);
    expect(find.text('Back to Main'), findsOneWidget);
  });
}

Widget _buildApp(SessionHistoryRepository repo) {
  return Provider<SessionHistoryRepository>.value(
    value: repo,
    child: MaterialApp(
      home: const HistoryScreen(),
      onGenerateRoute: (settings) {
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

SessionResult _sampleResult() {
  return SessionResult(
    completedAt: DateTime(2025, 1, 5, 9, 45),
    presetSnapshot: SessionPreset.defaults().copyWith(rounds: 5),
    roundsCompleted: 3,
    perRoundDurationsSec: const [60, 60, 60],
    totalElapsedSec: 180,
    stimuli: const [],
  );
}

class _FakeHistoryRepository extends SessionHistoryRepository {
  _FakeHistoryRepository(this._sessions) : super(LocalFileStorage());

  final List<SessionResult> _sessions;

  @override
  Future<List<SessionResult>> loadHistory() async {
    return _sessions;
  }

  @override
  Future<void> deleteByIds(Set<String> ids) async {}

  @override
  Future<File> exportCsv(List<SessionResult> sessions) async {
    return File('fake.csv');
  }
}
