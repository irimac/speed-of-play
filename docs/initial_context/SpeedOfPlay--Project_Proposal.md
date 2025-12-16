## Project Proposal: SpeedOfPlay — Awareness & Reactivity Trainer

Prepared: 2025-12-15
Owner: Ivica Rimac (Rimac Football Performance)

### 1. Product Vision

A **football awareness & reactivity trainer** for tablet/smartphone. It delivers brightly colored, high‑contrast visual stimuli (solid background + large number) on a **precise 1 Hz schedule**, with countdown and round/rest flows, **fast pause controls**, and **post‑session insights**. It must be **reliable outdoors, offline‑capable**, and **usable at distance**.

### 2. Core User Value

- **Coach**: configure once, run many sessions; low friction; dependable timing; quick pause/skip/reset.
- **Athlete**: fast, legible cues; predictable rhythm; audible ticks.

### 3. Success Criteria (MVP)

- Accurate tick/interval timing (1 Hz UI; stimulus switch ≤ 30 ms after second boundary).
- Zero crashes; works offline; preserves state across device rotation.
- Accessibility: large typography, color‑blind palettes, voiceover labels, ≥ 44×44 pt touch targets.

### 4. App Structure & Screens

1. **Launch** – logo + intro tone (≤ 1.5 s).

2. **Main** – settings summary + **Play** + **Settings** + **History** (portrait/landscape).

3. Settings

    – configure & persist:

   - Rounds; Round duration; Rest duration; Change interval; Palette; Number range; Countdown.

4. Session

   - **Countdown**: shows `-N … -1` ticks; plays tick each second; distinct round‑start sound at 0.
   - **Active Round**: solid bright color background; large number; changes every `changeIntervalSec` seconds; no immediate color/number repeat.
   - **Rest**: neutral background; center **circular progress** with remaining seconds; auto‑start next round.
   - **Pause Overlay** (double‑tap): Reset session | Reset round | Continue | Skip forward | Finish session.

5. End (Enhanced)

    – neutral background with:

   - **Session summary**: total rounds done, total elapsed, per‑round durations.

   - Buttons

     :

     - **Save to History** (local JSON record).
     - **End → Main**.

6. History


### 5. Data Model (Storage & Export)

**SessionResult JSON (saved locally)**
TBD

### 6. Timing & Randomization

- Use **monotonic clock**; align stimulus flips to exact second boundaries.
- Single **scheduler** drives all sub‑timers to avoid race conditions.
- **No immediate repeat** of color or number; optional RNG seed for reproducibility (QA).

### 7. Accessibility & Outdoor Readability

- Color‑blind safe palettes, adjustable font scaling, min contrast 4.5:1, optional brightness boost outdoors.

### 8. Tech Notes (for the agent)

- **Cross‑platform**: Flutter (Dart).
- **Audio**: pre‑warmed low‑latency sound pool (iOS `AVAudioEngine/PlayerNode`; Android `SoundPool/AudioTrack`).
- **Persistence**: AsyncStorage/SharedPreferences (JSON), plus CSV export through share sheet.
- **Orientation**: maintain state in a view‑model so rotation doesn’t reset timers.
- **Awake**: keep the device screen awake, prevent automatic screen lock.

------

