# SpeedOfPlay - Design Rationale

Purpose: capture the “why” behind key design and implementation choices so future changes can be reasoned against intent and constraints.

## Architecture
- **Single controller + scheduler**: Only `SessionController` owns session state; `SessionScheduler` is the sole time source. This prevents drift from multiple timers and keeps UI pure.
- **Layered responsibilities**: UI renders state; controllers orchestrate; services handle side effects (audio, storage, wakelock). Chosen to keep timing logic testable and platform interactions isolated.
- **Monotonic aligned ticks**: Scheduler uses `Stopwatch` + ticker, emits whole-second boundaries, holds on resume. Ensures countdown/active/rest stay aligned without wall-clock drift.

## Session logic
- **Pause overlay driven by controller state**: UI shows overlay whenever `snapshot.isPaused` so pause state and controls can’t diverge from the controller.
- **Skip-forward semantics**: Skip from countdown enters active; from active moves to rest or finish (records round duration); from rest jumps to next active or finish. Keeps user actions deterministic and matches session flow spec.
- **Stimulus rules**: No immediate repeat for number/color; optional RNG seed for QA. Reduces adaptation to repeats and supports reproducible tests.
- **Metrics from real time**: Results use accumulated elapsed seconds and per-round durations captured on ticks (including skips/early finish). Avoids preset multiplication that could misreport partial rounds.

## Audio & wakefulness
- **Tick audio gated to countdown**: Countdown is the only phase needing per-second ticks; avoids noise during active/rest while keeping the main cadence.
- **Wakelock via injected hooks**: Enable at session start, disable on end/reset through injected functions (test-safe). Avoid toggling on every pause/resume to reduce platform churn.

## UI choices
- **Controller as single source**: Session screen pulls preset and state from controller; removes duplicate preset copies and prevents divergence after edits.
- **Rest/countdown timing from snapshot**: Displays remaining time based on controller state, not preset literals, so UI reflects pauses/skips accurately.

## Persistence & storage
- **Atomic history writes**: temp file then rename to avoid corrupting history on crash.
- **Local-first**: SharedPreferences for presets; app documents for history/exports; no backend assumed.

## Testing
- **Manual scheduler + noop audio in tests**: Deterministic ticks without real time or audio dependencies.
- **Coverage focus**: encode/decode for models, random bounds, controller transitions (countdown→active→rest→end), skip-forward paths, real metrics, CSV export. Ensures core timing/state behaviors are locked.

## Remaining questions / follow-ups
- Add mute toggle and audio prewarm.
- Consider persisting in-flight session state for rotation/background resumes.
- Run accessibility/contrast/touch-target audit before release.
