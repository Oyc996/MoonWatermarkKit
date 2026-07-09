///|
pub(all) struct EventAssignment {
  event : StreamEvent
  status : EventStatus
  watermark_ms : Int
  windows : Array[TimeWindow]
} derive(Eq, Debug)

///|
pub fn assign_event(
  state : WatermarkState,
  spec : WindowSpec,
  event : StreamEvent,
) -> EventAssignment {
  {
    event,
    status: state.classify(event),
    watermark_ms: state.current_watermark_ms,
    windows: assign_windows(spec, event.event_time_ms),
  }
}

///|
pub fn EventAssignment::accepted(self : EventAssignment) -> Bool {
  self.status != TooLate
}
