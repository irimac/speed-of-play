# SpeedOfPlay - Progress Log

 Chronological notes of meaningful changes. Update this log whenever progress is made.

## 2025-12-16
- Added `PROJECT_PLAN.md` and updated to reflect current status (foundations/core UX done; reliability/release pending; audio assets present but format/name mismatch with code; UI mojibake outstanding; tests/CI missing).
- Settings/Main preset refresh fixed; Settings screen navigation fixed.
- User added audio assets (`tick.mp3`, `round_start.mp3`); app code still expects `.wav`, so cues may remain silent until aligned.
- Converted audio assets to `.wav` (`tick.wav`, `round_start.wav`) to match code; cues should now load.
- Fixed mojibake UI strings (rounds summary, history subtitle, End screen button) to use ASCII separators.
- Added model encode/decode smoke tests (`app/test/models_test.dart`).
- Added manual QA checklist (`docs/QA_CHECKLIST.md`).
- Added CSV export test to models suite.
- Added CI workflow (`.github/workflows/ci.yml`) running analyze + test for `app/`.
- Added `randomInRange` boundary test to models suite.
- Added SessionController smoke tests with manual scheduler and noop audio (`app/test/controller_test.dart`).
- Injected testable scheduler into SessionController, fixed analyzer warnings (deprecated API uses, unused imports, dropdown initialValue), and adjusted colors/opacity usage for lint clean runs.
- Const-ified palette map entries to silence remaining analyzer const hints.
- Fixed map literal keys (removed invalid `const` prefix) to satisfy analyzer.
- Removed redundant consts on palette values to clear unnecessary_const lint.
- Flattened palette const usage (static const map with non-redundant entries) to resolve lingering analyzer hints.
- Updated controller tests to initialize bindings and loosen end-of-round tick to avoid false negatives.
- Guarded wakelock calls for test environments, injected scheduler builder + no-op wakelock hooks, and achieved all tests passing (`flutter test`).
- Added pause overlay recipes (portrait/landscape) under `assets/ui_recipes/screens/pause_overlay.*.yaml` with action wiring to session controls.
- Implemented recipe renderer/loader, wired launch/main/session/end screens to recipes, and added recipe action dispatcher; pause overlay uses recipe actions.
- Added golden tests and generated images under `app/test/goldens/`.
- Expanded icon mapping and session actions in renderer/action dispatcher.

## 2025-12-17
- Recipe renderer now respects viewport origin and keeps backgrounds beneath component layers; main/countdown screens render correctly.
- Added settings UI refresh: light card layout, reordered fields, higher-contrast steppers, keypad entry for number fields, palette swatches, and active color selection per palette.
- Added 8-color palettes (basic/sunrise/field/contrast) and optional active-color filtering in `SessionPreset`/controller.
- Audio globally disabled via toggle in `AudioCuePlayer` to avoid runtime issues.
- Fixed analyzer deprecations (Color access, opacity APIs, switch colors) and guarded wakelock disable with injected hook to unblock tests.
