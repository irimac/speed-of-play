# SpeedOfPlay - QA Checklist

Use this for manual sweeps; note device/OS and build flavor.

## Functional
- [ ] Launch: splash shows, auto-transitions in ~1.5s to Main.
- [ ] Settings: edit rounds/durations/interval/number range/palette/countdown/outdoor boost/seed; Save returns to Main and values reflect immediately.
- [ ] Session start: countdown ticks each second with audio; enters active at 0.
- [ ] Active: number/color change at interval; no immediate repeats; tick sound each second.
- [ ] Rest: rest background + circular progress; resumes next round automatically.
- [ ] Pause overlay: double-tap to open; Continue, Reset Session, Reset Round, Skip Forward (active only), Finish all work.
- [ ] End screen: summary correct; Save to History persists entry; End to Main returns home.
- [ ] History: list newest-first; multi-select; delete removes entries; export CSV creates file and shows snackbar path.
- [ ] UI recipes: recipe renderer loads tokens/components/screens; pause overlay recipe renders correctly in portrait/landscape.
- [ ] Golden snapshots: main portrait/landscape and active session portrait match references.

## Persistence
- [ ] Preset persists across app restarts.
- [ ] History persists across restarts; CSV export file opens/exists.

## Audio & Performance
- [ ] Ticks/round-start play with low latency; first-play not delayed noticeably.
- [ ] No dropped frames or jank during sessions; CPU/battery reasonable for 10-minute use.

## Reliability
- [ ] Rotate device mid-countdown and mid-active; state and timing remain correct.
- [ ] Pause/resume multiple times; ticks remain aligned to seconds (no doubles/skips).
- [ ] Background/foreground app during session; state resumes correctly (if not implemented, note as known gap).

## Accessibility & Readability
- [ ] Text legible outdoors; outdoor boost improves contrast.
- [ ] Buttons meet touch target size; semantics/labels read correctly with screen reader.

## Known Gaps (track if not tested/implemented)
- [ ] Session persistence on background (stretch goal).
- [ ] Mute toggle (stretch).
