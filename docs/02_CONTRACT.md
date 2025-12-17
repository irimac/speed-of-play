# Contract — Working Agreement for the AI Coding Agent

This is the “how we work” contract. The agent must follow these rules.

## Goal
Implement the SpeedOfPlay Flutter MVP with:
- correct timing/state transitions,
- clean maintainable architecture,
- simple UI that is easy to restyle during early iteration.

## Core principles
1. **Correctness > cleverness**: timing/state machine must be reliable.
2. **Single source of truth**: one controller owns session state; UI is a pure renderer.
3. **One scheduler**: avoid multiple drifting timers.
4. **Small, reviewable changes**: incremental commits with clear messages.
5. **Type safety**: prefer typed models and compile-time checks.
6. **Test what matters**: scheduler + state transitions + non-repeat stimulus rules.

## Deliverables
- Implement all MVP screens (Launch/Main/Settings/Session/End/History).
- Implement session state machine with pause overlay actions.
- Implement persistence:
  - settings (local),
  - session history (local JSON),
  - CSV export/share.
- Implement audio cues (tick + round-start cue) with low-latency strategy.
- Keep screen awake during session.

## Architecture constraints
- Use these layers:
  - **UI**: `lib/ui/**` (widgets, styles; no business logic).
  - **Controllers**: `lib/controllers/**` (state machines, view models).
  - **Services**: `lib/services/**` (scheduler, audio, storage, history).
  - **Data models**: `lib/data/**` (typed models + JSON).
- Avoid “god widgets” and avoid placing timers in widgets.
- Prefer **ThemeExtensions** + typed screen styles for rapid design iteration.

## Codegen guidance
- Allowed/encouraged:
  - `freezed` + `json_serializable` for models,
  - typed routing (if repo already uses a router; otherwise keep it simple).
- Avoid full UI code generation; UI should be idiomatic Flutter.

## Quality bar
- Must build and run on Android and iOS (if iOS is in CI; otherwise ensure compatibility).
- No crashes on rapid pause/resume/rotate.
- Session rhythm must stay aligned to seconds.
- No immediate stimulus repeats (color/number) in Active phase.
- History records are deterministic and export correctly.

## Testing expectations
- Unit tests:
  - `SessionScheduler` alignment behavior (tick cadence, pause/resume behavior),
  - `SessionController` transitions table (events → next state),
  - stimulus generator “no immediate repeat”.
- Widget tests are optional for MVP, but welcome for key screens.

## UX rules (MVP)
- Large legible typography in Session.
- Double-tap to pause overlay must be reliable and not conflict with other gestures.
- Pause overlay actions must be idempotent (safe to tap twice).

## What NOT to do
- No backend/cloud auth.
- No overly complex architecture (no unnecessary layers).
- No long-lived background isolates for MVP unless required for audio.

## Documentation
- Update/maintain `README` with:
  - how to run,
  - how to add/replace audio assets,
  - how history export works.
- Add short inline docs for scheduler/controller responsibilities.

## “Stop conditions” (when to ask for input)
The agent should only ask if it cannot proceed due to missing repo facts, e.g.:
- unknown existing state management choice that would cause conflicts,
- platform constraints preventing audio implementation.

Otherwise, make a best-effort decision and proceed.
