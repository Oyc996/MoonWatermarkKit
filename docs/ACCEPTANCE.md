# Acceptance Notes

MoonWatermarkKit targets event-time correctness for stream-like data.

Implemented scope:

- watermark policy and state;
- max-event-time based watermark advancement;
- idle stream detection;
- on-time, late, and too-late classification;
- tumbling and sliding window assignment;
- window aggregate accounting;
- stream audit summary;
- JSON export, CLI demo, tests, CI, README, and related-work notes.

