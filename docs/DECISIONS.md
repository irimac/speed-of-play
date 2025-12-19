# SpeedOfPlay - Design Rationale

Purpose: capture the "why" behind key design and implementation choices so future changes can be reasoned against intent and constraints.

## Architecture
- **Single controller + scheduler**: Only `SessionController` owns session state; `SessionScheduler` is the sole time source. This prevents drift from multiple timers and keeps UI pure.
- **Layered responsibilities**: UI renders state; controllers orchestrate; services handle side effects (audio, storage, wakelock). Chosen to keep timing logic testable and platform interactions isolated.
- **Monotonic aligned ticks**: Scheduler uses `Stopwatch` + ticker, emits whole-second boundaries, holds on resume. Ensures countdown/active/rest stay aligned without wall-clock drift.

## Session logic
- **Pause overlay driven by controller state**: UI shows overlay whenever `snapshot.isPaused` so pause state and controls cannot diverge from the controller.
- **Skip-forward semantics**: Skip from countdown enters active; from active moves to rest or finish (records round duration); from rest jumps to next active or finish. Keeps user actions deterministic and matches session flow spec.
- **Stimulus rules**: No immediate repeat for number/color; optional RNG seed for QA. Reduces adaptation to repeats and supports reproducible tests.
- **Metrics from real time**: Results use accumulated elapsed seconds and per-round durations captured on ticks (including skips/early finish). Avoids preset multiplication that could misreport partial rounds. Stimulus timestamps are stored as session-relative seconds for monotonic, drift-free logs.

## Audio & wakefulness
- **Tick audio gated to countdown**: Countdown is the only phase needing per-second ticks; avoids noise during active/rest while keeping the main cadence.
- **Wakelock via injected hooks**: Enable at session start, disable on end/reset through injected functions (test-safe). Avoid toggling on every pause/resume to reduce platform churn.

## UI choices
- **Controller as single source**: Session screen pulls preset and state from controller; removes duplicate preset copies and prevents divergence after edits.
- **Rest/countdown timing from snapshot**: Displays remaining time based on controller state, not preset literals, so UI reflects pauses/skips accurately.
- **End navigation overlay guard**: Session UI stops rendering when the controller reaches `end`, avoiding overlay flashes during navigation to the summary screen.
- **Tests for invariants**: Added coverage for pause/skip/resume across phases, reset idempotency, and tiny ranges to guard core session behaviors.
- **Phase-specific session views**: Session UI is composed of per-phase widgets (countdown/active/rest) and a shared pause overlay to keep layout modular while preserving behavior.
- **Shared styles**: Introduced `AppTokens` and `SessionStyles` so session views use centralized spacing/typography/indicator sizing instead of hardcoded values.
- **Shared action sizing**: Main screen and Pause overlay buttons read height/icon/text sizes from `AppTokens` to keep touch targets and typography consistent across screens.
- **Summary screen layout**: Session Summary uses a compact stat card grid plus a secondary details card to keep key metrics scan-first for field use.
- **Settings save behavior**: Settings persist on each change, so explicit Save controls were removed to reduce redundant taps. End screen still requires manual save to history.
- **Large number scaling**: Large session digits scale from available height using a landscape base fraction with a portrait adjustment via aspect ratio for consistent sizing.
- **Session legibility polish**: Added luminance-based text colors, subtle header/footer scrims, and tabular figures with fixed sizing boxes to reduce digit jitter and improve outdoor readability without altering session logic.
- **Active color selection**: Added optional `activeColorIds` to presets so coaches can constrain stimulus colors; when unset/empty, behavior remains the full palette. Selection is UI-driven and persists with the preset, keeping default behavior unchanged.
- **Palette simplification**: Default palette is now `basic`, with a single alternative via the High Contrast toggle. Toggling high contrast clears `activeColorIds` to avoid mismatched color IDs.
- **Settings simplification**: Palette picker removed to reduce choice overload; High Contrast toggle is co-located with Active Colors to make display control obvious.
- **Eight-color palettes**: Standardized palettes to 8 colors so the active color selector has consistent capacity and predictable swatch spacing.
- **Basic palette**: Added a baseline palette (white, yellow, blue, red, green, orange, black, gray) to cover common coaching use cases.
- **Audio sequencing tests**: Recording audio fakes validate preload order, countdown tick gating, round-start cues on phase transition, and silence during paused skip/resume.
- **Accessibility toggles**: Settings include large session text and high-contrast palette; styles and palette resolution respond to these flags while persisting in presets.
- **Large text behavior**: Large session text meaningfully increases session number/countdown size using style overrides (not just a boolean flag).
- **Lifecycle handling**: App lifecycle observer auto-pauses sessions when backgrounded or detached; inactive is ignored to avoid rotation-triggered pauses. Scheduler pauses accordingly until the user resumes.
- **Audio control**: `audioEnabled` preset flag stored in settings; hooks ready for muting cues via controller/service if desired.
- **Cue idempotence**: Controller guards countdown ticks and round-start cues so they fire at most once per aligned second/round, respecting `audioEnabled` to avoid duplicate sounds.
- **Audio preload**: Audio player wraps injectable backends and preloads assets once on start; tests ensure plays don't retrigger loads, keeping per-tick work minimal.

## Persistence & storage
- **Atomic history writes**: temp file then rename to avoid corrupting history on crash.
- **Local-first**: SharedPreferences for presets; app documents for history/exports; no backend assumed.

## Testing
- **Manual scheduler + noop audio in tests**: Deterministic ticks without real time or audio dependencies.
- **Coverage focus**: encode/decode for models, random bounds, controller transitions (countdown -> active -> rest -> end), skip-forward paths, real metrics, CSV export. Ensures core timing/state behaviors are locked.

## Remaining questions / follow-ups
- Add mute toggle and audio prewarm.
- Consider persisting in-flight session state for rotation/background resumes.
- Run accessibility/contrast/touch-target audit before release.
