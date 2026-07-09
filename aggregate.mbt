///|
pub(all) struct WindowAggregate {
  window : TimeWindow
  key : String
  count : Int
  sum : Int
  late : Int
  dropped : Int
} derive(Eq, Debug)

///|
pub fn WindowAggregate::new(
  window : TimeWindow,
  key : String,
) -> WindowAggregate {
  { window, key, count: 0, sum: 0, late: 0, dropped: 0 }
}

///|
pub fn WindowAggregate::add(
  self : WindowAggregate,
  assignment : EventAssignment,
) -> WindowAggregate {
  {
    window: self.window,
    key: self.key,
    count: if assignment.accepted() {
      self.count + 1
    } else {
      self.count
    },
    sum: if assignment.accepted() {
      self.sum + assignment.event.value
    } else {
      self.sum
    },
    late: if assignment.status == Late {
      self.late + 1
    } else {
      self.late
    },
    dropped: if assignment.status == TooLate {
      self.dropped + 1
    } else {
      self.dropped
    },
  }
}

///|
pub fn WindowAggregate::avg_x100(self : WindowAggregate) -> Int {
  if self.count <= 0 {
    0
  } else {
    self.sum * 100 / self.count
  }
}
