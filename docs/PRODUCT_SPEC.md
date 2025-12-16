## SpeedOfPlay – Product & UX Specification

Prepared: 2025-12-16  
Author: Codex (on behalf of Ivica Rimac)  
Sources: `SpeedOfPlay - Project Proposal.md`, `Session_Flow_and_Behavior_with_History.md`, reference mocks in `/mocks`

---

### 1. Goals & Non-goals
- **Primary goal:** Deliver a deterministic 1 Hz football awareness trainer that coaches can configure once and reliably run in any environment (indoor/outdoor, offline). The experience must prioritize timing accuracy, legibility at distance, and fast pause controls.
- **Non-goals (MVP):** Remote multi-user syncing, wearable integrations, cloud accounts, or real-time analytics dashboards.

### 2. Users & Key Jobs
| Persona | Needs | Success signals |
| --- | --- | --- |
| Field Coach | Configure recurring session presets, monitor timing, pause/reset instantly without losing progress. | Can launch a session in ≤3 taps, timing stays aligned even after rotation/pause. |
| Athlete | Quickly recognize cues (color + large number), react on predictable beat, hear audio ticks. | Can see/read numbers from ≥5 m, audio ticks every second, no unexpected pauses. |

### 3. Core Assumptions
1. Sessions are always single-device, coach-controlled (based on provided specs).
2. Network may be unavailable; all persistence must be local JSON + optional CSV export (per project proposal).
3. Device orientation can change mid-session; timers must survive rotations (`Session_Flow_and_Behavior_with_History.md` §3).
4. Visual design follows provided mocks; colors referenced below assume accessibility-safe palettes derived from mocks.

### 4. End-to-end Flow Summary
1. Launch splash (≤1.5 s) auto-transitions to Main; intro tone plays once.
2. Main shows current configuration summary + primary actions: Play, Settings, History.
3. Settings edits rounds, durations, palette, number range, countdown, RNG seed toggle. Persist immediately.
4. Play → Session closes Main. Session sub-flow: Countdown → Active/Rest repeated per scheduler, with double-tap pause overlay.
5. End screen offers Save to History (navigates to History) or End → Main.
6. History lists saved sessions, supports selection, delete, export CSV, sorting newest-first.

### 5. Screen Specifications

#### 5.1 Launch
- Full-bleed dark background with centered logo (per `mocks/Launch.png`).
- Auto-dismiss via timer (1500 ms) once assets + audio pool ready.
- VoiceOver/ TalkBack label: “Speed of Play launch screen.”

#### 5.2 Main
- Layout: responsive column (portrait) / two-column (landscape). Left/top: session summary card; right/bottom: action buttons.
- Summary card content: Rounds × Duration, Rest duration, Change interval, Palette preview swatches (4), Number range, Countdown toggle.
- Primary CTA button `Play` (accent). Secondary buttons `Settings`, `History`.
- Accessibility: min 20 pt text, buttons ≥44×44 pt touch target.

#### 5.3 Settings
- Scrollable form grouped sections:
  - Session Structure: `Rounds (1–20)`, `Round Duration (15–180 s)`, `Rest Duration (0–120 s)`.
  - Stimulus: `Change Interval (1–5 s)`, `Number Range (min 1–max 99)`, `No Immediate Repeat` toggle (locked on for MVP), `RNG Seed` toggle + input (QA only).
  - Visuals: Palette selector (preview chips). Provide preset palettes A/B/C (color-blind friendly). Option `Outdoor boost` toggle (increases contrast/brightness).
  - Countdown: toggle + seconds (default 5).
- Actions: `Save & Back` (top-right). Auto-save on change as well (stored via local storage).

#### 5.4 Session Screen
- State-driven UI occupying full viewport.
- Countdown: background tinted per palette’s neutral color; center shows `-N` numeric countdown; per-second tick sound; final 0 triggers “round start” tone + color flash.
- Active Round: full-screen color (selected from palette) and central number (≥200 pt). On each change interval: new color + number chosen without immediate repeat. Provide top-left metadata (Round x / total, elapsed). Top-right small dot indicator showing schedule lock (green when aligned).
- Rest: neutral background with circular progress indicator and numeric seconds remaining; subtle pulsing ring to show still running.
- Pause overlay (double-tap anywhere) dims screen, surfaces modal sheet with: Continue, Reset Session, Reset Round, Skip Forward (only when in Active), Finish Session. Each action has textual + icon label. Overlay stays until Continue.

