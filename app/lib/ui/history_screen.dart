import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/history_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<SessionResult>> _future;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _future = _loadHistory();
  }

  Future<List<SessionResult>> _loadHistory() {
    final repo = context.read<SessionHistoryRepository>();
    return repo.loadHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<SessionResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No saved sessions yet.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final selected = _selectedIds.contains(session.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          if (selected) {
                            _selectedIds.remove(session.id);
                          } else {
                            _selectedIds.add(session.id);
                          }
                        });
                      },
                      title: Text(
                        '${session.completedAt.toLocal()}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        '${session.roundsCompleted} rounds | ${session.totalElapsedSec}s | ${session.presetSnapshot.paletteId}',
                      ),
                    );
                  },
                ),
              ),
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Selected'),
                          onPressed: () async {
                            final repo =
                                context.read<SessionHistoryRepository>();
                            await repo.deleteByIds(_selectedIds);
                            if (!mounted) return;
                            setState(() => _selectedIds.clear());
                            await _refresh();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Export CSV'),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final repo =
                                context.read<SessionHistoryRepository>();
                            final all = await repo.loadHistory();
                            final sessions = all
                                .where((s) => _selectedIds.contains(s.id))
                                .toList();
                            if (sessions.isEmpty) return;
                            final file = await repo.exportCsv(sessions);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                  content: Text('CSV saved to ${file.path}')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
