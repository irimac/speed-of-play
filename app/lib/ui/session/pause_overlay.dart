import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../data/models.dart';
import '../styles/app_tokens.dart';
import '../styles/session_styles.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.snapshot,
    required this.onDismiss,
    required this.controller,
    required this.onFinish,
    required this.styles,
  });

  final SessionSnapshot snapshot;
  final VoidCallback onDismiss;
  final SessionController controller;
  final VoidCallback onFinish;
  final SessionStyles styles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonSpacing = styles.overlayButtonSpacing;
    final buttonMinSize = Size.fromHeight(styles.overlayButtonMinHeight);
    const buttonShape = StadiumBorder();
    final primaryStyle = ElevatedButton.styleFrom(
      minimumSize: buttonMinSize,
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      shape: buttonShape,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: AppTokens.primaryActionTextSize,
      ),
    );
    final secondaryStyle = OutlinedButton.styleFrom(
      minimumSize: buttonMinSize,
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white54),
      shape: buttonShape,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: AppTokens.secondaryActionTextSize,
      ),
    );
    final mutedSecondaryStyle = OutlinedButton.styleFrom(
      minimumSize: buttonMinSize,
      foregroundColor: Colors.white70,
      side: const BorderSide(color: Colors.white24),
      backgroundColor: Colors.white.withAlpha((0.04 * 255).round()),
      shape: buttonShape,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: AppTokens.secondaryActionTextSize,
      ),
    );
    final destructiveStyle = ElevatedButton.styleFrom(
      minimumSize: buttonMinSize,
      foregroundColor: colorScheme.onError,
      backgroundColor: colorScheme.error,
      shape: buttonShape,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: AppTokens.primaryActionTextSize,
      ),
    );

    return Container(
      color: styles.overlayScrimColor,
      child: Center(
        child: Padding(
          padding: styles.overlayPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: styles.overlayMaxWidth),
            child: Material(
              color: styles.overlayCardColor,
              borderRadius: BorderRadius.circular(AppTokens.cornerL),
              child: Padding(
                padding: styles.overlayPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Paused',
                        style: styles.overlayTitleStyle,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppTokens.spacingS),
                    Text(
                      'Ready when you are',
                      style: styles.overlaySubtitleStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: styles.overlaySectionSpacing),
                    _OverlayButton(
                      icon: Icons.play_arrow,
                      label: 'Continue',
                      onPressed: onDismiss,
                      style: primaryStyle,
                      variant: _OverlayButtonVariant.elevated,
                    ),
                    SizedBox(height: buttonSpacing),
                    _OverlayButton(
                      icon: Icons.skip_next,
                      label: 'Skip',
                      onPressed: () {
                        controller.skipForward();
                      },
                      style: secondaryStyle,
                      variant: _OverlayButtonVariant.outlined,
                    ),
                    SizedBox(height: buttonSpacing),
                    _OverlayButton(
                      icon: Icons.replay,
                      label: 'Reset Round',
                      onPressed: () {
                        controller.resetRound();
                      },
                      style: mutedSecondaryStyle,
                      variant: _OverlayButtonVariant.outlined,
                    ),
                    SizedBox(height: buttonSpacing),
                    _OverlayButton(
                      icon: Icons.refresh,
                      label: 'Reset Session',
                      onPressed: () {
                        controller.resetSession();
                      },
                      style: mutedSecondaryStyle,
                      variant: _OverlayButtonVariant.outlined,
                    ),
                    SizedBox(height: styles.overlaySectionSpacing),
                    _OverlayButton(
                      icon: Icons.flag,
                      label: 'Finish Session',
                      onPressed: onFinish,
                      style: destructiveStyle,
                      variant: _OverlayButtonVariant.elevated,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.style,
    required this.variant,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final _OverlayButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == _OverlayButtonVariant.outlined) {
      return OutlinedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: AppTokens.actionIconSize),
        label: Text(label),
      );
    }
    return ElevatedButton.icon(
      style: style,
      onPressed: onPressed,
      icon: Icon(icon, size: AppTokens.actionIconSize),
      label: Text(label),
    );
  }
}

enum _OverlayButtonVariant { elevated, outlined }