#### 5.5 End Screen
- Neutral background. Card with summary: total rounds completed, total elapsed, per-round durations list (scrollable).
- Buttons: `Save to History` (primary) → persists record then navigates to History; `End → Main`.

#### 5.6 History
- App bar: `History`. Body: lazy list (newest first). Each item card includes date/time, rounds count, total elapsed, average change interval, palette name. Checkbox left of each row.
- Bulk actions pinned at bottom when ≥1 selected: `Delete Selected`, `Export CSV`. Floating `Back to Main` when no selection.
- Empty state: illustration + “No saved sessions yet. Run a session and save it from the End screen.”

### 6. Data Model
```ts
SessionPreset {
  rounds: int
  roundDurationSec: int
  restDurationSec: int
  changeIntervalSec: int
  numberRange: { min: int, max: int }
  paletteId: string
  countdownSec: int
  outdoorBoost: bool
  rngSeed?: int
}

SessionProgress {
  preset: SessionPreset
  roundIndex: int // 0-based during session
  phase: 'countdown' | 'active' | 'rest' | 'end'
  secondsIntoPhase: double // derived from monotonic clock
  stimuliHistory: Stimulus[]
  status: 'running' | 'paused'
}

Stimulus { timestamp: monotonicMillis, colorId: string, number: int }

SessionResult {
  id: uuid
  completedAt: iso8601
  presetSnapshot: SessionPreset
  roundsCompleted: int
  perRoundDurations: int[]
  totalElapsedSec: int
  stimuliHistory: Stimulus[]
}
```
- Storage: `history.json` (append-only list) + `preset.json`. On Save, write to storage atomically (temp file then rename) to avoid corruption.

### 7. Timing & Scheduler
- Single `SessionScheduler` uses `Ticker` tied to system monotonic clock (`stopwatch.elapsed`) to drive state. Aligns events to absolute second boundaries: e.g., start time `t0`; each tick calculates `floor((now - t0)/1000)` and triggers updates only when integer increments.
- Countdown, active stimuli, and rest timers share scheduler to avoid drift.
- Pause/resume: store `pausedAt` monotonic timestamp; on resume, shift base start time by `(now - pausedAt)` but wait for next second boundary before rendering (per behavior spec 2.1).

### 8. Audio Design
- Preload tick and round-start WAV files and keep low-latency audio players warm.
- Ticks: play at each integer second boundary (countdown, active, rest). Round-start: play on transition `Countdown → Active`.
- Respect silent mode? For training, assume volume ON; provide mute toggle in Settings (future).

### 9. Accessibility & Outdoor Readability
- Typography uses `MediaQuery.textScaleFactor` but clamps at 200% to maintain layout.
- All actionable controls have semantics labels and focus order.
- Color palettes validated for ≥4.5:1 contrast; outdoor boost increases brightness + enables white outline on numerals.
- Provide vibration feedback on pause/resume (where available) for coaches not looking at device.

### 10. Offline & Reliability
- App functions entirely without network; initial assets bundled. History export writes CSV to local temp dir then opens share sheet; no upload required.
- App keeps screen awake during session using `WakelockPlus`.
- Persist session progress when app backgrounds: on `AppLifecycleState.paused`, save `SessionProgress` to disk; on resume, restore scheduler with preserved timestamps.

### 11. QA Checklist
1. Verify monotonic timer alignment ≤30 ms after each boundary (log actual delta).
2. Rotate device mid-round; ensure state restores correctly.
3. Pause/resume multiple times; observe no double ticks or skipped stimuli.
4. Reset session while paused; confirm Countdown restarts and remain paused.
5. Save session and confirm History entry shows accurate stats and is exportable.

### 12. Open Questions
1. Should athletes also hear vocal callouts (numbers) for accessibility? (Not specified.)
2. Are there preset templates coaches can store/share? Current spec supports only single preset.
3. CSV export format columns (currently assumed: timestamp, round, phase, colorId, number). Need confirmation.

