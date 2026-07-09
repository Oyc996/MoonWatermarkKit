///|
test "watermark advances with max event time" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100))
    .observe(StreamEvent::new("a", 100, 1, 1))
    .observe(StreamEvent::new("a", 120, 2, 1))
  assert_eq(state.current_watermark_ms, 110)
}

///|
test "watermark never moves backwards" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100))
    .observe(StreamEvent::new("a", 100, 1, 1))
    .observe(StreamEvent::new("a", 90, 2, 1))
  assert_eq(state.current_watermark_ms, 90)
}

///|
test "classifies on time late and too late" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100)).observe(
    StreamEvent::new("a", 100, 1, 1),
  )
  assert_eq(state.classify(StreamEvent::new("a", 91, 2, 1)).name(), "on_time")
  assert_eq(state.classify(StreamEvent::new("a", 80, 2, 1)).name(), "late")
  assert_eq(state.classify(StreamEvent::new("a", 60, 2, 1)).name(), "too_late")
}

///|
test "idle stream is detected" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100)).observe(
    StreamEvent::new("a", 100, 10, 1),
  )
  assert_true(state.mark_idle(111))
}

///|
test "tumbling window assigns one window" {
  let windows = assign_windows(WindowSpec::tumbling(60), 125)
  assert_eq(windows.length(), 1)
  assert_true(windows[0].contains(125))
}

///|
test "sliding window assigns multiple windows" {
  let windows = assign_windows(WindowSpec::sliding(120, 60), 125)
  assert_eq(windows.length(), 2)
}

///|
test "assignment rejects too late events" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100)).observe(
    StreamEvent::new("a", 100, 1, 1),
  )
  let assignment = assign_event(
    state,
    WindowSpec::tumbling(60),
    StreamEvent::new("a", 60, 2, 1),
  )
  assert_false(assignment.accepted())
}

///|
test "aggregate counts late and dropped events" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100)).observe(
    StreamEvent::new("a", 100, 1, 1),
  )
  let late = assign_event(
    state,
    WindowSpec::tumbling(60),
    StreamEvent::new("a", 80, 2, 5),
  )
  let drop = assign_event(
    state,
    WindowSpec::tumbling(60),
    StreamEvent::new("a", 60, 2, 7),
  )
  let agg = WindowAggregate::new(TimeWindow::new(60, 120), "a")
    .add(late)
    .add(drop)
  assert_eq(agg.count, 1)
  assert_eq(agg.late, 1)
  assert_eq(agg.dropped, 1)
}

///|
test "audit summarizes assignments" {
  let state = WatermarkState::new(WatermarkPolicy::new(10, 20, 100)).observe(
    StreamEvent::new("a", 100, 1, 1),
  )
  let audit = audit_assignments([
    assign_event(
      state,
      WindowSpec::tumbling(60),
      StreamEvent::new("a", 100, 2, 1),
    ),
    assign_event(
      state,
      WindowSpec::tumbling(60),
      StreamEvent::new("a", 60, 2, 1),
    ),
  ])
  assert_eq(audit.total, 2)
  assert_eq(audit.too_late, 1)
  assert_false(audit.healthy())
}

///|
test "json exports assignment audit and aggregate" {
  let state = WatermarkState::new(default_policy()).observe(
    StreamEvent::new("a", 1000, 1, 3),
  )
  let assignment = assign_event(
    state,
    minute_window(),
    StreamEvent::new("a", 1000, 2, 3),
  )
  assert_true(assignment.to_json().contains("\"status\":\"on_time\""))
  assert_true(audit_assignments([assignment]).to_json().contains("\"total\":1"))
  assert_true(
    WindowAggregate::new(TimeWindow::new(0, 60_000), "a")
    .to_json()
    .contains("\"count\":0"),
  )
}
