# SpeedOfPlay - QA Checklist

Use this for manual sweeps; note device/OS and build flavor.

## Functional
- [ ] Launch: native OS splash shows, transitions directly to Main with no in-app delay.
- [ ] Settings: edit rounds/durations/interval/number range/countdown/outdoor boost/seed; Save returns to Main and values reflect immediately.
- [ ] Settings: palette is fixed to basic; High Contrast toggle (next to Active Colors) swaps palette and clears active color selection; stepper button borders render without bleeding into the app bar.
- [ ] Session start: countdown ticks each second with audio; enters active at 0.
- [ ] Active: number/color change at interval; no immediate repeats; tick sound only during countdown.
- [ ] Rest: rest background + circular progress ring; resumes next round automatically.
- [ ] Pause overlay: double-tap to open; Continue, Skip, Reset Round, Reset Session, Finish all work.
- [ ] End screen: summary correct; Save to History persists entry; End to Main returns home.
- [ ] History: list newest-first; multi-select; delete removes entries; export CSV creates file and shows snackbar path.

## Persistence
- [ ] Preset persists across app restarts.
- [ ] History persists across restarts; CSV export file opens/exists.

## Audio & Performance
- [ ] Ticks/round-start play with low latency; first-play not delayed noticeably.
- [ ] No dropped frames or jank during sessions; CPU/battery reasonable for 10-minute use.

## Reliability
- [ ] Rotate device mid-countdown and mid-active; session continues without auto-pause and timing remains correct.
- [ ] Pause/resume multiple times; ticks remain aligned to seconds (no doubles/skips).
- [ ] Background/foreground app during session; state resumes correctly (if not implemented, note as known gap).

## Accessibility & Readability
- [ ] Text legible outdoors; outdoor boost improves contrast.
- [ ] Session digits do not jitter; header/footer text remains readable on bright palettes.
- [ ] Buttons meet touch target size; semantics/labels read correctly with screen reader.

## Known Gaps (track if not tested/implemented)
- [ ] Session persistence on background (stretch goal).
- [ ] Mute toggle (stretch).
