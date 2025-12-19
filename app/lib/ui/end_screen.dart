import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/history_repository.dart';
import 'history_screen.dart';
import 'main_screen.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.result});

  static const routeName = '/end';

  final SessionResult? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Great work!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (result != null) ...[
              _SummaryRow(label: 'Rounds', value: '${result!.roundsCompleted}'),
              _SummaryRow(
                  label: 'Total Time', value: '${result!.totalElapsedSec}s'),
              _SummaryRow(
                label: 'Palette',
                value: result!.presetSnapshot.paletteId,
              ),
              const SizedBox(height: 16),
              const Text('Per Round Durations'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: result!.perRoundDurationsSec.length,
                  itemBuilder: (context, index) {
                    final duration = result!.perRoundDurationsSec[index];
                    return ListTile(
                      title: Text('Round ${index + 1}'),
                      trailing: Text('${duration}s'),
                    );
                  },
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text('No data captured.'),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: result == null
                  ? null
                  : () async {
                      final repo = context.read<SessionHistoryRepository>();
                      await repo.saveResult(result!);
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed(HistoryScreen.routeName);
                      }
                    },
              child: const Text('Save to History'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName,
                  (route) => false,
                );
              },
              child: const Text('End to Main'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
