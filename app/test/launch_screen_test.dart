import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speed_of_play/app.dart';
import 'package:speed_of_play/services/history_repository.dart';
import 'package:speed_of_play/services/storage.dart';
import 'package:speed_of_play/ui/launch_screen.dart';
import 'package:speed_of_play/ui/main_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppBootstrapData> buildBootstrapData() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final presetStore = PresetStore(prefs);
    final historyRepo = SessionHistoryRepository(_FakeLocalFileStorage());
    return AppBootstrapData(
      historyRepository: historyRepo,
      presetStore: presetStore,
    );
  }

  Widget buildApp() {
    return SpeedOfPlayBootstrapApp(
      bootstrapper: buildBootstrapData,
    );
  }

  testWidgets('LaunchScreen is visible initially', (tester) async {
    await tester.pumpWidget(buildApp());
    expect(find.byType(LaunchScreen), findsOneWidget);
    await tester.pump(kMinLaunchDisplayDuration);
    await tester.pump();
  });

  testWidgets('LaunchScreen not replaced before minimum duration',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 2, milliseconds: 900));
    expect(find.byType(LaunchScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
    await tester.pump(kMinLaunchDisplayDuration);
    await tester.pump();
  });

  testWidgets('LaunchScreen replaced after minimum duration when init done',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(kMinLaunchDisplayDuration);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(LaunchScreen), findsNothing);
    expect(find.byType(MainScreen), findsOneWidget);
  });
}

class _FakeLocalFileStorage extends LocalFileStorage {
  late final Directory _tempDir =
      Directory.systemTemp.createTempSync('speed_of_play_test');

  @override
  Future<File> file(String relativePath) async {
    final file = File('${_tempDir.path}/$relativePath');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }
}
