import 'package:flutter/material.dart';

class ActiveRoundView extends StatelessWidget {
  const ActiveRoundView({
    super.key,
    required this.displayText,
    required this.textStyle,
  });

  final String displayText;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        displayText,
        style: textStyle,
      ),
    );
  }
}
