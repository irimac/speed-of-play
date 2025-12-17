import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class RecipeTokens {
  RecipeTokens({required this.colors});

  final Map<String, String> colors;

  factory RecipeTokens.fromYaml(Map<dynamic, dynamic> yaml) {
    final colors = <String, String>{};
    final raw = yaml['colors'] as Map?;
    raw?.forEach((key, value) {
      if (key is String && value is String) {
        colors[key] = value;
      }
    });
    return RecipeTokens(colors: colors);
  }
}

class RecipeComponent {
  RecipeComponent({required this.params, required this.elements});

  final List<String> params;
  final List<dynamic> elements;

  factory RecipeComponent.fromYaml(Map<dynamic, dynamic> yaml) {
    final params = (yaml['params'] as List<dynamic>? ?? []).whereType<String>().toList();
    final elements = (yaml['elements'] as List<dynamic>? ?? []).toList();
    return RecipeComponent(params: params, elements: elements);
  }
}

class RecipeScreen {
  RecipeScreen({
    required this.meta,
    required this.uses,
    required this.elements,
  });

  final Map<String, dynamic> meta;
  final List<dynamic> uses;
  final List<dynamic> elements;

  factory RecipeScreen.fromYaml(Map<dynamic, dynamic> yaml) {
    return RecipeScreen(
      meta: (yaml['meta'] as Map<dynamic, dynamic>).cast<String, dynamic>(),
      uses: (yaml['uses'] as List<dynamic>? ?? []).toList(),
      elements: (yaml['elements'] as List<dynamic>? ?? []).toList(),
    );
  }
}

class RecipeLibrary {
  RecipeLibrary({
    required this.tokens,
    required this.components,
  });

  final RecipeTokens tokens;
  final Map<String, RecipeComponent> components;

  static RecipeLibrary? _cached;
  static final Map<String, Future<RecipeScreen>> _screenCache = {};

  static Future<RecipeLibrary> load() async {
    if (_cached != null) return _cached!;
    final tokensYaml = await _loadYamlAsset('assets/ui_recipes/tokens.yaml');
    final componentsYaml = await _loadYamlAsset('assets/ui_recipes/components.yaml');
    final components = <String, RecipeComponent>{};
    final compMap = componentsYaml['components'] as Map<dynamic, dynamic>? ?? {};
    compMap.forEach((key, value) {
      if (key is String && value is Map) {
        components[key] = RecipeComponent.fromYaml(value);
      }
    });
    _cached = RecipeLibrary(
      tokens: RecipeTokens.fromYaml(tokensYaml.cast<String, dynamic>()),
      components: components,
    );
    return _cached!;
  }

  static Future<Map<String, dynamic>> _loadYamlAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final doc = loadYaml(raw);
    final jsonStr = jsonEncode(doc);
    return (jsonDecode(jsonStr) as Map<dynamic, dynamic>).cast<String, dynamic>();
  }

  static Future<RecipeScreen> loadScreen(String name, String orientation) async {
    final key = '$name.$orientation';
    if (_screenCache.containsKey(key)) return _screenCache[key]!;
    final future = () async {
      try {
        final path = 'assets/ui_recipes/screens/$name.$orientation.yaml';
        final raw = await rootBundle.loadString(path);
        final doc = loadYaml(raw);
        final jsonStr = jsonEncode(doc);
        final map = (jsonDecode(jsonStr) as Map<dynamic, dynamic>).cast<String, dynamic>();
        return RecipeScreen.fromYaml(map);
      } catch (e) {
        debugPrint('Recipe load failed for $key: $e');
        _screenCache.remove(key);
        rethrow;
      }
    }();
    _screenCache[key] = future;
    return future;
  }
}
