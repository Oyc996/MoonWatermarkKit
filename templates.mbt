///|
pub fn default_policy() -> WatermarkPolicy {
  WatermarkPolicy::new(60_000, 120_000, 300_000)
}

///|
pub fn minute_window() -> WindowSpec {
  WindowSpec::tumbling(60_000)
}

///|
pub fn five_minute_sliding_window() -> WindowSpec {
  WindowSpec::sliding(5 * 60_000, 60_000)
}
