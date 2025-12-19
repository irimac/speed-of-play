import 'package:flutter/material.dart';

import '../data/models.dart';
import 'history_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';
import 'styles/main_styles.dart';

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
    final palette = Palette.resolveWithContrast(
      _preset.paletteId,
      highContrast: _preset.highContrastPalette,
    );
    final styles = MainStyles.defaults(Theme.of(context));
    final activeColors = _activeColors(palette, _preset.activeColorIds);
    final summaryText = 'Rounds: ${_preset.rounds} | '
        'Duration: ${_formatMinutesSeconds(_preset.roundDurationSec)} | '
        'Rest: ${_preset.restDurationSec}s';
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: styles.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: styles.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: styles.contentMaxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MainHeader(styles: styles),
                    SizedBox(height: styles.sectionSpacing),
                    Text(
                      summaryText,
                      style: styles.summaryStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: styles.summarySpacing),
                    _ActiveColorsRow(styles: styles, colors: activeColors),
                    SizedBox(height: styles.summarySpacing),
                    Text(
                      'Numbers: ${_preset.numberMin} - ${_preset.numberMax}',
                      style: styles.secondaryInfoStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: styles.sectionSpacing),
                    SizedBox(
                      width: styles.playButtonWidth,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(styles.playButtonHeight),
                          backgroundColor: styles.playButtonColor,
                          foregroundColor: styles.playButtonForegroundColor,
                          shape: const StadiumBorder(),
                          elevation: 4,
                          shadowColor: const Color.fromARGB(80, 0, 0, 0),
                          textStyle: styles.playButtonTextStyle,
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(
                          SessionScreen.routeName,
                          arguments: _preset,
                        ),
                        icon:
                            Icon(Icons.play_arrow, size: styles.buttonIconSize),
                        label: const Text('Start'),
                      ),
                    ),
                    SizedBox(height: styles.buttonSpacing),
                    SizedBox(
                      width: styles.playButtonWidth,
                      child: OutlinedButton.icon(
                        onPressed: _openSettings,
                        icon: Icon(Icons.settings, size: styles.buttonIconSize),
                        label: const Text('Settings'),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              Size.fromHeight(styles.secondaryButtonHeight),
                          shape: const StadiumBorder(),
                          textStyle: styles.secondaryButtonTextStyle,
                          foregroundColor: styles.primaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: styles.buttonSpacing),
                    SizedBox(
                      width: styles.playButtonWidth,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(HistoryScreen.routeName);
                        },
                        icon:
                            Icon(Icons.bar_chart, size: styles.buttonIconSize),
                        label: const Text('History'),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              Size.fromHeight(styles.secondaryButtonHeight),
                          shape: const StadiumBorder(),
                          textStyle: styles.secondaryButtonTextStyle,
                          foregroundColor: styles.primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

class _MainHeader extends StatelessWidget {
  const _MainHeader({required this.styles});

  final MainStyles styles;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: styles.logoMaxWidth),
      child: Image.asset(
        'assets/RPT-SpeedOfPlay.png',
        height: styles.logoHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ActiveColorsRow extends StatelessWidget {
  const _ActiveColorsRow({
    required this.styles,
    required this.colors,
  });

  final MainStyles styles;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Active colors',
          style: styles.activeColorsLabelStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: colors
              .map(
                (color) => Container(
                  width: styles.activeSwatchSize,
                  height: styles.activeSwatchSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: styles.activeSwatchBorderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

List<Color> _activeColors(Palette palette, List<String>? activeIds) {
  if (activeIds == null || activeIds.isEmpty) {
    return palette.colors;
  }
  final paletteById = <String, Color>{
    for (final color in palette.colors)
      color.toARGB32().toRadixString(16).toLowerCase(): color
  };
  final active = activeIds
      .map((id) => id.toLowerCase())
      .where(paletteById.containsKey)
      .map((id) => paletteById[id]!)
      .toList();
  return active.isEmpty ? palette.colors : active;
}

String _formatMinutesSeconds(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final minutes = clamped ~/ 60;
  final remaining = clamped % 60;
  return '${minutes}min:${remaining.toString().padLeft(2, '0')}s';
}
