import 'package:flutter/material.dart';

import 'main_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({
    super.key,
    this.autoProceed = false,
  });

  static const routeName = '/';
  final bool autoProceed;

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoProceed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _navigated) return;
        _navigated = true;
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_soccer, size: 96, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'SpeedOfPlay',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Awareness & Reactivity Trainer'),
            ],
          ),
        ),
      ),
    );
  }
}
