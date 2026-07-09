///|
pub(all) struct WatermarkState {
  policy : WatermarkPolicy
  max_event_time_ms : Int
  current_watermark_ms : Int
  last_arrival_ms : Int
  initialized : Bool
} derive(Eq, Debug)

///|
pub fn WatermarkState::new(policy : WatermarkPolicy) -> WatermarkState {
  {
    policy,
    max_event_time_ms: 0,
    current_watermark_ms: 0,
    last_arrival_ms: 0,
    initialized: false,
  }
}

///|
pub fn WatermarkState::observe(
  self : WatermarkState,
  event : StreamEvent,
) -> WatermarkState {
  let max_event_time = if !self.initialized ||
    event.event_time_ms > self.max_event_time_ms {
    event.event_time_ms
  } else {
    self.max_event_time_ms
  }
  let next_watermark = max_event_time - self.policy.max_out_of_order_ms
  {
    policy: self.policy,
    max_event_time_ms: max_event_time,
    current_watermark_ms: if self.initialized &&
      self.current_watermark_ms > next_watermark {
      self.current_watermark_ms
    } else {
      next_watermark
    },
    last_arrival_ms: event.arrival_time_ms,
    initialized: true,
  }
}

///|
pub fn WatermarkState::mark_idle(self : WatermarkState, now_ms : Int) -> Bool {
  self.initialized &&
  now_ms >= self.last_arrival_ms + self.policy.idle_timeout_ms
}

///|
pub fn WatermarkState::classify(
  self : WatermarkState,
  event : StreamEvent,
) -> EventStatus {
  if !self.initialized || event.event_time_ms >= self.current_watermark_ms {
    OnTime
  } else if event.event_time_ms + self.policy.allowed_lateness_ms >=
    self.current_watermark_ms {
    Late
  } else {
    TooLate
  }
}

///|
pub fn WatermarkState::deadline_for(
  self : WatermarkState,
  event_time_ms : Int,
) -> Int {
  event_time_ms + self.policy.allowed_lateness_ms
}
