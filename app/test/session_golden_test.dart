import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/controllers/session_controller.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/services/audio_cue_player.dart';
import 'package:speed_of_play/services/session_scheduler.dart';
import 'package:speed_of_play/ui/session/active_round_view.dart';
import 'package:speed_of_play/ui/session/countdown_view.dart';
import 'package:speed_of_play/ui/session/pause_overlay.dart';
import 'package:speed_of_play/ui/session/phase_ring_timer.dart';
import 'package:speed_of_play/ui/session/rest_view.dart';
import 'package:speed_of_play/ui/styles/session_styles.dart';

class _NoopBackend implements AudioBackend {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setAsset(String assetPath) async {}
}

SessionController _buildController() {
  final audio = AudioCuePlayer(
    tickBackend: _NoopBackend(),
    roundStartBackend: _NoopBackend(),
  );
  return SessionController(
    preset: SessionPreset.defaults(),
    audioPlayer: audio,
    schedulerBuilder: (cb) => SessionScheduler(onAlignedSecond: cb),
  );
}

Future<void> _pumpGolden(
  WidgetTester tester, {
  required Widget child,
  required Size size,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
        child: Material(
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

int _maxDigitCount(int a, int b) {
  final maxValue = a.abs() > b.abs() ? a.abs() : b.abs();
  return maxValue.toString().length;
}

void main() {
  // Update goldens with:
  // flutter test --update-goldens test/session_golden_test.dart
  testWidgets('Active view golden - normal size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF6F069);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: ActiveRoundView(
          displayText: '7',
          textStyle: numberStyle,
          sizingText: '88',
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/active_view_normal.png'),
    );
  });

  testWidgets('Active view golden - large size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF6F069);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: true),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: ActiveRoundView(
          displayText: '7',
          textStyle: numberStyle,
          sizingText: '88',
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/active_view_large.png'),
    );
  });

  testWidgets('Countdown view golden - normal size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    const countdownTotal = 5;
    const restDurationSec = 15;
    final minDigits = _maxDigitCount(countdownTotal, restDurationSec);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: CountdownView(
          remainingSeconds: 3,
          totalSeconds: countdownTotal,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          pulseScale: styles.countdownPulseScale,
          pulseDuration: styles.countdownPulseDuration,
          minTextDigits: minDigits,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/countdown_view_normal.png'),
    );
  });

  testWidgets('Countdown view golden - large size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    const countdownTotal = 5;
    const restDurationSec = 15;
    final minDigits = _maxDigitCount(countdownTotal, restDurationSec);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: true),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: CountdownView(
          remainingSeconds: 3,
          totalSeconds: countdownTotal,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          pulseScale: styles.countdownPulseScale,
          pulseDuration: styles.countdownPulseDuration,
          minTextDigits: minDigits,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/countdown_view_large.png'),
    );
  });

  testWidgets('Countdown view golden - mm:ss', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    const countdownTotal = 120;
    const restDurationSec = 15;
    final minDigits = _maxDigitCount(countdownTotal, restDurationSec);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: CountdownView(
          remainingSeconds: 90,
          totalSeconds: countdownTotal,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          pulseScale: styles.countdownPulseScale,
          pulseDuration: styles.countdownPulseDuration,
          minTextDigits: minDigits,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/countdown_view_mmss.png'),
    );
  });

  testWidgets('Rest view golden - normal size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    const restTotal = 15;
    const countdownTotal = 5;
    final minDigits = _maxDigitCount(countdownTotal, restTotal);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: RestView(
          secondsRemaining: 15,
          totalSeconds: restTotal,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          minTextDigits: minDigits,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/rest_view_normal.png'),
    );
  });

  testWidgets('Rest view golden - large size', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    const restTotal = 15;
    const countdownTotal = 5;
    final minDigits = _maxDigitCount(countdownTotal, restTotal);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: true),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: RestView(
          secondsRemaining: 15,
          totalSeconds: restTotal,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          minTextDigits: minDigits,
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/rest_view_large.png'),
    );
  });

  testWidgets('Rest view shows RECOVER label', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: RestView(
          secondsRemaining: 15,
          totalSeconds: 15,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          minTextDigits: 2,
        ),
      ),
    );

    expect(find.text('RECOVER'), findsOneWidget);
  });

  testWidgets('Countdown view shows GET READY label', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: CountdownView(
          remainingSeconds: 5,
          totalSeconds: 10,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          pulseScale: styles.countdownPulseScale,
          pulseDuration: styles.countdownPulseDuration,
          minTextDigits: 2,
        ),
      ),
    );

    expect(find.text('GET READY'), findsOneWidget);
  });

  testWidgets('Countdown view pulses on last 3 seconds', (tester) async {
    final styles = SessionStyles.defaults(ThemeData.light());
    const background = Color(0xFFF2F2F2);
    final textColor = styles.textOnStimulus(background);
    const size = Size(390, 844);
    final ringDiameter = styles.ringDiameterFor(size.height);
    final ringStrokeWidth = styles.ringStrokeWidthFor(ringDiameter);
    final ringInnerPadding = styles.ringInnerPaddingFor(ringDiameter);
    final numberStyle = styles.numberTextStyle.copyWith(
      fontSize: styles.bigNumberFontSizeFor(size, large: false),
      color: textColor,
      shadows: styles.numberShadowsForText(textColor),
    );
    final labelStyle = styles.phaseLabelTextStyle.copyWith(color: textColor);

    await _pumpGolden(
      tester,
      size: size,
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: CountdownView(
          remainingSeconds: 3,
          totalSeconds: 10,
          indicatorSize: ringDiameter,
          strokeWidth: ringStrokeWidth,
          innerPadding: ringInnerPadding,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          textStyle: numberStyle,
          labelStyle: labelStyle,
          labelGap: styles.phaseLabelGap,
          pulseScale: styles.countdownPulseScale,
          pulseDuration: styles.countdownPulseDuration,
          minTextDigits: 2,
        ),
      ),
    );

    expect(find.byType(PulseScale), findsOneWidget);
  });

  testWidgets('Pause overlay golden', (tester) async {
    final controller = _buildController();
    addTearDown(controller.dispose);
    final styles = SessionStyles.defaults(ThemeData.light());

    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      child: PauseOverlay(
        snapshot: controller.snapshot,
        onDismiss: () {},
        controller: controller,
        onFinish: () {},
        styles: styles,
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pause_overlay.png'),
    );
  });
}
