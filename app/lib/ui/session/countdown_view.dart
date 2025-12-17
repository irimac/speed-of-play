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
    return FittedBox(
      child: Text(
        '-$safeRemaining',
        style: textStyle,
      ),
    );
  }
}
