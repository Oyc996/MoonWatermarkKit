# Acceptance Notes

MoonWatermarkKit targets event-time correctness for stream-like data.

Implemented scope:

- watermark policy and state;
- max-event-time based watermark advancement;
- multi-partition coordination with conservative global watermarks;
- idle stream detection;
- on-time, late, and too-late classification;
- tumbling and sliding window assignment;
- window aggregate accounting;
- window finalization decisions for aggregate eviction;
- stream audit summary;
- JSON export, CLI demo, tests, CI, README, and related-work notes.

The core deliberately does not open sockets, write storage, or schedule
background tasks. Applications supply their own transport, checkpoint, and
aggregate-store adapters around these deterministic decisions.

