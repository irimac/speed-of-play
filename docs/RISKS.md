# SpeedOfPlay - Risk Log

Status legend: Open / Resolved / TBD

## Current risks
- **Rest skip elapsed semantics** (Resolved): Skipping from Rest keeps elapsed rest time in totals; clarified and tests cover behavior.
- **Wakelock during long pauses** (Open): Wakelock stays enabled even when paused (intentional for now). Future option: disable after a pause threshold and re-enable on resume.
- **Stimulus generation with tiny ranges** (Closed - acceptable): Non-repeat is best-effort; for very small ranges occasional repeats are acceptable to keep the logic simple/lightweight.
- **Overlay/end navigation flash** (Resolved): Session UI skips overlay rendering once phase is `end`, preventing transient flashes on navigation.
- **Stimulus timestamps monotonic** (Resolved): Stimulus events now store session-relative seconds; avoids wall-clock drift.
- **Round-start audio while paused** (Resolved): SkipForward uses silent transition when paused; audio only on running transitions.
- **Metrics alignment** (Resolved): `totalElapsedSec` includes countdown + active + rest (excluding pauses); `roundsCompleted` counts completed active phases only.
- **History/CI coverage** (Open): CI workflow exists; needs consistent green runs and history repository tests.
- **Accessibility/contrast audit** (Open): Contrast, semantics, touch-target checks pending. Session scrims, luminance-based text, and stabilized numerals are in place; full audit still required.
- **Action button size drift** (Resolved): Main and Pause overlay buttons now share sizing tokens to keep touch targets and typography aligned.
- **Mute toggle/audio prewarm** (Open): No mute control or prewarming for lowest-latency playback yet.
- **Settings save confusion** (Resolved): Settings persist immediately; save controls removed to avoid redundant flows.
