import 'dart:async';

import 'package:flutter/material.dart';

import 'main_screen.dart';
import 'widgets/recipe_renderer/recipe_renderer.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  static const routeName = '/';

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RecipeRenderer(screen: 'launch'),
    );
  }
}
