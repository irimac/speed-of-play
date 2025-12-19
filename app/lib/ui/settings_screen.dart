import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import 'components/app_header.dart';
import 'styles/settings_styles.dart';

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
  static const String _basicPaletteId = 'basic';

  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
    _showCountdown = _preset.countdownSec > 0;
    _useSeed = _preset.rngSeed != null;
    if (_preset.paletteId != _basicPaletteId) {
      _preset = _preset.copyWith(
        paletteId: _basicPaletteId,
        activeColorIds: null,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPresetChanged(_preset);
      });
    }
  }

  void _updatePreset(SessionPreset preset) {
    setState(() {
      _preset = preset;
    });
    widget.onPresetChanged(preset);
  }

  @override
  Widget build(BuildContext context) {
    final styles = SettingsStyles.defaults(Theme.of(context));
    return Scaffold(
      backgroundColor: styles.backgroundColor,
      appBar: AppHeader(
        title: 'Settings',
        titleColor: styles.textColor,
        actionColor: styles.accentColor,
        backgroundColor: styles.backgroundColor,
        leadingAction: AppHeaderAction(
          label: 'Done',
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: styles.screenPadding,
          children: [
            SettingsSection(
              title: 'Session',
              styles: styles,
              children: [
                SettingsNumberStepperRow(
                  label: 'Rounds',
                  value: _preset.rounds,
                  min: 1,
                  max: 20,
                  styles: styles,
                  valueKeyPrefix: 'rounds',
                  onChanged: (value) =>
                      _updatePreset(_preset.copyWith(rounds: value)),
                  onValueTap: () => _promptAndApplyValue(
                    label: 'Rounds',
                    value: _preset.rounds,
                    min: 1,
                    max: 20,
                    onChanged: (next) =>
                        _updatePreset(_preset.copyWith(rounds: next)),
                  ),
                ),
                SettingsNumberStepperRow(
                  label: 'Round duration (sec)',
                  value: _preset.roundDurationSec,
                  min: 15,
                  max: 180,
                  styles: styles,
                  onChanged: (value) => _updatePreset(
                    _preset.copyWith(roundDurationSec: value),
                  ),
                  onValueTap: () => _promptAndApplyValue(
                    label: 'Round duration (sec)',
                    value: _preset.roundDurationSec,
                    min: 15,
                    max: 180,
                    onChanged: (next) => _updatePreset(
                      _preset.copyWith(roundDurationSec: next),
                    ),
                  ),
                ),
                SettingsNumberStepperRow(
                  label: 'Rest duration (sec)',
                  value: _preset.restDurationSec,
                  min: 0,
                  max: 120,
                  styles: styles,
                  onChanged: (value) => _updatePreset(
                    _preset.copyWith(restDurationSec: value),
                  ),
                  onValueTap: () => _promptAndApplyValue(
                    label: 'Rest duration (sec)',
                    value: _preset.restDurationSec,
                    min: 0,
                    max: 120,
                    onChanged: (next) => _updatePreset(
                      _preset.copyWith(restDurationSec: next),
                    ),
                  ),
                ),
                SettingsNumberStepperRow(
                  label: 'Change interval (sec)',
                  value: _preset.changeIntervalSec,
                  min: 1,
                  max: 5,
                  styles: styles,
                  onChanged: (value) => _updatePreset(
                    _preset.copyWith(changeIntervalSec: value),
                  ),
                  onValueTap: () => _promptAndApplyValue(
                    label: 'Change interval (sec)',
                    value: _preset.changeIntervalSec,
                    min: 1,
                    max: 5,
                    onChanged: (next) => _updatePreset(
                      _preset.copyWith(changeIntervalSec: next),
                    ),
                  ),
                ),
                SettingsSwitchRow(
                  label: 'Audio enabled',
                  value: _preset.audioEnabled,
                  styles: styles,
                  onChanged: (value) =>
                      _updatePreset(_preset.copyWith(audioEnabled: value)),
                ),
              ],
            ),
            SettingsSection(
              title: 'Display',
              styles: styles,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SettingsNumberStepperRow(
                        label: 'Number min',
                        value: _preset.numberMin,
                        min: 0,
                        max: _preset.numberMax - 1,
                        styles: styles,
                        onChanged: (value) => _updatePreset(
                          _preset.copyWith(numberMin: value),
                        ),
                        onValueTap: () => _promptAndApplyValue(
                          label: 'Number min',
                          value: _preset.numberMin,
                          min: 0,
                          max: _preset.numberMax - 1,
                          onChanged: (next) => _updatePreset(
                            _preset.copyWith(numberMin: next),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SettingsNumberStepperRow(
                        label: 'Number max',
                        value: _preset.numberMax,
                        min: _preset.numberMin + 1,
                        max: 99,
                        styles: styles,
                        onChanged: (value) => _updatePreset(
                          _preset.copyWith(numberMax: value),
                        ),
                        onValueTap: () => _promptAndApplyValue(
                          label: 'Number max',
                          value: _preset.numberMax,
                          min: _preset.numberMin + 1,
                          max: 99,
                          onChanged: (next) => _updatePreset(
                            _preset.copyWith(numberMax: next),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SettingsActiveColorsSelector(
                  styles: styles,
                  palette: Palette.resolveWithContrast(
                    _basicPaletteId,
                    highContrast: _preset.highContrastPalette,
                  ),
                  activeColorIds: _preset.activeColorIds,
                  highContrastEnabled: _preset.highContrastPalette,
                  onHighContrastChanged: (value) => _updatePreset(
                    _preset.copyWith(
                      highContrastPalette: value,
                      activeColorIds: null,
                    ),
                  ),
                  onChanged: (value) => _updatePreset(
                    _preset.copyWith(
                      paletteId: _basicPaletteId,
                      activeColorIds: value,
                    ),
                  ),
                ),
                SettingsSwitchRow(
                  label: 'Outdoor brightness boost',
                  value: _preset.outdoorBoost,
                  styles: styles,
                  onChanged: (value) =>
                      _updatePreset(_preset.copyWith(outdoorBoost: value)),
                ),
                SettingsSwitchRow(
                  label: 'Large session text',
                  value: _preset.largeSessionText,
                  styles: styles,
                  onChanged: (value) => _updatePreset(
                    _preset.copyWith(largeSessionText: value),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: 'Timing',
              styles: styles,
              children: [
                SettingsSwitchRow(
                  label: 'Show countdown',
                  value: _showCountdown,
                  styles: styles,
                  switchKey: const ValueKey('settings-countdown-toggle'),
                  onChanged: (value) {
                    setState(() => _showCountdown = value);
                    _updatePreset(
                      _preset.copyWith(
                        countdownSec: value
                            ? (_preset.countdownSec == 0
                                ? 5
                                : _preset.countdownSec)
                            : 0,
                      ),
                    );
                  },
                ),
                if (_showCountdown)
                  SettingsNumberStepperRow(
                    label: 'Countdown seconds',
                    value: _preset.countdownSec,
                    min: 1,
                    max: 10,
                    styles: styles,
                    onChanged: (value) => _updatePreset(
                      _preset.copyWith(countdownSec: value),
                    ),
                    onValueTap: () => _promptAndApplyValue(
                      label: 'Countdown seconds',
                      value: _preset.countdownSec,
                      min: 1,
                      max: 10,
                      onChanged: (next) => _updatePreset(
                        _preset.copyWith(countdownSec: next),
                      ),
                    ),
                  ),
              ],
            ),
            SettingsSection(
              title: 'Advanced',
              styles: styles,
              children: [
                SettingsSwitchRow(
                  label: 'Lock RNG seed (QA)',
                  value: _useSeed,
                  styles: styles,
                  onChanged: (value) {
                    setState(() => _useSeed = value);
                    _updatePreset(
                      _preset.copyWith(
                        rngSeed: value ? (_preset.rngSeed ?? 42) : null,
                      ),
                    );
                  },
                ),
                if (_useSeed)
                  SettingsNumberStepperRow(
                    label: 'Seed',
                    value: _preset.rngSeed ?? 42,
                    min: 0,
                    max: 1 << 31,
                    styles: styles,
                    onChanged: (value) =>
                        _updatePreset(_preset.copyWith(rngSeed: value)),
                    onValueTap: () => _promptAndApplyValue(
                      label: 'Seed',
                      value: _preset.rngSeed ?? 42,
                      min: 0,
                      max: 1 << 31,
                      onChanged: (next) =>
                          _updatePreset(_preset.copyWith(rngSeed: next)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _promptAndApplyValue({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) async {
    final next = await _promptNumberInput(
      label: label,
      initialValue: value,
      min: min,
      max: max,
    );
    if (next != null && next != value) {
      onChanged(next);
    }
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.styles,
    required this.children,
  });

  final String title;
  final SettingsStyles styles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: styles.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(title, style: styles.sectionTitleStyle),
          ),
          ..._intersperse(
            children,
            SizedBox(height: styles.cardSpacing),
          ),
        ],
      ),
    );
  }
}

class SettingsCardRow extends StatelessWidget {
  const SettingsCardRow({
    super.key,
    required this.styles,
    required this.child,
  });

  final SettingsStyles styles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: styles.cardPadding,
      decoration: BoxDecoration(
        color: styles.cardColor,
        borderRadius: BorderRadius.circular(styles.cardRadius),
        boxShadow: styles.cardShadows,
      ),
      child: DefaultTextStyle.merge(
        style: styles.rowLabelStyle,
        child: child,
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.styles,
    required this.onChanged,
    this.switchKey,
  });

  final String label;
  final bool value;
  final SettingsStyles styles;
  final ValueChanged<bool> onChanged;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return SettingsCardRow(
      styles: styles,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: styles.rowLabelStyle),
          ),
          Switch.adaptive(
            key: switchKey,
            value: value,
            activeThumbColor: styles.accentColor,
            activeTrackColor: styles.accentColor.withAlpha(180),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class SettingsNumberStepperRow extends StatelessWidget {
  const SettingsNumberStepperRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.styles,
    required this.onChanged,
    required this.onValueTap,
    this.valueKeyPrefix,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final SettingsStyles styles;
  final ValueChanged<int> onChanged;
  final VoidCallback onValueTap;
  final String? valueKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final canDec = value > min;
    final canInc = value < max;
    return SettingsCardRow(
      styles: styles,
      child: Row(
        children: [
          Expanded(child: Text(label, style: styles.rowLabelStyle)),
          _StepperButton(
            icon: Icons.remove,
            enabled: canDec,
            styles: styles,
            buttonKey: valueKeyPrefix == null
                ? null
                : ValueKey('settings-$valueKeyPrefix-dec'),
            onPressed: canDec ? () => onChanged(value - 1) : null,
          ),
          InkWell(
            onTap: onValueTap,
            borderRadius: BorderRadius.circular(styles.valueTapRadius),
            child: SizedBox(
              key: valueKeyPrefix == null
                  ? null
                  : ValueKey('settings-$valueKeyPrefix-value'),
              width: styles.valueWidth,
              child: Center(
                child: Text('$value', style: styles.rowValueStyle),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            enabled: canInc,
            styles: styles,
            buttonKey: valueKeyPrefix == null
                ? null
                : ValueKey('settings-$valueKeyPrefix-inc'),
            onPressed: canInc ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.styles,
    required this.onPressed,
    this.buttonKey,
  });

  final IconData icon;
  final bool enabled;
  final SettingsStyles styles;
  final VoidCallback? onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final borderColor = enabled ? styles.textColor : styles.mutedTextColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(styles.stepperButtonRadius),
      side: BorderSide(color: borderColor, width: 2),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: styles.cardColor,
        shape: shape,
        child: InkWell(
          key: buttonKey,
          onTap: enabled ? onPressed : null,
          customBorder: shape,
          child: SizedBox(
            width: styles.stepperButtonSize,
            height: styles.stepperButtonSize,
            child: Icon(
              icon,
              color: borderColor,
              size: styles.stepperIconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsActiveColorsSelector extends StatelessWidget {
  const SettingsActiveColorsSelector({
    super.key,
    required this.styles,
    required this.palette,
    required this.activeColorIds,
    required this.onChanged,
    required this.highContrastEnabled,
    required this.onHighContrastChanged,
  });

  final SettingsStyles styles;
  final Palette palette;
  final List<String>? activeColorIds;
  final ValueChanged<List<String>?> onChanged;
  final bool highContrastEnabled;
  final ValueChanged<bool> onHighContrastChanged;

  @override
  Widget build(BuildContext context) {
    final allIds = palette.colors.map((color) => _colorId(color)).toList();
    final activeSet =
        activeColorIds?.map((value) => value.toLowerCase()).toSet() ??
            <String>{};
    return SettingsCardRow(
      styles: styles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Active colors', style: styles.rowLabelStyle),
                ),
                Text('High contrast', style: styles.helperStyle),
                Switch.adaptive(
                  value: highContrastEnabled,
                  activeThumbColor: styles.accentColor,
                  activeTrackColor: styles.accentColor.withAlpha(180),
                  onChanged: onHighContrastChanged,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: palette.colors.map((color) {
              final id = _colorId(color);
              final selected = activeSet.isEmpty || activeSet.contains(id);
              return GestureDetector(
                onTap: () {
                  final next =
                      activeSet.isEmpty ? allIds.toSet() : activeSet.toSet();
                  if (selected) {
                    next.remove(id);
                  } else {
                    next.add(id);
                  }
                  final normalized =
                      next.isEmpty || next.length == allIds.length
                          ? null
                          : next.toList();
                  onChanged(normalized);
                },
                child: Container(
                  width: styles.activeSwatchSize,
                  height: styles.activeSwatchSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.black54,
                      width: styles.activeSwatchBorderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(31, 0, 0, 0),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
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
          Text(
            'Toggle to include/exclude colors for stimuli.',
            style: styles.helperStyle,
          ),
        ],
      ),
    );
  }
}

List<Widget> _intersperse(Iterable<Widget> children, Widget separator) {
  final items = <Widget>[];
  for (final child in children) {
    if (items.isNotEmpty) {
      items.add(separator);
    }
    items.add(child);
  }
  return items;
}

String _colorId(Color color) =>
    color.toARGB32().toRadixString(16).toLowerCase();
