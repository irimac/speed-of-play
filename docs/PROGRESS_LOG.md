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

## 2025-12-18
- Session controller pause/overlay wiring moved to controller state; UI now renders overlay whenever paused and uses snapshot timings (countdown/rest) instead of preset copies.
- Skip-forward semantics implemented across countdown/active/rest (remains paused; advances to rest/next/finish as appropriate) with tick audio gated to countdown only.
- Results now use real elapsed and per-round durations captured from ticks; wakelock handled only via injected enable/disable at start/end.
- Removed duplicate preset plumbing from SessionScreen route; controller is sole source.
- Added controller tests covering skipForward paths and real metrics; `flutter test` green.
