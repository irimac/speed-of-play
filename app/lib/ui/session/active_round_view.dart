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
    final strutSize = textStyle.fontSize ?? 180;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        displayText,
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
