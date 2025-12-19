# SpeedOfPlay - Project Plan

Prepared from: `SpeedOfPlay--Project_Proposal.md`, `Session_Flow_and_Behavior_with_History.md`, `PRODUCT_SPEC.md`  
Date: 2025-12-16

## Status Snapshot
- Foundations and core UX are implemented in the app: scheduler, session controller, presets/history storage, and all screens (Launch/Main/Settings/Session/End/History).
- Reliability/polish improved: atomic history writes exist; audio assets now match expected format; UI mojibake fixed; Settings/Main preset refresh fixed; pause overlay now derives from controller state; skip-forward semantics cover countdown/active/rest; tick audio limited to countdown; results use real elapsed/per-round durations.
- Launch now uses native OS splash (Android configured; iOS pending platform folder) with no in-app delay before Main renders.
- Release prep not started.
- Session screen polish landed: stable tabular numerals, luminance-based text colors, top/bottom scrims, clearer pause overlay, and updated rest ring sizing; goldens cover Active and Pause views.
- Session header/footer bars now show round/time and session elapsed in mm:ss with consistent typography; rotation no longer auto-pauses.
- Default palette set to `basic` with optional High Contrast toggle; palette picker removed and active colors reset on toggle.
- Action buttons now share `AppTokens` sizing across Main and Pause overlay for consistent touch targets and typography.
- Tests now passing locally (`flutter test`, `flutter analyze`); controller/models suites cover transitions/skip/results; CI workflow exists but needs a green run after recent changes.
- Design rationale is captured in `docs/DECISIONS.md` for future reference.
- Risk log is tracked in `docs/RISKS.md` for ongoing mitigation.

## Milestones
- [x] M1 - Foundations: scheduler, controller, storage, preset persistence.
- [x] M2 - Core UX: screens wired to real data, audio hooks, readability theme.
- [ ] M3 - Reliability & polish: pause/resume/rotation hardening, atomic storage checks, CSV export validation, QA checklist, playtest fixes. (Partial: atomic writes and CSV export are in; QA/perf/accessibility/open bugs pending.)
- [ ] M4 - Release prep: performance sweep, crash/exception handling, app metadata/assets, build & store packaging.

## Workstreams & Tasks
### Timing & State
- [x] Aligned-second `SessionScheduler` (monotonic clock, pause/resume boundary hold).
- [x] `SessionController` phases (countdown, active, rest, end), stimulus generation with no immediate repeat, stimuli log, accurate elapsed/per-round metrics.
- [x] Audio cues preload + tick/round-start playback (tick gated to countdown).
- [ ] Mute toggle (stretch).
- [x] Wakelock during active sessions; disable on end/reset (via injected hooks).

### Data & Persistence
- [x] Models: `SessionPreset`, `Stimulus`, `SessionResult` with JSON/CSV helpers.
- [x] Persist preset to SharedPreferences; hydrate on app start.
- [x] Persist history to local file with temp-write-then-rename for atomicity.
- [x] CSV export of selected sessions to local file.
- [ ] Persist in-flight session progress on app background; restore on resume (stretch).

### UI & Navigation
- [x] Launch handled by native OS splash (no in-app gate); audio prewarm not implemented.
- [x] Main: centered logo, settings summary + active colors, prominent Start CTA, and Settings/History-Stats actions below (restyled to mock).
- [x] Settings: rounds, durations, interval, number range, outdoor boost, large session text, high contrast palette toggle with active colors in the same row, countdown toggle + seconds, RNG seed toggle/input (palette picker removed; default basic palette). Changes persist immediately; save controls removed.
- [x] Session: countdown/active/rest UIs, per-phase backgrounds, large number, rest progress, double-tap pause overlay with continue/reset/skip/finish driven by controller state; phase views and pause overlay are modular widgets. Added stable numeric layout, luminance-based text, and header/footer scrims for readability.
- [x] End: summary screen restyled with stat cards, detail section, and full-width actions; Save to History and Back to Main preserved.
- [x] History: newest-first list, multi-select, delete, export CSV, empty state.

### Visual/Accessibility/Performance
- [x] Theme/palettes applied; outdoor boost behavior implemented.
- [ ] Contrast, semantics, and touch-target audit; ensure readability outdoors. (Session screen scrims and tabular numerals done; full audit pending.)
- [ ] Optimize animations/transitions/perf; prewarm audio to reduce first-play latency.

### QA & Tooling
- [ ] Smoke tests: controller timing, preset encode/decode, history repo write/read. (models encode/decode, CSV, randomInRange, controller transitions/skip/result tests added)
- [x] Manual QA checklist (rotation, pause/resume, reset, end-save-export, history delete/export).
- [x] Local checks: `flutter analyze`, `flutter test` run green after recent UI polish.
- [ ] CI: format/lint/test (`flutter analyze`, `flutter test`). (workflow added; needs green run)

## Risks & Mitigations
- Timing drift or missed ticks -> use monotonic clock, emit only on integer boundaries, add dev logging (partial; logging not added).
- Asset issues (missing/mismatched audio) -> keep preload failure graceful; validate assets during CI.
- Data corruption on crash -> temp file + rename writes; guard reads for empty/invalid files (implemented).
- Outdoor readability -> palette contrast validation and outdoor boost option (boost exists; contrast audit pending).

## Near-Term Focus
- Finish CI/analyzer green run and add history repository coverage.
- Optional: add mute toggle and audio prewarm; consider session-progress persistence if needed.
- Do an accessibility/contrast pass and perf sanity check for session screen.
