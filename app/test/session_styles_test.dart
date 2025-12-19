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
}
