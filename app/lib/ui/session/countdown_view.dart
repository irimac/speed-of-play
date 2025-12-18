import 'package:flutter/material.dart';

class CountdownView extends StatelessWidget {
  const CountdownView({
    super.key,
    required this.remainingSeconds,
    required this.textStyle,
  });

  final int remainingSeconds;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final safeRemaining = remainingSeconds < 0 ? 0 : remainingSeconds;
    final strutSize = textStyle.fontSize ?? 180;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        '-$safeRemaining',
        style: textStyle,
        textAlign: TextAlign.center,
        softWrap: false,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        strutStyle: StrutStyle(
          forceStrutHeight: true,
          fontSize: strutSize,
          height: textStyle.height ?? 1,
          leading: 0,
          fontFamily: textStyle.fontFamily,
          fontWeight: textStyle.fontWeight,
          fontStyle: textStyle.fontStyle,
        ),
      ),
    );
  }
}
