# MoonWatermarkKit

MoonWatermarkKit is a zero-dependency MoonBit decision core for event-time
watermarks, late-event classification, and tumbling or sliding-window
assignment. It is designed to be embedded in telemetry ingestion, log
analysis, metrics, and IoT pipelines; it is not a broker, storage engine, or
distributed stream runtime.

## Install

```bash
moon add Oyc996/moonwatermarkkit
```

## Minimal use

```moonbit
import { "Oyc996/moonwatermarkkit" @watermark }

let policy = @watermark.WatermarkPolicy::new(10_000, 30_000, 60_000)
let state = @watermark.WatermarkState::new(policy).observe(
  @watermark.StreamEvent::new("sensor-a", 120_000, 1, 42),
)
let assignment = @watermark.assign_event(
  state,
  @watermark.minute_window(),
  @watermark.StreamEvent::new("sensor-a", 115_000, 2, 7),
)
println(assignment.status.name()) // "late"
```

`observe` advances a monotonic watermark using the maximum observed event time.
`assign_event` classifies a record as `on_time`, `late`, or `too_late` and
returns every matching window. Applications retain ownership of persistence,
networking, checkpointing, and window storage.

## Verify and run

```bash
moon fmt --check
moon info && git diff --exit-code -- '*.mbti'
moon check --target all
moon build --target all
moon test --target all
moon run cmd/main
```

The CLI prints a reproducible two-event example and its JSON audit summary.
See [README.mbt.md](README.mbt.md) for the API overview and
[docs/ACCEPTANCE.md](docs/ACCEPTANCE.md) for the implemented boundary.

