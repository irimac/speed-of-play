import 'package:flutter/material.dart';

class RestView extends StatelessWidget {
  const RestView({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final total = totalSeconds <= 0 ? 1 : totalSeconds;
    final progress = secondsRemaining / total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
          ),
        ),
        const SizedBox(height: 16),
        Text('$secondsRemaining s', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
