import 'package:flutter/material.dart';

import '../data/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.preset,
    required this.onPresetChanged,
  });

  static const routeName = '/settings';

  final SessionPreset preset;
  final ValueChanged<SessionPreset> onPresetChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SessionPreset _preset;
  bool _showCountdown = true;
  bool _useSeed = false;

  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
    _showCountdown = _preset.countdownSec > 0;
    _useSeed = _preset.rngSeed != null;
  }

  void _updatePreset(SessionPreset preset) {
    setState(() {
      _preset = preset;
    });
    widget.onPresetChanged(preset);
  }

  void _saveAndExit() {
    Navigator.of(context).pop(_preset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text('Save'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _numberField(
            label: 'Rounds',
            initialValue: _preset.rounds,
            min: 1,
            max: 20,
            onChanged: (value) => _updatePreset(_preset.copyWith(rounds: value)),
          ),
          _numberField(
            label: 'Round Duration (sec)',
            initialValue: _preset.roundDurationSec,
            min: 15,
            max: 180,
            onChanged: (value) => _updatePreset(_preset.copyWith(roundDurationSec: value)),
          ),
          _numberField(
            label: 'Rest Duration (sec)',
            initialValue: _preset.restDurationSec,
            min: 0,
            max: 120,
            onChanged: (value) => _updatePreset(_preset.copyWith(restDurationSec: value)),
          ),
          _numberField(
            label: 'Change Interval (sec)',
            initialValue: _preset.changeIntervalSec,
            min: 1,
            max: 5,
            onChanged: (value) => _updatePreset(_preset.copyWith(changeIntervalSec: value)),
          ),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Number Min',
                  initialValue: _preset.numberMin,
                  min: 0,
                  max: _preset.numberMax - 1,
                  onChanged: (value) => _updatePreset(_preset.copyWith(numberMin: value)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  label: 'Number Max',
                  initialValue: _preset.numberMax,
                  min: _preset.numberMin + 1,
                  max: 99,
                  onChanged: (value) => _updatePreset(_preset.copyWith(numberMax: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _preset.paletteId,
            decoration: const InputDecoration(labelText: 'Palette'),
            items: Palette.palettes.values
                .map(
                  (palette) => DropdownMenuItem(
                    value: palette.id,
                    child: Text(palette.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              _updatePreset(_preset.copyWith(paletteId: value));
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Outdoor brightness boost'),
            value: _preset.outdoorBoost,
            onChanged: (value) => _updatePreset(_preset.copyWith(outdoorBoost: value)),
          ),
          SwitchListTile(
            title: const Text('Large session text'),
            value: _preset.largeSessionText,
            onChanged: (value) => _updatePreset(_preset.copyWith(largeSessionText: value)),
          ),
          SwitchListTile(
            title: const Text('High contrast palette'),
            value: _preset.highContrastPalette,
            onChanged: (value) => _updatePreset(_preset.copyWith(highContrastPalette: value)),
          ),
          SwitchListTile(
            title: const Text('Audio enabled'),
            value: _preset.audioEnabled,
            onChanged: (value) => _updatePreset(_preset.copyWith(audioEnabled: value)),
          ),
          SwitchListTile(
            title: const Text('Countdown'),
            value: _showCountdown,
            onChanged: (value) {
              setState(() => _showCountdown = value);
              _updatePreset(_preset.copyWith(countdownSec: value ? (_preset.countdownSec == 0 ? 5 : _preset.countdownSec) : 0));
            },
          ),
          if (_showCountdown)
            _numberField(
              label: 'Countdown Seconds',
              initialValue: _preset.countdownSec,
              min: 1,
              max: 10,
              onChanged: (value) => _updatePreset(_preset.copyWith(countdownSec: value)),
            ),
          SwitchListTile(
            title: const Text('Lock RNG seed (QA)'),
            value: _useSeed,
            onChanged: (value) {
              setState(() => _useSeed = value);
              _updatePreset(_preset.copyWith(rngSeed: value ? (_preset.rngSeed ?? 42) : null));
            },
          ),
          if (_useSeed)
            _numberField(
              label: 'Seed',
              initialValue: _preset.rngSeed ?? 42,
              min: 0,
              max: 1 << 31,
              onChanged: (value) => _updatePreset(_preset.copyWith(rngSeed: value)),
            ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required int initialValue,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: 'Decrease',
            onPressed: initialValue > min
                ? () => onChanged(initialValue - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 64,
            child: Center(child: Text('$initialValue')),
          ),
          IconButton(
            tooltip: 'Increase',
            onPressed: initialValue < max
                ? () => onChanged(initialValue + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
