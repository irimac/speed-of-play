import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/session_controller.dart';
import 'data/models.dart';
import 'services/history_repository.dart';
import 'services/startup_gate.dart';
import 'services/storage.dart';
import 'theme.dart';
import 'ui/end_screen.dart';
import 'ui/history_screen.dart';
import 'ui/launch_screen.dart';
import 'ui/main_screen.dart';
import 'ui/session_screen.dart';
import 'ui/settings_screen.dart';

const Duration kMinLaunchDisplayDuration = Duration(
  seconds: 3,
); // Intentionally not user-configurable.

class SpeedOfPlayBootstrapApp extends StatefulWidget {
  const SpeedOfPlayBootstrapApp({
    super.key,
    this.bootstrapper,
  });

  final Future<AppBootstrapData> Function()? bootstrapper;

  @override
  State<SpeedOfPlayBootstrapApp> createState() =>
      _SpeedOfPlayBootstrapAppState();
}

class _SpeedOfPlayBootstrapAppState extends State<SpeedOfPlayBootstrapApp> {
  late final Future<AppBootstrapData> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    final bootstrapper = widget.bootstrapper ?? _createDependencies;
    _bootstrapFuture = startupGate(
      bootstrapper(),
      kMinLaunchDisplayDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: const LaunchScreen(),
          );
        }
        final data = snapshot.requireData;
        return SpeedOfPlayApp(
          historyRepository: data.historyRepository,
          presetStore: data.presetStore,
        );
      },
    );
  }

  Future<AppBootstrapData> _createDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    final presetStore = PresetStore(prefs);
    final historyRepo = SessionHistoryRepository(LocalFileStorage());
    return AppBootstrapData(
      historyRepository: historyRepo,
      presetStore: presetStore,
    );
  }
}

class SpeedOfPlayApp extends StatefulWidget {
  const SpeedOfPlayApp({
    super.key,
    required this.historyRepository,
    required this.presetStore,
    this.initialRoute = LaunchScreen.routeName,
  });

  final SessionHistoryRepository historyRepository;
  final PresetStore presetStore;
  final String initialRoute;

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
        initialRoute: widget.initialRoute,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case LaunchScreen.routeName:
              return MaterialPageRoute(
                builder: (_) => const LaunchScreen(autoProceed: true),
              );
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
                builder: (_) => const LaunchScreen(autoProceed: true),
              );
          }
        },
      ),
    );
  }
}

class AppBootstrapData {
  const AppBootstrapData({
    required this.historyRepository,
    required this.presetStore,
  });

  final SessionHistoryRepository historyRepository;
  final PresetStore presetStore;
}
