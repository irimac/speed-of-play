import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/ui/styles/session_styles.dart';

void main() {
  test('textOnStimulus returns light text on dark backgrounds', () {
    final styles = SessionStyles.defaults(ThemeData.light());

    expect(styles.textOnStimulus(const Color(0xFF000000)), Colors.white);
  });

  test('textOnStimulus returns dark text on light backgrounds', () {
    final styles = SessionStyles.defaults(ThemeData.light());

    expect(styles.textOnStimulus(const Color(0xFFFFFFFF)), Colors.black);
  });

  test('bigNumberFontSizeFor scales with orientation and large toggle', () {
    final styles = SessionStyles.defaults(ThemeData.light());
    const portrait = Size(400, 600);
    const landscape = Size(800, 600);

    final portraitNormal = styles.bigNumberFontSizeFor(portrait, large: false);
    final portraitLarge = styles.bigNumberFontSizeFor(portrait, large: true);
    final landscapeNormal =
        styles.bigNumberFontSizeFor(landscape, large: false);
    final landscapeLarge = styles.bigNumberFontSizeFor(landscape, large: true);

    expect(portraitLarge, greaterThan(portraitNormal));
    expect(landscapeLarge, greaterThan(landscapeNormal));
    expect(landscapeLarge, greaterThan(portraitLarge));
  });
}
