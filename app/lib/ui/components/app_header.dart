import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/app_tokens.dart';

class AppHeaderAction {
  const AppHeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAfter = false,
    this.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconAfter;
  final Key? key;
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.titleColor,
    required this.actionColor,
    this.leadingAction,
    this.trailingAction,
    this.centerTitle = true,
    this.backgroundColor = Colors.transparent,
    this.leadingWidth = AppTokens.headerLeadingWidth,
  });

  final String title;
  final Color titleColor;
  final Color actionColor;
  final AppHeaderAction? leadingAction;
  final AppHeaderAction? trailingAction;
  final bool centerTitle;
  final Color backgroundColor;
  final double leadingWidth;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: titleColor,
      fontWeight: FontWeight.w800,
      fontSize: AppTokens.headerTitleTextSize,
    );
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final overlayStyle = (brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(statusBarColor: backgroundColor);
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: overlayStyle,
      centerTitle: centerTitle,
      leadingWidth: leadingAction == null ? null : leadingWidth,
      leading: leadingAction == null
          ? null
          : _HeaderActionButton(
              action: leadingAction!,
              actionColor: actionColor,
              iconSize: AppTokens.headerIconSize,
            ),
      title: Text(title, style: titleStyle),
      actions: trailingAction == null
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(right: AppTokens.spacingS),
                child: _HeaderActionButton(
                  action: trailingAction!,
                  actionColor: actionColor,
                  iconSize: AppTokens.headerIconSize,
                ),
              ),
            ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.action,
    required this.actionColor,
    required this.iconSize,
  });

  final AppHeaderAction action;
  final Color actionColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: actionColor,
      fontWeight: FontWeight.w800,
      fontSize: AppTokens.headerActionTextSize,
    );
    if (action.iconAfter) {
      return TextButton(
        key: action.key,
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: actionColor,
          minimumSize: const Size(0, kToolbarHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action.label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 6),
            Icon(action.icon, color: actionColor, size: iconSize),
          ],
        ),
      );
    }
    return TextButton.icon(
      key: action.key,
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: actionColor,
        minimumSize: const Size(0, kToolbarHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingS),
      ),
      icon: Icon(action.icon, color: actionColor, size: iconSize),
      label: Text(
        action.label,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
