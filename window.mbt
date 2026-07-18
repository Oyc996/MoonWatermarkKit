///|
pub(all) struct TimeWindow {
  start_ms : Int
  end_ms : Int
} derive(Eq, Debug)

///|
pub fn TimeWindow::new(start_ms : Int, end_ms : Int) -> TimeWindow {
  { start_ms, end_ms }
}

///|
pub fn TimeWindow::contains(self : TimeWindow, event_time_ms : Int) -> Bool {
  event_time_ms >= self.start_ms && event_time_ms < self.end_ms
}

/// Returns true once the watermark has passed the window's allowed-lateness
/// boundary. A caller can then persist or evict its aggregate safely.

///|
pub fn TimeWindow::is_finalized(
  self : TimeWindow,
  watermark_ms : Int,
  allowed_lateness_ms : Int,
) -> Bool {
  watermark_ms >= self.end_ms + max_int(0, allowed_lateness_ms)
}

///|
pub(all) struct WindowSpec {
  size_ms : Int
  slide_ms : Int
} derive(Eq, Debug)

///|
pub fn WindowSpec::tumbling(size_ms : Int) -> WindowSpec {
  { size_ms: max_int(1, size_ms), slide_ms: max_int(1, size_ms) }
}

///|
pub fn WindowSpec::sliding(size_ms : Int, slide_ms : Int) -> WindowSpec {
  { size_ms: max_int(1, size_ms), slide_ms: max_int(1, slide_ms) }
}

/// The largest number of overlapping windows an event can belong to.
/// This lets callers pre-size aggregate storage for high-cardinality streams.

///|
pub fn WindowSpec::max_windows_per_event(self : WindowSpec) -> Int {
  (self.size_ms + self.slide_ms - 1) / self.slide_ms
}

///|
pub fn assign_windows(
  spec : WindowSpec,
  event_time_ms : Int,
) -> Array[TimeWindow] {
  let windows = []
  let last_start = event_time_ms / spec.slide_ms * spec.slide_ms
  let mut start = last_start
  while start + spec.size_ms > event_time_ms && start >= 0 {
    windows.push(TimeWindow::new(start, start + spec.size_ms))
    start = start - spec.slide_ms
  }
  windows
}
