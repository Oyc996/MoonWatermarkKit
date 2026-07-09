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
assert_true(assignment.accepted())
```

## Verification

```bash
moon check --target all
moon test --target wasm
moon test --target wasm-gc
moon run cmd/main
```

