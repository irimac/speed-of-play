# Prompt for AI Coding Agent - SpeedOfPlay (Flutter)

You are an AI coding agent working in the `speed-of-play` Flutter repo (https://github.com/irimac/speed).

Your job: implement the **MVP** described in `SpeedOfPlay--Project_Proposal.md` using clean long-term Flutter code:
recipe-based manual UI + typed style recipes, functional codegen for models, and a single monotonic scheduler.

Read and follow `01_CONTEXT.md` and `02_CONTRACT.md`.

---

## Success criteria (must-have)
1. App includes screens: **Native splash, Main, Settings, Session, End, History**.
2. Session runner implements phases:
   - Countdown (`-N ... -1`, 1 Hz ticks, distinct sound at 0)
   - Active round (stimulus changes every `changeIntervalSec`, no immediate repeats)
   - Rest (neutral bg + circular progress, auto-start next round)
   - Pause overlay via double-tap with actions: reset session, reset round, continue, skip forward, finish
3. Timing:
   - one scheduler aligned to whole-second boundaries
   - monotonic clock, no drift across pause/resume
4. Persistence:
   - settings stored locally
   - history stored locally as JSON
   - export history as CSV via share sheet
5. Reliability:
   - rotation does not reset session (state in controller above widget tree)
   - screen stays awake during session

---

## Architectural blueprint (implement this)
### State + transitions
Implement a single controller state machine:

- `enum SessionPhase { idle, countdown, active, rest, paused, completed }`
- `SessionState` with: phase, roundIndex, roundsTotal, secondsRemaining, stimulusColor, stimulusNumber, etc.
- `SessionController` owns all events:
  - `start()`, `pause()`, `resume()`, `resetSession()`, `resetRound()`, `skipForward()`, `finish()`

Transitions must match the proposal and the conversation:
- idle -> countdown -> active -> rest (repeat) -> completed
- any of countdown/active/rest -> paused on double-tap
- paused → previous phase on continue
- paused actions affect timers deterministically

### Timing engine
Create/finish `lib/services/session_scheduler.dart` as the *only* time source:
- align to next whole-second boundary using monotonic time
- then produce 1 Hz ticks
- provide pause/resume support without drift

The controller subscribes to scheduler ticks and updates state.

### Stimulus generation
In Active phase:
- change stimulus every `changeIntervalSec`
- ensure **no immediate repeat** for color or number
- keep palette and number range configurable from Settings

### UI
Implement screens with a “pure renderer” approach:
- Widgets read controller state and render appropriate view.
- No timers in widgets.
- Put fast-changing design values into typed style objects, not scattered literals.

Suggested layout:
- `lib/ui/session_screen.dart` switches among:
  - `ui/session/countdown_view.dart`
  - `ui/session/active_round_view.dart`
  - `ui/session/rest_view.dart`
  - `ui/session/pause_overlay.dart`

### Styles for rapid iteration (do this early)
Add `lib/ui/styles/`:
- `app_tokens.dart` (spacing, radii, typography scale)
- `session_styles.dart` and `screen_styles.dart` (typed, theme-driven)
Use `ThemeExtension`s if you prefer.

### Persistence + export
- Implement settings storage via existing `storage.dart` (SharedPreferences-style).
- Implement `HistoryRepository`:
  - append session record on End screen “Save”
  - read list for History screen
  - export to CSV + share

### Audio cues
Use/finish `AudioCuePlayer`:
- “pre-warm” sounds for low latency
- tick beep for countdown seconds
- distinct cue at active start / round start

If assets are missing, add placeholders and document how to replace them.

### Keep awake
During Session, prevent screen locking (use a known Flutter plugin if already present in repo; otherwise add one).

---

## Work plan (execute in order)
1. **Survey repo**: identify existing state mgmt and routing; do not fight existing conventions.
2. **Models**: add typed models for settings + history record (prefer `freezed` + JSON if available).
3. **Scheduler**: implement deterministic 1 Hz monotonic scheduler + unit tests.
4. **Controller**: implement phase machine + unit tests for transitions and stimulus non-repeat rules.
5. **UI scaffolding**: implement Main/Settings/History/End skeletons (native splash handled by platform).
6. **Session UI**: implement phase views + pause overlay gesture + wiring to controller actions.
7. **Persistence**: wire settings load/save and history append/read/export.
8. **Audio**: wire cues, ensure no lag spikes, document assets.
9. **Polish**: readability, accessibility toggles (font scaling, palettes), keep-awake, edge cases.
10. **Docs**: update repo README with run steps + configuration + assets + export.

---

## Edge cases to handle
- Rapid pause/resume toggles
- Skip forward from paused:
  - active → rest
  - rest → next active (or completed if last round)
- Reset round resets only current round timing, not session count
- Reset session re-initializes to countdown and round 1
- Rotation at any phase must not restart or desync
- No immediate repeats for color/number (handle small ranges gracefully)

---

## Output expectations
- Provide a clean PR/commit set:
  - “Add scheduler + tests”
  - “Add session controller + tests”
  - “Add session UI + pause overlay”
  - “Add history + CSV export”
  - etc.
- Keep generated files out of review noise where possible.
- If you add dependencies, justify them briefly in commit message and README.

Proceed now.
