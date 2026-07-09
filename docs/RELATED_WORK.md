# Related Work

Mooncakes has async I/O, data frame, audio stream, and compression packages, but
we did not find a dedicated event-time watermark and lateness decision package.

MoonWatermarkKit is intentionally smaller than a stream processing runtime. It
focuses on reusable primitives: watermark advancement, late-event classification,
window assignment, aggregate accounting, and audit summaries.

