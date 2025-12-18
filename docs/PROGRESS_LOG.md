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
