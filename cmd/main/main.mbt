///|
fn main {
  let state = @wm.WatermarkState::new(@wm.default_policy()).observe(
    @wm.StreamEvent::new("sensor-a", 120_000, 1, 10),
  )
  let current = @wm.StreamEvent::new("sensor-a", 122_000, 2, 11)
  let old = @wm.StreamEvent::new("sensor-a", 1_000, 3, 7)
  let a1 = @wm.assign_event(state, @wm.minute_window(), current)
  let a2 = @wm.assign_event(state, @wm.minute_window(), old)
  let audit = @wm.audit_assignments([a1, a2])
  println("MoonWatermarkKit demo")
  println(a1.to_json())
  println(a2.to_json())
  println(audit.to_json())
}
