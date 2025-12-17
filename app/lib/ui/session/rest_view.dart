import 'package:flutter/material.dart';

class RestView extends StatelessWidget {
  const RestView({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  final int secondsRemaining;
  final int totalSeconds;
  final double indicatorSize;
  final double strokeWidth;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final total = totalSeconds <= 0 ? 1 : totalSeconds;
    final progress = secondsRemaining / total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Text('$secondsRemaining s', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
