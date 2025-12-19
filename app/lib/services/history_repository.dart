import 'dart:convert';
import 'dart:io';

import '../data/models.dart';
import 'storage.dart';

class SessionHistoryRepository {
  SessionHistoryRepository(this._storage);

  final LocalFileStorage _storage;
  static const _historyFile = 'history.json';

  Future<List<SessionResult>> loadHistory() async {
    final file = await _storage.file(_historyFile);
    if (!file.existsSync() || file.readAsStringSync().isEmpty) {
      return [];
    }
    final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
    return raw
        .map((e) => SessionResult.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> saveResult(SessionResult result) async {
    final history = await loadHistory();
    history.insert(0, result);
    await _write(history);
  }

  Future<void> deleteByIds(Set<String> ids) async {
    final history = await loadHistory();
    history.removeWhere((element) => ids.contains(element.id));
    await _write(history);
  }

  Future<File> exportCsv(List<SessionResult> sessions) async {
    final file = await _storage
        .file('exports/history_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(sessions.toCsv());
    return file;
  }

  Future<void> _write(List<SessionResult> history) async {
    final file = await _storage.file(_historyFile);
    final tmpFile = File('${file.path}.tmp');
    await tmpFile.writeAsString(
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
    await tmpFile.rename(file.path);
  }
}
