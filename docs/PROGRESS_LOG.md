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

## 2025-12-17
- Session controller pause/overlay wiring moved to controller state; UI now renders overlay whenever paused and uses snapshot timings (countdown/rest) instead of preset copies.
- Skip-forward semantics implemented across countdown/active/rest (remains paused; advances to rest/next/finish as appropriate) with tick audio gated to countdown only.
- Results now use real elapsed and per-round durations captured from ticks; wakelock handled only via injected enable/disable at start/end.
- Removed duplicate preset plumbing from SessionScreen route; controller is sole source.
- Added controller tests covering skipForward paths and real metrics; `flutter test` green.

## 2025-12-17 (later)
- Stimulus timestamps switched to session-relative seconds to avoid wall-clock drift; JSON parsing remains backward compatible.
- Session UI skips rendering when phase is `end` to prevent pause overlay flashes during navigation.
- Risk log documented in `docs/RISKS.md`; tiny-range stimulus repeat marked acceptable; wakelock behavior during pauses noted for future decision.
- Added invariant tests (pause/skip/resume across phases, reset round vs session idempotency, tiny number ranges) and simplified stimulus repeat logic to allow repeats when ranges are size 1. Analyzer warning cleaned up; tests remain green.
- Refactored `session_screen` into phase-specific widgets (`countdown_view`, `active_round_view`, `rest_view`) plus shared `pause_overlay` without behavior changes; tests still green.
- Added session style tokens (`ui/styles/app_tokens.dart`) and `session_styles.dart`; session views now consume shared styles instead of hardcoded values. Added recording audio tests to verify preload and cue sequence and silence while paused.
- Added accessibility toggles to settings (large session text, high contrast palette) with persistence and palette/style wiring; model persistence tests updated.
- Increased the large-text toggle impact (larger display font) while keeping tests green.
- Added `audioEnabled` preset flag + Settings toggle with persistence; auto-pause on app background/inactive via lifecycle observer; pause now stops scheduler (tested).
- Audio cues made idempotent per session second/round (guards against duplicate ticks/round-starts, gated by audioEnabled); added tests for countdown tick counts and pause suppression.
- AudioCuePlayer now uses injectable backends and a single preload path; added spy-based test to ensure assets load once and play calls stay lightweight.

## 2025-12-18
- Added startup gate (`startup_gate.dart`) and `SpeedOfPlayBootstrapApp` wrapper to keep Launch screen visible for at least 3 seconds while bootstrapping dependencies.
- Launch screen now shows during initialization and auto-navigates to Main after the gate; removed embedded timer from `LaunchScreen` UI.
- Added widget tests for launch gating: initial visibility, minimum-duration enforcement, and transition after init; full test suite remains green.

## 2025-12-18 (later)
- Removed in-app `LaunchScreen` and startup gating; app now boots directly into `MainScreen` once Flutter is ready.
- Deleted launch gating tests and helper; simplified `main.dart` to construct dependencies up front.
- Android splash now native-branded: colored background and centered launcher icon via `LaunchTheme` (Android 12+ attributes plus pre-12 drawable). Added `splash_background` color and `splash_logo` drawable. No artificial delay.
- iOS platform folder is not present in this repo; add matching branding to `Runner/LaunchScreen.storyboard` when iOS is available.

## 2025-12-19
- Restyled the Settings screen with sectioned layout, shared SettingsStyles tokens, card rows, and a primary Save action; added widget tests for headers, steppers, countdown toggles, and save actions.
- Added active color selection UI, persisted `activeColorIds` in presets, and filtered stimulus palettes by the selected subset while keeping full-palette defaults when unset.
- Standardized palettes to 8 colors and added a basic palette (white, yellow, blue, red, green, orange, black, gray).

## 2025-12-19 (later)
- Polished Session screen visuals: stable tabular numerals, fixed-size number boxes, luminance-based text colors, and header/footer scrims for readability; rest ring sizing/tokens adjusted.
- Pause overlay hierarchy improved with subtitle and spacing; rest/countdown formatting uses mm:ss and avoids jitter.
- Added session goldens (Active bright/dark, Pause overlay) and a unit test for `textOnStimulus`; updated tests to use `TextScaler`.
- `flutter analyze` and `flutter test` run clean.
- Session header/footer bars now show round/time and session elapsed in mm:ss with consistent typography; rotation no longer auto-pauses. Added shared time formatting helper + unit test.
- Default palette set to `basic`; High Contrast toggle now clears active color selections to avoid mismatched color IDs.

## 2025-12-19 (settings polish)
- Removed palette picker; active colors now follow basic vs high-contrast toggle in the same row.
- Fixed stepper button borders (no bleed into app bar) and updated settings accent color.
- Settings app bar uses Back/Save icon+text actions for clarity.

## 2025-12-19 (main restyle)
- Restyled Main screen to match mock with centered logo, settings summary, active color swatches, and a prominent Start CTA.
- Secondary actions moved below the primary CTA with icon+text buttons; added MainStyles tokens and main screen widget tests.

## 2025-12-19 (action consistency)
- Unified Main and Pause overlay action button sizing/typography via `AppTokens` (height, icon size, text sizes) and matched pill shapes.
- Renamed the session footer text style token for clearer intent (`footerTextStyle`).

## 2025-12-19 (summary restyle)
- Restyled Session Summary screen with a scan-first header, stat card grid, and detail cards; actions are full-width and consistent with main token sizing.
- Added SummaryStyles tokens and widget tests for summary actions/navigation.

## 2025-12-19 (history restyle + header unification)
- Restyled History screen with scan-friendly card rows, selection action bar, and empty state CTA; added HistoryStyles tokens and widget tests.
- Unified Settings/History/End headers via shared AppHeader component; standardized title/action sizing tokens and status bar background colors.
- Settings no longer shows save controls (changes persist on edit); Done uses back arrow. End screen still prompts to save before exit.

## 2025-12-19 (session number sizing)
- Large session numbers now size as a fraction of available height with separate landscape/portrait scaling to prevent oversized digits.
- Unified Active/Countdown number sizing policy for both normal and large modes; added new countdown goldens.

## 2025-12-19 (rotation policy)
- Rotation no longer auto-pauses sessions (product decision) to avoid unintended interruptions; rationale and revisit criteria captured in `docs/DECISIONS.md`.
