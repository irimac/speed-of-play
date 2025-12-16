import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

class LocalFileStorage {
  Future<File> file(String relativePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$relativePath');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }
}

class PresetStore {
  PresetStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'sessionPreset';

  SessionPreset get currentPreset {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return SessionPreset.defaults();
    }
    return SessionPreset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(SessionPreset preset) async {
    await _prefs.setString(_key, jsonEncode(preset.toJson()));
  }
}
