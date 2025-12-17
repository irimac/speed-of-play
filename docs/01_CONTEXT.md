# Context — SpeedOfPlay (Flutter)

## Project summary
**SpeedOfPlay** is an **awareness & reactivity trainer** for football athletes, designed to run on
phones and tablets, outdoors, offline, and readable at distance.

Source of truth: the project proposal (`SpeedOfPlay--Project_Proposal.md`) bundled with the repo.

## Core UX
The app is essentially a *configured session runner*:

- Coach configures a session (rounds, durations, palettes, number range, countdown, sounds).
- Athlete runs the session at distance: big legible cue (color + number), consistent rhythm, audible ticks.
- History is stored locally and exportable (CSV via share sheet).

## Screens (MVP)
- **Launch**: logo + intro cue, then route to Main (≤ 1.5s).
- **Main**: settings summary + Start + Settings + History.
- **Settings**: configure the session (all parameters persisted).
- **Session**: phase-driven runner (Countdown → Active → Rest; pause overlay actions).
- **End**: session summary + save to History + back to Main.
- **History**: list of sessions + CSV export/share.

## Session phases (state machine)
Single controller drives phases:

1. **Countdown**: shows `-N … -1`, tick each second; distinct sound at `0`.
2. **Active round**: solid bright background + huge number.
   - The displayed stimulus changes every `changeIntervalSec`.
   - No immediate repeat for number or color (avoid AA / 7→7 consecutive).
3. **Rest**: neutral background + circular progress; auto-start next round.
4. **Paused overlay** (double tap): actions:
   - Reset session
   - Reset round
   - Continue
   - Skip forward
   - Finish

## Timing requirements (important)
- Drive the experience from a **single scheduler** aligned to exact **1 Hz boundaries**.
- Use a **monotonic clock** for scheduling to avoid drift/race conditions.
- Avoid multiple timers fighting each other.

## Non-functional requirements
- **Offline-first**, no backend required for MVP.
- **Outdoor readability** and accessibility:
  - color-blind safe palettes,
  - adjustable font scaling,
  - min contrast goal (4.5:1),
  - optional brightness boost mode (if feasible).
- Maintain session state through rotation by storing state above the widget tree (controller/view-model).
- Keep the device awake during sessions (prevent screen lock).

## Implementation philosophy (from conversation)
Prefer **clean long-term** Flutter code:
- **Recipe-based manual UI** with a small design system and typed style “recipes”.
- Use **functional codegen** where it helps long-term (models, JSON, routing), but avoid full UI codegen.
- Use metadata-driven rendering only for low-risk “content-like” sections (optional), not timing-critical screens.

## Repository assumptions
- Repo: `https://github.com/irimac/speed` (Flutter/Dart).
- Existing folders: `lib/controllers`, `lib/services`, `lib/ui`, `lib/theme.dart`, etc.
