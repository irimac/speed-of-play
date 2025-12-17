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
  static const _bgLight = Color(0xFFF5F5F5);
  static const _card = Colors.white;
  static const _textDark = Color(0xFF111111);
  static const _accent = Color(0xFF2E8E43);

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
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text(
              'Save',
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section(
              title: 'Session',
              children: [
                _numberField(
                  label: 'Rounds',
                  initialValue: _preset.rounds,
                  min: 1,
                  max: 20,
                  onChanged: (value) => _updatePreset(_preset.copyWith(rounds: value)),
                ),
                _numberField(
                  label: 'Round duration (sec)',
                  initialValue: _preset.roundDurationSec,
                  min: 15,
                  max: 180,
                  onChanged: (value) => _updatePreset(_preset.copyWith(roundDurationSec: value)),
                ),
                _numberField(
                  label: 'Rest duration (sec)',
                  initialValue: _preset.restDurationSec,
                  min: 0,
                  max: 120,
                  onChanged: (value) => _updatePreset(_preset.copyWith(restDurationSec: value)),
                ),
                _numberField(
                  label: 'Change interval (sec)',
                  initialValue: _preset.changeIntervalSec,
                  min: 1,
                  max: 5,
                  onChanged: (value) => _updatePreset(_preset.copyWith(changeIntervalSec: value)),
                ),
              ],
            ),
            _section(
              title: 'Display',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        label: 'Number min',
                        initialValue: _preset.numberMin,
                        min: 0,
                        max: _preset.numberMax - 1,
                        onChanged: (value) => _updatePreset(_preset.copyWith(numberMin: value)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        label: 'Number max',
                        initialValue: _preset.numberMax,
                        min: _preset.numberMin + 1,
                        max: 99,
                        onChanged: (value) => _updatePreset(_preset.copyWith(numberMax: value)),
                      ),
                    ),
                  ],
                ),
                _palettePicker(),
                _colorSelector(),
                _switchRow(
                  label: 'Outdoor brightness boost',
                  value: _preset.outdoorBoost,
                  onChanged: (value) => _updatePreset(_preset.copyWith(outdoorBoost: value)),
                ),
              ],
            ),
            _section(
              title: 'Timing',
              children: [
                _switchRow(
                  label: 'Show countdown',
                  value: _showCountdown,
                  onChanged: (value) {
                    setState(() => _showCountdown = value);
                    _updatePreset(
                      _preset.copyWith(countdownSec: value ? (_preset.countdownSec == 0 ? 5 : _preset.countdownSec) : 0),
                    );
                  },
                ),
                if (_showCountdown)
                  _numberField(
                    label: 'Countdown seconds',
                    initialValue: _preset.countdownSec,
                    min: 1,
                    max: 10,
                    onChanged: (value) => _updatePreset(_preset.copyWith(countdownSec: value)),
                  ),
              ],
            ),
            _section(
              title: 'Advanced',
              children: [
                _switchRow(
                  label: 'Lock RNG seed (QA)',
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
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              onPressed: _saveAndExit,
              child: const Text('Save & Close'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _palettePicker() {
    final items = Palette.palettes.values.toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _preset.paletteId,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          iconEnabledColor: _textDark,
          style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 16),
          items: items
              .map(
                (palette) => DropdownMenuItem(
                  value: palette.id,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: palette.colors.take(3).toList(),
                          ),
                        ),
                      ),
                      Text(palette.label),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            _updatePreset(
              _preset.copyWith(
                paletteId: value,
                activeColorIds: null, // reset selection when palette changes
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _switchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: _accent,
            onChanged: onChanged,
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
    final canDec = initialValue > min;
    final canInc = initialValue < max;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _roundButton(
            icon: Icons.remove,
            enabled: canDec,
            onPressed: canDec ? () => onChanged(initialValue - 1) : null,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final value = await _promptNumberInput(
                label: label,
                initialValue: initialValue,
                min: min,
                max: max,
              );
              if (value != null && value != initialValue) {
                onChanged(value);
              }
            },
            child: SizedBox(
              width: 64,
              child: Center(
                child: Text(
                  '$initialValue',
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          _roundButton(
            icon: Icons.add,
            enabled: canInc,
            onPressed: canInc ? () => onChanged(initialValue + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: enabled ? _textDark : Colors.grey.shade500, width: 2),
          ),
          child: Icon(
            icon,
            color: enabled ? _textDark : Colors.grey.shade700,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _colorSelector() {
    final palette = Palette.resolve(_preset.paletteId);
    final active = (_preset.activeColorIds ?? [])
        .map((e) => e.toLowerCase())
        .toSet();
    final allColors = palette.colors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Text(
              'Active colors',
              style: TextStyle(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: allColors.map((color) {
              final id = color.toARGB32().toRadixString(16).toLowerCase();
              final selected = active.isEmpty || active.contains(id);
              return GestureDetector(
                onTap: () {
                  final current = _preset.activeColorIds?.toSet() ?? <String>{};
                  if (selected && current.isNotEmpty) {
                    current.remove(id);
                  } else {
                    current.add(id);
                  }
                  final next = current.isEmpty ? null : current.toList();
                  _updatePreset(_preset.copyWith(activeColorIds: next));
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.black54,
                      width: 3,
                    ),
                    boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 31), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Toggle to include/exclude colors for stimuli.',
              style: TextStyle(color: _textDark, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _promptNumberInput({
    required String label,
    required int initialValue,
    required int min,
    required int max,
  }) async {
    final controller = TextEditingController(text: initialValue.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter value',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null) {
                  Navigator.of(ctx).pop();
                  return;
                }
                final clamped = parsed.clamp(min, max);
                Navigator.of(ctx).pop(clamped);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
    return result;
  }
}
