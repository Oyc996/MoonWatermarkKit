///|
pub(all) enum EventStatus {
  OnTime
  Late
  TooLate
} derive(Eq, Debug)

///|
pub fn EventStatus::name(self : EventStatus) -> String {
  match self {
    OnTime => "on_time"
    Late => "late"
    TooLate => "too_late"
  }
}

///|
pub(all) struct StreamEvent {
  key : String
  event_time_ms : Int
  arrival_time_ms : Int
  value : Int
} derive(Eq, Debug)

///|
pub fn StreamEvent::new(
  key : String,
  event_time_ms : Int,
  arrival_time_ms : Int,
  value : Int,
) -> StreamEvent {
  { key, event_time_ms, arrival_time_ms, value }
}

///|
pub(all) struct WatermarkPolicy {
  max_out_of_order_ms : Int
  allowed_lateness_ms : Int
  idle_timeout_ms : Int
} derive(Eq, Debug)

///|
pub fn WatermarkPolicy::new(
  max_out_of_order_ms : Int,
  allowed_lateness_ms : Int,
  idle_timeout_ms : Int,
) -> WatermarkPolicy {
  {
    max_out_of_order_ms: max_int(0, max_out_of_order_ms),
    allowed_lateness_ms: max_int(0, allowed_lateness_ms),
    idle_timeout_ms: max_int(0, idle_timeout_ms),
  }
}

///|
pub fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
