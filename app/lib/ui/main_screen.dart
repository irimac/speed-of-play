import 'package:flutter/material.dart';

import '../data/models.dart';
import 'history_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.preset,
    required this.onPresetChanged,
  });

  static const routeName = '/main';

  final SessionPreset preset;
  final ValueChanged<SessionPreset> onPresetChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late SessionPreset _preset;

  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preset != widget.preset) {
      _preset = widget.preset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.resolve(_preset.paletteId);
    return Scaffold(
      appBar: AppBar(title: const Text('SpeedOfPlay')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 640;
            final summaryCard = _SummaryCard(preset: _preset, palette: palette);
            final actions = _Actions(
              onPlay: () => Navigator.of(context).pushNamed(
                SessionScreen.routeName,
                arguments: _preset,
              ),
              onSettings: _openSettings,
              onHistory: () {
                Navigator.of(context).pushNamed(HistoryScreen.routeName);
              },
            );
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: summaryCard),
                  Expanded(child: actions),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                summaryCard,
                const SizedBox(height: 24),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    final updated = await Navigator.of(context).push<SessionPreset>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SettingsScreen(
          preset: _preset,
          onPresetChanged: (preset) {
            widget.onPresetChanged(preset);
            setState(() => _preset = preset);
          },
        ),
      ),
    );
    if (updated != null) {
      widget.onPresetChanged(updated);
      setState(() => _preset = updated);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.preset, required this.palette});

  final SessionPreset preset;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Preset', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(label: 'Rounds', value: '${preset.rounds} x ${preset.roundDurationSec}s'),
            _InfoRow(label: 'Rest', value: '${preset.restDurationSec}s'),
            _InfoRow(label: 'Change every', value: '${preset.changeIntervalSec}s'),
            _InfoRow(label: 'Numbers', value: '${preset.numberMin}-${preset.numberMax}'),
            _InfoRow(label: 'Countdown', value: '${preset.countdownSec}s'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: palette.colors
                  .map(
                    (color) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onPlay,
    required this.onSettings,
    required this.onHistory,
  });

  final VoidCallback onPlay;
  final VoidCallback onSettings;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onPlay,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onSettings,
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onHistory,
          icon: const Icon(Icons.history),
          label: const Text('History'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


