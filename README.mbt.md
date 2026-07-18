# MoonWatermarkKit

MoonWatermarkKit is a MoonBit foundation library for event-time watermarking,
late-event classification, window assignment, and stream audit summaries.

It is not a message broker, storage engine, or distributed stream runtime. It
provides the small decision core that stream processors, log analyzers, metrics
pipelines, and IoT event systems can embed.

```moonbit nocheck
let state = WatermarkState::new(default_policy())
  .observe(StreamEvent::new("sensor-a", 120_000, 1, 10))
let assignment = assign_event(state, minute_window(), StreamEvent::new("sensor-a", 122_000, 2, 11))
println(assignment.status.name())
```

## Verification

```bash
moon fmt --check
moon info && git diff --exit-code -- '*.mbti'
moon check --target all
moon build --target all
moon test --target all
moon run cmd/main
```

## Installation

```bash
moon add Oyc996/moonwatermarkkit
```

The package has no third-party runtime dependencies. `WatermarkState` is an
immutable value, so a caller can keep one state per source or partition and
persist it using the caller's own checkpoint mechanism.
