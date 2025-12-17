import 'dart:math';

import 'package:flutter/material.dart';

import 'recipe_loader.dart';

class RecipeRenderer extends StatelessWidget {
  const RecipeRenderer({
    super.key,
    required this.screen,
    this.textOverrides = const {},
    this.colorOverrides = const {},
    this.progressOverrides = const {},
    this.onAction,
  });

  final String screen;
  final Map<String, String> textOverrides;
  final Map<String, Color> colorOverrides;
  final Map<String, double> progressOverrides;
  final void Function(String actionId)? onAction;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final orientation = isPortrait ? 'portrait' : 'landscape';
    return FutureBuilder<RecipeLibrary>(
      future: RecipeLibrary.load(),
      builder: (context, libSnap) {
        if (libSnap.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: Colors.black12,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (libSnap.hasError) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: Text('Recipe load error', style: TextStyle(color: Colors.red))),
          );
        }
        return FutureBuilder<RecipeScreen>(
          future: RecipeLibrary.loadScreen(screen, orientation),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const ColoredBox(
                color: Colors.black12,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError || !snap.hasData) {
              return const ColoredBox(
                color: Colors.black,
                child: Center(child: Text('Recipe missing (see logs)', style: TextStyle(color: Colors.red))),
              );
            }
            final lib = libSnap.data!;
            final recipe = snap.data!;
            final expandedElements = _expand(recipe, lib);
            return LayoutBuilder(
              builder: (context, constraints) {
                final viewport = (recipe.meta['viewport'] as Map).cast<String, dynamic>();
                final vpX = _toDouble(viewport['x']);
                final vpY = _toDouble(viewport['y']);
                final vpW = _toDouble(viewport['w'], fallback: 1);
                final vpH = _toDouble(viewport['h'], fallback: 1);
                final scale = min(constraints.maxWidth / vpW, constraints.maxHeight / vpH);
                final offsetX = (constraints.maxWidth - vpW * scale) / 2;
                final offsetY = (constraints.maxHeight - vpH * scale) / 2;
                return ClipRect(
                  child: Stack(
                    children: expandedElements.map((e) {
                      return _buildElement(
                        e,
                        scale,
                        offsetX,
                        offsetY,
                        lib.tokens.colors,
                        textOverrides,
                        colorOverrides,
                        progressOverrides,
                        vpX,
                        vpY,
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _expand(RecipeScreen screen, RecipeLibrary lib) {
    // Keep native screen elements at the bottom of the stack (e.g., backgrounds)
    // and layer component "uses" on top.
    final out = <Map<String, dynamic>>[
      ...screen.elements.cast<Map<String, dynamic>>(),
    ];
    for (final use in screen.uses) {
      final useMap = (use as Map).cast<String, dynamic>();
      final name = useMap['use'] as String?;
      if (name == null) continue;
      final comp = lib.components[name];
      if (comp == null) continue;
      final idPrefix = useMap['idPrefix'] as String? ?? '';
      final props = (useMap['props'] as Map<dynamic, dynamic>? ?? {}).cast<String, dynamic>();
      for (final el in comp.elements) {
        final clone = _applyParams(el, comp.params, props);
        if (clone['id'] is String && idPrefix.isNotEmpty) {
          clone['id'] = '$idPrefix${clone['id']}';
        }
        out.add(clone);
      }
    }
    return out;
  }

  Map<String, dynamic> _applyParams(dynamic element, List<String> params, Map<String, dynamic> values) {
    final map = (element as Map).cast<String, dynamic>();
    dynamic replace(dynamic v) {
      if (v is String) {
        var out = v;
        for (final p in params) {
          if (values.containsKey(p)) {
            out = out.replaceAll('\${$p}', '${values[p]}');
          }
        }
        return out;
      } else if (v is Map) {
        return v.map((key, value) => MapEntry(key.toString(), replace(value)));
      } else if (v is List) {
        return {'__list__': v.map(replace).toList()};
      }
      return v;
    }

    final replaced = map.map((key, value) {
      final r = replace(value);
      if (r is Map && r.length == 1 && r.containsKey('__list__')) {
        return MapEntry(key, r['__list__']);
      }
      return MapEntry(key, r);
    });
    return replaced;
  }

  Widget _buildElement(
    Map<String, dynamic> el,
    double scale,
    double offsetX,
    double offsetY,
    Map<String, String> colors,
    Map<String, String> textOverrides,
    Map<String, Color> colorOverrides,
    Map<String, double> progressOverrides,
    double viewportX,
    double viewportY,
  ) {
    final id = el['id'] as String? ?? '';
    final type = el['type'] as String? ?? '';
    final frame = (el['frame'] as Map).cast<String, dynamic>();
    final fx = _toDouble(frame['x']) - viewportX;
    final fy = _toDouble(frame['y']) - viewportY;
    final fw = _toDouble(frame['w']);
    final fh = _toDouble(frame['h']);
    final positioned = Positioned(
      left: offsetX + fx * scale,
      top: offsetY + fy * scale,
      width: fw * scale,
      height: fh * scale,
      child: _buildContent(
        id: id,
        type: type,
        el: el,
        scale: scale,
        colors: colors,
        textOverrides: textOverrides,
        colorOverrides: colorOverrides,
        progressOverrides: progressOverrides,
      ),
    );
    return positioned;
  }

  Widget _buildContent({
    required String id,
    required String type,
    required Map<String, dynamic> el,
    required double scale,
    required Map<String, String> colors,
    required Map<String, String> textOverrides,
    required Map<String, Color> colorOverrides,
    required Map<String, double> progressOverrides,
  }) {
    final style = (el['style'] as Map<dynamic, dynamic>? ?? {}).cast<String, dynamic>();
    final onTap = el['onTap'] as String?;
    Widget child;

    Color? resolveColor(String? value) {
      if (value == null) return null;
      if (colorOverrides.containsKey(id)) return colorOverrides[id];
      if (value.startsWith('@colors.')) {
        final key = value.split('.').last;
        final hex = colors[key];
        if (hex != null) {
          return Color(int.parse(hex.replaceAll('#', ''), radix: 16) + 0xFF000000);
        }
      }
      if (value.startsWith('#')) {
        return Color(int.parse(value.replaceAll('#', ''), radix: 16) + 0xFF000000);
      }
      return null;
    }

    if (type == 'rect') {
      final radius = _toDouble(style['radius']);
      final fill = resolveColor(style['fill'] as String?);
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    } else if (type == 'text') {
      final text = textOverrides[id] ?? (el['text'] as String? ?? '');
      final fontSize = _toDouble(style['fontSize'], fallback: 14);
      final weight = _parseWeight(style['fontWeight'] as dynamic);
      final color = resolveColor(style['color'] as String?) ?? Colors.black;
      final align = _parseAlign(style['align'] as String?);
      final height = (style['lineHeight'] != null) ? _toDouble(style['lineHeight']) : null;
      child = Text(
        text,
        key: ValueKey(id),
        textAlign: align,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: height != null ? height / fontSize : null,
        ),
      );
    } else if (type == 'icon') {
      final color = resolveColor(style['color'] as String?) ?? Colors.black;
      final asset = el['asset'] as String? ?? '';
      final iconName = asset.startsWith('icon:') ? asset.split(':').last : 'help_outline';
      child = Icon(_materialIcon(iconName), color: color, size: _toDouble(el['frame']?['w']));
    } else if (type == 'image') {
      final asset = el['asset'] as String? ?? '';
      child = Image.asset(asset, fit: BoxFit.contain);
    } else if (type == 'button') {
      final label = el['text'] as String? ?? '';
      final fill = resolveColor(style['fill'] as String?) ?? Colors.blue;
      final radius = _toDouble(style['radius']);
      final textStyle = (style['textStyle'] as Map?)?.cast<String, dynamic>() ?? {};
      child = ElevatedButton(
        key: ValueKey(id),
        style: ElevatedButton.styleFrom(
          backgroundColor: fill,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: onTap != null && onAction != null ? () => onAction!(onTap) : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: _toDouble(textStyle['fontSize']),
            fontWeight: _parseWeight(textStyle['fontWeight']),
            color: resolveColor((textStyle['color'] as String?)),
          ),
        ),
      );
    } else if (type == 'progress_ring') {
      final strokeWidth = _toDouble(style['strokeWidth'], fallback: 8);
      final progressColor = resolveColor(style['progressColor'] as String?) ?? Colors.black;
      final trackColor = resolveColor(style['trackColor'] as String?) ?? Colors.black12;
      final progress = progressOverrides[id] ?? 0;
      child = Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            key: ValueKey(id),
            value: progress.clamp(0, 1),
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: trackColor,
          ),
        ],
      );
    } else {
      child = const SizedBox.shrink();
    }

    if (onTap != null && type != 'button' && onAction != null) {
      child = GestureDetector(onTap: () => onAction!(onTap), child: child);
    }
    return child;
  }

  IconData _materialIcon(String name) {
    switch (name) {
      case 'exit_to_app':
        return Icons.exit_to_app;
      case 'settings':
        return Icons.settings;
      case 'history':
        return Icons.history;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'skip_next':
        return Icons.skip_next;
      case 'refresh':
        return Icons.refresh;
      case 'replay':
        return Icons.replay;
      case 'flag':
        return Icons.flag;
      case 'save':
        return Icons.save;
      default:
        return Icons.help_outline;
    }
  }

  FontWeight _parseWeight(dynamic value) {
    if (value is int) {
      switch (value) {
        case 900:
          return FontWeight.w900;
        case 800:
          return FontWeight.w800;
        case 700:
          return FontWeight.w700;
        case 600:
          return FontWeight.w600;
        case 500:
          return FontWeight.w500;
        default:
          return FontWeight.w400;
      }
    }
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'bold':
          return FontWeight.bold;
        case 'w900':
          return FontWeight.w900;
        case 'w800':
          return FontWeight.w800;
        case 'w700':
          return FontWeight.w700;
        case 'w600':
          return FontWeight.w600;
        case 'w500':
          return FontWeight.w500;
        default:
          return FontWeight.normal;
      }
    }
    return FontWeight.w400;
  }

  TextAlign _parseAlign(String? v) {
    switch (v) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }
}
