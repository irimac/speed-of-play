import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/history_repository.dart';
import 'services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final presetStore = PresetStore(prefs);
  final historyRepo = SessionHistoryRepository(LocalFileStorage());

  runApp(
    SpeedOfPlayApp(
      historyRepository: historyRepo,
      presetStore: presetStore,
    ),
  );
}
