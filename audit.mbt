///|
pub(all) struct StreamAudit {
  total : Int
  on_time : Int
  late : Int
  too_late : Int
  accepted : Int
} derive(Eq, Debug)

///|
pub fn audit_assignments(assignments : Array[EventAssignment]) -> StreamAudit {
  let mut on_time = 0
  let mut late = 0
  let mut too_late = 0
  let mut accepted = 0
  for item in assignments {
    match item.status {
      OnTime => on_time = on_time + 1
      Late => late = late + 1
      TooLate => too_late = too_late + 1
    }
    if item.accepted() {
      accepted = accepted + 1
    }
  }
  { total: assignments.length(), on_time, late, too_late, accepted }
}

///|
pub fn StreamAudit::healthy(self : StreamAudit) -> Bool {
  self.too_late == 0
}
