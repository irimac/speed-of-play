# Speed of Play

Session training companion for rapid decision-making drills.

## Session UI polish (recent)
- Large session numbers use tabular figures, stable baselines, and a lightweight shadow/scrim for outdoor readability.
- Text color now adapts to the stimulus background for contrast.
- Rest view centers the thicker progress ring with the remaining seconds overlaid (no trailing "s").
- Pause overlay uses clear hierarchy: Continue (primary), Skip/Reset (secondary), Finish (destructive).

## Splash configuration
- Android: update `android/app/src/main/res/values/colors.xml` (`splash_background`) and drawable `launch_background.xml` / `splash_logo.xml` for branding. Android 12+ uses `LaunchTheme` splash attributes.
- iOS: add matching artwork in `Runner/LaunchScreen.storyboard` once the iOS platform folder is available.

## Getting started
1. Install Flutter (3.19+ recommended).
2. Run `flutter pub get`.
3. Run `flutter test` to verify.
4. Start the app with `flutter run`.
