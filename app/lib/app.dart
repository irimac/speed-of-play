import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/session_controller.dart';
import 'data/models.dart';
import 'services/history_repository.dart';
import 'services/storage.dart';
import 'ui/end_screen.dart';
import 'ui/history_screen.dart';
import 'ui/launch_screen.dart';
import 'ui/main_screen.dart';
import 'ui/session_screen.dart';
import 'ui/settings_screen.dart';
import 'theme.dart';

class SpeedOfPlayApp extends StatefulWidget {
  const SpeedOfPlayApp({
    super.key,
    required this.historyRepository,
    required this.presetStore,
  });

  final SessionHistoryRepository historyRepository;
  final PresetStore presetStore;

  @override
  State<SpeedOfPlayApp> createState() => _SpeedOfPlayAppState();
}

class _SpeedOfPlayAppState extends State<SpeedOfPlayApp> {
  late SessionPreset _preset;

  @override
  void initState() {
    super.initState();
    _preset = widget.presetStore.currentPreset;
  }

  void _updatePreset(SessionPreset preset) {
    setState(() {
      _preset = preset;
    });
    widget.presetStore.save(preset);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.historyRepository),
        Provider.value(value: widget.presetStore),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case LaunchScreen.routeName:
              return MaterialPageRoute(builder: (_) => const LaunchScreen());
            case MainScreen.routeName:
              return MaterialPageRoute(
                builder: (_) => MainScreen(
                  preset: _preset,
                  onPresetChanged: _updatePreset,
                ),
              );
            case SettingsScreen.routeName:
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => SettingsScreen(
                  preset: _preset,
                  onPresetChanged: _updatePreset,
                ),
              );
            case SessionScreen.routeName:
              final preset = settings.arguments as SessionPreset? ?? _preset;
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => SessionController(preset: preset),
                  child: const SessionScreen(),
                ),
              );
            case EndScreen.routeName:
              final result = settings.arguments as SessionResult?;
              return MaterialPageRoute(
                builder: (_) => EndScreen(result: result),
              );
            case HistoryScreen.routeName:
              return MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const LaunchScreen(),
              );
          }
        },
      ),
    );
  }
}
