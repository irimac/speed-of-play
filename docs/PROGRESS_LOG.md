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
