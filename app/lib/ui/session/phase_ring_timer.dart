import 'package:flutter/material.dart';

import 'time_format.dart';

class PhaseRingTimer extends StatelessWidget {
  const PhaseRingTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.diameter,
    required this.strokeWidth,
    required this.innerPadding,
    required this.textStyle,
    required this.backgroundRingColor,
    required this.minTextDigits,
    required this.alwaysShowMinutes,
    required this.pulse,
    required this.pulseTrigger,
    required this.pulseScale,
    required this.pulseDuration,
    this.ringColor,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final double diameter;
  final double strokeWidth;
  final double innerPadding;
  final TextStyle textStyle;
  final Color backgroundRingColor;
  final int minTextDigits;
  final bool alwaysShowMinutes;
  final bool pulse;
  final int pulseTrigger;
  final double pulseScale;
  final Duration pulseDuration;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final total = totalSeconds <= 0 ? 1 : totalSeconds;
    final clampedRemaining = remainingSeconds.clamp(0, total);
    final int displaySeconds = clampedRemaining.toInt();
    final progress = (displaySeconds / total).clamp(0.0, 1.0).toDouble();
    final strutSize = textStyle.fontSize ?? 72;
    final innerSize = diameter - (strokeWidth * 2) - (innerPadding * 2);
    final safeInnerSize = innerSize > 0 ? innerSize : 0.0;
    final useMinutes = alwaysShowMinutes || displaySeconds >= 60;
    final baseDigits = total.toString().length;
    final safeMinDigits = minTextDigits > 0 ? minTextDigits : 1;
    final sizingDigits =
        safeMinDigits > baseDigits ? safeMinDigits : baseDigits;
    final minutes = displaySeconds ~/ 60;
    final minuteDigits =
        minutes.toString().length < 2 ? 2 : minutes.toString().length;
    final sizingText = useMinutes
        ? '${_repeatChar('8', minuteDigits)}:88'
        : _repeatChar('8', sizingDigits);
    final displayText =
        useMinutes ? formatSessionSeconds(displaySeconds) : '$displaySeconds';
    final textScaler = MediaQuery.textScalerOf(context);
    final strutStyle = StrutStyle(
      forceStrutHeight: true,
      fontSize: strutSize,
      height: textStyle.height ?? 1,
      leading: 0,
      fontFamily: textStyle.fontFamily,
      fontWeight: textStyle.fontWeight,
      fontStyle: textStyle.fontStyle,
    );
    final measured = _measureTextSize(
      context,
      sizingText,
      textStyle,
      strutStyle,
      textScaler,
    );
    final sized = Size(
      measured.width.clamp(0.0, safeInnerSize),
      measured.height.clamp(0.0, safeInnerSize),
    );

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundRingColor,
              valueColor:
                  ringColor == null ? null : AlwaysStoppedAnimation(ringColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(strokeWidth + innerPadding),
            child: SizedBox(
              width: sized.width,
              height: sized.height,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: PulseScale(
                  enabled: pulse,
                  trigger: pulseTrigger,
                  scale: pulseScale,
                  duration: pulseDuration,
                  child: Text(
                    displayText,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    softWrap: false,
                    textWidthBasis: TextWidthBasis.longestLine,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    strutStyle: strutStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulseScale extends StatefulWidget {
  const PulseScale({
    super.key,
    required this.enabled,
    required this.trigger,
    required this.scale,
    required this.duration,
    required this.child,
  });

  final bool enabled;
  final int trigger;
  final double scale;
  final Duration duration;
  final Widget child;

  @override
  State<PulseScale> createState() => _PulseScaleState();
}

class _PulseScaleState extends State<PulseScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int? _lastTrigger;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _buildAnimation();
    if (widget.enabled) {
      _lastTrigger = widget.trigger;
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant PulseScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.scale != oldWidget.scale ||
        widget.duration != oldWidget.duration) {
      _buildAnimation();
    }
    if (!widget.enabled) {
      _controller.stop();
      return;
    }
    if (!oldWidget.enabled && widget.enabled) {
      _lastTrigger = widget.trigger;
      _controller.forward(from: 0);
      return;
    }
    if (_lastTrigger != widget.trigger) {
      _lastTrigger = widget.trigger;
      _controller.forward(from: 0);
    }
  }

  void _buildAnimation() {
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _scaleAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

Size _measureTextSize(
  BuildContext context,
  String text,
  TextStyle style,
  StrutStyle strutStyle,
  TextScaler textScaler,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: textScaler,
    maxLines: 1,
    strutStyle: strutStyle,
  )..layout();
  return painter.size;
}

String _repeatChar(String char, int count) {
  if (count <= 0) return char;
  return List.filled(count, char).join();
}
