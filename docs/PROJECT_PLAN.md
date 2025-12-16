# SpeedOfPlay - Project Plan

Prepared from: `SpeedOfPlay--Project_Proposal.md`, `Session_Flow_and_Behavior_with_History.md`, `PRODUCT_SPEC.md`  
Date: 2025-12-16

## Status Snapshot
- Foundations and core UX are implemented in the app: scheduler, session controller, presets/history storage, and all screens (Launch/Main/Settings/Session/End/History).
- Reliability/polish are partial: atomic history writes exist; audio assets now match expected format; UI mojibake fixed; Settings/Main preset refresh fixed. No automated tests or CI yet.
- Release prep not started.
- Tests now passing locally (`flutter test`); analyzer was near-clean after palette fixes—recheck and push to confirm CI.

## Milestones
- [x] M1 - Foundations: scheduler, controller, storage, preset persistence.
- [x] M2 - Core UX: screens wired to real data, audio hooks, readability theme.
- [ ] M3 - Reliability & polish: pause/resume/rotation hardening, atomic storage checks, CSV export validation, QA checklist, playtest fixes. (Partial: atomic writes and CSV export are in; QA/perf/accessibility/open bugs pending.)
- [ ] M4 - Release prep: performance sweep, crash/exception handling, app metadata/assets, build & store packaging.

## Workstreams & Tasks
### Timing & State
- [x] Aligned-second `SessionScheduler` (monotonic clock, pause/resume boundary hold).
- [x] `SessionController` phases (countdown, active, rest, end), stimulus generation with no immediate repeat, stimuli log.
- [x] Audio cues preload + tick/round-start playback.
- [ ] Mute toggle (stretch).
- [x] Wakelock during active sessions; disable on end/reset.

### Data & Persistence
- [x] Models: `SessionPreset`, `Stimulus`, `SessionResult` with JSON/CSV helpers.
- [x] Persist preset to SharedPreferences; hydrate on app start.
- [x] Persist history to local file with temp-write-then-rename for atomicity.
- [x] CSV export of selected sessions to local file.
- [ ] Persist in-flight session progress on app background; restore on resume (stretch).

### UI & Navigation
- [x] Launch splash auto-transition (~1.5s). (Audio prewarm not implemented.)
- [x] Main: preset summary card, palette swatches, actions (Play/Settings/History), responsive layout.
- [x] Settings: rounds, durations, interval, number range, palette select, outdoor boost, countdown toggle + seconds, RNG seed toggle/input.
- [x] Session: countdown/active/rest UIs, per-phase backgrounds, large number, rest progress, double-tap pause overlay with continue/reset/skip/finish.
- [x] End: summary, per-round list, Save to History, End to Main.
- [x] History: newest-first list, multi-select, delete, export CSV, empty state.

### Visual/Accessibility/Performance
- [x] Theme/palettes applied; outdoor boost behavior implemented.
- [ ] Contrast, semantics, and touch-target audit; ensure readability outdoors.
- [ ] Optimize animations/transitions/perf; prewarm audio to reduce first-play latency.

### QA & Tooling
- [ ] Smoke tests: controller timing, preset encode/decode, history repo write/read. (models encode/decode, CSV, randomInRange, and controller phase tests added)
- [x] Manual QA checklist (rotation, pause/resume, reset, end-save-export, history delete/export).
- [ ] CI: format/lint/test (`flutter analyze`, `flutter test`). (workflow added; needs green run)

## Risks & Mitigations
- Timing drift or missed ticks -> use monotonic clock, emit only on integer boundaries, add dev logging (partial; logging not added).
- Asset issues (missing/mismatched audio) -> keep preload failure graceful; validate assets during CI.
- Data corruption on crash -> temp file + rename writes; guard reads for empty/invalid files (implemented).
- Outdoor readability -> palette contrast validation and outdoor boost option (boost exists; contrast audit pending).

## Near-Term Focus
- Add smoke tests and a manual QA checklist; wire a minimal CI task.
- Optional: add mute toggle and audio prewarm; consider session-progress persistence if needed.
- Do an accessibility/contrast pass and perf sanity check for session screen.
